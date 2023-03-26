#!/bin/bash

# TODO: Ask user to pick a task
# TODO DB to store tasks... can this connect to notion?

fpomo_progbar() {
    barr=''
    for (( y=50; y <= 100; y++ )); do
        sleep 0.05
        barr="${barr} "
 
        echo -ne "\r"
        echo -ne "\e[43m$barr\e[0m"
 
        local left="$(( 100 - $y ))"
        printf " %${left}s"
        echo -n "${y}%"
    done
    echo -e "\n"
}


declare -A pomo_options
pomo_options["work"]=1
pomo_options["break"]=1

pomodoro() {
  val=$1
  echo "$val" | lolcat
  remaining=$((pomo_options["$val"] * 60))
  fpomo_progbar "$remaining" &
  fpomo_progbar_pid=$!
  while [ "$remaining" -gt 0 ]; do
    sleep 1
    remaining=$((remaining - 1))
  done
  kill "$fpomo_progbar_pid" >/dev/null 2>&1
  wait "$fpomo_progbar_pid" 2>/dev/null
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
