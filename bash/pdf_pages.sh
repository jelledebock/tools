#!/bin/sh

FILES=$1
totalpages=0
for f in $FILES
do
    fn=$(basename "$f")
    pg=$(exiftool "$f" | grep 'Page Count' | cut -c35-)
done

while read line
do
    totalpages=$(( $totalpages + $line ))
done <<<"$pg"

printf "$totalpages\n"
