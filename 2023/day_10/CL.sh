#!/usr/bin/env bash

while read -r LINE;do
    grep -Pob --label=$((c++)) -H  '[\.\|\-LJ7FS]' <<< "${LINE}"
done \
    | awk -F ':' '
       function iter_adj(i, j, pos_mat) {
            delete pos_mat
            curr_square_pos=0
            curr_arr_index=0
            for (x=i-1; x<=i+1; x++) {
                for (z=j-1; z<=j+1; z++) {
                    curr_square_pos++
                    if ( ( curr_square_pos % 2 != 0 ) || ( x == i && z == j ) ) { continue }
                    curr_arr_index++
                    pos_mat[curr_arr_index]["i"]=x
                    pos_mat[curr_arr_index]["j"]=z
                }
            }
       }

       $3 == "S" { s_i=$1; s_j=$2 }

       { game[$1][$2]=$3 }

       END {

            curr_i=s_i
            curr_j=s_j
            split("[|7F] [-LF] [-J7] [|LJ]", allowed_symbol, " ")
            split("N W E S", pos, " ")

            symbols["|"]="[NS]"
            symbols["-"]="[WE]"
            symbols["L"]="[NE]"
            symbols["J"]="[NW]"
            symbols["7"]="[SW]"
            symbols["F"]="[SE]"
            symbols["S"]="[NEWS]"

            while (1) {
                curr_symbol=game[curr_i][curr_j]

                iter_adj(curr_i, curr_j, pos_mat)
                for (x in pos_mat) {
                    i=pos_mat[x]["i"]
                    j=pos_mat[x]["j"]
                    adj_sym = game[i][j]

                    if ( pos[x] !~ symbols[curr_symbol] ) { continue  }
                    if ( adj_sym !~ allowed_symbol[x] ) { continue }
                    if ( visited[i][j]++ ) { continue  }
                    curr_i=i
                    curr_j=j
                    break
                }

                ++c
                if (c == 2) { for (x in allowed_symbol) { sub("]", "S]", allowed_symbol[x]) } }
                if ( c > 2 && curr_symbol == "S" ) {break}

            }
            print (c - 1) / 2    

       }
    '


