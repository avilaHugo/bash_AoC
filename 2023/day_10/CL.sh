#!/usr/bin/env bash

while read -r LINE;do
    grep -Pob --label=$((c++)) -H  '[\|\-LJ7FS]' <<< "${LINE}"
done \
    | awk -F ':' '
       function iter_adj(i, j, pos_mat) {
            delete pos_mat
            l=0
            for (x=i-1; x<=i+1; x++) {
                for (z=j-1; z<=j+1; z++) {
                    if (x == i && z == j) { continue }
                    l++
                    pos_mat[l][1]=x
                    pos_mat[l][2]=z
                }
            }
       }

       function is_path(i, j, I, J, symbol) {
            
       }

       $3 == "S" { s_i=$1; s_j=$2 }

       { game[$1][$2]=$3 }

       END {
            split("| - L J 7 F", symbols, " ")
            split("-1,1 0,0 -1,0 -1,0 0,1 0,1", is, " ")
            split("0,0 -1,1 0,1 -1,0 -1,0 0,1", js, " ")
            for (i in symbols) {
                split(is[i], arr, ",")
                sym_map[symbols[i]]["i"][1]=arr[1]
                sym_map[symbols[i]]["i"][2]=arr[2]

                split(js[i], arr, ",")
                sym_map[symbols[i]]["j"][1]=arr[1]
                sym_map[symbols[i]]["j"][2]=arr[2]
            }

            curr_i="Na"
            curr_j="Na"

            iter_adj(s_i, s_j, pos_mat)
            for (x in pos_mat) {
                i = pos_mat[x][1]
                j = pos_mat[x][2]
                print i, j
            }

            # while ( s_i != curr_i && s_j != curr_j ) {
                # break
            # }

       }
    '
