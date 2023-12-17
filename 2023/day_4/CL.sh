#!/usr/bin/env bash

# part_1
# while IFS='|' read -r WINNING CARD ;do
    # grep -xFf \
        # <(tr ' ' '\n' <<<  "${WINNING}") \
        # <(tr ' ' '\n' <<<  "${CARD}")  \
        # | grep -c  '[[:digit:]]'
# done \
    # | awk '$0 >= 1 { sum+=2^($0-1) } END { print sum } ' 


get_winning_numbers() {
    local winning=${1}
    local card=${2}

    grep -xFf \
        <(tr ' ' '\n' <<< "${winning}") \
        <(tr ' ' '\n' <<< "${card}")   \
        | grep '[[:digit:]]'

}

declare -A game

while IFS='|' read -r WINNING CARD ;do
    read -r game_id < <( [[ "${WINNING}" =~ ([[:digit:]]+) ]]; echo "${BASH_REMATCH[0]}" )
    read -r winning_numbers_count < <( get_winning_numbers "${WINNING}" "${CARD}" | wc -l )
    game[${game_id}]="${winning_numbers_count}"
done 

iter_card() {
    local game_id="${1}"
    local score="${game[${game_id}]}"

    echo "${game_id}"

    [[ "${score}" -eq 0 ]] && {
        return
    }

    seq $(( "${game_id}" + 1 )) $(( "${game_id}" + "${score}" )) \
        | while read -r GAME_ID;do
            iter_card "${GAME_ID}"
          done

          return

}

for ((i=1; i<=${#game[@]}; i++));do
    iter_card "${i}"
done | wc -l 

