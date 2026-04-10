#!/bin/ksh
# SCRIPT: Oracle_rsync.ksh
# AUTHOR: Zainer Araujo
# DATE: 01/20/2025
# REV: 1.1
# PURPOSE: Replicar base Oracle para DR via rsync
# NOTA: Banco deve estar em modo backup

########################################
# DEFINIÇÃO DE VARIÁVEIS
########################################
ORACLE_HOME=/u01/app/oracle/product/10.2.0
ORACLE_SID=PROD
ORACLE_BASE=/u01/app/oracle
DATA_DIR=/u01/oradata
ARCH_DIR=/u01/arch

DEST_HOST=backupdb
DEST_DIR=/u02/oracle_backup/${ORACLE_SID}

RSYNC=/usr/bin/rsync
LOGFILE=/var/log/oracle_rsync.log
LOCKFILE=/var/run/oracle_rsync.lock

export ORACLE_HOME ORACLE_SID ORACLE_BASE

########################################
# VALIDAÇÕES INICIAIS
########################################

# Garantir execução como oracle
if [ "$(id -un)" != "oracle" ]
then
   echo "ERROR: Must run as oracle user" >> $LOGFILE
   exit 1
fi

# Lock para evitar execução concorrente
if [ -f "$LOCKFILE" ]
then
   echo "ERROR: Script already running" >> $LOGFILE
   exit 2
fi
touch "$LOCKFILE"
trap 'rm -f "$LOCKFILE"' EXIT

# Testar conectividade
ping -c1 "$DEST_HOST" >/dev/null 2>&1 || {
   echo "ERROR: Destination host unreachable" >> $LOGFILE
   exit 3
}

########################################
# MAIN
########################################
{
   echo "=== Oracle rsync started: $(date '+%Y-%m-%d %H:%M:%S') ==="

   $RSYNC -av \
      "$DATA_DIR/" \
      "$ARCH_DIR/" \
      oracle@"$DEST_HOST":"$DEST_DIR"/

   RC=$?
   if (( RC != 0 ))
   then
      echo "ERROR: rsync failed with RC=$RC"
      exit 4
   fi

   echo "=== Oracle rsync completed: $(date '+%Y-%m-%d %H:%M:%S') ==="
} >> "$LOGFILE" 2>&1

exit 0
