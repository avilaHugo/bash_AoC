#!/usr/bin/env bash


create_db() { 
    while read -r line;do
        # grep -> LINE_NUMBER:MATCH_START:MATCH_CAPTURE
        grep --label=$((c++)) -H -Poab '\d+|[^\d.]+' <<< $line
    done \
        | awk -F ':' '
                 # LINE, MATCH_OFFSET, MATCH_CAPTURE -> i, j1, j2, MATCH_CAPTURE, TYPE
                 BEGIN {
                    OFS=FS
                 }
                 {
                    type = ($3 ~ /[[:digit:]]+/) ? "number" : "symbol"
                    print $1, $2, ($2 + length($3) - 1), $3, type
                 }
                 ' \
        | awk -F':' -v q="'" '
            BEGIN {
                print "CREATE TABLE game ( i INT, j1 INT, j2 INT, match_capture TEXT, type TEXT, PRIMARY KEY (type, i, j1));"
            }

            { printf "INSERT INTO game VALUES (%s,%s,%s,%s,%s);\n", $1, $2, $3, q$4q, q$5q }
        ' \
        | sqlite3 "${DB_NAME}"
}

query_part_1() {
    local i="${1}"
    local j1="${2}"
    local j2="${3}"
    local number="${4}"
    local type="${5}"
    local DB_NAME="${6}"

    i_l=$(( ${i} - 1 ))
    i_r=$(( ${i} + 1 ))

    j_l=$((${j1} - 1 ))
    j_r=$((${j2} + 1 ))

    printf '
        SELECT * FROM game
        WHERE (
            (type = %s) AND
            (i >= %s) AND
            (i <= %s) AND
            (j1 >= %s) AND 
            (j2 <= %s) 
        )
        LIMIT 1;\n' \
            "'symbol'" \
            "${i_l}" \
            "${i_r}" \
            "${j_l}" \
            "${j_r}" \
            \
    | sqlite3 "${DB_NAME}" \
    | grep -q '.' \
    && echo "${number}"

}


DB_NAME='./test.db'
N_JOBS=3

[[ ! -f "${DB_NAME}" ]] && {
    create_db
}

export -f query_part_1

sqlite3 "${DB_NAME}" -csv "SELECT * FROM game WHERE type = 'number'"  \
    | parallel \
        -j "${N_JOBS}" \
        --colsep ',' \
        'query_part_1 {1} {2} {3} {4} {5}' "${DB_NAME}" \
    | awk '{sum+=$0} END {print sum}'
