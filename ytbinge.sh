#!/bin/bash
#
# ytbinge - casual YouTube binge script.
# Downloads videos temporarily as you go from a youtube channel
# and plays them with mplayer

#todo
#checks
#bw behaviours
#check if end
#dl channel first shuffle
#anti ddos


URL="$1"
urlentry="1"

TEMPDIR="/tmp/ytbinge"
MPLAYEROPT="fs"

function spinner {
	tput civis
    local pid=$1
    local color=1
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
    	tput sc
    	tput setaf $(( ( RANDOM % 255 )  + 1 ))
    	echo -n "|"
    	tput rc
    	sleep 0.1

    	tput sc
    	tput setaf $(( ( RANDOM % 255 )  + 1 ))
    	echo -n "/"
    	tput rc
    	sleep 0.1

    	tput sc
    	tput setaf $(( ( RANDOM % 255 )  + 1 ))
    	echo -n "-"
    	tput rc
    	sleep 0.1

    	tput sc
    	tput setaf $(( ( RANDOM % 255 )  + 1 ))
    	echo -n '\'
    	tput rc
    	sleep 0.1
    done
    tput cnorm
}

chandl() {
	youtube-dl --get-id "$URL" > "$TEMPDIR/urls"
	touch "$TEMPDIR/done"
}


play() {
	echo "PRAYER     mplayer -vo "$MPLAYEROPT" -really-quiet "$1""
	mplayer "$MPLAYEROPT" -really-quiet "$1"
}

download() {
	youtube-dl -o "$TEMPDIR/next" -q "http://youtube.com/watch?v=$1"
}

swap() {
	mv "$TEMPDIR/$1.mkv" "$TEMPDIR/$2"
	mv "$TEMPDIR/$1.mp4" "$TEMPDIR/$2"
	mv "$TEMPDIR/$1.swf" "$TEMPDIR/$2"
}

main() {
	echo -en "Downloading channel..."
	chandl &
	chandlPID="$!"
	echo $chandlPID
	sleep 5 &
	spinner $!
	tput el
	#echo -en "Downloading first video..."
	#echo "FDling "$(sed -n "${urlentry}p" "$TEMPDIR/urls")""
	download "$(sed -n "${urlentry}p" "$TEMPDIR/urls")" &
	spinner $!
	tput el
	(( urlentry++ ))
	until [[ "$urlentry" -eq "$urls" ]]; do
		swap next current &> /dev/null
		#echo "DLing: "$(sed -n "${urlentry}p" "$TEMPDIR/urls")""
		download "$(sed -n "${urlentry}p" "$TEMPDIR/urls")" &
		#ls $TEMPDIR
		#sleep 3
		#echo plAY
		play "$TEMPDIR/current"
		#echo dplay
		#sleep 10
		[[ -f "$TEMPDIR/done" ]] && urls=$(wc -l < "$TEMPDIR/urls") && rm "$TEMPDIR/done"
		(( urlentry++ ))
	done
}

rm -rf "$TEMPDIR"
mkdir $TEMPDIR
main
kill -9 $chandlPID
