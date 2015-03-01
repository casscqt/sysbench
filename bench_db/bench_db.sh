#!/bin/bash

read -p "请输入功能编号： 1.DB测试登记与查看 2.DB基准测试" num1

case $num1 in

1)

sh ./bench_db/model.sh --host=localhost --user=root --socket=/usr/local/mysql/tmp/3306/mysql.sock

;; 
2)
read -p "请输入测试ID：" test_id
read -p "请输入测试类型1.服务器对比测试、2.数据库版本对比测试：" test_type

sh ./bench_db/sysbench.sh --test_type=$test_type --test_id=$test_id
;;
esac
