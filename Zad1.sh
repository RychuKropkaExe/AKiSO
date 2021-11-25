#!/bin/bash
tput civis
clear
while sleep 0.00000001; do
r1=$(grep -w sdc /proc/diskstats | awk '{print $6}')
w1=$(grep -w sdc /proc/diskstats | awk '{print $10}')
r1=$(bc -l <<< "scale=2;$r1/2")
w1=$(bc -l <<< "scale=2;$w1/2")
dt=$(grep -w sdc /proc/diskstats | awk '{print $7}')
dt=$(bc -l <<< "scale=2;$dt/1000")
rs=$(bc -l <<< "scale=0; $r1/$dt")
ws=$(bc -l <<< "scale=0; $w1/$dt")
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
if test $rs -ge 1000
then
        rscale=$(bc -l <<< "scale=0; $rs/1000")
        pI="MB"
else
        scale=$(bc -l <<< "scale=0;$rs/100")
        pI="*100kB"
fi
#if ends
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
