#!/bin/bash

echo "I lay these metrics at thy feet..."

# Function to draw a progress bar
draw_bar() {
    local percent=$1
    local size=20
    local filled=$(( percent * size / 100 ))
    local empty=$(( size - filled ))
    
    printf "["
    printf "%0.s#" $(seq 1 $filled)
    printf "%0.s." $(seq 1 $empty)
    printf "] %d%%\n" $percent
}

# Function to get CPU usage
get_cpu_usage() {
    top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}'
}

# Function to get memory usage
get_memory_usage() {
    free | grep Mem | awk '{print $3/$2 * 100.0}'
}

# Function to get disk usage
get_disk_usage() {
    df -h / | awk '/\// {print $5}' | sed 's/%//'
}

# Function to get system uptime
get_uptime() {
    uptime -p | sed 's/up //'
}

# Function to get top 5 CPU-consuming processes
get_top_cpu_processes() {
    ps aux --sort=-%cpu | head -n 4 | tail -n 5 | awk '{print $11, $3"%"}'
}

# Function to get top 5 memory-consuming processes
get_top_memory_processes() {
    ps aux --sort=-%mem | head -n 4 | tail -n 5 | awk '{print $11, $4"%"}'
}

# Main loop
while true; do
    clear
    echo "========================================="
    echo "          System Information"
    echo "========================================="
    echo

    # CPU Usage
    cpu_usage=$(get_cpu_usage)
    printf "CPU Usage:    "
    draw_bar ${cpu_usage%.*}

    # Memory Usage
    mem_usage=$(get_memory_usage)
    printf "Memory Usage: "
    draw_bar ${mem_usage%.*}

    # Disk Usage
    disk_usage=$(get_disk_usage)
    printf "Disk Usage:   "
    draw_bar $disk_usage

    # System Uptime
    echo
    echo "System Uptime: $(get_uptime)"

    # Top CPU-consuming processes
    echo
    echo "Top CPU-consuming processes:"
    get_top_cpu_processes | while read process cpu; do
        printf "%-20s %s\n" "$process" "	$cpu"
    done

    # Top memory-consuming processes
    echo
    echo "Top memory-consuming processes:"
    get_top_memory_processes | while read process mem; do
        printf "%-20s %s\n" "$process" "	$mem"
    done

    echo
    echo "Press Ctrl+C to exit"
    sleep 4
done