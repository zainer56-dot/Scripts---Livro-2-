#!/usr/bin/ksh
#
# SCRIPT: mk_swkey.ksh
# AUTHOR: Zainer Araujo
# DATE: 07/07/2025
# REV: 1.3.P
#
# PURPOSE:
# Cria uma chave de licença baseada no endereço IP local.
# Cada octeto do IP é convertido para hexadecimal e
# concatenado em uma única string.
#

#################################################
# DEFINIÇÃO DE VARIÁVEIS
#################################################

case $(uname) in
  SunOS) AWK="nawk" ;;
  *)     AWK="awk"  ;;
esac

#################################################
# FUNÇÕES
#################################################

# Converte número decimal (0–255) para hexadecimal (sem 0x)
convert_base_10_to_16()
{
  typeset DEC="$1"

  # Validação básica
  case $DEC in
    +([0-9])) ;;
    *) return 1 ;;
  esac

  printf "%02X" "$DEC"
}

#################################################
# MAIN
#################################################

# Obtém o IP da máquina (primeiro IP não-loopback)
IP=$(ifconfig 2>/dev/null | $AWK '
  /inet / && $2 != "127.0.0.1" {
    gsub("addr:", "", $2)
    print $2
    exit
  }')

# Se falhar, tenta hostname -i
if [ -z "$IP" ]; then
  IP=$(hostname -i 2>/dev/null | $AWK '{print $1}')
fi

# Valida IP
if [ -z "$IP" ]; then
  print "ERRO: Não foi possível obter o endereço IP"
  exit 1
fi

# Quebra o IP em octetos
IFS=.
set -- $IP
unset IFS

if [ $# -ne 4 ]; then
  print "ERRO: IP inválido: $IP"
  exit 1
fi

# Converte cada octeto
FIRST=$(convert_base_10_to_16 "$1")
SECOND=$(convert_base_10_to_16 "$2")
THIRD=$(convert_base_10_to_16 "$3")
FOURTH=$(convert_base_10_to_16 "$4")

# Gera a chave
SW_KEY="${FIRST}${SECOND}${THIRD}${FOURTH}"

print "IP detectado : $IP"
print "Chave gerada : $SW_KEY"
