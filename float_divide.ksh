#!/usr/bin/ksh
#
# SCRIPT: float_divide.ksh
# AUTHOR: Zainer Araujo
# DATE: 23/02/2025
# REV: 1.2
#
# PROPÓSITO:
#   Divide dois números inteiros ou de ponto flutuante.
#   Permite definir escala (-s) para casas decimais.
#

########################################################
# VARIÁVEIS
########################################################
SCRIPT_NAME=$(basename "$0")
SCALE=0
DIVIDEND=""
DIVISOR=""

########################################################
# FUNÇÕES
########################################################
usage() {
  print "
PROPÓSITO:
  Divide dois números

USO:
  $SCRIPT_NAME [-s escala] N1 N2

EXEMPLOS:
  $SCRIPT_NAME 2048 32
  $SCRIPT_NAME -s 4 2048.221 65536
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
[[ $# -lt 2 || $# -gt 4 ]] && {
  print "\nERRO: Número inválido de argumentos\n"
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
# VALIDAR QUANTIDADE DE NÚMEROS
########################################################
[[ $# -ne 2 ]] && {
  print "\nERRO: É necessário fornecer exatamente dois números\n"
  usage
  exit 1
}

DIVIDEND="$1"
DIVISOR="$2"

########################################################
# VALIDAR NÚMEROS
########################################################
for NUM in "$DIVIDEND" "$DIVISOR"
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
# PROTEÇÃO CONTRA DIVISÃO POR ZERO
########################################################
if [[ $(echo "$DIVISOR == 0" | bc) -eq 1 ]]
then
  print "\nERRO: Divisão por zero não é permitida\n"
  exit 1
fi

########################################################
# CALCULAR QUOCIENTE
########################################################
QUOTIENT=$(bc <<EOF
scale=$SCALE
$DIVIDEND / $DIVISOR
EOF
)

########################################################
# SAÍDA
########################################################
print "\nO quociente de:"
print "  $DIVIDEND / $DIVISOR"
print "\nCom escala $SCALE é:"
print "  $QUOTIENT\n"

exit 0
