#!/usr/bin/ksh
#
# SCRIPT: float_add.ksh
# AUTHOR: Zainer Araujo
# DATE: 03/01/2024
# REV: 1.2
# PURPOSE: Soma uma lista de números inteiros ou de ponto flutuante
#

############################################
# CONFIGURAÇÃO
############################################
SCRIPT_NAME=$(basename "$0")
SCALE=0
NUM_LIST=""
COUNT=0

############################################
# FUNÇÕES
############################################
usage() {
  print "
PROPÓSITO:
  Soma uma lista de números inteiros ou ponto flutuante

USO:
  $SCRIPT_NAME [-s escala] N1 N2 ... Nn

EXEMPLOS:
  $SCRIPT_NAME 2048.221 65536
  $SCRIPT_NAME -s 4 8.09838 2048 65536 42.632

"
}

exit_trap() {
  print "\n...SAINDO devido a sinal capturado...\n"
  exit 2
}

############################################
# TRAP
############################################
trap 'exit_trap' INT TERM HUP

############################################
# VALIDAÇÃO INICIAL
############################################
[[ $# -lt 2 ]] && {
  print "\nERRO: Forneça pelo menos dois números\n"
  usage
  exit 1
}

############################################
# PROCESSAR OPÇÕES
############################################
while getopts ":s:S:" opt
do
  case $opt in
    s|S)
      SCALE="$OPTARG"
      ;;
    *)
      usage
      exit 1
      ;;
  esac
done
shift $((OPTIND - 1))

############################################
# VALIDAR ESCALA
############################################
case $SCALE in
  +([0-9])) : ;;
  *)
    print "\nERRO: Escala inválida ($SCALE). Deve ser inteiro.\n"
    usage
    exit 1
    ;;
esac

############################################
# VALIDAR NÚMEROS
############################################
for NUM in "$@"
do
  case $NUM in
    +([0-9]))            : ;;  # inteiro
    -+([0-9]))           : ;;  # inteiro negativo
    +([0-9]).+([0-9]))   : ;;  # float positivo
    -+([0-9]).+([0-9]))  : ;;  # float negativo
    .+([0-9]))           : ;;
    -. +([0-9]))         : ;;
    *)
      print "\nERRO: '$NUM' não é um número válido\n"
      usage
      exit 1
      ;;
  esac
done

############################################
# CONSTRUIR EXPRESSÃO
############################################
ADD=""
PLUS=""

for X in "$@"
do
  # Remove prefixo +
  [[ ${X#?} != "$X" && ${X%${X#?}} = "+" ]] && X=${X#+}

  ADD="${ADD}${PLUS}${X}"
  PLUS="+"
done

############################################
# CALCULAR SOMA
############################################
SUM=$(bc <<EOF
scale=$SCALE
$ADD
EOF
)

############################################
# SAÍDA
############################################
print "\nA soma de:"
print "  $ADD"
print "\nÉ:"
print "  $SUM\n"

exit 0
