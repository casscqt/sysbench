#!/bin/bash

mysqlconn="-u root -p123456 -S /usr/local/mysql/tmp/3306/mysql.sock"
echo ""
echo "--------------正在进行互斥锁基准测试-------------------"
read -p "请输入功能编号：1.测试记录查询 2.互斥锁测试 3.互斥锁对比测试" num1

case $num1 in 
1)
mysql $mysqlconn <<EOF
use bench_system;
select * from mutexbench;
EOF
;;
2)
read -p "请输入运算中使用线程数量:" threads
read -p "请输入互斥锁数:" locks
read -p "请输入迭代数目:" loops
read -p "请输入备注信息"  remark
echo "---------正在测试中---------"
test1=`sysbench --test=threads --num-threads=$threads --mutex-locks=$locks --mutex-loops=$loops run|grep "total time:" |awk '{print $3}'|cut -d s -f1`
test2=`sysbench --test=threads --num-threads=$threads --mutex-locks=$locks --mutex-loops=$loops run|grep "total time:" |awk '{print $3}'|cut -d s -f1`
test3=`sysbench --test=threads --num-threads=$threads --mutex-locks=$locks --mutex-loops=$loops run|grep "total time:" |awk '{print $3}'|cut -d s -f1`
echo "---------------测试完成，正在统计与保存结果---------------"
##计算结果####

    total_time=`echo "scale=2;($test1+$test2+$test3)/3" |bc `

mysql $mysqlconn <<EOF
use bench_system;
INSERT INTO mutexbench (threads,locks,loops,total_time,remark,create_time) VALUES( $threads,$locks,$loops,$total_time,"$remark",now() );
EOF
echo "-----------测试结果已经保存数据库-----------"
;;


3)
read -p "请输入对比测试ID" id
read -p "请输入备注信息"  remark

threads=`mysql $mysqlconn -e "select threads from bench_system.mutexbench where id=$id"|sed -n '2p' ` 
if [ -z $threads ] ;then
	echo "id不存在！"
else

locks=`mysql $mysqlconn -e "select locks from bench_system.mutexbench where id=$id"|sed -n '2p' `
loops=`mysql $mysqlconn -e "select loops from bench_system.mutexbench where id=$id"|sed -n '2p' `

echo "--------------正在测试中-------------"
test1=`sysbench --test=threads --num-threads=$threads --mutex-locks=$locks --mutex-loops=$loops run|grep "total time:" |awk '{print $3}'|cut -d s -f1`
test2=`sysbench --test=threads --num-threads=$threads --mutex-locks=$locks --mutex-loops=$loops run|grep "total time:" |awk '{print $3}'|cut -d s -f1`
test3=`sysbench --test=threads --num-threads=$threads --mutex-locks=$locks --mutex-loops=$loops run|grep "total time:" |awk '{print $3}'|cut -d s -f1`
echo "---------------测试完成，正在统计与保存结果---------------"
##计算结果####

    total_time=`echo "scale=2;($test1+$test2+$test3)/3" |bc `

mysql $mysqlconn <<EOF
use bench_system;
INSERT INTO mutexbench (threads,locks,loops,total_time,remark,create_time) VALUES( $threads,$locks,$loops,$total_time,"$remark",now() );
EOF
echo "-----------测试结果已经保存数据库-----------"
fi
;;
*)
echo "请输入正确编号!"
;;
esac
