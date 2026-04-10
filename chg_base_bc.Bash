#!/bin/bash
#
# SCRIPT: chg_base_bc.Bash
# AUTHOR: Zainer Araujo
# DATE: 10/4/2025
# REV: 1.1.A
#
# PURPOSE: Este script converte números entre as bases
#          2 e 16 utilizando o utilitário bc. O usuário
#          é solicitado a fornecer o número.
#
# NOTE: Números devem ser informados no formato:
#
#       base#número
#
# EXAMPLE: 16#264bf
#
##########################################
# DEFINE FILES AND VARIABLES HERE
##########################################
# Configura o uso correto do awk. No Solaris,
# é necessário usar *nawk* em vez de *awk*.
case $(uname) in
  SunOS) AWK="nawk"
  ;;
  *)     AWK="awk"
  ;;
esac

##########################################
# BEGINNING OF MAIN
##########################################
# Solicita ao usuário um número de entrada com base
echo -e "\nInput the number to convert in the following format:
 Format: base#number
 Example: 16#264BF \n"

read IBASE_NUM
# Extrai a base e o número da variável IBASE_NUM
IBASE=$(echo $IBASE_NUM | $AWK -F '#' '{print $1}')
INUMBER=$(echo $IBASE_NUM | $AWK -F '#' '{print $2}')

# Testa para garantir que a base de entrada está entre 2 e 16
if (( IBASE < 2 || IBASE > 16 ))
then
  echo -e "\nERROR: A base de entrada deve estar entre 2 e 16\n"
  exit 1
fi

# O utilitário bc exige que todas as bases maiores que 10
# utilizem letras maiúsculas para dígitos não numéricos (A–F, etc.)
# Usamos o comando tr para converter caracteres minúsculos.
if (( IBASE > 10 ))
then
  INUMBER=$(echo $INUMBER | tr '[a-z]' '[A-Z]')
fi

# Solicita ao usuário a base de saída
echo -e "\nPara qual base você deseja converter $IBASE_NUM?
NOTE: bases de 2 a 16 são válidas\n"
echo -e "Output base: \c"
read OBASE

# Testa se a base de saída é um número inteiro
case $OBASE in
  [0-9]*) : # não faz nada
  ;;
  *) echo -e "\nERROR: $OBASE não é um número válido\n"
     exit 1
  ;;
esac







# Testa se a base de saída está entre 2 e 16
if (( OBASE < 2 || OBASE > 16 ))
then
  echo -e "\nERROR: A base de saída deve estar entre 2 e 16\n"
  exit 1
fi
# Salva o número de entrada antes de alterar a base
IN_BASE_NUM=$IBASE_NUM

# Converte o número de entrada para decimal
if (( IBASE != 10 ))
then
  DEC_EQUIV=$(echo "ibase=$IBASE; $INUMBER" | bc)
fi

# Converte o número decimal para a base de saída desejada
RESULT=$(echo "obase=$OBASE; $DEC_EQUIV" | bc)

# Exibe o resultado
echo -e "\nInput number $IN_BASE_NUM é equivalente a \
${OBASE}#${RESULT}\n"
