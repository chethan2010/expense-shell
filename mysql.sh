#!/bin/bash
USERID=$(id -u)
TIMESTAMP=$(date +%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1 )
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
echo "please enter Db passward"
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

   dnf install mysql-server -y &>>$LOGFILE
   VALIDATE $? "Installing Mysql Server"

   systemctl enable mysqld
   VALIDATE $? "Enableing Mysql Server"

   systemctl start mysqld
   VALIDATE $? "Starting Mysql Server" 

#    mysql_secure_installation --set-root-pass ExpenseApp@1
#    VALIDATE $? "Setting up root password"
   mysql -h db.daws93s.online -uroot  -p${mysql_root_password} -e 'SHOW DATABASES;' &&>>LOGFILE
   if [ $? -ne 0 ]
   then
        mysql_secure_installation --set-root-pass ${mysql_root_password} &>>LOGFILE
        VALIDATE $? "Mysql Root password setup"
   else 
        echo -e "MYSQL Root password is already setup ...$Y Skipping $N"

   fi


