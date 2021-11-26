#!/user/bin/bash

ls /proc | grep '[0-9]' > /tmp/Aprc
echo PID: USER: %CPU %MEM VSZ RSS TTY START COMMAND FILES
while read -a line; do
        for word in ${line[@]}; do
                echo -n "$word "
                if test -d "/proc/$word"; then
                userid=$(grep Uid /proc/$word/status | awk '{print $2}')
                user=$(grep -w "$userid" /etc/passwd | cut -d: -f1)
                echo -n  "$user "
                fi
                if test -d "/proc/$word"; then
                        utime=$(cat /proc/$word/stat | awk '{print $14}')
                        stime=$(cat /proc/$word/stat | awk '{print $15}')
                        uptime=$(cat /proc/uptime)
                        starttime=$(cat /proc/$word/stat | awk '{print $21}')
                        time=$(bc -l <<< "scale=0;$utime+$stime")
                        seconds=$(bc -l <<< "scale=0;($uptime-($starttime/100))")
                        cpus_usage=$(bc -l <<< "scale=2;100*($time/100)/$seconds")
                        echo "$cpu_usage% "
                fi

        done;
done < /tmp/Aprc
