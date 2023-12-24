#!/usr/bin/env bash

alpha_to_number(){
	local HAND="${1}"

	for ((i=0; i<"${#HAND}"; i++));do
		echo "${HAND:${i}:1}"
	done \
	| sed '
		s:A:14:;
		s:K:13:;
		s:Q:12:;
		s:J:11:;
		s:T:10:;
	'
}


while read -r HAND BID;do
	read -d '' -r CONVERTED_SYMBOLS < <(alpha_to_number "${HAND}")
	read -r PAIRS < <(awk '{d[$0]++} END {for (i in d) print d[i]}' <<< "${CONVERTED_SYMBOLS}" \
		| sort -nr \
		| tr -d '\n' \
		&& echo)

	echo "${HAND} ${BID} ${PAIRS} ${CONVERTED_SYMBOLS//$'\n'/ }"
done \
	| sort -k3,3 -k{4..8}n  \
	| awk '{sum+=(NR*$2)} END {print sum}'



