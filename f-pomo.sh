#!/bin/bash

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

    echo -ne " \r\033[48;2;177;124;1m${progress_bar}\033[0m${spaces} ${percentage}%"
    # The above line uses the RGB escape sequence: \033[48;2;<R>;<G>;<B>m
    # Replace <R>, <G>, and <B> with the respective values of the desired color.

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

print_tomato_counter() {
  for ((j=1; j <= current_pomodoro; j++)); do
    echo -n "🍅"
  done
  echo -e "\n"
}

pomodoro() {
  val=$1
  emoji=""
  case "$val" in
    "work")
      emoji="🔨"
      ;;
    "break")
      emoji="☕"
      ;;
  esac
  clear
  echo -e "Working on \"$task_name\""
  print_tomato_counter
  echo -e "$emoji $val on Pomodoro $current_pomodoro 🍅..."
  remaining=$((pomo_options["$val"] * 60))
  fpomo_progbar "$remaining" &
  fpomo_progbar_pid=$!
  while [ "$remaining" -gt 0 ]; do
    sleep 1
    remaining=$((remaining - 1))
  done
  kill "$fpomo_progbar_pid" >/dev/null 2>&1
  wait "$fpomo_progbar_pid" 2>/dev/null
}

start_pomodoro() {
  # Ask the user to name the task
  read -r -p "Please enter the task name: " task_name

  # Ask the user for the work time in minutes, with a default of 25 minutes
  read -r -p "Enter work time in minutes (default 25): " work_time
  work_time=${work_time:-25}
  pomo_options["work"]=$work_time

  # Ask the user for the break time in minutes, with a default of 5 minutes
  read -r -p "Enter break time in minutes (default 5): " break_time
  break_time=${break_time:-5}
  pomo_options["break"]=$break_time

  # Ask the user for the number of loops, with a default of 2
  read -r -p "Enter the number of Pomodori (default 2): " num_loops
  num_loops=${num_loops:-2}

  for ((i=1; i <= num_loops; i++)); do
    current_pomodoro=$i
    pomodoro "work"
    if [ "$i" -lt "$num_loops" ]; then
      pomodoro "break"
    fi
  done
}

# Repeat the pomodoro process if the user wants and include a long break
repeat_pomodoro() {
  while true; do
    start_pomodoro

    read -r -p "Do you want to take a longer break and repeat? (y/n): " repeat_choice
    case "$repeat_choice" in
      [yY]|[yY][eE][sS])
        read -r -p "Enter the length of the longer break in minutes (default 15): " long_break
        long_break=${long_break:-15}
        echo -e "\nTaking a longer break for $long_break minutes"
        sleep "$((long_break * 60))"
        ;;
      *)
        echo "Alright then, have a good day!"
        break
        ;;
    esac
  done
}

# Call the function with command line arguments
repeat_pomodoro "$@"
