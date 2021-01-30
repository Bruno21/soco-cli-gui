#!/usr/bin/env bash

# A bash GUI for soco-cli (https://github.com/avantrec/soco-cli/)
# Apache License 2.0

#set -e
#set -u
#set -o pipefail

list="local"
if [ "$list" = "discovery" ]; then loc="";
else loc=" -l"; fi

# Needed to get the soco-cli update
# add_your_token_below
GITHUB_TOKEN=

discover=$(sonos-discover -p)
dev=$(echo "$discover" | grep -E "([0-9]{1,3}[\.]){3}[0-9]{1,3}")
nbdevices=$(echo "$discover" | grep "Sonos device(s) found" | awk '{print $1}')

#dev=$(cat dev.txt)
#nbdevices=$(echo "$dev" | wc -l | xargs)
#echo "$dev \n $nbdevices"

italic="\033[3m"
underline="\033[4m"
bgd="\033[1;4;31m"
red="\033[1;31m"
bold="\033[1m"
bold_under="\033[1;4m"
reset="\033[0m"

function is_int() { test "$@" -eq "$@" 2> /dev/null; } 

# Main Menu

main() {

	clear
	set device
	device="$1"
	
	while :
	do
		clear
		
		echo -e ""
		echo -e "${bold} 🔈 SoCo-Cli GUI${reset}"
		echo -e ""
		echo -e " "
		echo -e "---------------------------------"
		echo -e "               Main Menu         "
		echo -e "---------------------------------"
		echo -e " 1) ${bgd}A${reset}bout          "
		echo -e " 2) ${bgd}H${reset}elp           "
		
		j=3
		while IFS= read -r line; do
			name=$(echo "${line}" | awk '{print $1}')
			model=$(echo "${line}" | awk '{print $3}')
			
			sc=${name:0:1}
			last=${name:1}
			echo -e " $j) ➔ Sonos $model device: ${bgd}$sc${reset}$last"
			
			((j++))
		done <<< "$dev"

		l=$j		# All devices entries
		k=$((j+1))	# Quit entrie

		echo -e " $j) ➔ A${bgd}l${reset}l devices  "
		echo -e " $k) ${bgd}Q${reset}uit           " 
		echo -e "================================="
		echo -e "Enter your menu choice [1-$k]: \c "

		read main_menu
		

		for i in {3..4}
		do
			
			if is_int "$main_menu"; then
				nth=$(($main_menu - 2))
				nth_device=$(echo "$dev" | sed -n "${nth}p")
				name=$(echo "${nth_device}" | awk '{print $1}')
				sc=${name:0:1}
				#echo -en "\007"
			else
				d=$(echo "$dev" | awk '{print $1}')
				sc=${main_menu^}	# Capitalize
				sc=${sc:0:1}		# First letter
				#echo "-$sc-"
				# tr [a-z] [A-Z
				name=$(echo "$d" | grep -E ^$sc)	# shortcut = first letter of a device
				#echo "-$name-"
				#echo -en "\007"
			fi
			
			#echo "$nth - $nth_device - $name"
			# 1 - Chambre           192.168.2.232  One             Visible       12.2.2 - Chambre
			#read -p ""
			
			#if [ $main_menu == "$i" ] || [ $main_menu == "$sc" ]; then
			if [ $main_menu == "$i" ] || [ -n "$name" ]; then
				#nth=$(($main_menu - 2))
				#nth_device=$(echo "$dev" | sed -n "${nth}p")
				#name=$(echo "${nth_device}" | awk '{print $1}')
			
				soco $name
			
			fi
		done
		#read -p ""
		
		if [ $main_menu == "13" ] || [ $main_menu == "14" ]; then
			
			nth=$(($main_menu - 2))
			nth_device=$(echo "$dev" | sed -n "${nth}p")
			name=$(echo "${nth_device}" | awk '{print $1}')
			
			soco $name
			
		elif [ $main_menu == "1" ] || [[ $main_menu == "a" ]] || [[ $main_menu == "A" ]]; then
			about
		elif [ $main_menu == "2" ] || [[ $main_menu == "h" ]] || [[ $main_menu == "H" ]]; then
			help
		elif [ $main_menu == "$j" ] || [[ $main_menu == "l" ]] || [[ $main_menu == "L" ]]; then
			all
		elif [ $main_menu == "$k" ] || [[ $main_menu == "q" ]] || [[ $main_menu == "Q" ]]; then
			exit 0
		else
			echo -e "\n${red}Oops!!! Please Select Correct Choice${reset}";
			echo -e "Press ${bold}ENTER${reset} To Continue..." ;
			read -p ""
		fi

	done
	}


about() {
	vers=$(sonos -v)
	reponse=""
	last_tag=""
	if [ -n "$GITHUB_TOKEN" ]; then
		GITHUB_API_HEADER_ACCEPT="Accept: application/vnd.github.v3+json"
		GITHUB_API_REST="/repos/avantrec/soco-cli/tags"
		reponse=$(curl -H "${GITHUB_API_HEADER_ACCEPT}" -H "Authorization: token $GITHUB_TOKEN" -s "https://api.github.com${GITHUB_API_REST}")
	fi
	[ -n "$reponse" ] && last_tag=$(echo $reponse | jq '.[0] | (.name)') || last_tag="-"

	clear
	echo ""
	echo -e "${bold}About:${reset}"
	echo ""
	echo -e "${bold}            #####             #####                     ####      ####                                 ## ${reset}"
	echo -e "${bold}           ##   ##           ##   ##                     ##        ## ${reset}"
	echo -e "${bold}   #####   ##   ##   ####    ##   ##            ####     ##        ##               ### ##  ##  ##    ### ${reset}"
	echo -e "${bold}  ##       ##   ##  ##  ##   ##   ##  ######   ##  ##    ##        ##              ##  ##   ##  ##     ## ${reset}"
	echo -e "${bold}   #####   ##   ##  ##       ##   ##           ##        ##   #    ##              ##  ##   ##  ##     ## ${reset}"
	echo -e "${bold}       ##  ##   ##  ##  ##   ##   ##           ##  ##    ##  ##    ##               #####   ##  ##     ## ${reset}"
	echo -e "${bold}  ######    #####    ####     #####             ####    #######   ####                 ##    ######   #### ${reset}"
	echo -e "${bold}                                                                                   ##### ${reset}"
	echo ""
	echo "Just a GUI for the wonderful tool SoCo-Cli"
	echo ""
	echo "https://github.com/avantrec/soco-cli"
	echo ""
	echo "To install / upgrade soco-cli: pip3 install -U soco-cli (last tag: $last_tag)"
	
	echo -e "\n$vers\n"
	echo "<Press Enter to quit>"
	read -p ""
	}

	
