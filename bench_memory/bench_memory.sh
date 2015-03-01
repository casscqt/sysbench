#!/bin/bash

mysqlconn="-u root -p123456 -S /usr/local/mysql/tmp/3306/mysql.sock"
echo ""
echo "--------------正在进行内存基准测试-------------------"
read -p "请输入功能编号：1.测试查询 2.内存测试 3.内存对比测试" num1

case $num1 in 
1)
mysql $mysqlconn <<EOF
use bench_system;
select * from memorybench;
EOF
;;
2)
read -p "请输入测试使用的线程数:" threads
read -p "请输入测试数据大小:" size
read -p "请输入分块大小(例如8K,16K):" block
read -p "请输入备注信息"  mark
echo "---------正在进行内存测试-------------"
time1=`sysbench --test=memory --memory-block-size=$block --memory-total-size=$size  --num-threads=$threads run |grep "transferred"|awk '{print $4}'|cut -c 2-`
time2=`sysbench --test=memory --memory-block-size=$block --memory-total-size=$size  --num-threads=$threads run |grep "transferred"|awk '{print $4}'|cut -c 2-`
time3=`sysbench --test=memory --memory-block-size=$block --memory-total-size=$size  --num-threads=$threads run |grep "transferred"|awk '{print $4}'|cut -c 2-`

throughput=`echo "scale=2;($time1+$time2+$time3)/3" |bc `
mysql $mysqlconn <<EOF
use bench_system;
INSERT INTO memorybench (threads,size,block,throughput,remark,create_time) VALUES( $threads,"$size","$block",$throughput,"$mark",now() );
EOF
echo "-----------测试结果已经保存数据库-----------"
;;
3)
read -p "请输入对比测试ID" id
read -p "请输入备注信息"  mark
threads=`mysql $mysqlconn -e "select threads from bench_system.memorybench where id=$id" |sed -n '2p'` 
if [ -z $threads ] ;then
	echo "id不存在！"
else
block=`mysql $mysqlconn -e "select block from bench_system.memorybench where id=$id" |sed -n '2p'` 
size=`mysql $mysqlconn -e "select size from bench_system.memorybench where id=$id" |sed -n '2p'`
echo "---------正在进行内存测试-------------"
time1=`sysbench --test=memory --memory-block-size=$block --memory-total-size=$size  --num-threads=$threads run |grep "transferred"|awk '{print $4}'|cut -c 2-`
time2=`sysbench --test=memory --memory-block-size=$block --memory-total-size=$size  --num-threads=$threads run |grep "transferred"|awk '{print $4}'|cut -c 2-`
time3=`sysbench --test=memory --memory-block-size=$block --memory-total-size=$size  --num-threads=$threads run |grep "transferred"|awk '{print $4}'|cut -c 2-`
throughput=`echo "scale=2;($time1+$time2+$time3)/3" |bc `
mysql $mysqlconn <<EOF
use bench_system;
INSERT INTO memorybench (threads,size,block,throughput,remark,create_time) VALUES( $threads,"$size","$block",$throughput,"$mark",now() );
EOF
echo "-----------测试结果已经保存数据库-----------"
fi
;;
*)
echo "请输入正确编号!"
;;
esac
