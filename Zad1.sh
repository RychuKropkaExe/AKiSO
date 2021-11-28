#!/bin/bash
tput civis
clear
arr=(0 0 0);
arw=(0 0 0);
art=(0 0 0);
ara=(0 0 0);
ars=(0 0 0);
ari=(0 0 0);
trigger=0;
counter=0;
while sleep 0.00000001; do
        #AVG
r1=$(grep -w sdc /proc/diskstats | awk '{print $6}')
w1=$(grep -w sdc /proc/diskstats | awk '{print $10}')
r1=$(bc -l <<< "scale=2;$r1/2")
w1=$(bc -l <<< "scale=2;$w1/2")
rt=$(grep -w sdc /proc/diskstats | awk '{print $7}')
wt=$(grep -w sdc /proc/diskstats | awk '{print $11}')
rt=$(bc -l <<< "scale=6;$rt/1000")
wt=$(bc -l <<< "scale=6;$wt/1000")
rs=$(bc -l <<< "scale=0; $r1/$rt")
ws=$(bc -l <<< "scale=0; $w1/$wt")
#KONIEC AVG
#AKTUALNA
sleep 0.1;
arr[$counter]=$(grep -w sdc /proc/diskstats | awk '{print $6}')
arw[$counter]=$(grep -w sdc /proc/diskstats | awk '{print $10}')
arr[$counter]=$(bc -l <<< "scale=0;${arr[$counter]}/2")
arw[$counter]=$(bc -l <<< "scale=0;${arw[$counter]}/2")
art[$counter]=$(grep -w sdc /proc/diskstats | awk '{print $7}')
art[$counter]=$(bc -l <<< "scale=9;${art[$counter]}/1000")
for((i=0; i<=2;i++)); do
        if (($i==0)); then
                if ((arr[0]==arr[2])); then
                        ara[0]=ara[2];
                else
                        ara[0]=$(bc -l <<< "scale=0;((${arr[0]}-${arr[2]})/(${art[0]}-${art[2]}))");
                fi
        else
                number=$(($i-1));
                if ((${arr[$i]}==${arr[$number]})); then
                        ara[$i]=ara[$number];
                else
                        ara[$i]=$(bc -l <<< "scale=0;(${arr[$i]}-${arr[$number]})/(${art[$i]}-${art[$number]})");
                fi
        fi
        done;
if (($counter>1)); then
        counter=0;
fi
#KONIEC AKTUALNEJ
t=$(awk '{print $1}' /proc/uptime)
d=$(bc -l <<< "scale=0;$t / 86400")
h=$(bc -l <<< "scale=0;(($t/3600)-($d*24))")
m=$(bc -l <<< "scale=0;(($t/60)-($d*1440)-($h*60))")
s=$(bc -l <<< "scale=0; ($t-($h*3600)-($d*86400)-($m*60))")
btF=$(grep -w "POWER_SUPPLY_ENERGY_FULL" /sys/class/power_supply/BAT0/uevent | grep -Eo '[0-9]{0,9}')
btN=$(grep -w "POWER_SUPPLY_ENERGY_NOW" /sys/class/power_supply/BAT0/uevent | grep -Eo '[0-9]{0,9}')
btS=$(bc -l <<< "scale=2; ($btN/$btF)*100")
sL=$(cat /proc/loadavg | awk '{print $1}')
mT=$(grep MemTotal /proc/meminfo | grep -Eo '[0-9]{0,9}')
mF=$(grep MemFree /proc/meminfo | grep -Eo '[0-9]{0,9}')
mU=$(bc -l <<< "scale=2;($mT-$mF)/1024")
pI=0
wI=0
rscale=0
wscale=0
#if begins
for num in {0..2}; do
        number=$(bc -l <<< "scale=0;${ara[$num]}/1")
        if (($number > 1024));
        then
                ars[$num]=$(bc -l <<< "scale=0; ${ara[$num]}/1000")
                ari[$num]="MB"
        else
                ars[$num]=$(bc -l <<< "scale=0;${ara[$num]}/10")
                ari[$num]="*10kB"
fi
done;
#if ends
echo Battery:$btS% 
echo uptime: d:$d h:$h m:$m s:$s
echo rs:$rs ws:$ws
echo systemLoad:$sL
echo MemUsed:$mU MB;
echo "Disk rspeed: "
# loop begins
if ((trigger>2)); then
        for (( num=0; num<=2; num++)); do
                echo $num
                number=${ars[$num]}
                for ((i=0; i <= $number; i++)); do
                        echo -e -n "$(tput setaf 2)■$(tput sgr 0)"
                done;
                echo -e ${ari[$num]} " Łącznie: ${ars[$num]}"
        done;
fi
#loop ends
sleep 1
trigger=$((trigger+1));
counter=$((counter+1));
clear
done


#next if begins
if test $ws -ge 1000
then
        wscale=$(bc -l <<< "scale=0; $ws/1000")
        wI="MB"
else
        wscale=$(bc -l <<< "scale=0;$ws/100")
        wI="*100kB"
fi
#if ends
echo Battery:$btS% 
echo uptime: d:$d h:$h m:$m s:$s
echo rs:$rs ws:$ws
echo systemLoad:$sL
echo MemUsed:$mU MB;
echo -n "Disk rspeed: "
# loop begins
for(( num=1; num<=$rscale; num++)); do
        echo -e -n "$(tput setaf 2)#$(tput sgr 0)"
done
#loop ends
echo " $pI"
echo -n "Disk wspeed: "
#loop begins
for(( num=1; num<=$wscale; num++)); do
        echo -e -n "$(tput setaf 3)#$(tput sgr 0)"
done
#loop ends
echo " $wI"
sleep 1
clear
done
