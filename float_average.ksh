#!/usr/bin/ksh
#
# SCRIPT: float_average.ksh
# AUTHOR: Zainer Araujo
# DATE: 03/01/2026
# REV: 1.2
#
# PURPOSE:
#   Calcula a média de uma lista de números inteiros
#   ou de ponto flutuante.
#
# EXIT STATUS:
#   0 => Execução normal
#   1 => Erro de uso
#   2 => Saída por sinal (trap)
#

########################################################
# VARIÁVEIS
########################################################
SCRIPT_NAME=$(basename "$0")
SCALE=0
NUM_LIST=""
TOTAL_TOKENS=0

########################################################
# FUNÇÕES
########################################################
usage() {
  print "
PROPÓSITO:
  Calcula a média de uma lista de números

USO:
  $SCRIPT_NAME [-s escala] N1 N2 ... Nn

EXEMPLOS:
  $SCRIPT_NAME 10 20 30
  $SCRIPT_NAME -s 4 8.09838 2048 65536 42.632
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
  print "\nERRO: Poucos argumentos para calcular a média\n"
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
    print "\nERRO: Escala inválida ($SCALE). Deve ser um inteiro\n"
    usage
    exit 1
    ;;
esac

########################################################
# VALIDAR LISTA DE NÚMEROS
########################################################
TOTAL_TOKENS=$#
NUM_LIST="$*"

for NUM in $NUM_LIST
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
# CONSTRUIR EXPRESSÃO DE SOMA
########################################################
ADD=""
PLUS=""

for X in $NUM_LIST
do
  # Remover prefixo +
  [[ ${X#?} != "$X" && ${X%${X#?}} = "+" ]] && X=${X#?}

  ADD="$ADD $PLUS $X"
  PLUS="+"
done

########################################################
# CALCULAR MÉDIA
########################################################
AVERAGE=$(bc <<EOF
scale=$SCALE
($ADD) / $TOTAL_TOKENS
EOF
)

########################################################
# SAÍDA
########################################################
print "\nMédia de:"
print "  $NUM_LIST"
print "\nCom escala $SCALE é:"
print "  $AVERAGE\n"

exit 0
