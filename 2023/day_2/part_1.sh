#!/usr/bin/env bash

cat - \
    | sed 's|:|;|;s:\;:\n:g' \
    | awk '
        /^Game/{ ID=gensub("[^[:digit:]]", "", $0); pull=0; next}
        { split($0, cubes, ","); pull++; for (i in cubes) {print ID, pull, cubes[i] } }' \
    | sed -r 's:\s+:,:g' \
    | awk '
        BEGIN { FS=","; l["green"]=13; l["red"]=12; l["blue"]=14;  }
        $3 > l[$4] { neg[$1] }
        { ids[$1]  }
        END { for (i in ids) { if (i in neg == 0) result+=i }; print result }  
        '  
