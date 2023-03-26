#!/bin/bash

# TODO: Ask user to pick a task
# TODO DB to store tasks... can this connect to notion?

declare -A pomo_options
pomo_options["work"]=1
pomo_options["break"]=1

pomodoro() {
  val=$1
  echo "$val" | lolcat
  for i in $(seq "${pomo_options["$val"]}" -1 1); do
    progress=$((100 - i*100/pomo_options["$val"]))
    echo "$i" | spd-say -w
    echo -ne "[$(printf "%-${progress}s" "")$(printf "%$((100-progress))s" "" )] $i min \r"
    sleep 1m
  done
  spd-say "'$val' session done"
  notify-send --app-name=Pomodoro🍅 "'$val' session done 🍅"
}

start_pomodoro() {
  # Number of times to repeat the loop, default is 2
  if [ -n "$1" ] && [ "$1" -eq "$1" ] 2>/dev/null; then
    num_loops=$1
  else
   # Default loops
    num_loops=2
  fi

  for ((i=1; i <= num_loops; i++)); do
    pomodoro "work"
    pomodoro "break"
  done
}

# call the function
start_pomodoro
