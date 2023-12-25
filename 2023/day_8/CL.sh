#!/usr/bin/env bash

sed -r '
    /^$/d;
    s|[^[:alpha:][:space:]]||g;
    s|([[:space:]])+|\1|g' \
    | awk '
        function get_next_direction(){
            return 
        }
        
        NR == 1 {
            DIRECTIONS=$0;
            directions_len=length(DIRECTIONS)
            next_index=1
            next;
        }

        {
            nodes[$1]["L"] = $2
            nodes[$1]["R"] = $3
        }

        END {
            CURRENT_NODE = "AAA"

            while (CURRENT_NODE != "ZZZ") {

                if (next_index > directions_len) { next_index=1 }

                CURRENT_NODE = nodes[CURRENT_NODE][substr(DIRECTIONS, next_index, 1)]

                next_index++
                c++
            }
            print c
        }
    '






