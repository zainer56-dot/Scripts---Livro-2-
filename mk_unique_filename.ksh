#!/bin/ksh
#
# AUTOR: Zainer Araujo
# SCRIPT: mk_unique_filename.ksh
# DATA: 11/12/2024
# REV: 1.3.P
#
# OBJETIVO:
# Gerar um nome de arquivo único no formato:
# <base>.<MMDDYY.HHMMSS>.<random>
#
####################################################
########## DEFINIÇÃO DE FUNÇÕES ####################
####################################################

usage ()
{
  echo "\nUSO: $SCRIPT_NAME base_file_name\n"
  exit 1
}

####################################################
get_date_time_stamp ()
{
  date +'%m%d%y.%H%M%S'
}

####################################################
get_second ()
{
  date +%S
}

####################################################
in_range_fixed_length_random_number_typeset ()
{
  typeset -Z5 RANDOM_NUMBER   # 5 dígitos (0–32767)

  RANDOM_NUMBER=$(( RANDOM % UPPER_LIMIT + 1 ))
  print "$RANDOM_NUMBER"
}

####################################################
my_program ()
{
  # Exemplo de processamento
  print "HELLO WORLD - $DATE_ST" > "$UNIQUE_FN"
}

####################################################
################### MAIN ############################
####################################################

SCRIPT_NAME=$(basename "$0")

# Validação de argumentos
(( $# != 1 )) && usage

BASE_FN="$1"
RANDOM=$$                 # Semente inicial
UPPER_LIMIT=32767

LAST_SECOND=""
USED_NUMBERS=""

# Obter data/hora
DATE_ST=$(get_date_time_stamp)
CURRENT_SECOND=$(get_second)

# Novo segundo → limpar histórico
if [[ "$CURRENT_SECOND" != "$LAST_SECOND" ]]
then
  USED_NUMBERS=""
  LAST_SECOND="$CURRENT_SECOND"
fi

# Gerar número aleatório único dentro do mesmo segundo
while :
do
  RN=$(in_range_fixed_length_random_number_typeset)

  print "$USED_NUMBERS" | grep -w "$RN" >/dev/null 2>&1
  if (( $? != 0 ))
  then
    USED_NUMBERS="$USED_NUMBERS $RN"
    break
  fi
done

# Montar nome de arquivo único
UNIQUE_FN="${BASE_FN}.${DATE_ST}.${RN}"

# Executar processamento
my_program

# Informar resultado
print "Arquivo único criado:"
print "$UNIQUE_FN"

exit 0
