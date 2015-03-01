#!/bin/bash

##sysbench测试调用脚本##
#调用其他各个基准测试单元#

basedir=$(cd $(dirname $0);pwd)

#帮助提示
usage () {
   cat <<EOF
Usage: $0 [OPTIONS]
--socket             ：socket file,默认为/usr/local/mysql/tmp/3306/mysql.sock
--user               : 备份用户,默认 root
--password           : 用户密码,默认 123456
--host               : 远程主机名 ,默认localhost
--port               : 远程端口 ,默认3306
--test_type          : 测试模型.(1.服务器对比测试 2.DB对比测试 3.OS对比测试 4.存储对比测试  5.参数对比测试)
--test_id            : 测试编号.
EOF
        exit 0
}
#######################################################################################
#判断是否对参数赋值，若没有即为各个参数赋默认值
#初始化赋值
#######################################################################################
parse_arguments() {
  for arg do
    opts_value=`echo "$arg" | sed -e 's/^[^=]*=//'`
    case "$arg" in
      --socket=*)  socket=$opts_value ;;
      --user=*)  user=$opts_value ;;
      --password=*)  password=$opts_value ;;
      --host=*)  host=$opts_value ;;
      --port=*)  port=$opts_value ;;
      --test_type=*) test_type=$opts_value ;;
      --test_id=*)   test_id=$opts_value   ;;
      --help)     usage ;;
      *)
      echo "Usage:`basename $0` --help   "
      exit 1 ;;
    esac
  done
}
setVar() {
  for var in $1
   do
     case $var in 
	1)  
	#oltp_table_size="100000 200000 300000" oltp_table_count="8" oltp_threads_count="4 8 16 32" 
        #confusion_table_size="100000 200000 300000" confusion_table_count="8" confusion_threads_count="4 8 16 32"
	 #   update_table_size="100000 200000 300000" update_table_count="8" update_threads_count="4 8 16 32"
        #index_non_table_size="100000 200000 300000" index_non_table_count="8" index_non_threads_count="4 8 16 32"
#	    pk_table_size="100000 200000 300000" pk_table_count="8" pk_threads_count="4 8 16 32"
#	    key_table_size="100000 200000 300000" key_table_count="8" key_threads_count="4 8 16 32" 
#	    join_table_size="100000 200000 300000" join_table_count="8" join_threads_count="4 8 16 32" 
#	    group_table_size="100000 200000 300000"  group_table_count="8"    group_threads_count="4 8 16 32"	


	oltp_table_size="10000 20000 30000" oltp_table_count="8" oltp_threads_count="4 8 16 32" 
        confusion_table_size="10000 20000 30000" confusion_table_count="8" confusion_threads_count="4 8 16 32"
	    #update_table_size="100000 200000 300000" update_table_count="8" update_threads_count="4 8 16 32"
       # index_non_table_size="100000 200000 300000" index_non_table_count="8" index_non_threads_count="4 8 16 32"
	#    pk_table_size="100000 200000 300000" pk_table_count="8" pk_threads_count="4 8 16 32"
	 ####   key_table_size="100000 200000 300000" key_table_count="8" key_threads_count="4 8 16 32" 
	    #join_table_size="100000 200000 300000" join_table_count="8" join_threads_count="4 8 16 32" 
	    #group_table_size="100000 200000 300000"  group_table_count="8"    group_threads_count="4 8 16 32"	
	    ;;
	2)  oltp_table_size="100000 200000 300000" oltp_table_count="8" oltp_threads_count="4 8 16 32"
            oltp_non_table_size="100000 200000 300000"   oltp_non_table_count="8"  oltp_non_threads_count="4 8 16 32 "
            confusion_table_size="100000 200000 300000" confusion_table_count="8" confusion_threads_count="4 8 16 32"
            update_table_size="100000 200000 300000" update_table_count="8" update_threads_count="4 8 16 32"
	    update_non_table_size="100000 200000 300000" update_non_table_count="8" update_non_threads_count="4 8 16 32"
            index_auto_table_size="100000 200000 300000" index_auto_table_count="8" index_auto_threads_count="4 8 16 32"
            index_non_table_size="100000 200000 300000" index_non_table_count="8" index_non_threads_count="4 8 16 32"
	    pk_table_size="100000 200000 300000" pk_table_count="8" pk_threads_count="4 8 16 32"
            key_table_size="100000 200000 300000" key_table_count="8" key_threads_count="4 8 16 32"
            join_table_size="100000 200000 300000" join_table_count="8" join_threads_count="4 8 16 32"
            select_table_size="100000 200000 300000" select_table_count="8" select_threads_count="4 8 16 32"
            points_table_size="100000 200000 300000" points_table_count="8" points_threads_count="4 8 16 32"
	    group_table_size="100000 200000 300000"  group_table_count="8"    group_threads_count="4 8 16 32 "
	    	
	    ;;
        *) ;;
      esac
    done
}
parse_arguments $@

