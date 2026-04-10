#!/bin/ksh
# SCRIPT: rsync_daily_copy.ksh
# AUTHOR: Zainer Araujo
# DATE: 11/10/2024
# REV: 3.3.Prod
# PURPOSE:
#   Replica arquivos Oracle (.dbf) entre o servidor master
#   e servidores Oracle OLTP usando rsync.
#
#   IMPORTANTE:
#   - Os tablespaces DEVEM estar em modo READ-ONLY
#   - Este script é usado em ambiente controlado
#   - Execução concorrente NÃO é permitida
##############################################

##############################################
# DEFINIÇÕES GLOBAIS E VARIÁVEIS
##############################################

typeset -i DAY

EMAIL_FROM="data_support@gamma"

export PATH=$PATH:/usr/local/bin
WORK_DIR=/usr/local/bin
LOGFILE=${WORK_DIR}/rsync_daily_copy.log
MAILMESSAGEFILE=${WORK_DIR}/email_message.out

SEARCH_DIR=/orabin/apps/oracle/dbadm/general/bin
READYTORUN_FILE=${SEARCH_DIR}/readytocopy.txt
COMPLETE_FILE=${SEARCH_DIR}/copycomplete.txt
RSYNCFAILED_FILE=${SEARCH_DIR}/copyfailed.txt

THIS_SCRIPT=$(basename "$0")
THIS_HOST=$(hostname)
START_TIME=$(date +%s)

LOCKFILE=/var/run/rsync_daily_copy.lock

##############################################
# CONFIGURAÇÃO CONDICIONAL POR HOST
##############################################
case "$THIS_HOST" in
   gamma|gamma-dg)
      MACHINE_LIST="alpha-rsync bravo-rsync"
      ;;
   *)
      MACHINE_LIST=""
      ;;
esac

##############################################
# AJUSTE DO echo PARA COMPATIBILIDADE
##############################################
case "$SHELL" in
   */bash) alias echo="echo -e" ;;
esac

##############################################
# FUNÇÕES
##############################################

usage ()
{
   echo "\nUSAGE: $THIS_SCRIPT"
   echo "This script waits for readytocopy.txt containing value 1 or 2\n"
}

cleanup_exit ()
{
   EXIT_CODE=${1:-1}

   echo "\n$THIS_SCRIPT exiting with code $EXIT_CODE"
   echo "Performing cleanup..."

   rm -f "$READYTORUN_FILE" "$COMPLETE_FILE" >/dev/null 2>&1

   echo "Rsync failed on $THIS_HOST at $(date)" \
      | tee -a "$RSYNCFAILED_FILE"

   rm -f "$LOCKFILE"
   exit "$EXIT_CODE"
}

ready_to_run ()
{
   if [ ! -f "$READYTORUN_FILE" ]
   then
      echo "NOT_READY"
   else
      cat "$READYTORUN_FILE"
   fi
}

elapsed_time ()
{
   SEC=$1
   if (( SEC < 60 ))
   then
      echo "[Elapsed time: ${SEC} sec]"
   elif (( SEC < 3600 ))
   then
      echo "[Elapsed time: $((SEC/60)) min $((SEC%60)) sec]"
   else
      echo "[Elapsed time: $((SEC/3600)) hr $(((SEC%3600)/60)) min $((SEC%60)) sec]"
   fi
}

##############################################
# TRAPS E LOCK
##############################################
trap 'cleanup_exit 99' 1 2 3 5 6 11 14 15

if [ -f "$LOCKFILE" ]
then
   echo "ERROR: Script already running"
   exit 8
fi

echo $$ > "$LOCKFILE"
trap 'rm -f "$LOCKFILE"' EXIT

##############################################
# INÍCIO DO MAIN
##############################################

# Backup do log anterior
cp -f "$LOGFILE" "${LOGFILE}.yesterday" 2>/dev/null
> "$LOGFILE"

{
echo "\n[[ $THIS_SCRIPT started on $(date) ]]"

##############################################
# VERIFICAÇÃO DE MÁQUINAS DESTINO
##############################################
if [ -z "$MACHINE_LIST" ]
then
   echo "ERROR: No target machines defined"
   cleanup_exit 4
fi

##############################################
# TESTE DE CONECTIVIDADE
##############################################
echo "\nTesting connectivity to target machines..."

for MACH in $MACHINE_LIST
do
   echo "Pinging $MACH..."
   ping -c1 "$MACH" >/dev/null 2>&1 || cleanup_exit 5
done

##############################################
# LIMPEZA DE ARQUIVOS DE STATUS
##############################################
rm -f "$COMPLETE_FILE" "$RSYNCFAILED_FILE" >/dev/null 2>&1

##############################################
# ESPERANDO O ARQUIVO ready_to_run
##############################################
echo "\nWaiting for $READYTORUN_FILE..."

RUN_STATUS=$(ready_to_run)
until [[ "$RUN_STATUS" != "NOT_READY" ]]
do
   echo "Not ready yet...sleeping 5 minutes"
   sleep 300
   RUN_STATUS=$(ready_to_run)
done

DAY=$RUN_STATUS

if (( DAY != 1 && DAY != 2 ))
then
   echo "ERROR: Invalid DAY value: $DAY"
   cleanup_exit 6
fi

echo "Proceeding with DAY=$DAY"

##############################################
# DEFINIÇÃO DE DIRETÓRIOS DE CÓPIA
##############################################
SOURCE_DIR=/oradata/PROD
TARGET_DIR=/oradata/PROD

##############################################
# EXECUÇÃO DO RSYNC
##############################################
for MACH in $MACHINE_LIST
do
   echo "\nStarting rsync to $MACH..."

   rsync -avz \
      "$SOURCE_DIR/" \
      "$MACH:$TARGET_DIR/"

   RC=$?
   if (( RC != 0 ))
   then
      echo "ERROR: rsync to $MACH failed (RC=$RC)"
      touch "$RSYNCFAILED_FILE"
   else
      echo "Rsync to $MACH completed successfully"
   fi
done

##############################################
# FINALIZAÇÃO
##############################################
END_TIME=$(date +%s)
ELAPSED=$(( END_TIME - START_TIME ))
elapsed_time "$ELAPSED"

touch "$COMPLETE_FILE"

echo "\n[[ $THIS_SCRIPT completed on $(date) ]]"

} 2>&1 | tee -a "$LOGFILE"

exit 0
