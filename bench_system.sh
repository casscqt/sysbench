#!/bin/bash
echo ""
echo "----------------------SysBench基准测试系统---------------------------------"
read -p "请输入基准测试类型：1.CPU性能测试 2.线程测试 3.互斥锁测试 4.内存测试 5.文件IO测试 6.数据库基准测试" type


case $type in
	1) sh ./bench_cpu/bench_cpu.sh	      ;;
	2) sh ./bench_threads/bench_threads.sh ;;
	3) sh ./bench_mutex/bench_mutex.sh    ;;
	4) sh ./bench_memory/bench_memory.sh  ;;
	5) sh ./bench_fileio/bench_fileio.sh  ;;
	6) sh ./bench_db/bench_db.sh      ;;
	*) echo "请输入正确类型编号";;
esac

