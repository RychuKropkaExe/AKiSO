#!/usr/bin/bash
lynx -dump "$1" > Site1
while sleep $2; do
lynx -dump "$1" > Site2
DifL=$(diff Site1 Site2 | wc -l)
if (($DifL > 0)) ; then
        echo "Strona uległa zmianie!";
fi
cat Site2 > Site1
done 