if [ -z $socket ];then
	socket=/usr/local/mysql/tmp/3306/mysql.sock
fi

if [ -z $user ];then
	user=root
fi

if [ -z $password ];then
	password=123456
fi

if [ -z $host ];then
	host=localhost
fi

if [ -z $port ];then
	port=3306
fi

if [ -z $test_type ];then
	echo "语法错误！,请指定测试类型"
	usage
fi

if [ -z $test_id ];then
	echo "语法错误！请指定测试编号"
        usage
fi

#######################################################################################
#判断进行何种测试
#调用测试单元判断,指定各个测试脚本输出日志的路径
#######################################################################################
date_str=`date +%Y%m%d_%H%M%S`
if [ "$host" = "localhost" ];then
  if [ -z $socket ];then
     sb_opts=" --mysql-user=$user --mysql-password=$password --mysql-socket=/tmp/mysql.sock "
     mysql_login=" -u $user -p$password -S /tmp/mysql.sock"
  else
     sb_opts=" --mysql-user=$user --mysql-password=$password --mysql-socket=$socket "
     mysql_login=" -u $user -p$password -S $socket"	  
fi
else
     sb_opts=" --mysql/-user=$user --mysql-password=$password --mysql-host=$host --mysql-port=$port "
     mysql_login=" -u $user -p$password -h $host -P $port"
fi
########################################################################################
#删除bench_test_rawdata表中测试编号与本次测试编号相同的记录，避免造成影响###############
#mysql --host=localhost --socket=/usr/local/mysql/tmp/3306/mysql.sock --user=root --password=111111 -e "delete from dbbench.bench_test_rawdata where bench_id=$test_id"

###############根据测试类型号，决定测试实例的表大小#####################################
setVar "$test_type"
########################################################################################

