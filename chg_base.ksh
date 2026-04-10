#!/usr/bin/ksh
#
# SCRIPT: chg_base.ksh
# PURPOSE: Converte números entre bases 2 e 36
# USO: ./chg_base.ksh
# Entrada interativa: base#number, por exemplo 16#264BF
# Saída: número convertido na base desejada
#################################################

# Configurar awk para Solaris
case $(uname) in
  SunOS) AWK="nawk" ;;
  *)     AWK="awk" ;;
esac

# Solicita o número ao usuário
printf "\nInforme o número no formato base#number (ex: 16#264BF): "
read ibase_num

# Extrai a base e o número
ibase=$(echo $ibase_num | $AWK -F '#' '{print $1}')
num=$(echo $ibase_num | $AWK -F '#' '{print $2}')

# Valida a base de entrada
case $ibase in
  [0-9]*) ;;
  *) echo "\nERRO: Base de entrada inválida"; exit 1 ;;
esac
if ((ibase < 2 || ibase > 36)); then
  echo "\nERRO: Base de entrada deve estar entre 2 e 36"; exit 1
fi

# Pergunta a base de saída
printf "Para qual base deseja converter $ibase_num? (2-36): "
read obase

# Valida a base de saída
case $obase in
  [0-9]*) ;;
  *) echo "\nERRO: Base de saída inválida"; exit 1 ;;
esac
if ((obase < 2 || obase > 36)); then
  echo "\nERRO: Base de saída deve estar entre 2 e 36"; exit 1
fi

# Converte usando bc
result=$(echo "ibase=$ibase; obase=$obase; $num" | bc)

# Exibe resultado
echo "\nO número $ibase_num na base $obase é: $result\n"
