#!/bin/ksh
#
# SCRIPT: put_ftp_files_pw_var.ksh
# DATE: July 15, 2024
# PURPOSE: Enviar arquivos locais para servidor remoto via FTP
#          usando senha definida externamente.

# =============================
# Configuração
# =============================
THISSCRIPT=$(basename "$0")
RNODE="wilma"
FTP_USER="ftpuser"
LOCALDIR="/scripts"
REMOTEDIR="/scripts/download"

# =============================
# Funções auxiliares
# =============================
usage() {
    printf "\nUSAGE: %s arquivo1 [arquivo2 ...]\n\n" "$THISSCRIPT"
    exit 1
}

usage_error() {
    printf "\nERROR: É necessário informar um ou mais arquivos locais.\n"
    usage
}

pre_event() {
    :   # no-op
}

post_event() {
    :   # no-op
}

# =============================
# Verificação de argumentos
# =============================
(( $# < 1 )) && usage_error
LOCALFILES="$@"

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
# Verificar arquivos locais
# =============================
for FILE in $LOCALFILES
do
    [[ ! -f "$FILE" ]] && {
        printf "ERRO: arquivo %s não encontrado\n" "$FILE" >&2
        exit 1
    }
done

# =============================
# Envio via FTP
# =============================
pre_event

ftp -i -n -v "$RNODE" <<EOF
user $FTP_USER $FTP_PASS
binary
lcd $LOCALDIR
cd $REMOTEDIR
mput $LOCALFILES
bye
EOF

post_event