help() {
	clear
	echo ""
	echo -e "${bold_under}Help:${reset}"

	echo -e "\n${bold}Main Menu:${reset}"
			
	echo -e "  ${italic}1) About:${reset} about page"
	echo -e "  ${italic}2) Help:${reset} this page"
	u=$((3+nbdevices-1))
	#echo "$u"
	echo -e "  Next (3-$u), all your Sonos device are automatically discover. Each call the main function soco()"
	echo -e "  ${italic}3-$u) ➔ Sonos <model> device <Name>:${reset} Command your <Name> device"
	#echo -e "  Last,  device"
	echo -e "  ${italic}$((u+1))) ➔ All devices:${reset} command all your device together"	
	echo -e "  ${italic}$((u+2))) Quit:${reset} quit the app" 

	echo -e "\n${bold}Sonos <$device> Menu:${reset}"

	echo -e " ${italic}[1-10] Play favorites:${reset} edit and duplicate functions option_1 to option_10 to add your favs"
	echo -e " ${italic}11) volume 11:${reset} set volume to level 11"
	echo -e " ${italic}12) mute ON:${reset}          "
	echo -e " ${italic}13) volume 13:${reset} set volume to level 13"
	echo -e " ${italic}14) mute OFF:${reset}        "
	echo -e " ${italic}15) volume 15:${reset} set volume to level 15"
	echo -e " ${italic}16) start <$device>:${reset}      "
	echo -e " ${italic}17) stop <$device>:${reset}       "
	echo -e " ${italic}18) pause on $device>:${reset}   "
	echo -e " ${italic}19) prev on <$device>:${reset}    "
	echo -e " ${italic}20) next on <$device>:${reset}    "

	echo -e " ${italic}21) ➔ Infos :${reset}    "
	echo -e " ${italic}22) ➔ Lists :${reset}   "
	echo -e " ${italic}23) Play albums:${reset}               "
	echo -e " ${italic}24) Play artists:${reset} "
	echo -e " ${italic}25) Play tracks:${reset}  "
	echo -e " ${italic}26) Sleeep:${reset}      "
	echo -e " ${italic}27) Shazaaaam:${reset}        "
	echo -e " ${italic}28) Switch Status Light:${reset}"
	echo -e " ${italic}29) Help:${reset}        "
	echo -e " ${italic}30) ➔ Accueil :${reset}     "

	echo -e "\n${bold}Sonos <$device> infos Menu:${reset}"
	echo -e " ${italic}1) Alarms:${reset}                   " 
	echo -e " ${italic}2) Groups:${reset}                  "
	echo -e " ${italic}3) Info:${reset}                     "
	echo -e " ${italic}4) Shares:${reset}                   "
	echo -e " ${italic}5) Sysinfo:${reset}                  "
	echo -e " ${italic}10) Return:${reset}                   "

	echo -e "\n${bold}Sonos <$device> lists Menu:${reset}"
	echo -e " ${italic}1) Favourite radio stations:${reset} "
	echo -e " ${italic}2) Favourites:${reset}               "
	echo -e " ${italic}3) Queue:${reset}                   "
	echo -e " ${italic}4) List artists:${reset} list artists on library"
	echo -e " ${italic}5) List albums:${reset} list albums on library"
	echo -e " ${italic}8) Remove from queue:${reset}        "
	echo -e " ${italic}9) Clear queue:${reset}              "
	echo -e " ${italic}11) Create Sonos playlist:${reset}               "
	echo -e " ${italic}12) List playlists:${reset}                     "
	echo -e " ${italic}13) Delete playlists:${reset}                    "
	echo -e " ${italic}14) Lists tracks in all Sonos Playlists:${reset} "
	echo -e " ${italic}15) Add a Sonos playlist to queue:${reset}       "
	echo -e " ${italic}16) Remove a track from a Sonos playlist:${reset}                                    "
	echo -e " ${italic}20) Return:${reset}                             "

	echo -e "\n<Press Enter to quit>"
	read -p ""
	}


inform() {
	device="$1"
	info=$(sonos $loc $device info)
	model_name=$(echo "$info" | grep "model_name" | awk -F"=" '{print $2}')
	model_number=$(echo "$info" | grep "model_number" | awk -F"=" '{print $2}')
	player_name=$(echo "$info" | grep "player_name" | awk -F"=" '{print $2}')
	zone_name=$(echo "$info" | grep "zone_name" | awk -F"=" '{print $2}')
	mac_address=$(echo "$info" | grep "mac_address" | awk -F"=" '{print $2}')
	ip_address=$(echo "$info" | grep "ip_address" | awk -F"=" '{print $2}')
	display_version=$(echo "$info" | grep "display_version" | awk -F"=" '{print $2}')
	hardware_version=$(echo "$info" | grep "hardware_version" | awk -F"=" '{print $2}')
	software_version=$(echo "$info" | grep "software_version" | awk -F"=" '{print $2}')
	
	echo ""
	printf "\e[1m| %-20s | %-20s |\e[0m\n" "$model_name" "$player_name"
	printf "| %-20s | %-20s |\n" "Model name" "$model_name"
	printf "| %-20s | %-20s |\n" "Model number" "$model_number"
	printf "| %-20s | %-20s |\n" "Player name" "$player_name"
	printf "| %-20s | %-20s |\n" "Zone name" "$zone_name"
	printf "| %-20s | %-20s |\n" "mac adress" "$mac_address"
	printf "| %-20s | %-20s |\n" "IP address" "$ip_address"
	printf "| %-20s | %-20s |\n" "Display version" "$display_version"
	printf "| %-20s | %-20s |\n" "Hardware version" "$hardware_version"
	printf "| %-20s | %-20s |\n" "Software version" "$software_version"
	echo ""
	}


