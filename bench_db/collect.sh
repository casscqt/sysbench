#!/bin/bash
source ~/.bash_profile
basedir="$6"
#mailgrooup=
mysqlconn="$2"


########################################################################################
#1.服务器对比测试  2.DB对比测试  3.OS对比测试  4.存储对比测试 5.参数对比测试' bench_type

#基准测试方法（1－15） bench_menthod=(1-15)

#数据呈现类别，代表每种测试的图表一、二、三：  			      unfold_type=(1-3)

#测试的并发线程数:			      					threads

#表大小，以w行为单表示，若为区间范围的表大小，则记录最大区间:		     table_size

#每秒事务数:tps

#平均响应时间:                               				   avg_resp_time

#测试过程中通过采集数据库状态变量的统计值     				      extra_stat
########################################################################################

#data collection

case "$3" in 
   oltp)         		bench_menthod=1;;
   oltp_notrx)   		bench_menthod=2;;
   confusion)   		bench_menthod=3;;
   update_index) 		bench_menthod=4;;
   update_non_index)      	bench_menthod=5;;
   insert_auto) 		bench_menthod=6;;
   insert_noauto) 		bench_menthod=7;;
   select_rand_pk)              bench_menthod=8;;
   select_key_orderby)          bench_menthod=9;;
   select_left_join)            bench_menthod=10;;
   select_in_select)            bench_menthod=11;;
   select_group_by)             bench_menthod=12;;
   select_in_points)            bench_menthod=13;;
   *) echo "uasge error";;
esac
##########################################################################################

#数据处理
extra_stat="$1"
thread_list=$4
table_size_list="$5"
id=$7
bench_type=$8
if [ ! -d "$basedir/test" ];then
    mkdir $basedir/test
else
    rm -rf $basedir/test
    mkdir $basedir/test
fi

for table_size in $table_size_list
do 
  for thread in $thread_list
  do
	if [ $bench_menthod -eq 8 -o $bench_menthod -eq 9 -o $bench_menthod -eq 10 -o $bench_menthod -eq 11 -o $bench_menthod -eq 12 -o $bench_menthod -eq 13 ];then
	     for ((q=1;q<=3;q++))
	     do
        	touch $basedir/test/"$thread"_"$table_size"
        	cat $basedir/$q/sysbench_run_"$thread"_"$table_size">>$basedir/test/"$thread"_"$table_size"
	     done
	     cd $basedir/test/
             avg_resp_time=`cat ${thread}_${table_size} | grep '\[' | sort -k 12r | awk '{print $13}' | sed '1s/.*//' | sed '$s/.*//' | awk '{sum+=$0}END{print sum/(NR-2)}'`
             tps=`cat ${thread}_${table_size} | grep '\[' | awk -F, '{print $3}' | awk '{print $2}'| sort -r | sed '1s/.*//' | sed '$s/.*//' |awk '{sum+=$0}END{print sum/(NR-2)}'`
	else
	     for ((d=1;d<=3;d++))
             do
                touch $basedir/test/"$thread"_"$table_size"
                cat $basedir/$d/sysbench_run_"$thread"_"$table_size">>$basedir/test/"$thread"_"$table_size"
             done
             cd $basedir/test/
             avg_resp_time=`cat ${thread}_${table_size} | grep '\[' | sort -k 12r | awk '{print $13}' | sed '1s/.*//' | sed '$s/.*//' | awk '{sum+=$0}END{print sum/(NR-2)}'`
             tps=`cat ${thread}_${table_size} | grep '\[' | awk -F, '{print $2}' | awk '{print $2}'| sort -r | sed '1s/.*//' | sed '$s/.*//' |awk '{sum+=$0}END{print sum/(NR-2)}'`
         fi
    
   mysql $mysqlconn <<EOF
   use dbbench;
   insert into bench_test_rawdata(bench_id,bench_type,bench_menthod,threads,table_size,tps,avg_resp_time,extra_stat,create_time) values($id,"$bench_type","$bench_menthod","$thread","$table_size","$tps","$avg_resp_time","$extra_stat",now());
EOF
 done
done

##############################################################################################################################
#echo "数据收集成功" | mailx -s "数据库基准测试---数据采集"   $mailgroup

