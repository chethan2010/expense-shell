#!/bin/bash
USERID=$(id -u)
TIMESTAMP=$(date +%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1 )
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
read -s mysql_root_password

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2....$R Failure $N"
        exit 1
    else
        echo -e "$2....$G Success $N"
    fi
}
if [ $USERID -ne 0 ]
then
     echo "please run script as super user"
     exit 1
else
     echo "You are a Super user"
fi

dnf module disable nodejs -y &>>$LOGFILE
VALIDATE $? "disabling default Nodejs"

dnf module enable nodejs:20 -y &>>$LOGFILE
VALIDATE $? "Enabling  Nodejs v20"

dnf install nodejs -y &>>$LOGFILE
VALIDATE $? "Installing Nodejs"

id expense
if [ $? -ne 0 ]
then
    useradd expense
    VALIDATE $? "Creating User Expense"
   
else    
    echo "User already Created "
fi

mkdir -p /app &>>$LOGFILE
VALIDATE $? "Creating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip  &>>$LOGFILE

cd /app
unzip /tmp/backend.zip &>>$LOGFILE
VALIDATE $? "Extracted backend code"


npm install &>>$LOGFILE
VALIDATE $? "Installing nodejs dependencies"

cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service
VALIDATE $? "copied backend service"

systemctl start backend &>>$LOGFILE
VALIDATE $? "starting and enabling backend"
systemctl enable backend 

dnf install mysql -y &>>$LOGFILE
VALIDATE $? "Installing Mysql client"

mysql -h db.daws93.online -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>$LOGFILE
VALIDATE $? "Schema is loading"

systemctl restart backend &>>$LOGFILE
VALIDATE $? "Restarting backend"