# Soco device Menu

soco() {
	clear
	#set device
	playing=""
	device="$1"
	
	# don't touch spaces below
	sp="            "
	device12="${device:0:12}${sp:0:$((12 - ${#device}))}"
	
	while :
	do
		clear
        echo -e ""
        echo -e "${bold} 🔊 Sonos $device ${reset}"
        echo -e ""
		echo -e " "
		echo -e "------------------------|--------------------------------|------------------------------"
		echo -e "                 Sonos $device Menu : $playing                                          "
		echo -e "------------------------|--------------------------------|------------------------------"
		echo -e " 1) France In${bgd}f${reset}o       " " | " "11) volume ${bgd}11${reset}               " " | " "26) ➔ ${bgd}I${reset}nfos     "
		echo -e " 2) France Int${bgd}e${reset}r      " " | " "12) ${bgd}m${reset}ute ON                 " " | " "27) ➔ ${bgd}L${reset}ists     "
		echo -e " 3) ${bgd}K${reset}6 FM             " " | " "13) volume ${bgd}13${reset}               " " | " "28) Pl${bgd}a${reset}y radio from TuneIn               "
		echo -e " 4) Rires et ${bgd}C${reset}hansons " " | " "14) m${bgd}u${reset}te OFF                " " | " "29) Pla${bgd}y${reset} local .m3u playlist               "
		echo -e " 5) ${bgd}R${reset}TL               " " | " "15) volume ${bgd}15${reset}               " " | " "30) Play locals audio files               "
		echo -e " 6) ${bgd}D${reset}eezer Flow       " " | " "16) volume ${bgd}+${reset}                " " | " "31) Play al${bgd}b${reset}ums               "
		echo -e " 7) ${italic}Edit/add fav here${reset} " " | " "17) volume ${bgd}-${reset}                " " | " "32) Play artists (${bgd}x${reset}) "
		echo -e " 8)                   " " | " "18) pause ${bgd}o${reset}n $device12   " " | " "33) Play tracks (${bgd}y${reset})  "
		echo -e " 9)                   " " | " "19) ${bgd}p${reset}rev on $device12    " " | " "34) Sleeep (${bgd}j${reset})      "
		echo -e "10)                   " " | " "20) ${bgd}n${reset}ext on $device12    " " | " "35) Sha${bgd}z${reset}aaaam        "
		echo -e "                      " " | " "21) ${bgd}s${reset}tart $device12      " " | " "36) S${bgd}w${reset}itch Status Light    "
		echo -e "                      " " | " "22) s${bgd}t${reset}op $device12       " " | " "37)     "
		echo -e "                      " " | " "23)                         " " | " "38)     "
		echo -e "                      " " | " "24)                         " " | " "39)     "
		echo -e "                      " " | " "25)                         " " | " "40) ➔ ${bgd}H${reset}ome     "
		echo -e "========================================================================================"
		echo -e "Enter your menu choice [1-40]: \c "
		read soco_menu
	
		case "$soco_menu" in

			# Play your favs from 1 to 10
			1|f|F) option_1;;
			2|e|E) option_2;;
			3|k|K) option_3;;
			4|c|C) option_4;;
			5|r|R) option_5;;
			6|d|D) option_6;;
			7) option_7;;
			11) option_11;;
			12|m|M) option_12;;
			13) option_13;;
			14|u|U) option_14;;
			15) option_15;;
			16|+) vol_+;;
			17|-) vol_-;;
			18|s|S) option_16;;
			19|t|T) option_17;;
			20|o|O) option_18;;
			21|p|P) option_19;;
			22|n|N) option_20;;
			26|i|I) soco_infos $device;;
			27|l|L) soco_lists $device;;
			28|a|A) play_radio_from_tunein;;
			29) play_local_m3u;;
			30) play_local_file;;	
			31|b|B) play_album_from_library;;
			32|x|X) play_artist_from_library;;
			33|y|Y) play_track_from_library;;
			34|j|J) sleeep;;
			35|z|Z) option_27;;
			36|w|W) led;;
			40|h|H) exec "$0";;
			*) echo -e "\n${red}Oops!!! Please Select Correct Choice${reset}";
			   echo -e "Press ${bold}ENTER${reset} To Continue..." ; read ;;
		esac
	done
	}

### ADD YOUR FAVS HERE ###

# Playing France Info
option_1() {
	#echo "$loc"
	playing="Playing France Info..."
	echo -e "\n${bold} $playing ${reset}"
	sonos $loc $device play_fav 'franceinfo' && sleep 2
	}

# Playing France Inter
option_2() {
	playing="Playing France Inter..."
	echo -e "\n${bold} $playing ${reset}"
	sonos $loc $device play_fav 'france inter' && sleep 2
	}

# Playing K6 FM
option_3() {
	playing="Playing K6 FM..."
    echo -e "\n${bold} $playing ${reset}"
    sonos $loc $device play_fav 'K6 FM' && sleep 2
	}

# Playing Rires et Chansons
option_4() {
	playing="Playing Rires et Chansons..."
    echo -e "\n${bold} $playing ${reset}"
    sonos $loc $device play_fav 'Rire et Chansons' && sleep 2
	}

# Playing RTL
option_5() {
	playing="Playing RTL..."
    echo -e "\n${bold} $playing ${reset}"
	sonos $loc $device play_fav 'RTL' && sleep 2
	}

# Playing Deezer Flow
option_6() {
	playing="Playing Deezer Flow..."
    echo -e "\n${bold} $playing ${reset}"
    sonos $loc $device play_fav 'Flow' && sleep 2
	}

# Playing ...
option_7() {
	playing="Playing..."
    echo -e "\n${bold} $playing ${reset}"
    #sonos $loc $device play_fav '<favori>' && sleep 2
	}

