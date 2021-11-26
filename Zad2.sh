#!/usr/bin/bash
ls /proc | grep '[0-9]' > /tmp/Aprc
echo PID: USER: %CPU %MEM VSZ STAT FILES
while read -a line; do
        for word in ${line[@]}; do
                if test -d "/proc/$word"; then
                        echo -n "$word "
                        userid=$(grep Uid /proc/$word/status | awk '{print $2}')
                        user=$(grep -w "$userid" /etc/passwd | cut -d: -f1)
                        echo -n  "$user "
                        utime=$(cat /proc/$word/stat | awk '{print $14}')
                        stime=$(cat /proc/$word/stat | awk '{print $15}')
                        starttime=$(cat /proc/$word/stat | awk '{print $21}')
                        uptime=$(cat /proc/uptime | awk '{print $1}')
                        time=$(bc -l <<< "scale=0;$utime+$stime")
                        seconds=$(bc -l <<< "scale=0;($uptime-($starttime/100))")
                        cpu_usage=$(bc -l <<< "scale=2;$time/$seconds")
                        echo -n "$cpu_usage% "
                        mem=$(cat /proc/$word/statm | awk '{print $2}')
                        memU=$(bc -l <<< "scale=2; (100*($mem/1024))/7829")
                        echo -n "$memU% "
                        VSZ=$(cat /proc/$word/statm | awk '{print $1}')
                        echo -n "$VSZ "
                        stat=$(grep State /proc/$word/status | awk '{print $2}')
                        echo -n "$stat "
                        Files=$(sudo ls -l /proc/$word/fd | awk '{print $11}' | paste -d, -s)
                        echo "$Files "


                fi

        done;
done < /tmp/Aprc
