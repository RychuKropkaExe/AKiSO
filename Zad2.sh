#!/user/bin/bash
ls /proc | grep '[0-9]' > /tmp/Aprc
printf "PID\tUSER\t%%CPU\t%%MEM\tVSZ\tSTAT\tFILES\t \n"
while read -a line; do
        for word in ${line[@]}; do
                if test -d "/proc/$word"; then
                        printf "$word\t"
                        userid=$(grep Uid /proc/$word/status | awk '{print $2}')
                        user=$(grep -w "$userid" /etc/passwd | cut -d: -f1)
                        printf "$user\t"
                        utime=$(cat /proc/$word/stat | awk '{print $14}')
                        stime=$(cat /proc/$word/stat | awk '{print $15}')
                        starttime=$(cat /proc/$word/stat | awk '{print $21}')
                        uptime=$(cat /proc/uptime | awk '{print $1}')
                        time=$(bc -l <<< "scale=0;$utime+$stime")
                        seconds=$(bc -l <<< "scale=0;($uptime-($starttime/100))")
                        cpu_usage=$(bc -l <<< "scale=2;$time/$seconds")
                        printf "$cpu_usage%%\t"
                        mem=$(cat /proc/$word/statm | awk '{print $2}')
                        memU=$(bc -l <<< "scale=2; (100*($mem/1024))/7829")
                        printf "$memU%%\t"
                        VSZ=$(cat /proc/$word/statm | awk '{print $1}')
                        printf "$VSZ\t"
                        stat=$(grep State /proc/$word/status | awk '{print $2}')
                        printf "$stat\t"
                        Files=$(ls -l /proc/$word/fdinfo | wc -l)
                        printf "$Files\n"


                fi

        done;
done < /tmp/Aprc