### /ADD YOUR FAVS HERE ###


# Set volume to level 11
option_11() {
	#playing="Playing Deezer Flow..."
    echo -e "\n${bold} Set volume to level 11... ${reset}"
    sonos $loc $device volume 11 && sleep 2
	}

# Mute ON
option_12() {
	playing="Mute ON..."
    echo -e "\n${bold} $playing ${reset}"
    sonos $loc $device mute on && sleep 2
	}

# Set volume to level 13
option_13() {
	#playing="Start $device..."
    echo -e "\n${bold} Set volume to level 13... ${reset}"
    sonos $loc $device volume 13 && sleep 2
	}

# Mute OFF
option_14() {
	playing=""
    echo -e "\n${bold} Mute OFF... ${reset}"
    sonos $loc $device mute off && sleep 2
	}

# Set volume to level 15
option_15() {
	#playing="Stop $device..."
    echo -e "\n${bold} Set volume to level 15... ${reset}"
    sonos $loc $device volume 15 && sleep 2
	}

# Start $device
option_16() {
	playing="Start $device..."	# <= Shazaaam
    echo -e "\n${bold} $playing ${reset}"
    sonos $loc $device start && sleep 2
	}

# Stop $device
option_17() {
	playing="Stop $device..."
    echo -e "\n${bold} $playing ${reset}"
    sonos $loc $device stop && sleep 2
	}

# Pause $device
option_18() {
	playing="Pause $device..."
    echo -e "\n${bold} $playing ${reset}"
    sonos $loc $device pause && sleep 2
	}

# Previous tracks
option_19() {
	#playing="Start $device..."	# <= Shazaaam
    echo -e "\n${bold} $playing ${reset}"
    sonos $loc $device previous && sleep 2
	}

# Next tracks
option_20() {
	#playing="Stop $device..."	# <= Shazaaam
    echo -e "\n${bold} $playing ${reset}"
    sonos $loc $device next && sleep 2
	}

vol_+() {
	#playing="Volume +..."
    #echo -e "\n${bold} $playing ${reset}"
    volume=$(sonos $loc $device volume)
    vol=$((volume+1))
    sonos $loc $device volume $vol
    echo -e "\nSet volume to ${bold}level $vol${reset}" && sleep 0.5
	}

vol_-() {
	#playing="Volume -..."
    #echo -e "\n${bold} $playing ${reset}"
    volume=$(sonos $loc $device volume)
    vol=$((volume-1))
    sonos $loc $device volume $vol
    echo -e "\nSet volume to ${bold}level $vol${reset}" && sleep 0.5
	}

# Play favorite from TuneIn radio
play_radio_from_tunein() {
	playing="Play a radio from TuneIn..."
    echo -e "\n${bold} $playing ${reset}"

	list=$(sonos $loc $device favourite_radio_stations)
	echo -e "$list\n"
	
	read -p "Radio to play: " number
	
	radio=$(echo "$list" | awk 'NF' | sed "${number}q;d" | awk -F '[0-9]+:' '{print $2}' | xargs)
	
	playing="Play $radio from TuneIn..."
	sonos $loc $device play_fav_radio_station_no $number
	echo "$playing"
	}

# Play local .m3u playlist
play_local_m3u() {
	playing="Play a local .m3u playlist..."
    echo -e "\n${bold} $playing ${reset}\n"

	# /Users/bruno/Music/Shaka Ponk - Apelogies/CD1/playlist.m3
	
	# ${directory////\\/}
	# sed 's/ /\\ /g'
	
	#plt=$(ls *.m3u*)
	#cd /Users/bruno/Music/Shaka\ Ponk\ -\ Apelogies/CD1
	
	read -e -p "Enter .m3u file path: " fp
	
	m3u=$(echo "$fp" | awk -F"/" '{print $NF}')
	if [ -a "$fp" ]; then
		echo -e "\n${underline}$m3u:${reset}"
		pls=$(cat "$fp")
		echo -e "\n$pls\n"
		sonos $loc $device play_m3u "$fp" pi
	else
		echo -e "File ${bold}$m3u${reset} doesn't exist!"
	fi
}

# Read tags from mp3 file
minfo () {
	#echo "s1: $1"
	info=$(mediainfo "$1")
	
	album=$(echo "$info" | grep -m 1 'Album ')
	performer=$(echo "$info" | grep -m 1 'Performer')
	duration=$(echo "$info" | grep -m 1 'Duration ')
	track=$(echo "$info" | grep -m 1 'Track name ')
	year=$(echo "$info" | grep -m 1 'Recorded date ')
	codec=$(echo "$info" | grep -m 1 'Codec ID/Info ')
	format=$(echo "$info" | grep -m 1 'Format ')
	profile=$(echo "$info" | grep -m 1 'Format profile ')
	format="${format#*: } ${profile#*: }"
	
	if [ -n "$2" ]; then	
		printf " %-2s %-20s  %-30s %-30s %-12s %-10s \n" "$2" "${performer#*: }" "${track#*: }" "${album#*: }" "${duration#*: }" "${year#*: }"
	else
		printf " %-12s  %-35s \n" "Artist:" "${performer#*: }"
		printf " %-12s  %-35s \n" "Track:" "${track#*: }"
		printf " %-12s  %-35s \n" "Album:" "${album#*: }"
		printf " %-12s  %-35s \n" "Duration:" "${duration#*: }"
		printf " %-12s  %-35s \n" "Year:" "${year#*: }"
		if [ -n "$codec" ]; then
			printf " %-12s  %-35s \n" "Codec:" "${codec#*: }"
		elif [ -n "$format" ]; then
			printf " %-12s  %-35s \n" "Format:" "${format#*: }"
		fi
	fi
}

# play local file (.mp3|.mp4|.m4a|.aac|.flac|.ogg|.wma|.wav)
# alac in m4v

