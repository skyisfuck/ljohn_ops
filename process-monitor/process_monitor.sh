#!/bin/bash
#
#===============================
# Description:  monitor process
# Author: Ljohn
# Mail: ljohnmail@foxmail.com
# Last Update: 2017.12.26
# Version: 1.0
#===============================
#
Date=`date`
MAIL=`which mail`
ProcNam=netExtender
IP=`ip addr| grep eth0 |grep inet |egrep -v "inet6|127.0.0.1" |awk '{print $2}' |awk -F "/" '{print $1}'`
while true  
do   
   # 判断当进程数为0，或ping IP 失败则执行重启进程命令
   ProcNum=`ps -ef|grep $ProcNam | grep -v grep |wc -l`
   ping -c 3 -i 0.2 -w 3 10.4.129.42 &> /dev/null
   if [ $? -gt 0 -o  $ProcNum  -eq 0 ]; then
      nohup  /cljj/$ProcNam/start.sh &> /dev/null & 
      if [ $? -eq 0 ];then
         echo "-------$Date-------" >> /tmp/process_monitor.log
         echo "starting $ProcNam..." >> /tmp/process_monitor.log
         echo "$ProcNam is restarted!!" >> /tmp/process_monitor.log
         sleep 10
         # 如果重启完成，ping 还是不通，则发邮件通知管理员
         ping -c 3 -i 0.2 -w 3 10.4.129.42 &> /dev/null
         if [ $? -eq 0 ];then 
            echo "$ProcNam status is ok" >> /tmp/process_monitor.log
         fi
      else
            echo "$ProcNam state is failure on $Date,Please check VPN on $IP!!" | $MAIL -s "VPN state Warning"  ljohnmail@foxmail.com
      fi
   fi
   sleep 30
done
