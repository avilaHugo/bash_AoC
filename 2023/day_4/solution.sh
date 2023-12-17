#!/usr/bin/env bash

get_winning_numbers() {
    local winning=${1}
    local card=${2}

    grep -xFf \
        <(tr ' ' '\n' <<< "${winning}") \
        <(tr ' ' '\n' <<< "${card}")   \
        | grep '[[:digit:]]'

}

# part_1 
while IFS='|' read -r WINNING CARD ;do
    get_winning_numbers "${WINNING}" "${CARD}" \
        | wc -l 
done | awk '$0 >= 1 { sum+=2^($0-1) } END { print sum }'


# part_2
declare -A game
while IFS='|' read -r WINNING CARD ;do
    read -r game_id < <( [[ "${WINNING}" =~ ([[:digit:]]+) ]]; echo "${BASH_REMATCH[0]}" )
    read -r winning_numbers_count < <( get_winning_numbers "${WINNING}" "${CARD}" | wc -l)

    # 0: wins
    game["${game_id}",0]="${winning_numbers_count}"

    # 1: total card
    game["${game_id}",1]=1
done

for ((i=1; i<=$(( "${#game[@]}" / 2 )); i++));do
    wins=game["${i}",0]
    for (( j=$(( ${i} + 1 )); j <=  $(( ${i} + ${wins} )); j++));do
       game["${j}",1]=$(( ${game["${j}",1]} + ${game["${i}",1]} ))
    done
    echo "${game[${i},1]}"
done | awk '{sum+=$0} END {print sum}'
