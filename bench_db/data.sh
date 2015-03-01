#!/bin/bash
#将数据库中的数据保存到log文件中，以便进行数据图表化
mkdir -p /home/nemo/scripts/Dlog/rhel5/mysql5.1
mkdir -p /home/nemo/scripts/Dlog/rhel5/mysql5.5
mkdir -p /home/nemo/scripts/Dlog/rhel6/mysql5.1
mkdir -p /home/nemo/scripts/Dlog/rhel6/mysql5.5
for ((id=5;id<=12;id++))
do
	if [ $id -le 8 ];then
		if [ $id -le 6 ];then
		mkdir /home/nemo/scripts/Dlog/rhel5/mysql5.1/$id
		basedir="/home/nemo/scripts/Dlog/rhel5/mysql5.1/$id"
	    else
		#有错 改rhel5为rhel6
		mkdir /home/nemo/scripts/Dlog/rhel5/mysql5.5/$id        
		basedir="/home/nemo/scripts/Dlog/rhel5/mysql5.5/$id"
        fi
	else
		if [ $id -le 10 ];then
		mkdir /home/nemo/scripts/Dlog/rhel6/mysql5.5/$id
		basedir="/home/nemo/scripts/Dlog/rhel6/mysql5.5/$id"
		else
	    mkdir /home/nemo/scripts/Dlog/rhel6/mysql5.1/$id
		basedir="/home/nemo/scripts/Dlog/rhel6/mysql5.1/$id"
	   fi
	fi
	
#当bench_type=2时，
number=$((${id}%2))
echo $number

if [ $number -eq 0  ];then
	for ((i=1;i<=13;i++))
		do
		mkdir -p $basedir/${i}
			if [ $i -eq 6 -o $i -eq 7 ];then
#改动密码
mysql --user=root --password=123456 --socket=/usr/local/mysql/tmp/3306/mysql.sock -e "select tps from dbbench.bench_test_data where bench_id=$id and bench_menthod=$i and picture=1 "|sed -n '2,4p' >>$basedir/${i}/picture1
mysql --user=root --password=123456 --socket=/usr/local/mysql/tmp/3306/mysql.sock -e "select tps from dbbench.bench_test_data where bench_id=$id and bench_menthod=$i and picture=2 "|sed -n '2,4p' >>$basedir/${i}/picture2
mysql --user=root --password=123456 --socket=/usr/local/mysql/tmp/3306/mysql.sock -e "select tps from dbbench.bench_test_data where bench_id=$id and bench_menthod=$i and picture=3 "|sed -n '2,5p' >>$basedir/${i}/picture3
mysql --user=root --password=123456 --socket=/usr/local/mysql/tmp/3306/mysql.sock -e "select tps from dbbench.bench_test_data where bench_id=$id and bench_menthod=$i and picture=4 "|sed -n '2,5p' >>$basedir/${i}/picture4
			else
mysql --user=root --password=123456 --socket=/usr/local/mysql/tmp/3306/mysql.sock -e "select tps from dbbench.bench_test_data where bench_id=$id and bench_menthod=$i and picture=1 "|sed -n '2,5p' >>$basedir/${i}/picture1
mysql --user=root --password=123456 --socket=/usr/local/mysql/tmp/3306/mysql.sock -e "select tps from dbbench.bench_test_data where bench_id=$id and bench_menthod=$i and picture=2 "|sed -n '2,5p' >>$basedir/${i}/picture2
mysql --user=root --password=123456 --socket=/usr/local/mysql/tmp/3306/mysql.sock -e "select tps from dbbench.bench_test_data where bench_id=$id and bench_menthod=$i and picture=3"|sed -n '2,5p' >>$basedir/${i}/picture3
			fi
	done
else

#当bench_type=1时，
type_list="1 3 4 7 8 9 10 12"
	for type in $type_list
		do
			mkdir -p $basedir/${type}
			if [ $type -eq 7 ];then
mysql --user=root --password=123456 --socket=/usr/local/mysql/tmp/3306/mysql.sock -e "select tps from dbbench.bench_test_data where bench_id=$id and bench_menthod=$type and picture=1"|sed -n '2,4p' >>$basedir/${type}/picture1
mysql --user=root --password=123456 --socket=/usr/local/mysql/tmp/3306/mysql.sock -e "select tps from dbbench.bench_test_data where bench_id=$id and bench_menthod=$type and picture=2"|sed -n '2,4p' >>$basedir/${type}/picture2
mysql --user=root --password=123456 --socket=/usr/local/mysql/tmp/3306/mysql.sock -e "select tps from dbbench.bench_test_data where bench_id=$id and bench_menthod=$type and picture=3"|sed -n '2,5p' >>$basedir/${type}/picture3
mysql --user=root --password=123456 --socket=/usr/local/mysql/tmp/3306/mysql.sock -e "select tps from dbbench.bench_test_data where bench_id=$id and bench_menthod=$type and picture=4"|sed -n '2,5p' >>$basedir/${type}/picture4
			else
mysql --user=root --password=123456 --socket=/usr/local/mysql/tmp/3306/mysql.sock -e "select tps from dbbench.bench_test_data where bench_id=$id and bench_menthod=$type and picture=1"|sed -n '2,4p' >>$basedir/${type}/picture1
mysql --user=root --password=123456 --socket=/usr/local/mysql/tmp/3306/mysql.sock -e "select tps from dbbench.bench_test_data where bench_id=$id and bench_menthod=$type and picture=2"|sed -n '2,4p' >>$basedir/${type}/picture2
mysql --user=root --password=123456 --socket=/usr/local/mysql/tmp/3306/mysql.sock -e "select tps from dbbench.bench_test_data where bench_id=$id and bench_menthod=$type and picture=3"|sed -n '2,5p' >>$basedir/${type}/picture3
			fi
	done
fi
done
