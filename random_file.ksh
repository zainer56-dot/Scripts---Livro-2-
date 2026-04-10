#!/bin/ksh

THIS_SCRIPT=$(basename "$0")

CHAR_FILE="./char_file.txt"
OUTFILE="./random.out"
MB_SIZE="$1"

typeset -a KEYS
typeset X=0
typeset i=1

#--------------------------------------
load_default_keyboard() {
    for CHAR in 1 2 3 4 5 6 7 8 9 0 \
        q w e r t y u i o p a s d f g h j k l \
        z x c v b n m \
        Q W E R T Y U I O P A S D F G H J K L \
        Z X C V B N M
    do
        print "$CHAR" >> "$CHAR_FILE"
    done
}

usage() {
    printf "\nUSAGE: %s Mb_size\n" "$THIS_SCRIPT"
    printf "Where Mb_size is the size of the file to build\n\n"
}

#--------------------------------------
# Início do programa principal

[[ $# -ne 1 ]] && { usage; exit 1; }

# Validar número inteiro positivo
case "$MB_SIZE" in
    +([0-9])) ;;
    *) usage; exit 1 ;;
esac

# Verificar CHAR_FILE
if [[ ! -s "$CHAR_FILE" ]]; then
    printf "\nNOTE: %s não existe\n" "$CHAR_FILE"
    print "Carregando dados padrão do teclado."
    print "Criando $CHAR_FILE..."
    > "$CHAR_FILE"
    load_default_keyboard
    print "Concluído"
fi

#--------------------------------------
# Carregar array
print "\nCarregando array com elementos alfanuméricos"
while read -r ARRAY_ELEMENT
do
    (( X += 1 ))
    KEYS[X]="$ARRAY_ELEMENT"
done < "$CHAR_FILE"

print "Total de elementos no array: $X"

#--------------------------------------
# Gerar semente aleatória
print "Consultando /dev/random para obter semente"
RN=$(dd if=/dev/random count=1 2>/dev/null | od -An -tu4 | head -1)

RN=$(( RN % 32767 + 1 ))
RANDOM=$RN

#--------------------------------------
# Função auxiliar
build_random_line() {
    print -n "${KEYS[RANDOM % X + 1]}"
}

#--------------------------------------
print "Construindo arquivo de $MB_SIZE MB ==> $OUTFILE"
print "Isso pode levar algum tempo..."

SECONDS=0
TOT_LINES=$(( MB_SIZE * 12800 ))

> "$OUTFILE"

until (( i > TOT_LINES ))
do
    build_random_line >> "$OUTFILE"
    (( i % 100 == 0 )) && printf "."
    (( i += 1 ))
done

print "\nArquivo concluído em $SECONDS segundos."
