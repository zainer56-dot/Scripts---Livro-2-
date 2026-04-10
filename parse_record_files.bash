#!/bin/bash
#
# SCRIPT: parse_record_files.bash
# DATE: 12/7/2024
# REV: 1.0
# PURPOSE: Parse de arquivos de registros fixos e variáveis

# =============================
# Verificação de entrada
# =============================
if (( $# != 1 )); then
    printf "\nUSAGE: %s -f|-v\n" "$(basename "$0")"
    printf "  -f  fixed-length records\n"
    printf "  -v  variable-length records\n\n"
    exit 1
fi

case "$1" in
    -f) RECORD_TYPE="fixed" ;;
    -v) RECORD_TYPE="variable" ;;
    *)
        printf "\nUSAGE: %s -f|-v\n\n" "$(basename "$0")"
        exit 1
        ;;
esac

# =============================
# Definição de variáveis
# =============================
DATADIR="/data"
FD=","

if [[ "$RECORD_TYPE" == "fixed" ]]; then
    MERGERECORDFILE="$DATADIR/mergedrecords_fixed.$(date +%m%d%y)"
    RECORDFILELIST="$DATADIR/branch_records_fixed.lst"
    OUTFILE="$DATADIR/post_processing_fixed_records.dat"
else
    MERGERECORDFILE="$DATADIR/mergedrecords_variable.$(date +%m%d%y)"
    RECORDFILELIST="$DATADIR/branch_records_variable.lst"
    OUTFILE="$DATADIR/post_processing_variable_records.dat"
fi

: > "$MERGERECORDFILE"
: > "$OUTFILE"

# =============================
# Funções de processamento
# =============================
process_fixedlength_data_new_duedate() {
    printf '%s%s%s%s%s%s\n' \
        "$1" "$2" "$3" "$4" "$7" "$6" >> "$OUTFILE"
}

process_variablelength_data_new_duedate() {
    printf '%s,%s,%s,%s,%s,%s\n' \
        "$1" "$2" "$3" "$4" "$7" "$6" >> "$OUTFILE"
}

# =============================
# Merge dos arquivos
# =============================
merge_fixed_length_records() {
    while IFS= read -r FILE
    do
        sed "s/\$/${FILE##*/}/" "$FILE" >> "$MERGERECORDFILE"
    done < "$RECORDFILELIST"
}

merge_variable_length_records() {
    while IFS= read -r FILE
    do
        sed "s/\$/${FD}${FILE##*/}/" "$FILE" >> "$MERGERECORDFILE"
    done < "$RECORDFILELIST"
}

# =============================
# Parse dos registros
# =============================
parse_fixed_length_records() {
    while IFS= read -r LINE
    do
        branch=${LINE:0:4}
        account=${LINE:4:10}
        name=${LINE:14:20}
        total=${LINE:34:6}
        datedue=${LINE:40:8}
        recfile=${LINE:48}

        new_datedue=$(date -d "$datedue +30 days" +%m%d%Y)

        process_fixedlength_data_new_duedate \
            "$branch" "$account" "$name" "$total" "$datedue" "$recfile" "$new_datedue"
    done < "$MERGERECORDFILE"
}

parse_variable_length_records() {
    while IFS=',' read -r branch account name total datedue recfile
    do
        new_datedue=$(date -d "$datedue +30 days" +%m%d%Y)

        process_variablelength_data_new_duedate \
            "$branch" "$account" "$name" "$total" "$datedue" "$recfile" "$new_datedue"
    done < "$MERGERECORDFILE"
}

# =============================
# Bloco principal
# =============================
if [[ "$RECORD_TYPE" == "fixed" ]]; then
    merge_fixed_length_records
    parse_fixed_length_records
else
    merge_variable_length_records
    parse_variable_length_records
fi