play_local_file() {
	playing="Play a local audio file..."
    echo -e "\n${bold} $playing ${reset}\n"

	echo -e "${underline}Enter audio file/folder path${reset} (.mp3|.mp4|.m4a|.aac|.flac|.ogg|.wma|.wav) "
	read -e -p ": " fa
	
	#fa=/Users/bruno/Music/Alanis\ Morissette\ -\ Such\ Pretty\ Forks\ In\ The\ Road
	
	if ! command -v mediainfo &> /dev/null; then
		echo "Install mediainfo to display media tags !"
		echo -e "${italic}brew install mediainfo${reset}"
		mediainfo=false
	else
		mediainfo=true
	fi
	
	audio=$(echo "$fa" | awk -F"/" '{print $NF}')
	
	if [ -d "$fa" ]; then
		if [[ "$OSTYPE" == "darwin"* ]]; then
			list=$(find -E "$fa" -iregex ".*\.(mp3|mp4|m4a|aac|flac|ogg|wma|wav)" | sort)
		else
			list=$(find "$fa" -iregex ".*\.\(mp3\|mp4\|m4a\|aac\|flac\|ogg\|wma\|wav\)" | sort)
		fi

		echo -e "\n${underline}Tracks to play...${reset}"
		i=1
		while IFS= read -r line; do
			[ "$mediainfo" = true ] && minfo "${line}" "$i"
			((i++))
		done <<< "$list"
		
		echo -e "\n${underline}Playing...${reset}"
		echo -e "\nHit CTRL-C to play next track \n"
		printf " %-2s %-20s  %-30s %-30s %-12s %-10s \n" "N°" "Artist" "Track" "Album" "Duration" "Year"
		
		i=1
		while IFS= read -r line; do
			[ "$mediainfo" = true ] && minfo "${line}" "$i"
			
			sonos $loc $device play_file "${line}"
			((i++))
		done <<< "$list"

		#sonos $loc $device play_file "$list"
	
	elif [ -f "$fa" ]; then
		echo -e "\nCurrently playing ${underline}$audio${reset} ...\n"
		[ "$mediainfo" = true ] && minfo "$fa"

		echo -e "\n${italic}Wait for the music to end, hit <sonos -l $device stop> from another shell or hit CTRL-C to quit${reset}"
		sonos $loc $device play_file "$fa"
		#album_art
	else
		echo -e "❗ ️File/folder ${bold}$audio${reset} doesn't exist!" && sleep 2
		playing=""
	fi
}

# Search artist in library -> add album to queue -> play it
play_artist_from_library() {
	read -p "Search artist in library: " search
	
	a=$(sonos $loc $device search_artists "$search")
	echo -e "$a\n"
	read -p "Album to play: " number
	
	b=$(echo "$a" | grep "$number: ")
	album=$(echo "$b" | awk -F ": " '{print $3}' | awk -F "|" '{print $1}' | sed 's/ *$//g')
	artist=$(echo "$b" | awk -F ": " '{print $4}')

	playing="Playing $album from $artist..."
    echo -e "\n${bold} $playing ${reset}"
	
	sonos $loc $device queue_search_result_number $number first : $device play_from_queue > /dev/null
	}

# Search album in library -> add to queue -> play it
play_album_from_library() {
	read -p "Search album in library: " search
	
	a=$(sonos $loc $device search_albums "$search")
	echo -e "$a\n"
	read -p "Album to play: " number
	
	b=$(echo "$a" | grep "$number: ")	
	album=$(echo "$b" | awk -F ": " '{print $3}' | awk -F "|" '{print $1}' | sed 's/ *$//g')
	artist=$(echo "$b" | awk -F ": " '{print $4}')
	
	playing="Playing $album from $artist..."
    echo -e "\n${bold} $playing ${reset}"

	sonos $loc $device queue_search_result_number $number first : $device play_from_queue > /dev/null
	}

# Search track in library -> add to queue -> play it
play_track_from_library() {
	read -p "Search track in library: " search
	
	a=$(sonos $loc $device search_tracks "$search")
	echo -e "$a\n"
	read -p "Track to play: " number

	b=$(echo "$a" | grep "$number: ")
	# 1: Artist: Alain Souchon | Album: Collection (1984-2001) | Title: J'veux du cuir	
	track=$(echo "$b" | awk -F ": " '{print $5}')
	artist=$(echo "$b" | awk -F ": " '{print $3}' | awk -F "|" '{print $1}' | sed 's/ *$//g')

	playing="Playing $track from $artist..."
    echo -e "\n${bold} $playing ${reset}"
	
	sonos $loc $device queue_search_result_number $number first : $device play_from_queue > /dev/null
	}

# Help
help_soco() {
	echo -e "\n${bold} Help... ${reset}\n"
	echo -e "Play albums:"
	echo -e "Play artists:"
	echo -e "Play tracks:"
	
	echo -e "\n"
	read -p "< Press Enter>"
	}

# Sleep timer
sleeep() {
	playing="Set sleep timer..."
    echo -e "\n${bold} $playing ${reset}"
  
	status=$(sonos $loc $device status)
	if [[ "$status" != "STOPPED" ]]; then
	
  		while :
		do
  
   		echo -e "\n1) -${bgd}d${reset}uration (10s, 30m, 1.5h)"
    	echo -e "2) -${bgd}t${reset}ime (16:00)"
    	echo -e "3) ${bgd}C${reset}ancel timer"
    	#echo -e "4) ${bgd}R${reset}eturn"
    	read -p "Choose an action [1-3]: " st
    
    	case $st in
    		1|d|D) sleeep_1
    		break;;
    		2|t|T) sleeep_2
    		break;;
    		3|c|C) sleeep_3
    		break;;
    		#4|r|R) exec "$0";;
    		*) echo -e "\n${red}Oops!!! Please Select Correct Choice${reset}";
    		break
    	esac
    	done
	
	else
		echo -e "\n${red}$device is not playing !${reset}";
		sleep 1
	fi
   
	}

