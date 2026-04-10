#!/bin/ksh
#
# AUTHOR: Zainer Araujo
# SCRIPT: random_number.ksh
# DATE: 11/12/2024
# REV: 1.3.P
#
# PLATFORM: Not Platform Dependent
#
# EXIT CODES:
# 0 - Execução normal
# 1 - Erro de uso
#
# set -x   # Depuração
# set -n   # Verificar sintaxe sem executar
#
####################################################
########## DEFINIR FUNÇÕES AQUI ####################
####################################################

usage ()
{
  echo "\nUSO: $SCRIPT_NAME [-f] [upper_number_range]"
  echo "\nEXEMPLO: $SCRIPT_NAME"
  echo "Retorna um número aleatório entre 0 e 32767"
  echo "\nEXEMPLO: $SCRIPT_NAME 1000"
  echo "Retorna um número aleatório entre 1 e 1000"
  echo "\nEXEMPLO: $SCRIPT_NAME -f 1000"
  echo "Retorna um número aleatório de 1 a 1000"
  echo "com zeros à esquerda, mantendo o tamanho fixo\n"
}

####################################################
get_random_number ()
{
  # Retorna número pseudoaleatório (0–32767)
  print "$RANDOM"
}

####################################################
in_range_random_number ()
{
  integer RANDOM_NUMBER
  RANDOM_NUMBER=$(( RANDOM % UPPER_LIMIT + 1 ))
  print "$RANDOM_NUMBER"
}

####################################################
in_range_fixed_length_random_number_typeset ()
{
  integer RANDOM_NUMBER
  integer UL_LENGTH

  UL_LENGTH=${#UPPER_LIMIT}

  # Força preenchimento com zeros à esquerda
  typeset -Z$UL_LENGTH RANDOM_NUMBER

  RANDOM_NUMBER=$(( RANDOM % UPPER_LIMIT + 1 ))

  print "$RANDOM_NUMBER"
}

####################################################
############## INÍCIO DO MAIN ######################
####################################################

SCRIPT_NAME=$(basename "$0")

# Inicializa RANDOM com PID (semente)
RANDOM=$$

case $# in
   0)
      get_random_number
      ;;
   1)
      UPPER_LIMIT="$1"

      case $UPPER_LIMIT in
         +([0-9])) : ;;
         *)
            echo "\nERRO: '$UPPER_LIMIT' não é um número."
            usage
            exit 1
            ;;
      esac

      in_range_random_number
      ;;
   2)
      if [[ "$1" = "-f" || "$1" = "-F" ]]
      then
         UPPER_LIMIT="$2"

         case $UPPER_LIMIT in
            +([0-9])) : ;;
            *)
               echo "\nERRO: '$UPPER_LIMIT' não é um número."
               usage
               exit 1
               ;;
         esac

         in_range_fixed_length_random_number_typeset
      else
         echo "\nERRO: opção inválida '$1'"
         usage
         exit 1
      fi
      ;;
   *)
      usage
      exit 1
      ;;
esac

exit 0
# Fim do script
