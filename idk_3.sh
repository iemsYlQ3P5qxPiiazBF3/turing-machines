#!/bin/bash
clear
:>out0.data

TAPE=( $(tr -cd '012'</dev/urandom|head -c 12|sed 's/.\{1\}/& /g') x F )
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
		write 1
		move R
		state_a
		;;
		"1")
		write 0
		move R
		state_b
		;;
		"2")
		write 1
		move L
		state_b
		;;
		"x")
		move R
		state_chk
		;;
		*)
		state_chk
		;;
	esac
}

state_b(){
	STATE="B"
	case "${TAPE[$HEAD]}" in
		"0")
		write 2
		move R
		state_b
		;;
		"1")
		move L
		write 0
		move L
		state_a
		;;
		"2")
		write 0
		move L
		state_b
		;;
		"x")
		state_a
		;;
		*)
		state_chk
		;;
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
		move R
		write 2
		move R
		state_a
		;;
		"2")
		move L
		state_c
		;;
		"x")
		move R
		state_chk
		;;
		*)
		state_chk
		;;
	esac
}

state_chk(){
	STATE="chk"
	case "${TAPE[$HEAD]}" in
		"x")
		move L
		state_chk
		;;
		"F")
		move L
		move L
		write 2
		move R
		move R
		write E
		move R
		state_b
		;;
		"E")
		write D
		move L
		move L
		move L
		write 1
		state_a
		;;
		"D")
		write C
		move R
		state_a
		;;
		"C")
		write B
		move R
		write 2
		move R
		state_a
		;;
		"B")
		write A
		move L
		move L
		move L
		state_c
		;;
		"A")
		write '_'
		move L
		move L
		move L
		state_a
		;;
		"_")
		move L
		state_accept
		;;
		"0")
		write F
		move R
		state_a
		;;
		"1")
		write F
		move R
		state_b
		;;
	esac
}

state_a