# Cancel timer
sleeep_3() {
	clear
	echo -e "\n${bold} Cancel timer... ${reset}\n"
	secs=$(sonos $loc $device sleep_timer)
	 
	if [ $secs -ne 0 ]; then
	
		printf "Current timer: $device goes to sleep in %02dh:%02dm:%02ds\n" $(($secs/3600)) $(($secs%3600/60)) $(($secs%60))		
		echo -e "\n"

		read -p "Do you want to cancel timer [y/n] ?: " rep
		#if [[ "$rep" == "y" ]] || [[ "$rep" == "o" ]]; then
		if [[ "$rep" == "y" || "$rep" == "Y" || "$rep" == "o" || "$rep" == "O" ]]; then
			sonos $loc $device sleep_timer cancel
		fi
	else
		echo -e "There is currently no timer !"
	fi
	
	sleep 1
	}

# Sleep timer: timer		 
sleeep_2() { 
	clear
    while :
	do
    	read -p "Enter time [16:00]: " timer
		if [[ $timer =~ ^([0-2][0-3]|[0-1][0-9]):[0-5][0-9]+$ ]];
		then
			sonos $loc $device sleep_at $timer
			echo -e "\n$device goes to sleep at ${bold}$timer${reset}."
			break
		else echo -e "\n${red}Oops!!! Please enter correct hour.${reset}";
		fi
	done
	sleep 2
	}

# Sleep timer: duration
sleeep_1() {
	clear
    while :
	do
    	read -p "Enter duration [10s, 30m, 1.5h]: " duration
		if [[ $duration =~ ^[0-9](.?)[0-9]?(s|m|h)$ ]]; # 10s 2h
		then
			if [[ $duration =~ "s" ]];
			then
				a=${duration%?}
			fi
			if [[ $duration =~ "m" ]];
			then
				a=${duration%?}
				a=$((a*60))
				 
			fi
			if [[ $duration =~ "h" ]];
			then
				a=${duration%?}
				b=$(echo "$a" | awk -F"." '{print $1}')
				c=$(echo "$a" | awk -F"." '{print $2}')
				b=$((b * 3600))
				c=$((c * (3600 / 10)))
				a=$((b + c))
			fi
			t=$(date +"%s")
			t=$((t+a))
			#date -d @$t # linux
			h=$(date -r $t)	# osx
			
			sonos $loc $device sleep_timer $duration
			echo -e "\n$device goes to sleep in ${bold}${duration//m/mn} ($h)${reset}."
			break
		else echo -e "\n${red}Oops!!! Please enter correct duration.${reset}";
		fi
	done
	sleep 2
	}

# Shazaaaam
option_27() {
    echo -e "\n${bold} Shazaaaam... ${reset}"
    shazam
	}

shazam() {
	sz=$(sonos $loc $device track)

	if [[ "$sz" =~ "Artist" ]]; then artist=$(echo "$sz" | grep "Artist" | awk -F"[=:]" '{print $2}');
	else artist=""; fi

	if [[ "$sz" =~ "Title" ]]; then title=$(echo "$sz" | grep "Title" | awk -F"[=:]" '{print $2}');
	else title=""; fi
	
	if [[ "$sz" =~ "Album" ]]; then album=$(echo "$sz" | grep "Album" | awk -F"[=:]" '{print $2}');
	else album=""; fi

	result=$( grep -i "uRi" <<< $sz)
	if [ -n "$result" ]; then
		uri=$(echo ${sz} | grep "URI" | grep -Eo '(https?|ftp|file)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]');
		
		if [[ "$uri" =~ "?" ]]; then
		 	radio=$(echo "$uri" | awk -F"?" '{print $1}')
		else
			radio="$uri"
		fi
	else radio=""; fi
	
	if [ -n "$radio" ]; then
		shazam="${bold}On air${reset}: \033[3m$radio${reset}"
	else
		shazam="${bold}On air${reset}: ${bold}$title${reset} \033[3mfrom${reset} $album \033[3mof${reset} $artist"
	fi
	
	echo -e "\n $shazam \n"
	sleep 2.5
	#read -p "< Press Enter>"
	}

# Switch status light
led() {
	playing="Switch status light..."
    echo -e "\n${bold} $playing ${reset}"

	led=$(sonos $loc $device status_light)
	echo -e "Status light is ${bold}$led${reset}"

	if [[ "$led" == "on" ]]; then		
		echo -e "${italic} ...Switching status light off${reset}"
		sleep 0.5
		sonos $loc $device status_light off
		status="OFF"
	elif [[ "$led" == "off" ]]; then
		echo -e "${italic} ...Switching status light on${reset}"
		sleep 0.5
		sonos $loc $device status_light on
		status="ON"
	fi
	
	echo -e "Status light is ${bold}$status${reset}"
	playing="Status light $status..."
	sleep 1.5
	}
	

# Soco device Lists Menu

soco_lists() {
	clear
	device="$1"
	
	while :
	do
		clear
        echo -e ""
        echo -e "${bold} 🔊 Sonos lists $device ${reset}"
        echo -e ""
		echo -e " "
		echo -e "------------------------------------------------------------------------------"
		echo -e "    Sonos $device lists Menu                                                  "
		echo -e "------------------------------------------------------------------------------"
		echo -e " 1) Favourite radio ${bgd}s${reset}tations " " | " " 11) Create Sonos ${bgd}p${reset}laylist               " " | "
		echo -e " 2) ${bgd}F${reset}avourites               " " | " " 12) L${bgd}i${reset}st playlists                      " " | "
		echo -e " 3) ${bgd}Q${reset}ueue                    " " | " " 13) D${bgd}e${reset}lete playlists                    " " | "
		echo -e " 4) Re${bgd}m${reset}ove from queue        " " | " " 14) ${bgd}L${reset}ists tracks in all Sonos Playlists " " | "
		echo -e " 5) ${bgd}C${reset}lear queue              " " | " " 15) Ad${bgd}d${reset} a Sonos playlist to queue       " " | "
		echo -e " 6)                          " " | " " 16) Remove a trac${bgd}k${reset} from a Sonos playlist" " | "
		echo -e " 7) List ${bgd}a${reset}rtists             " " | " " 17)                                     " " | "
		echo -e " 8) List al${bgd}b${reset}ums              " " | " " 18)                                     " " | "
		echo -e " 9)                          " " | " " 19)                                     " " | " 
		echo -e "10)                          " " | " " 20) ${bgd}H${reset}ome                               " " | "
		echo -e "=============================================================================="
		echo -e "Enter your menu choice [1-20]: \c "
		read lists
	
		case "$lists" in

			1|s|S) list_1;;
			2|f|F) list_2;;
			3|q|Q) list_3;;
			4|m|M) list_4;;
			5|c|C) list_5;;
			7|a|A) list_7;;
			8|b|B) list_8;;
			11|p|P) list_11;;
			12|i|I) list_12;;
			13|e|E) list_13;;
			14|l|L) list_14;;
			15|d|D) list_15;;
			16|k|K) list_16;;
			20|h|H) exec "$0";;
			*) echo -e "\n${red}Oops!!! Please Select Correct Choice${reset}";
			   echo -e "Press ${bold}ENTER${reset} To Continue..." ; read ;;
		esac
	done
	}


