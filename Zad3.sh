#!/usr/bin/bash

wget --output-document=catimg.png https://api.thecatapi.com/v1/images/search
URL=$(cat catimg.png | cut -d\" -f10)
wget --output-document=catimg.png "$URL"
wget --output-document=random http://api.icndb.com/jokes/random
CN=$(cat random | cut -d\" -f12)
catimg catimg.png
echo $CN
