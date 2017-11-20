## Install sysbench
```bash 
yum localinstall http://repo.percona.com/release/7/RPMS/x86_64/sysbench-1.0.8-1.el7.x86_64.rpm   
```
 

##create

```sql
create database demo;
```
## create tables and load data

```bash 
sysbench --db-driver=mysql --test=/usr/share/sysbench/tests/include/oltp_legacy/oltp.lua --oltp-table-size=1000000 --mysql-db=demo --mysql-user=root --mysql-password=oracle --mysql-port=3306 --mysql-host=mysqlserver01 prepare
```

##run
```bash 
sysbench --db-driver=mysql --test=/usr/share/sysbench/tests/include/oltp_legacy/oltp.lua --oltp-table-size=1000000 --mysql-db=demo --mysql-user=root --mysql-password=oracle --mysql-port=3306 --mysql-host=mysqlserver01 --time=60 --oltp-read-only=off --max-requests=0 --threads=8 run
```

##cleanup
```bash 
sysbench --test=oltp --mysql-db=test --mysql-user=root --mysql-password=oracle cleanup
```
