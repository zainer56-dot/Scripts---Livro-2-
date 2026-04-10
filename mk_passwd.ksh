#!/usr/bin/ksh
#
# AUTOR: Zainer Araujo
# SCRIPT: mk_passwd.ksh
# REV: 2.6.P
#

############################################
# CONFIGURAÇÃO
############################################
LENGTH=8
KEYBOARD_FILE="/scripts/keyboard.keys"
OUTFILE="/tmp/password_manager.out"
SCRIPT=$(basename "$0")
DEFAULT_PRINTER="hp4@unixbr2000"
NOTIFICATION_LIST="Donald Duck, Unixbr2000 Bear, and Mr. Ranger"
PRINT_MANAGER_REPORT=FALSE

############################################
# FUNÇÕES
############################################
usage() {
  print "
USO: $SCRIPT [-n] [-m] [tamanho]

-n  Cria arquivo padrão de teclado
-m  Imprime relatório de senha do gerente
tamanho  Comprimento da senha (padrão: 8)
"
}

trap_exit() {
  [[ -s "$OUTFILE" ]] && rm -f "$OUTFILE"
  exit 2
}

random_index() {
  typeset rn
  rn=$(dd if=/dev/urandom bs=2 count=1 2>/dev/null | od -An -tu2)
  print $(( rn % UPPER_LIMIT + 1 ))
}

load_default_keyboard() {
  print "Criando arquivo padrão de teclado em $KEYBOARD_FILE"
  > "$KEYBOARD_FILE"

  for c in \
  1 2 3 4 5 6 7 8 9 0 \
  q w e r t y u i o p \
  a s d f g h j k l \
  z x c v b n m \
  Q W E R T Y U I O P \
  A S D F G H J K L \
  Z X C V B N M \
  '!' '@' '#' '$' '%' '^' '&' '*' '(' ')' '_' '+' '-' '='
  do
    print "$c" >> "$KEYBOARD_FILE"
  done
}

check_keyboard_file() {
  if [[ ! -s "$KEYBOARD_FILE" ]]; then
    print "Arquivo de teclado não encontrado."
    load_default_keyboard
  fi
}

build_manager_password_report() {
  {
    i=1
    while (( i <= 3 ))
    do
      print "USO RESTRITO!!!"
      print ""
      print "Envie imediatamente um e-mail para:"
      print "$NOTIFICATION_LIST"
      print ""
      print "Senha ROOT AIX: $PW"
      print "----------------------------------"
      (( i++ ))
    done
  } > "$OUTFILE"
}

############################################
# TRAP
############################################
trap 'trap_exit' INT TERM HUP

############################################
# PARSE ARGUMENTOS
############################################
while getopts ":nNmM" opt
do
  case $opt in
    n|N) load_default_keyboard ;;
    m|M) PRINT_MANAGER_REPORT=TRUE ;;
    *) usage; exit 1 ;;
  esac
done
shift $(( OPTIND - 1 ))

[[ $# -gt 1 ]] && { usage; exit 1; }

if [[ $# -eq 1 ]]; then
  case $1 in
    +([0-9])) LENGTH=$1 ;;
    *) usage; exit 1 ;;
  esac
fi

############################################
# MAIN
############################################
check_keyboard_file

# Carregar teclado no array
X=0
while read ch
do
  (( X++ ))
  KEYS[$X]="$ch"
done < "$KEYBOARD_FILE"

UPPER_LIMIT=$X

# Gerar senha
PW=""
i=0
while (( i < LENGTH ))
do
  idx=$(random_index)
  PW="${PW}${KEYS[$idx]}"
  (( i++ ))
done

print "\nSenha gerada ($LENGTH caracteres):"
print "$PW\n"

# Relatório do gerente
if [[ $PRINT_MANAGER_REPORT = TRUE ]]; then
  build_manager_password_report
  print "Enviar para impressora $DEFAULT_PRINTER? (Y/N): \c"
  read r
  [[ $r = Y ]] && lp -c -d "$DEFAULT_PRINTER" "$OUTFILE"
fi

# Limpeza
[[ -s "$OUTFILE" ]] && rm -f "$OUTFILE"
exit 0