# Favourite radio stations
list_1() {
    echo -e "\n${bold} Favourite radio stations... ${reset}"
    s=$(sonos $loc $device favourite_radio_stations)
    echo -e "\n $s \n"
    read -p "< Press Enter>"
	}

# Favourites
list_2() {
    echo -e "\n${bold} Favourites... ${reset}"
    f=$(sonos $loc $device list_favs)
    echo -e "\n $f \n"
    read -p "< Press Enter>"
	}

# Queue
list_3() {
    echo -e "\n${bold} Queue... ${reset}"
    q=$(sonos $loc $device list_queue)
    echo -e "\n $q \n"
    read -p "< Press Enter>"
	}

# Remove from queue
list_4() {
    echo -e "\n${bold} Remove from queue... ${reset}"

	l=$(sonos $loc $device queue_length)
	if [ $l -ne 0 ]; then
    	while :
		do
			sonos $loc $device list_queue
		
	    	read -p "Enter track to remove [3][4,7,3][5-10][1,3-6,10] or [q] to quit: " track
    		if [[ "$track" == "q" || "$track" == "Q" ]]; then break; fi
			sonos $loc $device remove_from_queue $track		
		done
	else
		echo -e "\n${red}Queue is empty !${reset}"
	fi	
	sleep 2  
	}

# Clear queue
list_5() {
    echo -e "\n${bold} Clear queue... ${reset}"
    sonos $loc $device clear_queue
    q=$(sonos $loc $device queue_length)
    if [ $q -eq 0 ]; then echo "Queue is empty"; else echo "Queue is not empty"; fi
    sleep 1.5
	}

# List Artists
list_7() {
    echo -e "\n${bold} List artists... ${reset}"
    a=$(sonos $loc $device list_artists | more)
    echo -e "\n $a \n"
    read -p "< Press Enter>"
	}

# Lists Albums
list_8() {
    echo -e "\n${bold} List albums... ${reset}"
    b=$(sonos $loc $device list_albums | more)
    echo -e "\n $b \n"
    read -p "< Press Enter>"
	}

# Create Sonos playlist
list_11() {
    echo -e "\n${bold} Create Sonos playlist... ${reset}"
    echo -e "\n"
    read -p "Input a name for playlist: " name
   	sonos $loc $device create_playlist "$name"
	}

#list_playlists
list_12() {
	 echo -e "\n${bold} List Sonos playlist... ${reset}"
	l=$(sonos $loc $device list_playlists)
    echo -e "\n $l \n"
    read -p "< Press Enter>"
	}

#delete_playlist
list_13() {
	 echo -e "\n${bold} Delete Sonos playlist... ${reset}"
	 
    while :
	do
		sonos $loc $device list_playlists
		
    	read -p "Enter playlist <playlist> to delete or [q] to quit: " pll
    	if [[ "$pll" == "q" || "$pll" == "Q" ]]; then break; fi
		sonos $loc $device delete_playlist $pll		
	done    
	}

# List tracks in all Sonos Playlists
list_14() {
    echo -e "\n${bold} List tracks in all Sonos Playlists... ${reset}"
   	c=$(sonos $loc $device list_all_playlist_tracks)
    echo -e "\n $c \n"
    read -p "< Press Enter>"
	}

# Add a Sonos playlist to queue
list_15() {
	playing="Add Sonos playlist to queue..."
    echo -e "\n${bold} $playing ${reset}"

	echo -e "\nList of Sonos playlist:"
	sonos $loc $device list_playlists
	
	read -p "Enter a playlist name: " lsp
	sonos $loc $device add_playlist_to_queue "$lsp"
	# Give an error if empty playlist
	}
	
# Remove a track from a Sonos playlist
list_16() {
	playing="Remove a track from a Sonos playlist..."
    echo -e "\n${bold} $playing ${reset}"

    while :
	do
		echo -e "\nList of Sonos playlist:"
		sonos $loc $device list_playlists
	
		read -p "Enter a playlist <name>: " lsp
		sonos $loc $device list_playlist_tracks "$lsp"
		# Error: Can't pickle <class 'soco.music_services.data_structures.MSTrack'>: attribute lookup MSTrack on soco.music_services.data_structures failed
		# Erreur si la playlist contient des podcasts, pistes Deezer. Ok pour les mp3 dela Library.
	
		read -p "Enter the <number> track to remove or [q] to quit: " trk
		if [[ "$trk" == "q" || "$trk" == "Q" ]]; then break; fi
		sonos $loc $device remove_from_playlist "$lsp" "$trk"
		# Give an error if empty playlist
	done
	}

	
# Soco device Infos Menu

