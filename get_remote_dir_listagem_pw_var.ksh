#!/bin/ksh
#
# SCRIPT: get_remote_dir_listagem_pw_var.ksh
# DATE: July 15, 2024
# PURPOSE: Obter listagem e arquivos via FTP usando senha externa

# =============================
# Configuração
# =============================
RNODE="wilma"
FTP_USER="ftpuser"
LOCALDIR="/scripts/download"
REMOTEDIR="/scripts"
THISSCRIPT=$(basename "$0")

DIRLISTFILE="${LOCALDIR}/${RNODE}.$(basename "$REMOTEDIR").dirlist.out"

# =============================
# Funções auxiliares
# =============================
usage() {
    printf "\nUSAGE: %s \"arquivo1 [arquivo2 ...]\"\n\n" "$THISSCRIPT"
    exit 1
}

usage_error() {
    printf "\nERROR: É necessário informar ao menos um arquivo remoto.\n"
    usage
}

post_event() {
    :   # no-op
}

# =============================
# Verificação de argumentos
# =============================
(( $# < 1 )) && usage_error
REMOTEFILES="$*"

# =============================
# Importar senha
# Arquivo deve definir FTP_PASS
# =============================
. /usr/sbin/setlink.ksh

[[ -z "$FTP_PASS" ]] && {
    printf "ERRO: FTP_PASS não definido\n" >&2
    exit 1
}

# =============================
# Preparação
# =============================
: > "$DIRLISTFILE"

# =============================
# Listagem remota
# =============================
ftp -i -n -v "$RNODE" <<EOF
user $FTP_USER $FTP_PASS
nlist $REMOTEDIR $DIRLISTFILE
bye
EOF

# =============================
# Download dos arquivos
# =============================
ftp -i -n -v "$RNODE" <<EOF
user $FTP_USER $FTP_PASS
binary
lcd $LOCALDIR
cd $REMOTEDIR
mget $REMOTEFILES
bye
EOF

post_event

