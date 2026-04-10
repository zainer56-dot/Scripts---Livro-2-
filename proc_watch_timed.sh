#!/usr/bin/env bash
# proc_watch_timed.sh
# Monitorar um processo por tempo definido, com logs, PIDs e eventos.

set -u

# ========= Configuração =========
LOGFILE="/tmp/proc_watch_timed.log"
TTY_DEV="$(tty 2>/dev/null || echo /dev/tty)"

# -------- Hooks (customizáveis) --------
pre_start()  { :; }  # antes do primeiro start
on_start()   { :; }  # toda vez que o processo inicia
on_stop()    { :; }  # toda vez que o processo termina
post_stop()  { :; }  # ao final do monitoramento

# ========= Utilidades =========
ts() { date '+%m/%d/%y@%H:%M:%S'; }

say() {
  echo "$*" | tee -a "$LOGFILE" >"$TTY_DEV"
}

list_pids() {
  # Lista PIDs do processo, excluindo grep e este script
  ps aux \
  | awk -v pat="$1" -v self="$$" '
      $0 ~ pat && $2 != self && $0 !~ /awk/ { print $2 }
    ' | sort -n
}

proc_running() {
  list_pids "$1" | grep -q '[0-9]'
}

usage() {
  cat <<EOF
Uso: $0 [-s seg] [-m min] [-h horas] [-d dias] -p <processo>

Exemplos:
  $0 -m 10 -p my_backup
  $0 -s 30 -h 1 -p nginx

Monitora início/fim do processo, loga eventos e PIDs ativos.
EOF
}

# ========= Parse de argumentos =========
SECS=0; MINS=0; HRS=0; DAYS=0; PROCESS=""

while getopts ":s:m:h:d:p:" opt; do
  case "$opt" in
    s) SECS=$OPTARG ;;
    m) MINS=$OPTARG ;;
    h) HRS=$OPTARG ;;
    d) DAYS=$OPTARG ;;
    p) PROCESS=$OPTARG ;;
    *) usage; exit 1 ;;
  esac
done

[[ -z "$PROCESS" ]] && { usage; exit 1; }

# Validar inteiros
for v in "$SECS" "$MINS" "$HRS" "$DAYS"; do
  [[ "$v" =~ ^[0-9]+$ ]] || {
    echo "Valor inválido de tempo: $v" >&2
    exit 1
  }
done

TOTAL=$(( SECS + MINS*60 + HRS*3600 + DAYS*86400 ))
(( TOTAL <= 0 )) && {
  echo "Defina uma duração > 0 (ex.: -m 5)" >&2
  exit 1
}

touch "$LOGFILE" || {
  echo "Não foi possível escrever em $LOGFILE" >&2
  exit 1
}

# ========= Estado =========
RUN_FLAG="N"
LAST_PID_SET=""

# ========= Sinais =========
cleanup() {
  say "MON_STOP: Monitoramento de $PROCESS encerrado ==> $(ts)"
  post_stop
  exit 0
}

trap cleanup INT TERM HUP

# ========= Início =========
say "MON_START: Monitoramento de $PROCESS iniciado ==> $(ts)"
START_TS=$(date +%s)

pre_start

# ========= Loop principal =========
while :; do
  NOW=$(date +%s)
  ELAPSED=$(( NOW - START_TS ))
  REMAINING=$(( TOTAL - ELAPSED ))
  (( REMAINING < 0 )) && REMAINING=0

  if proc_running "$PROCESS"; then
    mapfile -t PIDS < <(list_pids "$PROCESS")
    PID_STR="${PIDS[*]}"

    if [[ "$RUN_FLAG" != "Y" ]]; then
      RUN_FLAG="Y"
      say "START PROCESS: $PROCESS iniciou ==> $(ts)"
      on_start
    fi

    if [[ "$PID_STR" != "$LAST_PID_SET" ]]; then
      LAST_PID_SET="$PID_STR"
      say "PIDs ATIVOS: $PID_STR"
    fi
  else
    if [[ "$RUN_FLAG" = "Y" ]]; then
      RUN_FLAG="N"
      LAST_PID_SET=""
      say "END PROCESS: $PROCESS finalizou ==> $(ts)"
      on_stop
    fi
  fi

  (( REMAINING == 0 )) && cleanup
  sleep 1
done
