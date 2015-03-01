#!/bin/bash
source ~/.bash_profile
#获得当前测试环境的硬件信息，并存储到dbench.bench_model表中

usage () {
        cat <<EOF
Usage: $0 [OPTIONS]

  --host=name         connect to the host    
  --port=port         connect to the port 
  --socket=socket     connect to the socket
  --user=name         user to log in
EOF
        exit 1
}

if [ $# -ne 0 ] ; then
   for arg do
      val=`echo "$arg" | sed -e "s;--[^=]*=;;"`
      case "$arg" in
      --host=*)          host="$val" ;;
      --port=*)          port="$val" ;;
      --socket=*)        socket="$val" ;;
      --user=*)          user="$val" ;;
      --help)            usage ;;
      *)
      usage
      echo "Sample:`basename $0` --host=ip_address --port=portnum --user=name -p"
      exit 1 ;;
      esac
   done
else
   usage
   exit 1
fi


#获得当前硬件信息
os="`cat /etc/issue | awk 'NR==1 {print $1,$2}'`-`uname -a | awk '{print $12}'`" 
os_version="`lsb_release -a | grep Release | awk '{print $2}'`"                  
db_type="mysql"   								 
db_version="`mysql -V | awk  -F, '{print $1}' | awk '{print $5}'`"	 	 
host_type="`dmidecode | grep "Manufacturer" | tail -n1 |awk -F: '{print $2}'`"   
host_name="`hostname`"
echo "os         : " $os  
echo "os version : " $os_version  
echo "db type    : " $db_type
echo "db version : " $db_version   
echo "host type  : "$host_type   
echo "host name  : " $host_name

read -s -p "请输入从库的$user密码:" password
#mysql -u $user -p$password -h $host -P $port -e "select * from  dbbench.bench_model;"
echo ""
mysql -u $user -p$password -h $host -S $socket -e "select * from  dbbench.bench_model;"
echo ""
read -p "是否创建新测试记录bench_model:(y/n)" reply
[ -z ${reply} ] && reply="n"
if [ ${reply} = "y" ] || [ ${reply} = "Y" ] ; then
#存储到bench_model表中
read  -p "请输入本次测试的测试类型：1.服务器对比测试 2.DB对比测试 " num
bench_type=$num
if [ -z ${num} ] || [ ${num} -gt 5 ] || [ ${num} -lt 1 ];then
    echo "测试类型出错，确保是输入1--5"
    exit 1
fi
read  -p "请输入该服务器的备注说明信息:" mark
[ -z ${mark} ] && mark=""
remark=$mark
mysql -u $user -p$password -h $host -S $socket <<EOF
#mysql -u $user -p$password -h $host -P $port <<EOF 
  insert into dbbench.bench_model(bench_type,os,os_version,db_type,db_version,host_type,host_name,remark,create_time) values("$num","$os","$os_version","$db_type","$db_version","$host_type","$host_name","$remark",now());
EOF
#mysql -u $user -p$password -h $host -P $port -e "insert into dbbench.bench_model(bench_type,os,os_version,db_type,db_version,host_type,remark) values($num,$os,$os_version,$db_type,$db_version,$host_type,$remark);"
echo  "刚才新插入的id为：" `mysql -u $user -p$password -h $host -S $socket -e "select max(id) from dbbench.bench_model;" | awk 'NR==2 {print $0}'`
#echo  "刚才新插入的id为：" `mysql -u $user -p$password -h $host -P $port -e "select max(id) from dbbench.bench_model;" | awk 'NR==2 {print $0}'`
fi
