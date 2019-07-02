#!/bin/bash
sid=$1
source /home/oracle/.bash_profile
export ORACLE_SID=$sid

sqlplus  -S / as sysdba > /tmp/${sid}_dbnagios.lst <<EOF
set heading off;
set feedback off;
select (SELECT PROPERTY_VALUE from DATABASE_PROPERTIES WHERE PROPERTY_NAME='DEFAULT_PERMANENT_TABLESPACE')||' '||(SELECT PROPERTY_VALUE from DATABASE_PROPERTIES WHERE PROPERTY_NAME='DEFAULT_TEMP_TABLESPACE')||' '||(select username from dba_users where username='NAGIOS') from dual;
quit
EOF

sed -e '/^$/d' /tmp/${sid}_dbnagios.lst

default_tbs=`awk '{print $1}' /tmp/${sid}_dbnagios.lst`
default_temp_ts=`awk '{print $2}' /tmp/${sid}_dbnagios.lst`
dbnagios=`awk '{print $3}' /tmp/${sid}_dbnagios.lst`

if [[ ${dbnagios} = "NAGIOS" ]]; then
echo " nagios account already existed in database";
else
sqlplus  -S / as sysdba <<EOF
create user nagios identified by Nagios_test_1 DEFAULT TABLESPACE $default_tbs TEMPORARY TABLESPACE $default_temp_ts;
grant connect, select any table,select any dictionary to nagios;
quit
EOF
fi

if [ $? -eq 0 ]; then echo "db account created"; else echo "db account creation failed, pls investigation"; fi
exit

