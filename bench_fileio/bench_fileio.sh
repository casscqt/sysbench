#!/bin/bash

mysqlconn="-u root -p123456 -S /usr/local/mysql/tmp/3306/mysql.sock"
echo ""
echo "--------------正在进行IO基准测试-------------------"
read -p "请输入功能编号：1.测试查询 2.IO测试 3.IO对比测试" num1

case $num1 in 
1)
mysql $mysqlconn <<EOF
use bench_system;
select * from iobench;
EOF
;;
2)
read -p "请输入运算中使用线程数量" threads
read -p "请输入测试文件大小(例如300M、30G等)" maxfile

#test=`free -m |grep Mem |awk '{print $2}'`
#if [ $maxfile -lt $test  ];then
#echo "测试文件大小小于内存，将影响测试结果准确性"
#fi
read -p "请输io入测试模式1.顺序写 2.顺序重写 3.顺序读 4.随机读 5.随机写 6.随机读写" type
read -p "请输入备注信息"  mark

case $type in
1)type=seqwr;;
2)type=seqrewr;;
3)type=seqrd;;
4)type=rndrd;;
5)type=rndwr;;
6)type=rndrw;;
esac
echo "---------正在准备测试数据---------"
sysbench --test=fileio --num-threads=$threads --file-total-size=$maxfile --file-test-mode=$type prepare
echo "---------正在测试中---------"
test1=`sysbench --test=fileio --num-threads=$threads --file-total-size=$maxfile --file-test-mode=$type run |grep -E '(Requests/sec|Total transferred|95 percentile)'`
test2=`sysbench --test=fileio --num-threads=$threads --file-total-size=$maxfile --file-test-mode=$type run |grep -E '(Requests/sec|Total transferred|95 percentile)'`
test3=`sysbench --test=fileio --num-threads=$threads --file-total-size=$maxfile --file-test-mode=$type run |grep -E '(Requests/sec|Total transferred|95 percentile)'`

echo "---------------测试完成，正在统计与保存结果---------------"
##计算结果####

transferred1=`echo $test1|awk '{print $8}'|cut -d "(" -f 2| cut -d M -f 1`
transferred2=`echo $test2|awk '{print $8}'|cut -d "(" -f 2| cut -d M -f 1`
transferred3=`echo $test3|awk '{print $8}'|cut -d "(" -f 2| cut -d M -f 1`
    total_transferred=`echo "scale=2;($transferred1+$transferred2+$transferred3)/3" |bc `

request1=`echo $test1 |awk '{print $9}'`
request2=`echo $test2 |awk '{print $9}'`
request3=`echo $test3 |awk '{print $9}'`
    request=`echo "scale=2;($request1+$request2+$request3)/3" |bc `

percentile1=`echo $test1 |awk '{print $15}'|cut -d m -f1`
percentile2=`echo $test2 |awk '{print $15}'|cut -d m -f1`
percentile3=`echo $test3 |awk '{print $15}'|cut -d m -f1`
    percentile=`echo "scale=2;($percentile1+$percentile2+$percentile3)/3" |bc `
echo $total_transferred $request $percentile
mysql $mysqlconn <<EOF
use bench_system;
INSERT INTO iobench (threads,maxfile,io_type,per_transferred,per_request,95_percentile,remark,create_time) VALUES( $threads,"$maxfile","$type",$total_transferred,$request,$percentile,"$mark",now() );
EOF
echo "-------------正在清理数据--------------"
sysbench --test=fileio --num-threads=$threads --file-total-size=$maxfile --file-test-mode=type cleanup
echo "-----------测试结果已经保存数据库-----------"
;;


3)
read -p "请输入对比测试ID" id
read -p "请输入备注信息"  mark

threads=`mysql $mysqlconn -e "select threads from bench_system.iobench where id=$id"|sed -n '2p' ` 
if [ -z $threads ] ;then
	echo "id不存在！"
else

maxfile=`mysql $mysqlconn -e "select maxfile from bench_system.iobench where id=$id"|sed -n '2p' `
type=`mysql $mysqlconn -e "select io_type from bench_system.iobench where id=$id"|sed -n '2p' `
echo "---------正在准备测试数据---------"
sysbench --test=fileio --num-threads=$threads --file-total-size=$maxfile --file-test-mode=$type prepare
echo "---------正在测试中---------"
test1=`sysbench --test=fileio --num-threads=$threads --file-total-size=$maxfile --file-test-mode=$type run |grep -E '(Requests/sec|Total transferred|95 percentile)'`
test2=`sysbench --test=fileio --num-threads=$threads --file-total-size=$maxfile --file-test-mode=$type run |grep -E '(Requests/sec|Total transferred|95 percentile)'`
test3=`sysbench --test=fileio --num-threads=$threads --file-total-size=$maxfile --file-test-mode=$type run |grep -E '(Requests/sec|Total transferred|95 percentile)'`

echo "---------------测试完成，正在统计与保存结果---------------"
##计算结果####

transferred1=`echo $test1|awk '{print $8}'|cut -d "(" -f 2| cut -d M -f 1`
transferred2=`echo $test2|awk '{print $8}'|cut -d "(" -f 2| cut -d M -f 1`
transferred3=`echo $test3|awk '{print $8}'|cut -d "(" -f 2| cut -d M -f 1`
    total_transferred=`echo "scale=2;($transferred1+$transferred2+$transferred3)/3" |bc `

request1=`echo $test1 |awk '{print $9}'`
request2=`echo $test2 |awk '{print $9}'`
request3=`echo $test3 |awk '{print $9}'`
    request=`echo "scale=2;($request1+$request2+$request3)/3" |bc `

percentile1=`echo $test1 |awk '{print $15}'|cut -d m -f1`
percentile2=`echo $test2 |awk '{print $15}'|cut -d m -f1`
percentile3=`echo $test3 |awk '{print $15}'|cut -d m -f1`
    percentile=`echo "scale=2;($percentile1+$percentile2+$percentile3)/3" |bc `
echo $total_transferred $request $percentile
mysql $mysqlconn <<EOF
use bench_system;
INSERT INTO iobench (threads,maxfile,io_type,per_transferred,per_request,95_percentile,remark,create_time) VALUES( $threads,"$maxfile","$type",$total_transferred,$request,$percentile,"$mark",now() );
EOF
echo "-------------正在清理数据--------------"
sysbench --test=fileio --num-threads=$threads --file-total-size=$maxfile --file-test-mode=type cleanup
echo "-----------测试结果已经保存数据库-----------"
fi
;;
*)
echo "请输入正确编号!"
;;
esac
