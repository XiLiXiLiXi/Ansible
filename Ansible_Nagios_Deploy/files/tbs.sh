#!/bin/bash
sid=$1
source /home/oracle/.bash_profile
export ORACLE_SID=$sid
sqlplus  -S / as sysdba > /tmp/${sid}_tbs.lst <<EOF
set heading off;
set feedback off;
SELECT instance_name||','||tablespace_name from dba_tablespaces,v\$instance;
quit
EOF
sed -e '/^$/d' /tmp/${sid}_tbs.lst

sqlplus  -S / as sysdba > /tmp/${sid}_dbnagios.lst <<EOF
set heading off;
set feedback off;
select (SELECT PROPERTY_VALUE from DATABASE_PROPERTIES WHERE PROPERTY_NAME='DEFAULT_PERMANENT_TABLESPACE')||' '||(SELECT PROPERTY_VALUE from DATABASE_PROPERTIES WHERE PROPERTY_NAME='DEFAULT_TEMP_TABLESPACE')||' '||(select username from dba_users where username='NAGIOS') from dual;
quit
EOF
exit
