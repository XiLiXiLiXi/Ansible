#!/bin/bash

# determine the server role

ansible_hostname=$1
ansible_distribution=$2
ansible_distribution_major_version=$3

for PortNum in $(netstat -ntl | awk '{print $4}' | sed -e 's/.*://; s/[^0-9]//g; /^$/d' | sort -n)
do
    case "$PortNum" in
    22)   echo "${2}_${3}" >> /tmp/${1}_roles_dup.csv
        ;;
    443) echo "WebApp_Service" >> /tmp/${1}_roles_dup.csv
        ;;
    1433) echo "MSSQL_Service" >> /tmp/${1}_roles_dup.csv
        ;;
    1521) echo "OracleDB_Service" >> /tmp/${1}_roles_dup.csv
        ;;
    2181 | 2888 | 3888 | 4181) echo "ZooKeeper_Service" >> /tmp/${1}_roles_dup.csv
        ;;
    2376) echo "Docker_Service" >> /tmp/${1}_roles_dup.csv
        ;;
    2882) echo "Campaign_Optimise_Service" >> /tmp/${1}_roles_dup.csv
        ;;
    3306) echo "MySQL_Service" >> /tmp/${1}_roles_dup.csv
        ;;
    4664) echo "Campaign_Listener_Service" >> /tmp/${1}_roles_dup.csv
        ;;
    6066 | 7077 | 8080 | 18080) echo "Spark_Master_Service" >> /tmp/${1}_roles_dup.csv
        ;;
    6379) echo "Redis_Service" >> /tmp/${1}_roles_dup.csv
        ;;
    7337 | 8081) echo "Spark_Woker_Service" >> /tmp/${1}_roles_dup.csv
        ;;
    8047) echo "Apache_Drill_Service" >> /tmp/${1}_roles_dup.csv
        ;;
    8082 | 8092) echo "Mule Service" >> /tmp/${1}_roles_dup.csv
        ;;
    9092) echo "Kafka_Service" >> /tmp/${1}_roles_dup.csv
        ;;
    9200) echo "ElasticSearch_Service" >> /tmp/${1}_roles_dup.csv
        ;;
    10000 | 10002) echo "Hive_Service" >> /tmp/${1}_roles_dup.csv
        ;;
    27017) echo "MongoDB_Service" >> /tmp/${1}_roles_dup.csv
        ;;
    *) echo "$PortNum" >> /tmp/other_listening_ports.log
    esac
done
#uniq /tmp/server_roles_tmp.csv | tee /tmp/server_roles_dup.csv
sort /tmp/${1}_roles_dup.csv | uniq | sed '/^$/d' | tee ${1}_roles.csv
exit

