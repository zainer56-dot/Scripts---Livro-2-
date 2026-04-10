#!/bin/ksh
# Script: rsync_backup.ksh
# Uso: ./rsync_backup.ksh /origem usuario@host:/destino

ORIGEM="$1"
DESTINO="$2"

# Verifica argumentos
if [[ -z "$ORIGEM" || -z "$DESTINO" ]]; then
    print "Uso: $0 /origem usuario@host:/destino"
    exit 1
fi

# Verifica se a origem existe
if [[ ! -d "$ORIGEM" && ! -f "$ORIGEM" ]]; then
    print "ERRO: Origem não existe: $ORIGEM"
    exit 2
fi

# Executa o backup
rsync -av --delete "$ORIGEM" "$DESTINO"
STATUS=$?

# Retorna o status do rsync
if [[ $STATUS -ne 0 ]]; then
    print "ERRO: rsync falhou (status=$STATUS)"
    exit $STATUS
fi

print "Backup concluído com sucesso."
exit 0
