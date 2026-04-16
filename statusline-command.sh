#!/bin/sh
input=$(cat)

used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
h5=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
w7=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

if [ -n "$used" ]; then
  if [ "$used" -lt 25 ]; then
    color="\033[32m"
  elif [ "$used" -lt 75 ]; then
    color="\033[33m"
  else
    color="\033[31m"
  fi
  bar=""
  filled=$((used / 10))
  empty=$((10 - filled))
  i=0; while [ $i -lt $filled ]; do bar="${bar}█"; i=$((i+1)); done
  i=0; while [ $i -lt $empty ]; do bar="${bar}░"; i=$((i+1)); done
  printf "${color}CTX ${bar} ${used}%%\033[0m"
fi

if [ -n "$h5" ]; then
  if [ "$h5" -lt 50 ]; then c="\033[32m"; elif [ "$h5" -lt 80 ]; then c="\033[33m"; else c="\033[31m"; fi
  printf " ${c}5H ${h5}%%\033[0m"
fi

if [ -n "$w7" ]; then
  if [ "$w7" -lt 50 ]; then c="\033[32m"; elif [ "$w7" -lt 80 ]; then c="\033[33m"; else c="\033[31m"; fi
  printf " ${c}7D ${w7}%%\033[0m"
fi

if [ -n "$model" ]; then
  printf " \033[35m⬡ ${model}\033[0m"
fi
