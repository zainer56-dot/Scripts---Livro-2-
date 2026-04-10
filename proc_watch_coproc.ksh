#!/bin/ksh
#
# SCRIPT: proc_watch_coproc.ksh
#

######################################
# Função executada como CO-PROCESSO
######################################
proc_watch()
{
   while :
   do
      # ---- Código que roda continuamente ----
      print "Co-processo ativo... $(date)"

      # Lê comando enviado pelo processo pai
      if read -p BREAK_OUT
      then
         if [[ "$BREAK_OUT" = "Y" ]]
         then
            print "Co-processo recebendo comando de parada..."
            exit 0
         fi
      fi

      sleep 1
   done
}

######################################
# PRINCIPAL
######################################

TOTAL_SECONDS=300

# Trap: envia comando ao co-processo antes de sair
trap '
   print "Trap recebido, encerrando co-processo..."
   print -p Y
   wait
   exit 2
' 1 2 3 15

# Inicia o co-processo
proc_watch |&

# Loop temporizado no processo principal
until (( TOTAL_SECONDS == 0 ))
do
   (( TOTAL_SECONDS-- ))
   sleep 1
done

# Envia comando de saída ao co-processo
print "Tempo esgotado, sinalizando co-processo..."
print -p Y

# Aguarda o co-processo terminar
wait

print "Processo principal finalizado."
exit 0
