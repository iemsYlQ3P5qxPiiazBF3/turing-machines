#!/bin/bash
#what does this do??
clear

TAPE=( $(tr -cd '01'</dev/urandom|head -c 50|sed 's/.\{1\}/& /g') )
ORIG_TAPE=( ${TAPE[@]} )
HEAD=0
STEPS=0

write(){
	TAPE[$HEAD]="$1"
	echo -e "${TAPE[@]}"
	for i in $(seq $HEAD);do
	echo -n "  "
	done
	echo "^"
	echo -e "Steps: $STEPS\nHead: $HEAD"
	sleep 0.075
	((++STEPS))
}

move(){
	case "$1" in
		"L")
		((HEAD--))
		((HEAD<0))&&HEAD=0
		;;
		"R")
		((HEAD++))
		;;
	esac
	((++STEPS))
}

state_accept(){
	echo "Accepted after $STEPS steps."
	echo -e "${ORIG_TAPE[@]}\n${TAPE[@]}"
}

state_reject(){
	echo "Rejected after $STEPS steps."
	exit
}

state_1(){
	case "${TAPE[$HEAD]}" in
		"1")
		write 0
		move R
		state_1
		;;
		"0")
		state_0
		;;
		"")
		state_accept
		;;
	esac
}

state_0(){
	case "${TAPE[$HEAD]}" in
		"0")
		write 1
		move L
		state_0
		;;
		"1")
		write 1
		move R
		state_1
		;;
	esac
}

state_1
