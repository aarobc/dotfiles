#!/bin/bash
mons=`xrandr | grep -w connected  | awk -F'[ \+]' '{print $1,$3,$4}' 2>/dev/null`
# echo "$mons"
# echo " "
# $test=echo "$mons" | awk '{print $1}'
# echo $test
IFS=$'\n' mray=($(echo "$mons" | awk '{print $1}'))

num=${#mray[@]}

switch=`expr 10 / $num`
# echo "num $switch"
st=1;

for i in "${mray[@]}"
do :
    for k in $(seq $st $switch); do
        # echo "$i $k"
        i3-msg workspace \"$k\" output $i
    done
    st=$(expr $switch + 1)
    switch=$(expr $switch + $switch )
done
