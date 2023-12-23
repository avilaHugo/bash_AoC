#!/usr/bin/env bash


rm *.temp

(
    # Setting up seeds ranges
    head -2 \
        | tr ' ' '\n' \
        | sed '/^[[:digit:]]/!d' \
        | paste -d ' ' -- - - \
        | awk '{print "seed_ranges", $1, ($1 + ( $2 - 1 ))}'

    # Formating ranges 
    sed '/^$/ s/^$/@/; $a@' \
        | while IFS=$'\n' read -r -d '@' MAP_TITLE MAP_RANGES;do
                while read -r MAP_RANGE;do
                    echo "${MAP_TITLE%[[:space:]]*} ${MAP_RANGE}";
                done <<< "${MAP_RANGES}"
           done \
        | awk '
            {
                f=( $4 - 1 )
                # map_range, dest_start, dest_end, source_start, source_end
                print $1,$2,($2 + f),$3,($3 + f)
            }
        '
) \
    | while IFS=' ' read -r FILE_NAME DATA;do
        echo "${DATA}" >> "${FILE_NAME}.temp"
      done


read -d '' SEED_RANGES < seed_ranges.temp
read -d '' FILE_ORDER < <(grep '[[:alpha:]]' sample_1.txt | sed '1d; s: .*::;s:$:.temp:')


while read -r MAP_FILE ;do
    echo 
    echo '---------------'
    echo "${MAP_FILE@A}"


    read -r -d '' SEED_RANGES < <(

        while read -r SEED_START SEED_END ;do
            # echo "SEEDS RANGE: ${SEED_START} ${SEED_END}"

            has_overlaps=false
            while read -r DEST_START DEST_END SOURCE_START SOURCE_END;do
            # echo "${DEST_START}" "${DEST_END}" "${SOURCE_START}" "${SOURCE_END}"
                # Check if intervals not overlap
                if ! (( SEED_START <= SOURCE_END )) && (( SEED_END >= SOURCE_START ));then
                    continue
                fi

                has_overlaps=true

                if (( SEED_START < SOURCE_START ));then
                    echo "${SEED_START}" "$((SOURCE_START - 1))"
                    SEED_START="${SOURCE_START}"
                fi

                l=$((DEST_START + (SEED_START - SOURCE_START)))

                if (( SEED_END > SOURCE_END ));then
                    SEED_START="$((SOURCE_END + 1))"    
                fi

                L=$((DEST_START + (SEED_END - SOURCE_START)))

                echo "${l} ${L}" 

            done < <(sort -n -k3 -t ' ' "${MAP_FILE}")

            echo "${SEED_START} ${SEED_END}" 

        done <<< "${SEED_RANGES}"
    )
    
    printf '%s\n' "${SEED_RANGES[@]}"

    echo '---------------'
    echo 
done < <( cat <<< "${FILE_ORDER}")

printf '%s\n' "${SEED_RANGES[@]}" \
    | sort -n -k1 -t ' ' \
    | head -1 \
    | cut -f 1








