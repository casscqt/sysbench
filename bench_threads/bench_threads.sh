#!/bin/bash

mysqlconn="-u root -p123456 -S /usr/local/mysql/tmp/3306/mysql.sock"
echo ""
echo "--------------正在进行线程基准测试-------------------"
read -p "请输入功能编号：1.测试记录查询 2.线程测试 3.线程对比测试" num1

case $num1 in 
1)
mysql $mysqlconn <<EOF
use bench_system;
select * from threadsbench;
EOF
;;
2)
read -p "请输入运算中使用线程数量:" threads
read -p "请输入yields:"  yields
read -p "请输入locks:" locks
read -p "请输入备注信息"  remark
echo "---------正在测试中---------"
test1=`sysbench --test=threads --num-threads=$threads --thread-yields=$yields  --thread-locks=$locks run |grep "total time:"|awk '{print $3}' |cut -d s -f1 `
test2=`sysbench --test=threads --num-threads=$threads --thread-yields=$yields  --thread-locks=$locks run |grep "total time:"|awk '{print $3}' |cut -d s -f1 `
test3=`sysbench --test=threads --num-threads=$threads --thread-yields=$yields  --thread-locks=$locks run |grep "total time:"|awk '{print $3}' |cut -d s -f1 `
echo "---------------测试完成，正在统计与保存结果---------------"
##计算结果####

    total_time=`echo "scale=2;($test1+$test2+$test3)/3" |bc `

mysql $mysqlconn <<EOF
use bench_system;
INSERT INTO threadsbench (threads,yields,locks,total_time,remark,create_time) VALUES( $threads,$yields,$locks,$total_time,"$remark",now() );
EOF
echo "-----------测试结果已经保存数据库-----------"
;;


3)
read -p "请输入对比测试ID" id
read -p "请输入备注信息"  remark

threads=`mysql $mysqlconn -e "select threads from bench_system.threadsbench where id=$id"|sed -n '2p' ` 
if [ -z $threads ] ;then
	echo "id不存在！"
else

yields=`mysql $mysqlconn -e "select yields from bench_system.threadsbench where id=$id"|sed -n '2p' `
locks=`mysql $mysqlconn -e "select locks from bench_system.threadsbench where id=$id"|sed -n '2p' `

echo "---------正在测试中---------"
test1=`sysbench --test=threads --num-threads=$threads --thread-yields=$yields  --thread-locks=$locks run |grep "total time:"|awk '{print $3}' |cut -d s -f1 `
test2=`sysbench --test=threads --num-threads=$threads --thread-yields=$yields  --thread-locks=$locks run |grep "total time:"|awk '{print $3}' |cut -d s -f1 `
test3=`sysbench --test=threads --num-threads=$threads --thread-yields=$yields  --thread-locks=$locks run |grep "total time:"|awk '{print $3}' |cut -d s -f1 `
echo "---------------测试完成，正在统计与保存结果---------------"
    total_time=`echo "scale=2;($test1+$test2+$test3)/3" |bc `

mysql $mysqlconn <<EOF
use bench_system;
INSERT INTO threadsbench (threads,yields,locks,total_time,remark,create_time) VALUES( $threads,$yields,$locks,$total_time,"$remark",now() );
EOF
echo "-----------测试结果已经保存数据库-----------"

fi
;;
*)
echo "请输入正确编号!"
;;
esac
