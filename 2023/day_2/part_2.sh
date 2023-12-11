#!/usr/bin/env bash

query_part_1() {
    awk '
        BEGIN { FS=","; l["green"]=13; l["red"]=12; l["blue"]=14;  }
        $3 > l[$4] { neg[$1] }
        { ids[$1]  }
        END { for (i in ids) { if (i in neg == 0) print i } }  
        '  
}

query_part_2() {
    awk '
        BEGIN {
                FS=",";
                current_game=1
            }

        current_game != $1 {
            result[r++] = l["green"] *  l["red"] *  l["blue"]
            current_game=$1
            l["green"]=0; l["red"]=0; l["blue"]=0;  
        }

        $3 > l[$4]  {
            l[$4]=$3
        }

        END {
            result[r++] = l["green"] *  l["red"] *  l["blue"]
            for (i in result) {print result[i]}
        }
        '
}

sed 's|:|;|;s:\;:\n:g' \
    | awk '
        /^Game/{ ID=gensub("[^[:digit:]]", "", $0); pull=0; next}
        { split($0, cubes, ","); pull++; for (i in cubes) {print ID, pull, cubes[i] } }' \
    | sed -r 's:\s+:,:g'

    # | query_part_2 \
    # | awk '{ result+=$0 } END {print result}'