soco_infos() {
	clear
	device="$1"
	
	while :
	do
		clear
        echo -e ""
        echo -e "${bold} 🔊 Sonos $device infos ${reset}"
        echo -e ""
		echo -e " "
		echo -e "-----------------------------------------"
		echo -e "    Sonos $device infos Menu    "
		echo -e "-----------------------------------------"
		echo -e " 1) ${bgd}A${reset}larms                            " " | " 
		echo -e " 2) ${bgd}G${reset}roups                            " " | "
		echo -e " 3) ${bgd}I${reset}nfo                              " " | "
		echo -e " 4) ${bgd}S${reset}hares                            " " | "
		echo -e " 5) Reinde${bgd}x${reset} shares                    " " | "
		echo -e " 6) S${bgd}y${reset}sinfo                           " " | "
		echo -e " 7) All ${bgd}z${reset}ones                         " " | "
		echo -e " 8) Re${bgd}f${reset}reshing the Local Speaker List " " | "
		echo -e " 9)                                   " " | " 
		echo -e "10) ${bgd}H${reset}ome                              " " | "
		echo -e "========================================="
		echo -e "Enter your menu choice [1-10]: \c "
		read infos
	
		case "$infos" in

			1|a|A) info_1;;
			2|g|G) info_2;;
			3|i|I) info_3;;
			4|s|S) info_4;;
			5|x|X) info_5;;
			6|y|Y) info_6;;
			7|z|Z) info_7;;
			8|f|F) info_8;;
			10|h|H) exec "$0";;
			*) echo -e "\n${red}Oops!!! Please Select Correct Choice${reset}";
			   echo -e "Press ${bold}ENTER${reset} To Continue..." ; read ;;
		esac
	done
	}

# Alarms
info_1() {
    echo -e "\n${bold} Alarms... ${reset}"
    a=$(sonos $loc $device alarms)
    echo -e "\n $a \n"
    read -p "< Press Enter>"
	}

# Groups
info_2() {
    echo -e "\n${bold} Groups... ${reset}"
    g=$(sonos $loc $device groups)
	echo -e "\n $g \n"
    read -p "< Press Enter>"
	}

# Infos
info_3() {
    inform $device
	read -p "< Press Enter>"
	}

# Shares
info_4() {
    echo -e "\n${bold} Shares... ${reset}"
    s=$(sonos $loc $device shares)
    echo -e "\n $s \n"
    read -p "< Press Enter>"
	}

# Reindex
info_5() {
    echo -e "\n${bold} Reindex shares... ${reset}"
    y=$(sonos $loc $device reindex)
    echo -e "\n $y \n"
    read -p "< Press Enter>"
	}

# Sysinfo
info_6() {
    echo -e "\n${bold} Sysinfo... ${reset}"
    s=$(sonos $loc $device sysinfo)
    echo -e "\n $s \n"
    read -p "< Press Enter>"
	}

# All Zones (rooms)
info_7() {
    echo -e "\n${bold} All Zones... ${reset}"
    z=$(sonos $loc $device all_zones)
    echo -e "\n $z \n"
    read -p "< Press Enter>"
	}

# Refreshing the Local Speaker List
info_8() {
    echo -e "\n${bold} Refreshing the Local Speaker List... ${reset}"
    r=$(sonos -lr $device groups)
    echo -e "\n $r \n"
    read -p "< Press Enter>"
	}

all() {
	clear
	cde=""
	
	while :
	do
		clear
        echo -e ""
        echo -e "${bold} 🔊 Sonos All devices ${reset}"
        echo -e ""
        echo -e "Below commands apply to all Sonos devices in the network."
		echo -e ""
		echo -e "-------------------------------------"
		echo -e "       Sonos All devices             "
		echo -e "  $cde                               "
		echo -e "-------------------------------------"
		echo -e " 1) S${bgd}w${reset}itch Status Light OFF       " " | " 
		echo -e " 2) ${bgd}S${reset}witch Status Light ON        " " | "
		echo -e " 3) ${bgd}M${reset}ute ON                       " " | "
		echo -e " 4) M${bgd}u${reset}te OFF                      " " | "
		echo -e " 5)                               " " | "
		echo -e " 6)                               " " | "
		echo -e " 7)                               " " | "
		echo -e " 8)                               " " | "
		echo -e " 9)                               " " | " 
		echo -e "10) ${bgd}R${reset}eturn                        " " | "
		echo -e "====================================="
		echo -e "Enter your menu choice [1-10]: \c "
		read infos
	
		case "$infos" in

			1|w|W) all_1;;
			2|s|S) all_2;;
			3|m|M) all_3;;
			4|u|U) all_4;;
			5|y|Y) all_5;;
			10|r|R) exec "$0";;
			*) echo -e "\n${red}Oops!!! Please Select Correct Choice${reset}";
			   echo -e "Press ${bold}ENTER${reset} To Continue..." ; read ;;
		esac
	done
	}

# Switch OFF status light
all_1() {
	cde="Switch OFF status light on All devices..."
    echo -e "\n${bold} $cde ${reset}"

	sleep 0.5
	saslof=$(sonos _all_ status_light off | tr '\n' ' ' | xargs)
	
	cde="Status light is ${bold}OFF${reset} on $saslof devices"
	echo -e "Status light is ${bold}OFF${reset} on ALL devices"
	sleep 1.5
	}

# Switch ON status light
all_2() {
	cde="Switch ON status light on All devices..."
    echo -e "\n${bold} $cde ${reset}"

	sleep 0.5
	saslon=$(sonos _all_ status_light on | tr '\n' ' ' | xargs)
	
	cde="Status light is ${bold}ON${reset} on $saslon devices"
	echo -e "Status light is ${bold}ON${reset} on ALL devices"
	sleep 1.5
	}

# Mute ON 
all_3() {
	cde="Mute ON All devices..."
    echo -e "\n${bold} $cde ${reset}"

	sleep 0.5
	saslon=$(sonos _all_ mute on | tr '\n' ' ' | xargs)
	
	cde="Mute ${bold}ON${reset} $saslon devices"
	echo -e "Mute ${bold}ON${reset} ALL devices"
	sleep 1.5
	}

# Mute OFF 
all_4() {
	cde="Mute OFF All devices..."
    echo -e "\n${bold} $cde ${reset}"

	sleep 0.5
	saslon=$(sonos _all_ mute off | tr '\n' ' ' | xargs)
	
	cde="Mute ${bold}OFF${reset} $saslon devices"
	echo -e "Mute ${bold}OFF${reset} ALL devices"
	sleep 1.5
	}
		
main
