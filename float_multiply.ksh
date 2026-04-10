#!/usr/bin/ksh
#SCRIPT: float_multiply.kshhttps://github.com/zainer56-dot/Scripts---Livro-2-/tree/main
#AUTHOR: Zainer Araujo
#DATE: 02/12/2024
#REV: 1.1.P
#PROPÓSITO: Este shell script é usado para multiplicar uma lista de #númerosjuntos. Os números podem ser inteiros ou de ponto flutuante.
#Para números de ponto flutuante, o usuário tem a opção de especificar #uma escala com o número de dígitos à direita do ponto decimal.
#A escala é definida adicionando -s ou -S seguido de um número inteiro.
#STATUS DE SAÍDA:
#0 ==> Este script/função terminou normalmente
#1 ==> Erro de uso ou de sintaxe
#2 ==> Este script/função saiu devido a um sinal capturado (trap)
#LISTA DE REVISÕES:
set -x # Descomente para depurar este script
set -n # Descomente para verificar a sintaxe sem executar nenhum #comando
########################################################
############## DEFINIR VARIÁVEIS AQUI ##################
########################################################
SCRIPT_NAME=$(basename $0) # O nome deste shell script
SCALE="0" # Inicializar o valor da escala em zero
NUM_LIST= # Inicializar NUM_LIST como NULO
COUNT=0 # Inicializar o contador em zero
MAX_COUNT=$# # Definir MAX_COUNT como o total de argumentos
# da linha de comando
########################################################
################ FUNÇÕES ###############################
########################################################
function usage
{
echo "\nPROPÓSITO: Multiplica uma lista de números\n"
echo "USO: $SCRIPT_NAME [-s valor_da_escala] N1 N2...Nn"
echo "\nPara um resultado inteiro sem casas decimais significativas..."
echo "\nEXEMPLO: $SCRIPT_NAME 2048.221 65536 \n"
echo "OU para 4 casas decimais significativas"
echo "\nEXEMPLO: $SCRIPT_NAME -s 4 8.09838 2048 65536 42.632"
echo "\n\t...SAINDO...\n"
}
########################################################
function exit_trap
{
echo "\n...SAINDO devido a sinal capturado...\n"
}
########################################################
################# INÍCIO DO MAIN #######################
########################################################
#Definir um Trap
trap ’exit_trap; exit 2’ 1 2 3 15
########################################################
#Verifique se há pelo menos dois argumentos na linha de comando
if (($# < 2))
then
echo "\nERRO: Por favor, forneça uma lista de números para multiplicar"
usage
exit 1
fi
########################################################
#Analise os argumentos da linha de comando para encontrar o valor da #escala, se presente.
while getopts ":s:S:" ARGUMENT
do
case $ARGUMENT in
s|S) SCALE=$OPTARG
;;
?) # Porque podemos ter números negativos, precisamos
#testar para ver se o ARGUMENT que começa com um hífen (-) é um número #e não uma opção inválida!!!
for TST_ARG in $*
do
if [[ $(echo $TST_ARG | cut-c1) = ’-’ ]] 
&& [ $TST_ARG != ’-s’ -a $TST_ARG != ’-S’ ]
then
case $TST_ARG in
+([-0-9])) : # No-op, não faz nada
;;
+([-0-9].[0-9]))
: # No-op, não faz nada
;;
+([-.0-9])) : # No-op, não faz nada
;;
*) echo "\nERRO: $TST_ARG é um argumento inválido\n"
usage
exit 1
;;
esac
fi
done
;;
esac
done
########################################################
#Analise os argumentos da linha de comando e reúna uma lista
#de números a serem multiplicados.
while ((COUNT < MAX_COUNT))
do
done
((COUNT = COUNT + 1))
TOKEN=$1
case $TOKEN in -s|-S) shift 2
((COUNT = COUNT + 1))
;; -s${SCALE}) shift
;; -S${SCALE}) shift
;;
*) NUM_LIST="${NUM_LIST} $TOKEN"
((COUNT < MAX_COUNT)) && shift
;;
esac
done
########################################################
#Garantir que o scale seja um valor inteiro
case $SCALE in
+([0-9])) : # No-Op — Não faz nada
;;
*) echo "\nERRO: Escala inválida — $SCALE — Deve ser um inteiro"
usage
exit 1
;;
esac
########################################################
#Verificar cada número fornecido para garantir que os “números”
#sejam inteiros ou de ponto flutuante.
for NUM in $NUM_LIST
do
case $NUM in
+([0-9])) # Verificar se é um inteiro
: # No-op — não faz nada.
;;
+([-0-9])) # Verificar se é um número inteiro negativo
: # No-op — não faz nada
;;
+([0-9]|[.][0-9]))
#Verificar se é um número de ponto flutuante positivo
: # No-op — não faz nada
;;
+(+[0-9]|[.][0-9]))
#Verificar se é um número de ponto flutuante positivo
#com um prefixo +
: # No-op — não faz nada
;;
+([-0-9]|.[0-9]))
#Verificar se é um número de ponto flutuante negativo
: # No-op — não faz nada
;;
+(-.[0-9]))
#Verificar se é um número de ponto flutuante negativo
: # No-op — não faz nada
;;
+([+.0-9]))
#Verificar se é um número de ponto flutuante positivo
: # No-op — não faz nada
;;
*) echo "\nERRO: $NUM NÃO é um número válido"
   usage
   exit 1
   ;;
esac
done
########################################################
# Monte a lista de números para multiplicar
MULTIPLY=   # Inicialize a variável MULTIPLY como NULA
TIMES=      # Inicialize a variável TIMES como NULA
# Percorra cada número e construa uma expressão
# que multiplique todos os números
for X in $NUM_LIST
do
  # Se o número tiver prefixo '+', remova!
  if [[ $(echo $X | cut -c1) = '+' ]]
  then
    X=$(echo $X | cut -c2-)
  fi
  MULTIPLY="$MULTIPLY $TIMES $X"
  TIMES='*'
done
########################################################
# Faça a conta usando um here document para fornecer
# entrada ao comando bc. O produto da multiplicação
# dos números é atribuído à variável PRODUCT.
PRODUCT=$(bc <<EOF
scale=$SCALE
$MULTIPLY
EOF)
########################################################
# Apresente o resultado da multiplicação ao usuário.
echo "\nO produto de: $MULTIPLY"
echo "\ncom escala $SCALE é ${PRODUCT}\n"