case $test_type in
	1)
		echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>测试oltp........<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
		sh $basedir/oltp/oltp.sh "$sb_opts"  "$mysql_login" "$test_id" "$test_type" "$oltp_table_size" "$oltp_table_count" "$oltp_threads_count"
		if [ "$?" -ne 0 ];then
			echo "测试失败！"
		fi  
        echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>测试混合delete,insert,update_trx,update_nontrx......<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
                sh  $basedir/confusion/confusion.sh "$sb_opts" "$mysql_login"  "$test_id" "$test_type" "$confusion_table_size" "$confusion_table_count" "$confusion_threads_count"
                if [ "$?" -ne 0 ];then
                        echo "测试失败"
                fi  ;; 
	22)	echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>测试update_index......<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
                sh  $basedir/update_index/update_index.sh "$sb_opts" "$mysql_login"  "$test_id" "$test_type" "$update_table_size" "$update_table_count" "$update_threads_count"
                if [ "$?" -ne 0 ];then
                        echo "测试失败"
                fi  
		echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>测试insert_noauto.......<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
                sh $basedir/insert_noauto/insert_noauto.sh "$sb_opts" "$mysql_login" "$test_id" "$test_type" "$index_non_table_size" "$index_non_table_count" "$index_non_threads_count"
                if [ "$?" -ne 0 ];then
                        echo "测试失败"
                fi  
		echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>测试select_rand_pk.......<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
                sh $basedir/select_rand_pk/select_rand_pk.sh "$sb_opts" "$mysql_login" "$test_id" "$test_type" "$pk_table_size" "$pk_table_count" "$pk_threads_count"
                if [ "$?" -ne 0 ];then
                        echo "测试失败"
                fi  
        echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>测试select_key_orderby.......<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
                sh $basedir/select_key_orderby/select_key_orderby.sh "$sb_opts" "$mysql_login" "$test_id" "$test_type" "$key_table_size" "$key_table_count" "$key_threads_count"
                if [ "$?" -ne 0 ];then
                        echo "测试失败"
                fi ;;
      110)   echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>测试select_left_join.......<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
                sh $basedir/select_left_join/select_left_join.sh "$sb_opts" "$mysql_login" "$test_id" "$test_type" "$join_table_size" "$join_table_count" "$join_threads_count"
                if [ "$?" -ne 0 ];then
                        echo "测试失败"
                fi 
  #		echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>测试select_group_by.......<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
   #             sh $basedir/select_group_by/select_group_by.sh "$sb_opts" "$mysql_login" "$test_id" "$test_type" "$group_table_size" "$group_table_count" "$group_threads_count"
    #            if [ "$?" -ne 0 ];then
     #                   echo "测试失败"
  #              fi
		;;	

	21)      echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>测试oltp........<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
                sh $basedir/oltp/oltp.sh "$sb_opts"  "$mysql_login" "$test_id" "$test_type" "$oltp_table_size" "$oltp_table_count" "$oltp_threads_count"
                if [ "$?" -ne 0 ];then
                        echo "测试失败！"
                fi

		   echo "测试>>>>>>>>>>>>>>>>>>>>>>>>>>>>oltp_notrx........<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
             	sh $basedir/oltp_notrx/oltp_notrx.sh "$sb_opts" "$mysql_login" "$test_id" "$test_type" "$oltp_non_table_size" "$oltp_non_table_count" "$oltp_non_threads_count"
                if [ "$?" -ne 0 ];then
                        echo "测试失败！"
                fi 	
		echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>测试混合delete,insert,update_trx,update_nontrx......<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
                sh  $basedir/confusion/confusion.sh "$sb_opts" "$mysql_login"  "$test_id" "$test_type" "$confusion_table_size" "$confusion_table_count" "$confusion_threads_count"
                if [ "$?" -ne 0 ];then
                        echo "测试失败"
                fi 
                echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>测试update_index......<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
                sh  $basedir/update_index/update_index.sh "$sb_opts" "$mysql_login"  "$test_id" "$test_type" "$update_table_size" "$update_table_count" "$update_threads_count"
                if [ "$?" -ne 0 ];then
                        echo "测试失败"
                fi
 		echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>测试update_non_index.......<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
                sh  $basedir/update_non_index/update_non_index.sh "$sb_opts" "$mysql_login" "$test_id" "$test_type" "$update_non_table_size" "$update_non_table_count" "$update_non_threads_count"
                if [ "$?" -ne 0 ];then
                        echo "测试失败"
                fi   
		echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>测试select_rand_pk.......<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
               sh $basedir/select_rand_pk/select_rand_pk.sh "$sb_opts" "$mysql_login" "$test_id" "$test_type" "$pk_table_size" "$pk_table_count" "$pk_threads_count"
                if [ "$?" -ne 0 ];then
                        echo "测试失败"
                fi 
		 echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>测试select_in_select.......<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
                sh $basedir/select_in_select/select_in_select.sh "$sb_opts" "$mysql_login" "$test_id" "$test_type" "$select_table_size" "$select_table_count" "$select_threads_count"
                if [ "$?" -ne 0 ];then
                        echo "测试失败"
                fi
                echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>测试select_group_by.......<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
                sh $basedir/select_group_by/select_group_by.sh "$sb_opts" "$mysql_login" "$test_id" "$test_type" "$group_table_size" "$group_table_count" "$group_threads_count"
                if [ "$?" -ne 0 ];then
                        echo "测试失败"
                fi
                echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>测试select_in_points.......<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
                sh $basedir/select_in_points/select_in_points.sh "$sb_opts" "$mysql_login" "$test_id" "$test_type" "$points_table_size" "$points_table_count" "$points_threads_count"
                if [ "$?" -ne 0 ];then
                        echo "测试失败"
                fi

		 echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>测试insert_auto.......<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
                sh  $basedir/insert_auto/insert_auto.sh "$sb_opts" "$mysql_login" "$test_id" "$test_type" "$index_auto_table_size" "$index_auto_table_count" "$index_auto_threads_count"
                if [ "$?" -ne 0 ];then
                        echo "测试失败"
                fi 
                echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>测试insert_noauto.......<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
                sh $basedir/insert_noauto/insert_noauto.sh "$sb_opts" "$mysql_login" "$test_id" "$test_type" "$index_non_table_size" "$index_non_table_count" "$index_non_threads_count"
                if [ "$?" -ne 0 ];then
                        echo "测试失败"
                fi ;; 
	2)	echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>测试select_key_orderby.......<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
                sh $basedir/select_key_orderby/select_key_orderby.sh "$sb_opts" "$mysql_login" "$test_id" "$test_type" "$key_table_size" "$key_table_count" "$key_threads_count"
                if [ "$?" -ne 0 ];then
                        echo "测试失败"
                fi
		echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>测试select_left_join.......<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
                sh $basedir/select_left_join/select_left_join.sh "$sb_opts" "$mysql_login" "$test_id" "$test_type" "$join_table_size" "$join_table_count" "$join_threads_count"
                if [ "$?" -ne 0 ];then
                        echo "测试失败"
                fi
		;;
	--help)
		usage ;;
	*)
		echo "Usage:`basename $0` --help   "
      		exit 1 ;;
esac



