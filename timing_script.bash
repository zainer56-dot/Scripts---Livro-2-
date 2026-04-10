#!/bin/bash
# timing_script.bash
# Mede o tempo de execução de cada método

INFILE="large_file.dat"
OUTFILE="outfile.dat"
FUNC_LIST="functions.lst"
FUNC_FILE="functions.sh"   # arquivo onde as funções estão definidas

# Verificações básicas
[[ ! -r "$INFILE" ]] && {
    echo "ERRO: arquivo de entrada $INFILE não encontrado" >&2
    exit 1
}

[[ ! -r "$FUNC_LIST" ]] && {
    echo "ERRO: lista de funções $FUNC_LIST não encontrada" >&2
    exit 1
}

[[ -r "$FUNC_FILE" ]] && source "$FUNC_FILE"

echo "Início dos testes"
echo "================"

while IFS= read -r FUNC
do
    [[ -z "$FUNC" ]] && continue

    if ! declare -F "$FUNC" >/dev/null; then
        echo "Função $FUNC não definida — pulando"
        continue
    fi

    echo
    echo "Testando $FUNC"
    echo "----------------"

    # Executar e medir
    time "$FUNC"

done < "$FUNC_LIST"
