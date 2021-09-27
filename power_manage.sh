#!/bin/bash
# For Power on/down/reset Dell Server
# Author Jun Yu
# V1.0
# 该脚本用于检查DELL服务器电源状态，远程批量自动开关机。服务器必须有iDRAC功能，配置IP地址，账号密码，可用于远程ssh.

#set -x
pub(){
expect_dir="`dirname $0`"
server_ip="${expect_dir}/ip.txt"
pass="password"
chass_ip="192.168.21.2"
}

ping_test(){
# Ping servers
    sed -i '/^$/d' ${server_ip}
    num=`cat ${server_ip}|grep -v "^#"| wc -l`
    for ((i=1;i<=${num};i++))
    do
       ip=`cat ${server_ip} | grep -v "^#" |head -$i | tail -1|awk -F " " '{print $1}'`
#       sed -i "/${ip}/d" ${ssh_know}
       ping -c 4 -W 1  $ip >/dev/null 2>&1
       if [ $? -eq 0 ]
       then
            echo -e "\033[35m$ip network is reachable!!!\033[0m"
       else
            echo "$ip network is unreachable!!!"
       fi
    done

}

power_status(){
# Check Dell server power status
     sed -i '/^$/d' ${server_ip}
     num=`cat ${server_ip}|grep -v "^#"| wc -l`
     for ((i=1;i<=${num};i++))
     do
     ip=`cat ${server_ip} | grep -v "^#" |head -$i | tail -1|awk -F " " '{print $1}'`
     echo "Show $ip power status"
     status="`sshpass -p $pass ssh -o StrictHostKeyChecking=no root@$ip racadm serveraction powerstatus`"
     echo $status
     printf "$(date) Server $ip $status\n" >>/root/powerstatus1.txt
     done
}

power_on(){
     sed -i '/^$/d' ${server_ip}
     num=`cat ${server_ip}|grep -v "^#"| wc -l`
     for ((i=1;i<=${num};i++))
     do
     ip=`cat ${server_ip} | grep -v "^#" |head -$i | tail -1|awk -F " " '{print $1}'`
     echo "Show $ip power status"
     status="`sshpass -p $pass ssh -o StrictHostKeyChecking=no root@$ip racadm serveraction powerup`"
     echo $status
     printf "$(date) Server $ip $status\n" >>/root/powerstatus1.txt
     done
}

power_off(){
     sed -i '/^$/d' ${server_ip}
     num=`cat ${server_ip}|grep -v "^#"| wc -l`
     for ((i=1;i<=${num};i++))
     do
     ip=`cat ${server_ip} | grep -v "^#" |head -$i | tail -1|awk -F " " '{print $1}'`
     echo "Show $ip power status"
     status="`sshpass -p $pass ssh -o StrictHostKeyChecking=no root@$ip racadm serveraction powerdown`"
     echo $status
     printf "$(date) Server $ip $status\n" >>/root/powerstatus1.txt
     done
}

reboot(){
     sed -i '/^$/d' ${server_ip}
     num=`cat ${server_ip}|grep -v "^#"| wc -l`
     for ((i=1;i<=${num};i++))
     do
     ip=`cat ${server_ip} | grep -v "^#" |head -$i | tail -1|awk -F " " '{print $1}'`
     echo "Show $ip power status"
     status="`sshpass -p $pass ssh -o StrictHostKeyChecking=no root@$ip racadm serveraction powercycle`"
     echo $status
     printf "$(date) Server $ip $status\n" >>/root/powerstatus1.txt
     done
}

power_on_chassis(){
     echo "Show Poweredge chassis power status"
     status="`sshpass -p "$pass" ssh -o StrictHostKeyChecking=no root@$chassis_ip racadm getsysinfo -c`"
     stat=`awk '/Power Status/{print}' $status`
     echo $stat
     printf "$(date) Server $ip $status\n" >>/root/powerstatus1.txt

while true
do
  pub
  echo -e "\n"
  echo -e "\033[32m ***********请输入要操作的序号****************** \033[0m"
  echo -e "\033[32m [1].检测所有服务器网络是否可达. \033[0m"
  echo -e "\033[32m [2].运行服务器电源状态查询.\033[0m"
  echo -e "\033[31m [3].一键运行所有服务器关机. \033[0m"
  echo -e "\033[31m [4].一键运行所有服务器开机. \033[0m"
  echo -e "\033[31m [5].一键运行所有服务器重启. \033[0m"
  echo -e "\033[31m [6].一键查看刀片服务器主机电源状态.\033[0m"
  echo -e "\033[32m [0].退出程序. \033[0m"
  echo -e "\033[32m ******************************************\n \033[0m"

read -p "请输入序号:" action

case $action in
  1)
     pub
     ping_test
     ;;
  2)
     pub
     power_status
     ;;
  3)
     pub
     power_off
     ;;
  4)
     pub
     power_on
     ;;
  5)
     pub
     reboot
     ;;
  6)
     pub
     power_on_chassis
     ;;
  0)
    echo -e "\033[31m 程序已退出! \033[0m"
    exit 0
    ;;

  *)
    echo "抱歉，您的选择有误!"
    ;;

esac
done
