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
    bar=$(printf "%-${progress}s" " ")
    printf "[$bar%s] %2d min \r" "" "$i"
    sleep 1m
  done
  echo "'$val' session done"
}

start_pomodoro() {
  # Number of times to repeat the loop, default is 2
  if [ -n "$1" ] && [ "$1" -eq "$1" ] 2>/dev/null; then
    num_loops=$1
  else
   # Default loops
    num_loops=2
  fi

  # Set the length of the work and break sessions based on command line arguments
  if [ -n "$2" ] && [ "$2" -eq "$2" ] 2>/dev/null; then
    pomo_options["work"]=$2
  fi
  if [ -n "$3" ] && [ "$3" -eq "$3" ] 2>/dev/null; then
    pomo_options["break"]=$3
  fi

  for ((i=1; i <= num_loops; i++)); do
    pomodoro "work"
    pomodoro "break"
  done
}

# Call the function with command line arguments
start_pomodoro "$@"
