#!/bin/ksh
#
# SCRIPT: proc_watch.ksh
# AUTOR: Zainer Araujo
# DATA: 12/09/2024
# REV: 1.1.P
#
# OBJETIVO:
#   Monitorar e registrar quando um processo INICIA e FINALIZA
#
####################################################

LOGFILE="/tmp/proc_status.log"
SCRIPT_NAME=$(basename "$0")
PROCESS="$1"
TTY=$(tty)

[[ ! -f $LOGFILE ]] && touch "$LOGFILE"

####################################################
# FUNÇÕES
####################################################
usage() {
   echo
   echo "USO: $SCRIPT_NAME processo_a_monitorar"
   echo
}

trap_exit() {
   TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
   echo "MON_STOP: Monitoramento de $PROCESS encerrado ==> $TIMESTAMP" \
      | tee -a "$LOGFILE"
   exit 0
}

####################################################
# Aguarda processo FINALIZAR
####################################################
mon_proc_end() {
   while ps aux | grep "$PROCESS" | grep -v grep | grep -v "$SCRIPT_NAME" >/dev/null 2>&1
   do
      sleep 1
   done

   TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
   echo "END PROCESS: $PROCESS terminou ==> $TIMESTAMP" | tee -a "$LOGFILE" > "$TTY"
   print N
}

####################################################
# Aguarda processo INICIAR
####################################################
mon_proc_start() {
   until ps aux | grep "$PROCESS" | grep -v grep | grep -v "$SCRIPT_NAME" >/dev/null 2>&1
   do
      sleep 1
   done

   TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
   echo "START PROCESS: $PROCESS iniciou ==> $TIMESTAMP" | tee -a "$LOGFILE" > "$TTY"
   print Y
}

####################################################
# MAIN
####################################################
trap 'trap_exit' 1 2 3 15

if (( $# != 1 )); then
   usage
   exit 1
fi

# Estado inicial
if ps aux | grep "$PROCESS" | grep -v grep | grep -v "$SCRIPT_NAME" >/dev/null 2>&1
then
   RUN="Y"
   echo "O processo $PROCESS está em execução... Monitorando..."
else
   RUN="N"
   echo "O processo $PROCESS não está em execução... Monitorando..."
fi

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
echo "MON_START: Monitoramento de $PROCESS iniciado ==> $TIMESTAMP" \
   | tee -a "$LOGFILE"

# Loop infinito
while :
do
   case "$RUN" in
      Y) RUN=$(mon_proc_end) ;;
      N) RUN=$(mon_proc_start) ;;
   esac
done

# FIM
