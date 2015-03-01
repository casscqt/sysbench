#!/bin/bash

mysqlconn="-u root -p123456 -S /usr/local/mysql/tmp/3306/mysql.sock"
echo ""
echo "--------------正在进行CPU基准测试-------------------"
read -p "请输入功能编号：1.测试查询 2.CPU测试 3.CPU对比测试" num1

case $num1 in 
1)
mysql $mysqlconn <<EOF
use bench_system;
select * from cpubench;
EOF
;;
2)
read -p "请输入运算中使用线程数量" threads
read -p "请输入运算最大素数值" maxprime
read -p "请输入备注信息"  mark
time1=` sysbench --test=cpu --num-threads=$threads --cpu-max-prime=$maxprime run |grep "total time:" |awk '{print $3}' |sed 's/s//g' `
time2=` sysbench --test=cpu --num-threads=$threads --cpu-max-prime=$maxprime run |grep "total time:" |awk '{print $3}' |sed 's/s//g' `
time3=` sysbench --test=cpu --num-threads=$threads --cpu-max-prime=$maxprime run |grep "total time:" |awk '{print $3}' |sed 's/s//g' `
avg_totaltime=`echo "scale=2;($time1+$time2+$time3)/3" |bc `
mysql $mysqlconn <<EOF
use bench_system;
INSERT INTO cpubench (threads,maxprime,result,remark,create_time) VALUES( $threads,$maxprime,$avg_totaltime,"$mark",now());
EOF
echo "-----------测试结果已经保存数据库-----------"
;;
3)
read -p "请输入对比测试ID" id
read -p "请输入备注信息"  mark

threads=`mysql $mysqlconn -e "select *from bench_system.cpubench where id=$id" |awk '{print $2}'|sed -n '2p'` 
if [ -z $threads ] ;then
	echo "id不存在！"
else
maxprime=`mysql $mysqlconn -e "select *from bench_system.cpubench where id=$id" |awk '{print $3}'|sed -n '2p'`
time1=` sysbench --test=cpu --num-threads=$threads --cpu-max-prime=$maxprime run |grep "total time:" |awk '{print $3}' |sed 's/s//g' `
time2=` sysbench --test=cpu --num-threads=$threads --cpu-max-prime=$maxprime run |grep "total time:" |awk '{print $3}' |sed 's/s//g' `
time3=` sysbench --test=cpu --num-threads=$threads --cpu-max-prime=$maxprime run |grep "total time:" |awk '{print $3}' |sed 's/s//g' `
avg_totaltime=`echo "scale=2;($time1+$time2+$time3)/3" |bc `
mysql $mysqlconn <<EOF
use bench_system;
INSERT INTO cpubench (threads,maxprime,result,remark,create_time) VALUES( $threads,$maxprime,$avg_totaltime,"$mark",now() );
EOF
echo "-----------测试结果已经保存数据库-----------"
fi
;;
*)
echo "请输入正确编号!"
;;
esac
