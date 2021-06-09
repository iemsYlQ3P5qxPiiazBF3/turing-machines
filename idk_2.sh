#!/bin/bash
clear
:>out0.data

TAPE=( $(tr -cd '01'</dev/urandom|head -c 50|sed 's/.\{1\}/& /g') )
LEN="${#TAPE[@]}"
ORIG_TAPE=( ${TAPE[@]} )
HEAD=25
STEPS=0

write(){
	TAPE[$HEAD]="$1"
	echo -e "${TAPE[@]}"
	echo "${TAPE[@]}"|tr -d ' '|sed 's/0/000000/g;s/1/FFFFFF/g'|xxd -r -p >> out0.data #open in GIMP with width 50 to visualize the output
	for i in $(seq $HEAD);do
	echo -n "  "
	done
	echo "^"
	echo -e "Steps: $STEPS\nHead: $HEAD\nState: $STATE"
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
		((HEAD>=LEN))&&HEAD="$LEN"
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

state_a(){
	STATE="A"
	case "${TAPE[$HEAD]}" in
		"0")
		write 1
		move R
		state_b
		;;
		"1")
		move L
		state_c
		;;
		"")
		write 0
		move L
		move L
		state_b
	esac
}

state_b(){
	STATE="B"
	case "${TAPE[$HEAD]}" in
		"0")
		move L
		write 0
		move R;move R
		state_a
		;;
		"1")
		write 1
		move R
		state_b
		;;
		"")
		write 0
		move L
		state_a
	esac
}

state_c(){
	STATE="C"
	case "${TAPE[$HEAD]}" in
		"0")
		write 1
		move L
		state_b
		;;
		"1")
		write 1
		move R
		state_b
		;;
		"")
		write 0
		move L
		state_c
		;;
	esac
}

state_a
