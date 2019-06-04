#!/bin/bash

distribution=$1
major_version=$2

echo \"timestamp\",\"package name\",\"current version\",\"update version\"
yum -q check-update --security --disablerepo=* --enablerepo=${distribution}${major_version}_x86_64_latest | tr -s " " | while read PNAME UVERSION extra
do
    if [ "${PNAME}x" != "x" ]; then
        TIMESTAMP=$( date +%D" "%r )
        echo \"$TIMESTAMP\",$(rpm -q "${PNAME}" --qf '"%{NAME}","%{VERSION}","')${UVERSION}\"
    fi
done

