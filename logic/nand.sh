#!/bin/bash
clear
:>out0.data

TAPE=( $(tr -cd '01'</dev/urandom|head -c 2|sed 's/.\{1\}/& /g') 0 )
LEN="${#TAPE[@]}"
ORIG_TAPE=( ${TAPE[@]} )
HEAD=0
STEPS=0

display(){
	echo -e "${TAPE[@]}"
	for i in $(seq $HEAD);do
		echo -n "  "
	done
	echo "^"
	echo -e "Steps: $STEPS\nHead: $HEAD\nState: $STATE"
	sleep 0.035
}

write(){
	TAPE[$HEAD]="$1"
	echo "${TAPE[@]}"|tr -cd 'A-Fa-f0-9'|tr 'a-f' 'A-F'|sed 's/0/000000/g;s/1/111111/g;s/2/222222/g;s/3/333333/g;s/4/444444/g;s/5/555555/g;s/6/666666/g;s/7/777777/g;s/8/888888/g;s/9/999999/g;s/A/AAAAAA/g;s/B/BBBBBB/g;s/C/CCCCCC/g;s/D/DDDDDD/g;s/E/EEEEEE/g;s/F/FFFFFF/g'|xxd -r -p >> out0.data
	((++STEPS))
	display
}

move(){
	case "$1" in
		"L")
		((HEAD--))
#		((HEAD<0))&&{ TAPE=( 0 ${TAPE[@]} );HEAD=0; }
		((HEAD<0))&&HEAD=$((LEN-1))
		;;
		"R")
		((HEAD++))
#		((HEAD>=LEN))&&{ TAPE=( ${TAPE[@]} 0 );LEN="${#TAPE[@]}";HEAD="$LEN"; }
		((HEAD>=LEN))&&HEAD=0
		;;
	esac
	((++STEPS))
	display
}

state_accept(){
	display
	echo "Accepted after $STEPS steps."
	echo -e "${ORIG_TAPE[@]}\n${TAPE[@]}"
	exit 0
}

state_reject(){
	display
	echo "Rejected after $STEPS steps."
	echo -e "${ORIG_TAPE[@]}\n${TAPE[@]}"
	exit 1
}

state_a(){
	STATE="A"
	case "${TAPE[$HEAD]}" in
		"0")
		move R
		state_0
		;;
		"1")
		move R
		state_1
		;;
	esac
}

state_0(){
	STATE="0"
	case "${TAPE[$HEAD]}" in
		"0")
		move R
		write 1
		state_accept
		;;
		"1")
		move R
		write 1
		state_accept
		;;
	esac
}

state_1(){
	STATE="1"
	case "${TAPE[$HEAD]}" in
		"0")
		move R
		write 1
		state_accept
		;;
		"1")
		move R
		write 0
		state_reject
		;;
	esac
}

state_a