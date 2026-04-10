#!/usr/bin/ksh
#
# SCRIPT: proc_mon.ksh
# AUTOR: Zainer Araujo
# DATA: 14/02/2024
# REV: 1.2.P
# PLATAFORMA: Não dependente de plataforma
#
# OBJETIVO:
#   Monitorar o término de um processo.
#
#   - Modo normal: monitora o processo informado
#   - Modo verbose (-v): exibe informações do ps durante a execução
#
# USO:
#   proc_mon.ksh [-v] processo_a_monitorar
#
# CÓDIGOS DE SAÍDA:
#   0 ==> O processo monitorado foi encerrado
#   1 ==> Erro de uso do script
#   3 ==> Saída por sinal
#
# set -x   # Depuração
# set -n   # Verifica sintaxe sem executar
########################################################

SCRIPT_NAME=$(basename "$0")

########################################################
# FUNÇÕES
########################################################
usage() {
   echo
   echo "USO: $SCRIPT_NAME [-v] processo_a_monitorar"
   echo
   echo "EXEMPLOS:"
   echo "  $SCRIPT_NAME my_backup"
   echo "  $SCRIPT_NAME -v my_backup"
   echo
   echo "SAINDO..."
   echo
}

exit_trap() {
   echo
   echo "...SAINDO devido a um sinal interceptado..."
   echo
}

########################################################
# TRAPS
########################################################
trap 'exit_trap; exit 3' 1 2 3 15

########################################################
# VALIDAÇÃO DE ARGUMENTOS
########################################################
VERBOSE=0

case $# in
   1)
      if [ "$1" = "-v" ]; then
         usage
         exit 1
      fi
      PROCESS="$1"
      ;;
   2)
      if [ "$1" = "-v" ]; then
         VERBOSE=1
         PROCESS="$2"
      else
         usage
         exit 1
      fi
      ;;
   *)
      usage
      exit 1
      ;;
esac

########################################################
# VERIFICA SE O PROCESSO EXISTE
########################################################
ps aux | grep "$PROCESS" | grep -v grep | grep -v "$SCRIPT_NAME" >/dev/null 2>&1
RC=$?

if (( RC != 0 )); then
   echo
   echo "$PROCESS NÃO é um processo ativo... SAINDO..."
   echo

   if (( VERBOSE == 1 )); then
      echo "Modo verbose ativado:"
      ps aux | head -n 1
      ps aux | grep "$PROCESS" | grep -v grep | grep -v "$SCRIPT_NAME"
   fi

   exit 1
fi

########################################################
# PROCESSO ATIVO — INICIAR MONITORAMENTO
########################################################
SLEEP_TIME=1

echo
echo "$PROCESS está em execução no momento... $(date)"
echo

while :   # loop infinito até o processo terminar
do
   ps aux | grep "$PROCESS" | grep -v grep | grep -v "$SCRIPT_NAME" >/dev/null 2>&1
   RC=$?

   if (( RC != 0 )); then
      echo
      echo "...$PROCESS foi FINALIZADO... $(date)"
      echo
      exit 0
   fi

   if (( VERBOSE == 1 )); then
      ps aux | head -n 1
      ps aux | grep "$PROCESS" | grep -v grep | grep -v "$SCRIPT_NAME"
      echo "--------------------------------------------"
   fi

   sleep $SLEEP_TIME
done

# FIM DO SCRIPT
