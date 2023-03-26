#!/bin/bash

# TODO: Ask user to pick a task
# TODO DB to store tasks... can this connect to notion?

fpomo_progbar() {
  local total_seconds=$1
  local start_time=$(date +%s)
  local end_time=$((start_time + total_seconds))
  local current_time

  while true; do
    current_time=$(date +%s)
    local time_passed=$((current_time - start_time))
    local percentage=$((time_passed * 100 / total_seconds))

    if [ $percentage -gt 100 ]; then
      percentage=100
    fi

    local progress_bar_length=$((percentage / 2))
    local progress_bar=$(printf "%${progress_bar_length}s" | tr ' ' ' ')
    local remaining_spaces=$((50 - progress_bar_length))
    local spaces=$(printf "%${remaining_spaces}s")

    echo -ne "\r\e[43m${progress_bar}\e[0m${spaces} ${percentage}%" 

    if [ $current_time -ge $end_time ]; then
      break
    fi

    sleep 1
  done

  echo -e "\n"
}


declare -A pomo_options
pomo_options["work"]=1
pomo_options["break"]=1

pomodoro() {
  val=$1
  echo "$val" 
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
