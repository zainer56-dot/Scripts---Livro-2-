#!/bin/ksh
#
# SCRIPT: float_subtract.ksh
# AUTHOR: Zainer Araujo
# DATE: 02/12/2024
# REV: 1.2
#
# PROPÓSITO:
#   Subtrai uma lista de números inteiros ou de ponto flutuante.
#

########################################################
# VARIÁVEIS
########################################################
SCRIPT_NAME=$(basename "$0")
SCALE=0
NUM_LIST=""

########################################################
# FUNÇÕES
########################################################
usage() {
  print "
PROPÓSITO:
  Subtrai uma lista de números

USO:
  $SCRIPT_NAME [-s escala] N1 N2 ... Nn

EXEMPLOS:
  $SCRIPT_NAME 100 25 10
  $SCRIPT_NAME -s 3 50.5 12.25 3.1
"
}

exit_trap() {
  print "\n...SAINDO devido a sinal capturado...\n"
  exit 2
}

########################################################
# TRAP
########################################################
trap 'exit_trap' INT TERM HUP

########################################################
# VALIDAÇÃO INICIAL
########################################################
[[ $# -lt 2 ]] && {
  print "\nERRO: Forneça pelo menos dois números para subtrair\n"
  usage
  exit 1
}

########################################################
# PROCESSAR OPÇÕES
########################################################
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

########################################################
# VALIDAR ESCALA
########################################################
case $SCALE in
  +([0-9])) : ;;
  *)
    print "\nERRO: Escala inválida ($SCALE). Deve ser inteiro.\n"
    usage
    exit 1
    ;;
esac

########################################################
# VALIDAR NÚMEROS
########################################################
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

########################################################
# CONSTRUIR EXPRESSÃO DE SUBTRAÇÃO
########################################################
SUBTRACT=""
FIRST=1

for X in "$@"
do
  # Remove prefixo +
  X=${X#+}

  if (( FIRST ))
  then
    SUBTRACT="$X"
    FIRST=0
  else
    SUBTRACT="$SUBTRACT - $X"
  fi
done

########################################################
# CALCULAR DIFERENÇA
########################################################
DIFFERENCE=$(bc <<EOF
scale=$SCALE
$SUBTRACT
EOF
)

########################################################
# SAÍDA
########################################################
print "\nA diferença de:"
print "  $SUBTRACT"
print "\nÉ:"
print "  $DIFFERENCE\n"

exit 0
