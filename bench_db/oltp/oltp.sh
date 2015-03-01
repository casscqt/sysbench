#!/bin/bash

basedir=$(cd $(dirname $0);pwd)

## sysbench输出结果每次间隔多少秒
#interval_sec=20
#test_type_list="oltp_notrx"
#numthreads_list="2 4 16 32 64 128"
#table_size_list="1000000 100000000 1000000000 10000000000"
#table_count=32
#max_time=180
interval_sec=10
i=0
declare -a table_size_list
for var in $5
 do
   table_size_list[$i]=$var
   i=`expr $i + 1`
done
numthreads_list="$7"
table_count="$6"
max_time=180
test_time=0
###################开启关闭mysql服务##########################
mysqld_service() {
        try_time=1
        /usr/local/mysql/bin/mysqld_multi stop 3306
        echo "Waiting stop...sleep 10s"  
        sleep 60
        while true
        do      
                echo "ps -ef | grep mysqld"
                threadnum=$(ps -ef | grep mysqld |grep -v grep | wc -l)
                
                if [ $threadnum -ne 0 ];then
                        sleep 10
                fi
                /usr/local/mysql/bin/mysqladmin $1 ping >/dev/null 2>&1
                check=$?
                if [ $check -eq 1 ];then
                        break
                else
                        echo "Still alive,try $try_time"
                        sleep 10
                        try_time=$(($try_time+1))
                fi
        done
        /usr/local/mysql/bin/mysqld_multi start 3306
        if [ $? -eq 0 ];then
                echo "已执行了start mysqld命令"
        fi
        echo "Waiting start..."
        sleep 10
        try_time=1
        while true 
        do
                /usr/local/mysql/bin/mysqladmin $1 ping  >/dev/null 2>&1
                check=$?
                if [ $check -eq 0 ];then
                        break
                else
                        echo "Starting ,wait more  $try_time"
                        try_time=$(($try_time+1))
                        sleep 10

                fi
        done
         mysql $1 <<EOF
        set global query_cache_type=off;   
EOF
}
###################################################################################
####建立输出文件存放目录#########
for ((j=1;j<=3;j++))
  do
        if [ ! -d  $basedir/$j ];then
                mkdir $basedir/$j
        else
		rm -rf $basedir/$j
		mkdir $basedir/$j
        fi
  done
#################################  
for table_size in ${table_size_list[*]}
    do
     echo $table_size
     if [ $test_time -eq 0 ]; then
        sysbench --test=$basedir/oltp.lua --oltp-tables-count=$table_count --oltp-test-mode=$test_type_list --oltp-table-size=$table_size  --max-time=$max_time --max-requests=0 --report-interval=$interval_sec  $1 prepare | tee -a $basedir/sysbench_prepare
     else
        a=${table_size_list[$test_time]}
        b=${table_size_list[$(($test_time-1))]}
        let asize=$a-$b
        sysbench --test=$basedir/oltp_delta.lua --oltp-tables-count=$table_count --oltp-test-mode=$test_type_list --oltp-table-size=$asize  --max-time=$max_time --max-requests=0 --report-interval=$interval_sec  $1 prepare | tee -a $basedir/sysbench_prepare
      fi
      if [ $? -eq 1 ]; then
        echo "sysbench prepare failed"  
      fi 
     echo ""
mysqld_service "$2"
#######################收集com_select，com_delete，com_update，com_insert##############################################
date_start=$(date +%s)
com_select_1=`mysql $2 -e "show global status like 'Com_select';" | awk 'NR==2 {print $2}'`
com_delete_1=`mysql $2 -e "show global status like 'Com_delete';" | awk 'NR==2 {print $2}'`
com_insert_1=`mysql $2 -e "show global status like 'Com_insert';" | awk 'NR==2 {print $2}'`
com_update_1=`mysql $2 -e "show global status like 'Com_update';" | awk 'NR==2 {print $2}'`

echo "########################################################开始测试:$table_size######################################################"
for ((i=1;i<=3;i++))
   do
    for numthreads in $numthreads_list
      do
        sysbench --test=$basedir/oltp.lua  --oltp-tables-count=$table_count --oltp-test-mode=$test_type_list --oltp-table-size=$table_size  --max-time=$max_time --max-requests=0 --num-threads=$numthreads  --report-interval=$interval_sec  $1 run |tee -a $basedir/$i/sysbench_run_${numthreads}_${table_size}
      if [ "$?" != "0" ];then
          echo "sysbench run failed"
      fi
    done
done
    echo "End running test :  `date`"
    test_time=$(($test_time+1))
done
#######################收集com_select，com_delete，com_update，com_insert##############################################
date_stop=$(date +%s)
com_select_2=`mysql $2 -e "show global status like 'Com_select';" | awk 'NR==2 {print $2}'`
com_delete_2=`mysql $2 -e "show global status like 'Com_delete';" | awk 'NR==2 {print $2}'`
com_insert_2=`mysql $2 -e "show global status like 'Com_insert';" | awk 'NR==2 {print $2}'`
com_update_2=`mysql $2 -e "show global status like 'Com_update';" | awk 'NR==2 {print $2}'`
let com_select="($com_select_2 - $com_select_1)"/"($date_stop-$date_start)"
let com_delete="($com_delete_2 - $com_delete_1)"/"($date_stop-$date_start)"
let com_insert="($com_insert_2 - $com_insert_1)"/"($date_stop-$date_start)"
let com_update="($com_update_2 - $com_update_1)"/"($date_stop-$date_start)"
extra_stat="s:$com_select/i:$com_insert/d:$com_delete/u:$com_update"
echo "extra_stat : "$extra_stat
########################################################结束测试######################################################

    sysbench --test=$basedir/oltp.lua  --oltp-tables-count=$table_count  $1 cleanup |tee -a $basedir/sysbench_clean
echo "#############################################开始收集信息并入库###########################################################"
updir=$(cd $basedir;cd ..;pwd)
test_id=$3
test_type=$4
#######入库到db35##########################
#conn="--user=dbbench --password=w5q9C4BHXgH3Y --host=10.16.133.35 --port=3306"
#`sh $updir/collect.sh "$extra_stat" "$conn" "oltp" "$numthreads_list" "$table_size_list" "$basedir" "$test_id" "$test_type"`
echo "$table_size_list"
`sh $updir/collect.sh "$extra_stat" "$2" "oltp" "$numthreads_list" "$5" "$basedir" "$test_id" "$test_type"`
if [ "$?" != "0" ];then
    echo "入库出现错误，请检查入库脚本是否有错！"
else
    echo "入库成功"
fi
