#!/bin/bash
clear
:>out0.data
:>out1.data

TAPE=( _ $(tr -cd '01'</dev/urandom|head -c21|sed 's/.\{1\}/& /g') _ )
#TAPE=( _ 0 0 1 0 0 0 _ )
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

display

write(){
	TAPE[$HEAD]="$1"
	echo "${TAPE[@]}"|tr -cd 'A-Fa-f0-9'|tr 'a-f' 'A-F'|sed 's/0/000000/g;s/1/111111/g;s/2/222222/g;s/3/333333/g;s/4/444444/g;s/5/555555/g;s/6/666666/g;s/7/777777/g;s/8/888888/g;s/9/999999/g;s/A/AAAAAA/g;s/B/BBBBBB/g;s/C/CCCCCC/g;s/D/DDDDDD/g;s/E/EEEEEE/g;s/F/FFFFFF/g'|xxd -r -p >> out0.data
	echo -n "${TAPE[@]}"|tr -d ' '>>"out1.data"
	((++STEPS))
	display
}

move(){
	case "$1" in
		"L")
		((HEAD--))
		((HEAD<0))&&{ TAPE=( 0 ${TAPE[@]} );HEAD=0; }
#		((HEAD<0))&&HEAD=$((LEN-1))
		;;
		"R")
		((HEAD++))
		((HEAD>=LEN))&&{ TAPE=( ${TAPE[@]} 0 );LEN="${#TAPE[@]}";HEAD="$LEN"; }
#		((HEAD>=LEN))&&HEAD=0
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

state_shiftl(){
	STATE="SHIFTL"
	case "${TAPE[$HEAD]}" in
		"0")
		move L
		state_shiftl
		;;
		"1")
		move L
		state_shiftl
		;;
		"_")
		move R
		state_check
		;;
	esac
}

state_check(){
	STATE="CHECK"
	case "${TAPE[$HEAD]}" in
		"0")
		write '_'
		move R
		state_0__
		;;
		"1")
		write '_'
		move R
		state_1__
		;;
		"_")
		state_accept
		;;
	esac
}

state_0__(){
	STATE="0__"
	case "${TAPE[$HEAD]}" in
		"0")
		move R
		state_00_
		;;
		"1")
		move R
		state_01_
		;;
		"_")
		state_accept
		;;
	esac
}

state_1__(){
	STATE="1__"
	case "${TAPE[$HEAD]}" in
		"0")
		move R
		state_10_
		;;
		"1")
		move R
		state_11_
		;;
		"_")
		state_accept
		;;
	esac
}


state_00_(){
	STATE="00_"
	case "${TAPE[$HEAD]}" in
		"0") #000
		move L
		write 0
		move R
		state_check
		;;
		"1") #001
		move L
		write 1
		move R
		state_check
		;;
		"_")
		state_accept
		;;
	esac
}

state_01_(){
	STATE="01_"
	case "${TAPE[$HEAD]}" in
		"0") #010
		move L
		write 1
		move R
		state_check
		;;
		"1") #011
		move L
		write 0
		move R
		state_check
		;;
		"_")
		state_accept
		;;
	esac
}

state_10_(){
	STATE="10_"
	case "${TAPE[$HEAD]}" in
		"0") #100
		move L
		write 1
		move R
		state_check
		;;
		"1") #101
		move L
		write 1
		move R
		state_check
		;;
		"_")
		state_accept
		;;
	esac
}

state_11_(){
	STATE="11_"
	case "${TAPE[$HEAD]}" in
		"0") #110
		move L
		write 1
		move R
		state_check
		;;
		"1") #111
		move L
		write 0
		move R
		state_check
		;;
		"_")
		state_accept
		;;
	esac
}


state_shiftl
