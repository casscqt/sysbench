#!/bin/bash
source ~/.bash_profile
basedir=$(cd $(dirname $0);pwd)
#mailgrooup=zhenghh3@ucweb.com
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
#echo "请选择测试类别：1.服务器对比测试  2.DB对比测试  3.OS对比测试  4.存储对比测试 5.参数对比测试'"
#read num1
#bench_type=$num1
#echo "请选择基准测试方法：（1-15）"
#read num2
#bench_menthod=$num2
#case $bench_menthod in 
 # 1) remark="测试oltp" ;;
 # 2) remark="测试no_oltp" ;;
 # 3) remark="测试confusion" ;;
 # 4) remark="测试update_index" ;;
 # 5) remark="测试update_non_index" ;;
 # 6) remark="测试insert_index" ;;
 # 7) remark="测试insert_non_index" ;;
 # 8) remark="测试" ;;
 # 9) remark="测试confusion" ;;
 #10) remark="测试confusion" ;;
 #11) remark="测试confusion" ;;
 #12) remark="测试confusion" ;;
 #13) remark="测试confusion" ;;
 #14) remark="测试confusion" ;;
 #15) remark="测试confusion" ;;
 #*) echo "uasge error";;
#esac
#########################################################################################
os="`cat /etc/issue | awk 'NR==1 {print $1,$2}'`"-"`uname -a | awk '{print $12}'`"
os_version="`lsb_release -a | grep Release | awk '{print $2}'`"
db_type="mysql"
db_version="`mysql -V | awk  -F, '{print $1}' | awk '{print $5}'`"
host_type="`dmidecode | grep "Manufacturer" | tail -n1 |awk -F: '{print $2}'`"
bench_type=1
bench_menthod=1
remark="测试oltp"
extra_stat="$1"
#获取插入时间,并插入测试条件
time=`date +"%Y-%m-%d %T"`
mysql $mysqlconn <<EOF
 set @time=(select STR_TO_DATE("$time",'%Y-%m-%d %H:%i:%s'));
 insert into dbbench.bench_model(bench_type,os,os_version,db_type,db_version,host_type,remark,create_time) values("$bench_type","$os","$os_version","$db_type","$db_version","$host_type","$remark",@time);
EOF
##########################################################################################

#数据处理
#thread_list="2 4 8 16 32 64 128"
thread_list="2 4"
#table_size_list="1000000 100000000"
table_size_list=1000
if [ ! -d "$basedir/test" ];then
 mkdir $basedir/test
fi

for table_size in $table_size_list
do 
  for thread in $thread_list
  do
    for ((i=1;i<=3;i++))
    do
        touch $basedir/test/"$thread"_"$table_size"
        cat $basedir/$i/sysbench_run_"$thread"_"$table_size">>$basedir/test/"$thread"_"$table_size"
    done
    cd $basedir/test/
    avg_resp_time=`cat ${thread}_${table_size} | grep '\[' | sort -k 12r | awk '{print $13}' | sed '1s/.*//' | sed '$s/.*//' | awk '{sum+=$0}END{print sum/(NR-2)}'`
    tps=`cat ${thread}_${table_size} | grep '\[' | awk -F, '{print $2}' | awk '{print $2}'| sort -r | sed '1s/.*//' | sed '$s/.*//' |awk '{sum+=$0}END{print sum/(NR-2)}'`

    mysql $mysqlconn <<EOF
   use dbbench;
   set @a=(select id from bench_model where create_time="$time");
   insert into bench_test_rawdata(bench_id,bench_type,bench_menthod,threads,table_size,tps,avg_resp_time,extra_stat,create_time) values(@a,"$bench_type","$bench_menthod","$thread","$table_size","$tps","$avg_resp_time","$extra_stat",now());
    insert into bench_test_data(bench_id,bench_type,bench_menthod,unfold_type,table_size,tps,avg_resp_time,threads,extra_stat,create_time) values(@a,$bench_type,$bench_menthod,3,$table_size,$tps,"$avg_resp_time",$thread,"$extra_stat",now()); 
EOF
  done
  mysql $mysqlconn <<EOF
  use dbbench;
  set @id=(select id from bench_model where create_time="$time");
  set @a=(select tps from (select max(tps) as tps ,table_size from bench_test_rawdata group by  table_size ) as t where table_size=$table_size);
  set @b=(select threads from bench_test_rawdata where tps=(select @a));
 
  insert into bench_test_data(bench_id,bench_type,bench_menthod,unfold_type,table_size,tps,threads,extra_stat,create_time) values(@id,$bench_type,$bench_menthod,1,"$talbe_size",@a,@b,"$extra_stat",now());
  
  set @c=(select tps from (select avg(tps) as tps,table_size from bench_test_rawdata group by table_size) as t where table_size=$table_size);
  set @d=(select avg_resp_time from (select avg(avg_resp_time) as avg_resp_time,table_size from bench_test_rawdata group by table_size) as t where table_size=$table_size); 

  insert into bench_test_data(bench_id,bench_type,bench_menthod,unfold_type,table_size,tps,threads,avg_resp_time,extra_stat,create_time) values(@id,$bench_type,$bench_menthod,2,"$talbe_size",@c,"",@d,"$extra_stat",now());
EOF
done

##############################################################################################################################
echo "数据收集成功" | mailx -s "数据库基准测试---数据采集"   $mailgroup

