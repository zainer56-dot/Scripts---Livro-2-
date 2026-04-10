#!/bin/ksh
#
# SCRIPT: proc_watch_timed.ksh
# AUTOR: Zainer Araujo
# DATA: 14-09-2007
# REV: 1.0.P (corrigido)
#

####################################################
############ VARIÁVEIS GLOBAIS #####################
####################################################
typeset -u RUN_PRE_EVENT RUN_STARTUP_EVENT RUN_POST_EVENT
RUN_PRE_EVENT='N'
RUN_STARTUP_EVENT='Y'
RUN_POST_EVENT='Y'

LOGFILE="/tmp/proc_status.log"
SCRIPT_NAME=$(basename "$0")
TTY=$(tty 2>/dev/null || echo /dev/tty)
INTERVAL=1
BREAK='N'
RUN='N'

[[ ! -f $LOGFILE ]] && touch "$LOGFILE"

####################################################
################ FUNÇÕES ###########################
####################################################
usage() {
  print "
USO:
 $SCRIPT_NAME [-s seg] [-m min] [-h hrs] [-d dias] -p processo

EXEMPLOS:
 $SCRIPT_NAME 300 dtcalc
 $SCRIPT_NAME -m 5 -p dtcalc
"
}

trap_exit() {
  TIMESTAMP=$(date +%D@%T)
  print "INTERRUPÇÃO RECEBIDA — SAINDO..." > $TTY
  print "MON_STOPPED: $PROCESS ==> $TIMESTAMP" | tee -a $LOGFILE
  BREAK='Y'
  print -p "$BREAK" 2>/dev/null
  exit 2
}

pre_event_script() { :; return 0; }
startup_event_script() { :; return 0; }
post_event_script() { :; return 0; }

####################################################
############# MONITOR (CO-PROCESSO) ################
####################################################
proc_watch() {
  while :
  do
    read BREAK
    [[ "$BREAK" = 'Y' ]] && return 0

    PROC_COUNT=$(ps -ef | grep "$PROCESS" | grep -v grep | grep -v "$SCRIPT_NAME" | wc -l)

    if (( PROC_COUNT > 0 )) && [[ "$RUN" = 'N' ]]
    then
      RUN='Y'
      TIMESTAMP=$(date +%D@%T)
      print "START: $PROCESS ==> $TIMESTAMP" | tee -a $LOGFILE
      [[ "$RUN_STARTUP_EVENT" = 'Y' ]] && startup_event_script
    fi

    if (( PROC_COUNT == 0 )) && [[ "$RUN" = 'Y' ]]
    then
      RUN='N'
      TIMESTAMP=$(date +%D@%T)
      print "STOP: $PROCESS ==> $TIMESTAMP" | tee -a $LOGFILE
      [[ "$RUN_POST_EVENT" = 'Y' ]] && post_event_script
    fi

    sleep $INTERVAL
  done
}

####################################################
################# MAIN #############################
####################################################
trap trap_exit INT TERM HUP

PROCESS=""
TOTAL_SECONDS=0

if (( $# == 2 )) && [[ $1 != -* ]]
then
  TOTAL_SECONDS=$1
  PROCESS=$2
else
  while getopts ":s:m:h:d:p:" opt
  do
    case $opt in
      s) (( TOTAL_SECONDS += OPTARG )) ;;
      m) (( TOTAL_SECONDS += OPTARG * 60 )) ;;
      h) (( TOTAL_SECONDS += OPTARG * 3600 )) ;;
      d) (( TOTAL_SECONDS += OPTARG * 86400 )) ;;
      p) PROCESS=$OPTARG ;;
      *) usage; exit 1 ;;
    esac
  done
fi

[[ -z "$PROCESS" || $TOTAL_SECONDS -le 0 ]] && usage && exit 1

####################################################
########### INÍCIO DO MONITORAMENTO ################
####################################################
TIMESTAMP=$(date +%D@%T)
print "MON_STARTED: $PROCESS ==> $TIMESTAMP" | tee -a $LOGFILE

proc_watch |&
WATCH_PID=$!

SECONDS_LEFT=$TOTAL_SECONDS
while (( SECONDS_LEFT > 0 ))
do
  sleep 1
  (( SECONDS_LEFT-- ))
done

BREAK='Y'
print -p "$BREAK" 2>/dev/null
kill $WATCH_PID 2>/dev/null

TIMESTAMP=$(date +%D@%T)
print "MON_STOPPED: $PROCESS ==> $TIMESTAMP" | tee -a $LOGFILE
exit 0
