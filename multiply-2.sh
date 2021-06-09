#!/bin/bash
TAPE=( $(tr -cd '01'</dev/urandom|head -c50|sed 's/.\{1\}/& /g') )
HEAD=1
STEPS=0 #Steps until halted

write(){
	TAPE[$HEAD]="$1"
	echo -e "Steps: $STEPS\nHead: $HEAD"

	echo "${TAPE[@]}"|sed 's/0/ /g;s/1/█/g'
	for i in $(seq $HEAD);do
		echo -n "  "
	done
	echo "█"

	sleep 0.075
	((++STEPS))
}

move(){
	case "$1" in
		"L")
		((HEAD--))
		;;
		"R")
		((HEAD++))
		;;
	esac
	((++STEPS))
}

state_accept(){
	echo "Accepted after $STEPS steps."
	exit
}

state_reject(){
	echo "Rejected after $STEPS steps."
	exit
}

state_0(){
	case "${TAPE[$HEAD]}" in
		"0")
		move L
		write 0
		move R
		write x
		move R
		state_0
		;;
		"1")
		move L
		write 1
		move R
		write x
		move R
		state_0
		;;
		*)
		move L
		write 0
		state_accept
		;;
	esac
}

state_0
