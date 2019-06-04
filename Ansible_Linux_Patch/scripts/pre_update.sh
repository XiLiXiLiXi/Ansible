#!/bin/bash
# @brief actions required to be conducted before updates are applied
#        and/or servers are rebooted.  

logFile="/tmp/pre_update.log"

###########################
# Begin Functions         #
function log_msg {
  current_time=$(date "+%Y-%m-%d %H:%M:%S.%3N")
  log_level=$1
  # all arguments except for the first one, since that is the level
  log_msg="${@:2}"
  echo "[$current_time] $log_level - $log_msg" >> $logFile
}

function log_error {
  log_msg "ERROR" "$@"
}

function log_info {
  log_msg "INFO " "$@"
}

function log_debug {
  log_msg "DEBUG" "$@"
}
# End Functions           #
###########################
###########################
# Begin Body              #
#errorCheck=0
#cat /dev/null > $logFile

log_info "========================================================"
log_info "= Pre-update status for $HOSTNAME"
log_info "========================================================"

# Stop app/db

# command to stop app/db
#result=$(ps -ef | grep -i app/db | grep -v grep | wc -l)
#count=0

# if app/db process is still running, PPM has not stopped.  
#while [ "$result" != 0 ] && [ $count -lt 9 ]; do
#    sleep 20
#    result=$(ps -ef | grep -i DNAME | grep -v grep | wc -l)
#    count=$((count + 1))
#done

# if app/db hasn't stopped by now, manual intervention/review will be necessary.
#if [ "$result" != 0 ] && [ $count -ge 9 ]; then
#    log_error "app/db has NOT stopped"
#    errorCheck=1
#else
#    log_info "app/db has stopped successfully"
#fi

# Final status of healthchecks
#if [ ${errorCheck} != 0 ]; then
#        statusMsg="STATUS: ERROR: Something went wrong.  Please review results"
#        sed -i "1s/^/$statusMsg\n\n/" $logFile
#else
#        statusMsg="STATUS: OK"
#        sed -i "1s/^/$statusMsg\n\n/" $logFile
#fi
