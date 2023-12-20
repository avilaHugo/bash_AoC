#!/usr/bin/env bash


seeds_part_1() {
    head -2 \
        | grep 'seeds:' \
        | cut -d ' ' -f 2- \
        | tr ' ' '\n' 
}


seeds_part_2() {
    head -2 \
        | grep 'seeds:' \
        | cut -d ' ' -f 2- \
        | tr ' ' '\n' \
        | paste -d ' '  - - \
        | while IFS=' ' read -r SOURCE RANGE_LENGTH;do
            seq "${SOURCE}" $(( ${SOURCE} + ( ${RANGE_LENGTH} - 1) ))
          done

}

# seeds_part_1 > SEEDS.txt
seeds_part_2 > SEEDS.txt

sed '/^$/ s:^:@:' \
    | cat - <(echo '@') \
    | while IFS=$'\n' read -d $'@' MAP_TITLE INTERVALS;do
        readarray -t SEEDS < SEEDS.txt 
        for seed in "${SEEDS[@]}";do
            echo "${INTERVALS}" | while IFS=' ' read -r DESTINATION SOURCE RANGE_LENGTH;do
                (( ${SOURCE} <= ${seed} )) && (( "${seed}" < $(( ${SOURCE} + ${RANGE_LENGTH} )) )) \
                    && echo $(( ( ${seed} - ${SOURCE} ) + ${DESTINATION} ))
            done \
            | grep -m1 . || echo "${seed}"
        done \
            | tee SEEDS.txt \
            | awk -v map_title="${MAP_TITLE}" '{print  map_title $0}' 
      done \
      | grep location \
      | cut -d':' -f 2 \
      | sort -n \
      | head -1 
