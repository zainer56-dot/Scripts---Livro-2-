#!/bin/bash
#
# SCRIPT: random_file.bash
# AUTHOR: Zainer Araujo
# DATE: 08/03/2024
# REV: 1.1
#
# PURPOSE:
# Criar um arquivo de tamanho específico
# preenchido com caracteres aleatórios.
#

##########################################
# VARIÁVEIS
##########################################
MB_SIZE="$1"
WORKDIR="/scripts"
OUTFILE="${WORKDIR}/largefile.random.txt"
CHAR_FILE="${WORKDIR}/char_file.txt"
THIS_SCRIPT=$(basename "$0")

declare -i RN
declare -i i=1
declare -i X=0

> "$OUTFILE"

##########################################
# FUNÇÕES
##########################################

usage() {
  printf "\nUSO: %s <tamanho_em_MB>\n\n" "$THIS_SCRIPT"
  exit 1
}

##########################################
build_random_line() {
  local C=1
  local LINE=""

  while (( C <= 79 ))
  do
    LINE+="${KEYS[RANDOM % X]}"
    (( C++ ))
  done

  printf "%s\n" "$LINE"
}

##########################################
elapsed_time() {
  local SEC=$1

  if (( SEC < 60 )); then
    printf "[Tempo decorrido: %d segundos]\n" "$SEC"
  elif (( SEC < 3600 )); then
    printf "[Tempo decorrido: %d min %d seg]\n" \
      $(( SEC / 60 )) $(( SEC % 60 ))
  else
    printf "[Tempo decorrido: %d h %d min %d seg]\n" \
      $(( SEC / 3600 )) \
      $(( (SEC % 3600) / 60 )) \
      $(( SEC % 60 ))
  fi
}

##########################################
load_default_keyboard() {
  > "$CHAR_FILE"
  for CHAR in \
    {a..z} {A..Z} {0..9}
  do
    printf "%s\n" "$CHAR" >> "$CHAR_FILE"
  done
}

##########################################
# MAIN
##########################################

# Validação de argumentos
[[ $# -ne 1 ]] && usage

# Testa se é número inteiro positivo
[[ "$MB_SIZE" =~ ^[0-9]+$ ]] || usage

# Cria CHAR_FILE se não existir
if [[ ! -s "$CHAR_FILE" ]]
then
  printf "\nNOTA: %s não existe\n" "$CHAR_FILE"
  printf "Criando arquivo padrão de caracteres...\n"
  load_default_keyboard
fi

# Carregar array de caracteres
printf "\nCarregando array de caracteres...\n"
while read -r CHAR
do
  KEYS[X++]="$CHAR"
done < "$CHAR_FILE"

printf "Total de caracteres no array: %d\n" "$X"

# Inicializa RANDOM com /dev/urandom
printf "Inicializando gerador pseudoaleatório...\n"
RN=$(od -An -N4 -tu4 < /dev/urandom | tr -d ' ')
RANDOM=$(( RN % 32767 + 1 ))

printf "\nCriando arquivo de %d MB em %s\n" "$MB_SIZE" "$OUTFILE"
printf "Por favor, aguarde...\n"

SECONDS=0

# Aproximação:
# 80 bytes por linha (79 chars + \n)
# 1 MB ≈ 1024 * 1024 bytes
LINES_PER_MB=$(( 1024 * 1024 / 80 ))
TOTAL_LINES=$(( MB_SIZE * LINES_PER_MB ))

while (( i <= TOTAL_LINES ))
do
  build_random_line >> "$OUTFILE"
  (( i % 500 == 0 )) && printf "."
  (( i++ ))
done

printf "\n\nArquivo criado com sucesso!\n"

TOTAL_SECONDS=$SECONDS
(( TOTAL_SECONDS == 0 )) && TOTAL_SECONDS=1

elapsed_time "$TOTAL_SECONDS"

BYTES_PER_SEC=$(( (MB_SIZE * 1024 * 1024) / TOTAL_SECONDS ))
printf "\nTaxa de criação: %d bytes/segundo\n\n" "$BYTES_PER_SEC"

ls -lh "$OUTFILE"
echo

##########################################
# FIM DO SCRIPT
##########################################
