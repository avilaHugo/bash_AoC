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


read -d '' SEED_RANGES < <( cat seed_ranges.temp)
read -d '' FILE_ORDER < <(grep '[[:alpha:]]' sample_1.txt | sed '1d; s: .*::;s:$:.temp:')


while read -r MAP_FILE ;do
    read -r -d '' SEED_RANGES < <(

        while read -r SEED_START SEED_END ;do

            overlap_intervals=()

            while read -r DEST_START DEST_END SOURCE_START SOURCE_END;do

                # Check if intervals not overlap
                if ! (( (SEED_START <= SOURCE_END) && (SEED_END >= SOURCE_START) ));then
                    continue
                fi

                overlap_intervals+=("${DEST_START} ${DEST_END} ${SOURCE_START} ${SOURCE_END}")

            done < <(sort -n -k3 -t ' ' "${MAP_FILE}")


            if (( ${#overlap_intervals[@]} < 1 ));then
                echo "${SEED_START}" "${SEED_END}"
                continue
            fi
            
            while read -r DEST_START DEST_END SOURCE_START SOURCE_END;do
                if (( SEED_START < SOURCE_START ));then
                    echo "${SEED_START} $(( SOURCE_START - 1 ))"
                    SEED_START=$(( SOURCE_START ))
                fi

                l=$(( DEST_START + (SEED_START - SOURCE_START) ))
                L=$(( DEST_START + (SEED_END - SOURCE_START) ))

                if (( SEED_END > SOURCE_END ));then
                    L=$(( DEST_START + (SOURCE_END - SOURCE_START) ))
                fi

                echo "${l}" "${L}"
                SEED_START=$(( SOURCE_END + 1 ))

            done < <(printf '%s\n' "${overlap_intervals[@]}" )

            ((SEED_START <= SEED_END)) && echo "${SEED_START}" "${SEED_END}"

        done <<< "${SEED_RANGES}"
    )
    
done <<< "${FILE_ORDER}"

printf '%s\n' "${SEED_RANGES[@]}" \
    | sort -n -k1 -t ' ' \
    | head -1 \
    | cut -f 1 -d ' '

