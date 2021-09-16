#!/bin/sh

dwm_network() {
    old_received_bytes=$received_bytes
    old_transmitted_bytes=$transmitted_bytes
    old_time=$now

    interface=$(ip route get 8.8.8.8 2>/dev/null| awk '{print $5}')
    netdev=$(grep $interface /proc/net/dev | cut -d ':' -f 2)
    received_bytes=$(echo $netdev | awk '{print "received_bytes="$1}')
    transmitted_bytes=$(echo $netdev | awk '{print "transmitted_bytes="$9}')

    now=$(date +%s%N)
}

function get_velocity {
    if [ "$old_time" = "" ]; then
        echo 0KB
        return
    fi
    value=$1
    old_value=$2

    timediff=$(($now - $old_time))
    velKB=$(echo "1000000000*($value-$old_value)/1024/$timediff" | bc)
    if [ $velKB -gt 1024 ]
    then
	echo $(echo "scale=2; $velKB/1024" | bc)MB
    else
        echo ${velKB}KB
    fi
}

dwm_cpu() {
    # CPU temperature
    CPU="$(top -bn1 | grep Cpu | awk '{print $2}')"
}

dwm_memory() {
    free_output=$(free -h | grep Mem)

    MEMUSED=$(echo $free_output | awk '{print $3}')
    MEMTOT=$(echo $free_output | awk '{print $2}')
}

dwm_alsa() {
    master=$(amixer get Master | tail -n1)
    power=$(echo $master | sed -r "s/.*\[(.*)\].*/\1/")
    VOL=$(echo $master | sed -r "s/.*\[(.*)%\].*/\1/")
    if [ "$power" = "off" ] || [ "$VOL" -le 0 ]; then
        ICON="婢"
    elif [ "$VOL" -gt 0 ] && [ "$VOL" -le 33 ]; then
        ICON=""
    elif [ "$VOL" -gt 33 ] && [ "$VOL" -le 66 ]; then
        ICON="奔"
    else
        ICON="墳"
    fi
}

dwm_backlight() {
	BACKLIGHT=$(xbacklight | cut -d '.' -f 1)
}

dwm_battery() {
    if [ ! -f "/sys/class/power_supply/BAT0/capacity" ]; then
	BATTERY="ﮣ"
	return
    fi

    CHARGE=$(cat /sys/class/power_supply/BAT0/capacity)
    STATUS=$(cat /sys/class/power_supply/BAT0/status)
    
    if [ "$STATUS" = "Charging" ]; then
	if [ $CHARGE -eq 100 ]; then
	    BATTERY_ICON=""
	elif [ $CHARGE -gt 90 ]; then
            BATTERY_ICON=""
	elif [ $CHARGE -gt 75 ]; then
            BATTERY_ICON=""
	elif [ $CHARGE -gt 60 ]; then
            BATTERY_ICON=""
	elif [ $CHARGE -gt 45 ]; then
            BATTERY_ICON=""
	elif [ $CHARGE -gt 30 ]; then
            BATTERY_ICON=""
	elif [ $CHARGE -lt 90 ]; then
            BATTERY_ICON=""
	else
            BATTERY_ICON=""
	fi
    else
        if [ $CHARGE -eq 100 ]; then
	    BATTERY_ICON=""
	elif [ $CHARGE -gt 90 ]; then
	    BATTERY_ICON=""
	elif [ $CHARGE -gt 75 ]; then
	    BATTERY_ICON=""
	elif [ $CHARGE -gt 60 ]; then
	    BATTERY_ICON=""
	elif [ $CHARGE -gt 45 ]; then
	    BATTERY_ICON=""
	elif [ $CHARGE -gt 30 ]; then
	    BATTERY_ICON=""
        else
            BATTERY_ICON=""
	fi
    fi
    BATTERY="$BATTERY_ICON $CHARGE"
}

dwm_date() {
    DATE="$(date '+%F %H:%M')" 
}

while true
do
    dwm_cpu
    dwm_memory
    dwm_alsa
    dwm_backlight
    dwm_date
    dwm_battery
    dwm_network

    xsetroot -name "  $CPU%  $MEMUSED  $(get_velocity $transmitted_bytes $old_transmitted_bytes $old_time)  $(get_velocity $received_bytes $old_received_bytes $old_time) $ICON $VOL ﯦ $BACKLIGHT $BATTERY  $DATE "

    sleep 2
done
