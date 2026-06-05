#!/bin/bash

OUT=`swaymsg -t get_outputs -r | jq '.[] |= select(.active == true) | map({x: .rect.x, name: .name}) | sort_by(.x)'`

# get num of outs
qty=`echo $OUT | jq 'length'`
echo $qty

# filter out the laptop
echo $OUT | jq -c '.[] | select(.name != "eDP-1")' | while read obj ; do
  x=`echo $obj | jq '.x'`
  name=`echo $obj | jq '.name'`
  echo "hello $name $x"
  # todo: get workspaces, distribute among the remaining displays
done
