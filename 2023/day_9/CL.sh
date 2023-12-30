#!/usr/bin/env bash

awk '
    function check_all_zeros(arr) {
        for (i in arr) {
            if (arr[i] != 0) {
                return 0
            }
        }
        return 1
    }

    {

        split($0, arr, " ")

        while (1) {

            trace_last[++L]=arr[length(arr)]

            if ( check_all_zeros(arr) == 1 ) {
                break
            }

            for (i=1; i<length(arr); i++) {
                diff[++l] = arr[i+1] - arr[i]
            }
            delete arr
            l=0

            for (i in diff) {
                arr[i]=diff[i]
            }
            delete diff

        }
        L=0

        new_val = 0
        for (i=length(trace_last); i > 0; i--) {
            new_val += trace_last[i] 
        }

        print new_val
    } 
' \
    | awk '{sum+=$0} END {print sum}'
