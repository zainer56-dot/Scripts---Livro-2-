#!/usr/bin/ksh
#
# SCRIPT: findlarge.ksh
#
# AUTOR: Zainer Araujo
#
# DATA: 30/11/2024
#
# REV: 1.1.A
#
# OBJETIVO:
#   Este script procura arquivos maiores que um tamanho
#   especificado em Megabytes, iniciando no diretório
#   atual (pwd) e incluindo todos os subdiretórios.
#
#   A saída é exibida ao usuário e também armazenada
#   em um arquivo para revisão posterior.
#
# set -x   # Descomente para depuração
############################################

############################################
# Função usage
############################################
usage() {
   echo "\n***************************************"
   echo "\nUSO:"
   echo "  findlarge.ksh <Número_de_Megabytes>"
   echo "\nEXEMPLO:"
   echo "  findlarge.ksh 5"
   echo "\nIrá encontrar arquivos maiores que 5 MB"
   echo "no diretório atual e abaixo dele."
   echo "\nSAINDO...\n"
   echo "***************************************"
   exit 1
}

############################################
# Função cleanup
############################################
cleanup() {
   echo "\n********************************************************"
   echo "\nSAINDO DEVIDO A UM SINAL INTERCEPTADO..."
   echo "\n********************************************************\n"
   exit 2
}

############################################
# Trap de sinais
# (não é possível interceptar kill -9)
############################################
trap cleanup 1 2 3 15

############################################
# Validação de argumentos
############################################
if [ $# -ne 1 ]; then
   usage
fi

# Verifica se o argumento é um inteiro >= 1
if ! echo "$1" | grep -q '^[0-9][0-9]*$' || [ "$1" -lt 1 ]; then
   usage
fi

############################################
# Variáveis
############################################
THISHOST=$(hostname)
DATESTAMP=$(date +"%b %d %Y %H:%M:%S")
SEARCH_PATH=$(pwd)
MEG_BYTES=$1

DATAFILE="/tmp/filesize_datafile.out"
OUTFILE="/tmp/largefiles.out"
HOLDFILE="/tmp/temp_hold_file.out"

# Inicializa arquivos
> "$DATAFILE"
> "$OUTFILE"
> "$HOLDFILE"

############################################
# Cabeçalho de saída
############################################
echo "\nProcurando arquivos maiores que ${MEG_BYTES} MB iniciando em:"
echo "==> $SEARCH_PATH"
echo "\nPor favor, aguarde...\n"

{
   echo "Resultados da busca por arquivos grandes"
   echo "--------------------------------------"
   echo "Hostname              : $THISHOST"
   echo "Diretório de busca    : $SEARCH_PATH"
   echo "Data/Hora da busca    : $DATESTAMP"
   echo
   echo "Resultados ordenados por data (mais recentes primeiro):"
   echo
} >> "$OUTFILE"

############################################
# Busca por arquivos maiores que X MB
# 1 MB = 1.048.576 bytes
############################################
find "$SEARCH_PATH" -type f -size +"${MEG_BYTES}"M -print > "$HOLDFILE" 2>/dev/null

############################################
# Processamento dos resultados
############################################
if [ -s "$HOLDFILE" ]; then
   NUMBER_OF_FILES=$(wc -l < "$HOLDFILE")

   echo "\nNúmero de arquivos encontrados: $NUMBER_OF_FILES\n" >> "$OUTFILE"

   # Lista arquivos ordenados por data
   xargs ls -lt < "$HOLDFILE" >> "$OUTFILE" 2>/dev/null

   # Exibe ao usuário
   more "$OUTFILE"

   echo "\nResultados armazenados em: $OUTFILE"
   echo "\nBusca concluída... SAINDO...\n"
else
   echo "\nNenhum arquivo maior que ${MEG_BYTES} MB foi encontrado."
   echo "\nSAINDO...\n"
fi

exit 0
