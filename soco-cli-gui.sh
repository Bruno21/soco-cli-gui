#!/usr/bin/env bash

# A bash GUI for soco-cli (https://github.com/avantrec/soco-cli/)
# Apache License 2.0

# soco-cli installed in venv $HOME/Documents/venv/soco-cli/bin
# and added to $PATH -> export PATH="$HOME/Documents/venv/soco-cli/bin:$PATH"

func=$1
param=$2

#set -e
#set -u
#set -o pipefail

italic="\033[3m"
underline="\033[4m"
bgd="\033[1;4;31m"
red="\033[1;31m"
bold="\033[1m"
bold_under="\033[1;4m"
greenbold="\033[1;32m"
greenita="\033[3;32m"
cyanita="\033[3;36m"
reset="\033[0m"

list="local"
if [ "$list" = "discovery" ]; then loc="";
else loc=" -l"; fi

# Needed to get the soco-cli update
# add_your_token_below
GITHUB_TOKEN=

# Step up/down volume
step=2

# Default Sonos device
default="Salon"

device=""

devices() {
	discover=$(sonos-discover -p 2>/dev/null)
	if [ -z "$discover" ]; then
		# Saved speaker data at: /Users/bruno/.soco-cli/speakers_v2.pickle
		discover=$(sonos-discover -t 256 -n 1.0 -m 24)
	fi

	dev=$(echo "$discover" | grep -E "([0-9]{1,3}[\.]){3}[0-9]{1,3}")
	nbdevices=$(echo "$discover" | grep "Sonos device(s) found" | awk '{print $1}')
}

function is_int() { test "$@" -eq "$@" 2> /dev/null; } 


# Main Menu

main() {

	devices

	clear
	#set device
	#device="$1"
	
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

		read -e main_menu
		
		for i in {3..4}
		do
			
			if is_int "$main_menu"; then
				nth=$(($main_menu - 2))
				nth_device=$(echo "$dev" | sed -n "${nth}p")
				name=$(echo "${nth_device}" | awk '{print $1}')
				sc=${name:0:1}
			else
				d=$(echo "$dev" | awk '{print $1}')
				sc=${main_menu^}	# Capitalize
				sc=${sc:0:1}		# First letter
				name=$(echo "$d" | grep -E ^$sc)	# shortcut = first letter of a device
			fi
			
			if [ $main_menu == "$i" ] || [ -n "$name" ]; then
			
				soco $name
			
			fi
		done
		
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
	
	#imgcat soco-cli-logo-01-large.png

	if [ $(echo $__CFBundleIdentifier | grep iterm2) ]; then
		#printf "\n\033]1337;File=;inline=1:`cat soco-cli-logo-01-large.png | base64`\a\n"
		printf "\n\033]1337;File=;width=400px;inline=1:`cat soco-cli-logo-01-large.png | base64`\a\n"
	else
		echo ""
		echo ""
		echo -e "${greenbold}            #####             #####                     ####      ####                                 ## ${reset}"
		echo -e "${greenbold}           ##   ##           ##   ##                     ##        ## ${reset}"
		echo -e "${greenbold}   #####   ##   ##   ####    ##   ##            ####     ##        ##               ### ##  ##  ##    ### ${reset}"
		echo -e "${greenbold}  ##       ##   ##  ##  ##   ##   ##  ######   ##  ##    ##        ##              ##  ##   ##  ##     ## ${reset}"
		echo -e "${greenbold}   #####   ##   ##  ##       ##   ##           ##        ##   #    ##              ##  ##   ##  ##     ## ${reset}"
		echo -e "${greenbold}       ##  ##   ##  ##  ##   ##   ##           ##  ##    ##  ##    ##               #####   ##  ##     ## ${reset}"
		echo -e "${greenbold}  ######    #####    ####     #####             ####    #######   ####                 ##    ######   #### ${reset}"
		echo -e "${greenbold}                                                                                   ##### ${reset}"
	fi
	echo ""
	echo -e "${bold}Just a GUI for the wonderful tool SoCo-Cli${reset}"
	echo ""
	echo "https://github.com/avantrec/soco-cli"
	echo ""
	echo "To install / upgrade soco-cli: pip install -U soco-cli (last tag: $last_tag)"
	
	echo -e "\n$vers\n"
	echo "<Press Enter to quit>"
	read -p ""
	}

	
help() {
	clear
	echo ""
	echo -e "${bold_under}Help:${reset}"

	echo -e "\n${bold}Main Menu:${reset}"
			
	echo -e "  ${greenbold}1) About:${reset} about page"
	echo -e "  ${greenbold}2) Help:${reset} this page"
	u=$((3+nbdevices-1))
	#echo "$u"
	echo -e "  Next (3-$u), all your Sonos device are automatically discover. Each call the main function soco()"
	echo -e "  ${greenbold}3-$u) ➔ Sonos <model> device <Name>:${reset} Command your <Name> device"
	#echo -e "  Last,  device"
	echo -e "  ${greenbold}$((u+1))) ➔ All devices:${reset} command all your device together"	
	echo -e "  ${greenbold}$((u+2))) Quit:${reset} quit the app" 


	echo -e "\n${bold}Sonos <$device> Menu:${reset}"

	echo -e " ${greenbold}[1-10] Play favorites:${reset} edit and duplicate functions option_1 to option_10 to add your favs"
	
	echo -e " ${greenbold}11) Volume 11:${reset} set volume to level 11"
	echo -e " ${greenbold}12) Mute ON:${reset} sets the mute setting of the speaker to 'on'"
	echo -e " ${greenbold}13) Volume 13:${reset} set volume to level 13"
	echo -e " ${greenbold}14) Mute OFF:${reset} sets the mute setting of the speaker to 'off'"
	echo -e " ${greenbold}15) Volume 15:${reset} set volume to level 15"
	echo -e " ${greenbold}16) Volume +:${reset} turn up the volume"
	echo -e " ${greenbold}17) Volume -:${reset} lower the volume"
	echo
	echo -e " ${greenbold}27) Pause on <device>:${reset} pause playback"
	echo -e " ${greenbold}28) Prev on <device>:${reset} move to the previous track"
	echo -e " ${greenbold}29) Next on <device>:${reset} move to the next track"
	echo -e " ${greenbold}30) Start <device>:${reset} start playback"
	echo -e " ${greenbold}31) Stop <device>:${reset} stop playback"
	echo
	echo -e " ${greenbold}32) Party mode <device>:${reset} adds all speakers in the system into a single group. The target speaker becomes the group coordinator"
	echo -e " ${greenbold}33) Group status <device>:${reset} indicates whether the speaker is part of a group, and whether it's part of a stereo pair or bonded home theatre configuration"
	echo -e " ${greenbold}34) Ungroup all speakers:${reset} removes all speakers in the target speaker's household from all groups"
	echo
	echo -e " ${greenbold}35) ➔ Infos :${reset} go to menu Infos"
	echo -e " ${greenbold}36) ➔ Lists :${reset} go to menu Lists"
	echo	
	echo -e " ${greenbold}37) Play radio from TuneIn:${reset} play favorite from TuneIn radio"
	echo -e " ${greenbold}38) Play local .m3u playlist:${reset} play a local M3U/M3U8 playlist consisting of local audio files (in supported audio formats)"
	echo -e " ${greenbold}39) Play local audio files:${reset} play MP3, M4A, MP4, FLAC, OGG, WMA, WAV, or AIFF audio files from your computer. Multiple filenames can be provided and will be played in sequence."
	echo -e " ${greenbold}40) Play local directories:${reset} play all of the audio files in the specified local directory (does not traverse into subdirectories)"
	echo -e " ${greenbold}41) Play shared links:${reset} play a shared link from Deezer,Spotify, Tidal or Apple Music"
	echo	
	echo -e " ${greenbold}42) Play albums:${reset} search album in library -> add to queue -> play"
	echo -e " ${greenbold}43) Play artists:${reset} search artist in library -> add to queue -> play"
	echo -e " ${greenbold}44) Play tracks:${reset} search track in library -> add to queue -> play"
	echo -e " ${greenbold}45) Play radio stream:${reset} play the audio object given by the <uri> parameter (e.g., a radio stream URL)"
	echo -e " ${greenbold}46) Create a playlist:${reset} create a Sonos playlist named <playlist>"
	echo	
	echo -e " ${greenbold}47) ➔ Sleeep:${reset} go to sleep menu"
	echo	
	echo -e " ${greenbold}48) Shazaaaam:${reset} identify current playing track, like Shazam"
	echo -e " ${greenbold}49) Switch Status Light:${reset}"
	echo -e " ${greenbold}50) Rename speaker <device>:${reset}"
	echo -e " ${greenbold}51) ➔ Home :${reset} go to Home menu"
	echo
	echo -e "\n${bold}Sonos <$device> infos Menu:${reset}"
	echo -e " ${greenbold}1) Alarms:${reset} list all of the alarms in the Sonos system" 
	echo -e " ${greenbold}2) Groups:${reset} lists all groups in the Sonos system. Also includes single speakers as groups of one, and paired/bonded sets as groups"
	echo -e " ${greenbold}3) Info:${reset} device informations"
	echo -e " ${greenbold}4) Shares:${reset} list the local music library shares"
	echo -e " ${greenbold}5) Reindex shares:${reset} start a reindex of the local music libraries"
	echo -e " ${greenbold}6) Sysinfo:${reset} prints a table of information about all speakers in the system"
	echo -e " ${greenbold}7) All zones:${reset} prints a simple list of comma separated visible zone/room names. Use all_zones (or all_rooms) to return all devices including ones not visible in the Sonos controller apps"
	echo -e " ${greenbold}8) Refreshing the Local Speaker List:${reset} refresh speaker cache"
	echo -e " ${italic}9) Delete the local speaker cache file:${reset} delete speaker cache"
	echo -e " ${italic}10) Return:${reset} go to Home menu"
	echo
	echo -e "\n${bold}Sonos <$device> lists Menu:${reset}"
	echo -e " ${greenbold}1) Favourite radio stations:${reset} lists the favourite radio stations"
	echo -e " ${greenbold}2) Favourites:${reset} lists all Sonos favourites"	echo
	echo
	echo -e " ${greenbold}3) Queue:${reset} list the tracks in the queue"
	echo -e " ${greenbold}4) Remove from queue:${reset} remove tracks from the queue. Track numbers start from 1. (single integers, sequences ('4,7,3'), ranges ('5-10')"
	echo -e " ${greenbold}5) Clear queue:${reset} clears the current queue."
	echo
	echo -e " ${greenbold}7) List artists:${reset} list artists on library"
	echo -e " ${greenbold}8) List albums:${reset} list albums on library"
	echo
	echo -e " ${greenbold}11) Create Sonos playlist:${reset} create a Sonos playlist named <playlist>"
	echo -e " ${greenbold}12) List playlists:${reset} lists the Sonos playlists"
	echo -e " ${greenbold}13) Delete playlists:${reset} delete the Sonos playlist named <playlist>"
	echo -e " ${greenbold}14) Lists tracks in all Sonos Playlists:${reset} lists all tracks in all Sonos Playlists"
	echo -e " ${greenbold}15) Add a Sonos playlist to queue:${reset} add <playlist_name> to the queue. The number in the queue of the first track in the playlist will be returned"
	echo -e " ${greenbold}16) Remove a track from a Sonos playlist:${reset} remove tracks from the queue. Track numbers start from 1. (single integers, sequences ('4,7,3'), ranges ('5-10')"
	echo -e " ${greenbold}20) Return:${reset} go to Home menu"

	echo -e "\n${bold}SocoCLI Gui configuration:${reset}"
	echo -e "${greenbold}see at the beginning of the script...${reset}"

	echo -e " ${greenbold}GITHUB_TOKEN= :${reset} add your Github token (needed to get the soco-cli update)"
	echo -e " ${greenbold}step=2:${reset} step for up/down volume"
	echo -e " ${greenbold}default=\"Salon\":${reset} default Sonos device (useful when running ${italic}soco-cli-gui.sh <function>${reset})"

	echo
	echo -e "$(sonos-discover --docs)"
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
	serial_number=$(echo "$info" | grep "serial_number" | awk -F"=" '{print $2}')
	
	echo ""
	printf "\e[1m| %-20s | %-20s |\e[0m\n" "$model_name" "$player_name"
	printf "| %-20s | %-20s |\n" "Model name" "$model_name"
	printf "| %-20s | %-20s |\n" "Model number" "$model_number"
	printf "| %-20s | %-20s |\n" "Serial number" "$serial_number"
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

	if [ -z "$playing" ]; then	# playing est vide
    	on_air="$(shazam)"
		curr=$(echo -e "$on_air" | sed -n '1p')
		playing="Playing $curr..."
	fi
	
	while :
	do
		clear
        echo -e ""
        echo -e "${bold} 🔊 Sonos $device ${reset}"
        echo -e ""
		echo -e " "
		echo -e "------------------------|-----------------------------------|------------------------------"
		echo -e "${italic}                 Sonos $device Menu : $playing                         ${reset}"
		echo -e "------------------------|-----------------------------------|------------------------------"
		echo -e " 1) France In${bgd}f${reset}o       " " | " "21)                            " " | " "41) ➔ ${bgd}I${reset}nfos     "
		echo -e " 2) France Int${bgd}e${reset}r      " " | " "22)                            " " | " "42) ➔ ${bgd}L${reset}ists     "
		echo -e " 3) ${bgd}K${reset}6 FM             " " | " "23)                            " " | " "43) ➔ ${bgd}A${reset}larms    "
		echo -e " 4) Rires et ${bgd}C${reset}hansons " " | " "24)                            " " | " "44)              "
		echo -e " 5) ${bgd}R${reset}TL               " " | " "25)                            " " | " "45) Play radio from TuneIn            "
		echo -e " 6) ${bgd}D${reset}eezer Flow       " " | " "26)                            " " | " "46) Play local .m3u playlist ${red}*${reset}        "
		echo -e " 7) ${italic}Edit/add fav here${reset} " " | " "27)                            " " | " "47) Play locals audio files ${red}*${reset}      "
		echo -e " 8)                   " " | " "28)                            " " | " "48) Play local directories ${red}*${reset}                "
		echo -e " 9)                   " " | " "29) pause ${bgd}o${reset}n $device12      " " | " "49) Play Shared links  "
		echo -e "10)                   " " | " "30) ${bgd}p${reset}rev on $device12       " " | " "50) Play al${bgd}b${reset}ums  "
		echo -e "11) volume ${bgd}11${reset}         " " | " "31) ${bgd}n${reset}ext on $device12       " " | " "51) Play artists (${bgd}x${reset})      "
		echo -e "12) ${bgd}m${reset}ute ON           " " | " "32) ${bgd}s${reset}tart $device12         " " | " "52) Play tracks (${bgd}y${reset})      "
		echo -e "13) volume ${bgd}13${reset}         " " | " "33) s${bgd}t${reset}op $device12          " " | " "53) Play radio stream      "
		echo -e "14) m${bgd}u${reset}te OFF          " " | " "34)                            " " | " "54) Create a playlist        "
		echo -e "15) volume ${bgd}15${reset}         " " | " "35) Party mode $device12    " " | " "55) Sleeep (${bgd}j${reset})    "
		echo -e "16) volume ${bgd}+${reset}          " " | " "36) ${bgd}G${reset}roup status $device12    | " "56) Sha${bgd}z${reset}aaaam "
		echo -e "17) volume ${bgd}-${reset}          " " | " "37) Ungroup all speakers       " " | " "57)    "
		echo -e "18)                   " " | " "38)                            " " | " "58)   "
		echo -e "19)                   " " | " "39) S${bgd}w${reset}itch Status Light        " " | " "59)    "
		echo -e "20)                   " " | " "40) Rename speaker $device12" " | " "60) ➔ ${bgd}H${reset}ome     "
	
	
	
		echo -e "${red}* Hit CTRL-C to stop current${reset}"
		echo -e "==========================================================================================="
		echo -e "Enter your menu choice [1-51]: \c "
		read -e soco_menu
	
		case "$soco_menu" in

			# Play your favs from 1 to 51
			1|f|F) franceinfo;;
			2|e|E) franceinter;;
			3|k|K) k6fm;;
			4|c|C) rires;;
			5|r|R) rtl;;
			6|d|D) deezer_flow;;
			7) option_7;;
			11) level_11;;
			12|m|M) mute_on;;
			13) level_13;;
			14|u|U) mute_off;;
			15) level_15;;
			16|+) vol+;;
			29|o|N) pause;;
			30|p|P) prev;;
			31|n|N) next;;
			32|s|S) start;;
			33|t|T) stop;;
			35) party_mode;;
			36|g|G) groupstatus;;
			37) ungroup_all;;
			39|w|W) led;;
			40) rename_spk;;			
			41|i|I) soco_infos $device;;
			42|l|L) soco_lists $device;;
			43|a|A) soco_alarms $device;;
			45) play_radio_from_tunein;;
			46) play_local_m3u;;
			47) play_local_file;;	
			48) play_local_dir;;
			49) play_shared_link;;	
			50|b|B) play_album_from_library;;
			51|x|X) play_artist_from_library;;
			52|y|Y) play_track_from_library;;
			53) play_uri;;
			54) make_playlist;;
			55|j|J) sleeep;;
			56|z|Z) shazaaaam;;
			60|h|H) exec "$0";;
			*) echo -e "\n${red}Oops!!! Please Select Correct Choice${reset}";
			   echo -e "Press ${bold}ENTER${reset} To Continue..." ; read -e ;;
		esac
	done
	}

### ADD YOUR FAVS HERE ###

# Playing France Info
franceinfo() {
	#echo "$loc"
	playing="Playing France Info..."
	echo -e "\n${bold} $playing ${reset}"
	sonos $loc $device play_fav 'franceinfo' && sleep 2
	}

# Playing France Inter
franceinter() {
	playing="Playing France Inter..."
	echo -e "\n${bold} $playing ${reset}"
	sonos $loc $device play_fav 'france inter' && sleep 2
	}

# Playing K6 FM
k6fm() {
	playing="Playing K6 FM..."
    echo -e "\n${bold} $playing ${reset}"
    sonos $loc $device play_fav 'K6 FM' && sleep 2
	}

# Playing Rires et Chansons
rires() {
	playing="Playing Rires et Chansons..."
    echo -e "\n${bold} $playing ${reset}"
    sonos $loc $device play_fav 'Rire et Chansons' && sleep 2
	}

# Playing RTL
rtl() {
	playing="Playing RTL..."
    echo -e "\n${bold} $playing ${reset}"
	sonos $loc $device play_fav 'RTL' && sleep 2
	}

# Playing Deezer Flow
deezer_flow() {
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
level_11() {
    echo -e "\n${bold} Set volume to level 11... ${reset}"
    sonos $loc $device volume 11 && sleep 2
	}

# Mute ON
mute_on() {
    echo -e "\n${bold} Mute ON... ${reset}"
    sonos $loc $device mute on && sleep 2
	}

# Set volume to level 13
level_13() {
    echo -e "\n${bold} Set volume to level 13... ${reset}"
    sonos $loc $device volume 13 && sleep 2
	}

# Mute OFF
mute_off() {
    echo -e "\n${bold} Mute OFF... ${reset}"
    sonos $loc $device mute off && sleep 2
	}

# Set volume to level 15
level_15() {
    echo -e "\n${bold} Set volume to level 15... ${reset}"
    sonos $loc $device volume 15 && sleep 2
	}

# Start $device
start() {
	playing=""
    sonos $loc $device start

    on_air="$(shazam)"	# ligne 1114
	curr=$(echo "$on_air" | sed -n '1p')
	playing="Playing $curr..."
	echo -e "\n${bold} Start $device playing $curr... ${reset}"
	sleep 2
	}

# Stop $device
stop() {
	playing="Stop $device..."
    echo -e "\n${bold} Stop $device... ${reset}"
    sonos $loc $device stop && sleep 2
	}

# Pause $device
pause() {
	playing="Pause $device..."
    echo -e "\n${bold} Pause $device... ${reset}"
    sonos $loc $device pause && sleep 0.5
	}

# Previous tracks
# 	No applicable for sonos fav, radios Tune-in
prev() {
	backup=$playing

    sonos $loc $device previous 2>/dev/null
    if [ $? > 0 ]; then
    	msg="No applicable for the audio source !"
    else
    	msg="Prev. track on $device..."	# <= Shazaaam
    fi
    echo -e "\n${bold} $msg ${reset}"
    sleep 2
	}

# Next tracks
# 	No applicable for sonos fav, radios Tune-in
next() {
	backup=$playing

    sonos $loc $device next 2>/dev/null
    if [ $? > 0 ]; then
    	msg="No applicable for the audio source !"
    else
    	msg="Next. track on $device..."	# <= Shazaaam
    fi
    echo -e "\n${bold} $msg ${reset}"
    sleep 2
	}

# Party_mode
party_mode() {
    echo -e "\n${bold} Party mode $device... ${reset}"
    sonos $loc $device party_mode
    sonos $loc $device groupstatus && sleep 2
	}

# Groupstatus
groupstatus() {
    echo -e "\n${bold} Group status $device... ${reset}"
    sonos $loc $device groupstatus && sleep 2
	}

# Ungroup_all
ungroup_all() {
    echo -e "\n${bold} Ungroup all speakers... ${reset}"
    sonos $loc $device ungroup_all
    sonos $loc $device groupstatus && sleep 2
	}

# Rename
rename_spk() {
    echo -e "\n${bold} Rename speaker $device... ${reset}"
    
    read -p "New name: " newname
    sonos $loc $device rename $newname && sleep 2
    
    main
    #devices
    #ScriptLoc=$(readlink -f "$0")
    #exec "$ScriptLoc"
	}

vol+() {
    volume=$(sonos $loc $device volume)
    vol=$((volume+$step))
    sonos $loc $device volume $vol
    echo -e "\nSet volume to ${bold}level $vol${reset}" && sleep 0.5
	}

vol-() {
    volume=$(sonos $loc $device volume)
    vol=$((volume-$step))
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

	# /Users/bruno/Music/Shaka Ponk - Apelogies/CD1/playlist.m3u
	
	# ${directory////\\/}
	# sed 's/ /\\ /g'
	
	#plt=$(ls *.m3u*)
	#cd /Users/bruno/Music/Shaka\ Ponk\ -\ Apelogies/CD1
	
	read -e -i "$HOME/" -p "Enter .m3u file path: " fp
	
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
# /Users/bruno/Music/The Smile - A Light For Attracting Attention [Japan Edition] (2022)/01. The Same.mp3

# BLOQUANT Ctrl-C to quit

play_local_file() {
	playing="Play a local audio file..."
    echo -e "\n${bold} $playing ${reset}\n"

	echo -e "${underline}Enter audio file/folder path${reset} (.mp3|.mp4|.m4a|.aac|.flac|.ogg|.wma|.wav) "
	read -e -i "$HOME/" -p ": " fa
	
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

play_local_dir() {

	playing="Playing a local directory..."
    echo -e "\n${bold} $playing ${reset}\n"

	echo -e "${underline}Enter a folder path:${reset} "
	read -e -i "$HOME/" -p "? " dir
	echo $fa
	#dir=$(echo "$fa" | sed 's/ /\\ /g')
	if [ -d "$dir" ]; then
		sonos $loc $device play_directory "$dir"
	else
		echo -e "❗ ️Folder ${bold}$dir${reset} doesn't exist!" && sleep 2
		playing=""
	fi	
	
	read -p "< Press Enter>"
	sleep 2

}

export -f play_local_dir

play_shared_link() {

	playing="Playing a shared link..."
    echo -e "\n${bold} $playing ${reset}\n"

	echo -e "\nExample:"
	echo "https://open.spotify.com/track/6cpcorzV5cmVjBsuAXq4wD"
	echo "https://tidal.com/browse/album/157273956"
	echo "https://www.deezer.com/en/playlist/5390258182"
	echo "https://music.apple.com/dk/album/black-velvet/217502930?i=217503142"

	music=("https://open.spotify.com" "https://tidal.com" "https://www.deezer.com/" "https://music.apple.com")
	echo -e "${underline}Enter an url:${reset} "
	read -e -i "https://" -p "? " sl
	
	for i in ${music[@]}; do
		[[ "$sl" == *"$i"* ]] && s_link=$sl
	done
	if [ -n "$s_link" ]; then
		echo "$sl" 
		queue=$(sonos $loc $device sharelink "$sl")
		sonos $loc $device play_from_queue $queue
	else
		echo -e "❗ ️Invalid shared link !"
		playing=""
	fi
	
	read -p "< Press Enter>"
	sleep 2
}

make_playlist() {

	playing="Create a playlist..."
    echo -e "\n${bold} $playing ${reset}\n"
	
	# GNU bash, version 3.2.57(1)-release-(x86_64-apple-darwin20)
	#read -e -p "Choose folder to create playlist from: " folder
	# GNU bash, version 5.1.4(1)-release (x86_64-apple-darwin19.6.0) (brew install bash)
	read -e -i "$HOME/Music/" -p "Choose folder to create playlist from: " folder
	
	if [ -d "$folder" ]; then
			
		read -e -p "Include subfolder ? (y/n) " sub
		
		if [ "$sub" == "y" ] || [ "$sub" == "Y" ]; then		
			#m3u=$(echo "$fp" | awk -F"/" '{print $NF}')	
			if [[ "$OSTYPE" == "darwin"* ]]; then list=$(find -E "$folder" -iregex ".*\.(mp3|mp4|m4a|aac|flac|ogg|wma|wav)" | sort)
			else list=$(find "$folder" -iregex ".*\.\(mp3\|mp4\|m4a\|aac\|flac\|ogg\|wma\|wav\)" | sort); fi	
		else
			if [[ "$OSTYPE" == "darwin"* ]]; then list=$(find -E "$folder" -maxdepth 1 -iregex ".*\.(mp3|mp4|m4a|aac|flac|ogg|wma|wav)" | sort)
			else list=$(find "$folder" -maxdepth 1 -iregex ".*\.\(mp3\|mp4\|m4a\|aac\|flac\|ogg\|wma\|wav\)" | sort); fi
		fi
		
		while [ true ] ; do
			read -t 10 -e -p "Give a name to the playlist (without extension): " pl_name
			if [ -n "$pl_name" ] ; then
				break ;
			else
				echo "Waiting for a name !"
			fi
		done

		plst="$pl_name.m3u"
		printf "#EXTM3U\n" > "$plst"
		echo "$list" >> "$plst"
		
		
		read -e -p "Do you want to edit $plst ? (y/n) " edit	
		if [ "$edit" == "y" ] || [ "$edit" == "Y" ]; then
			[ -n $EDITOR ] && $EDITOR "$plst" || nano "$plst"
		fi

		# Extract album art from .mp3
		# ffmpeg -hide_banner -loglevel error -i 01.\ Portez\ vos\ croix.mp3 -s 300x300 album_art.jpg
		
		read -e -p "Do you want to play $plst ? (y/n) " play	
		if [ "$play" == "y" ] || [ "$play" == "Y" ]; then
			playing="Playing the ${bold_under}$plst${reset}${underline} playlist..."
			echo -e "\n${underline}$playing${reset}"
			pls=$(cat "$plst")
			echo -e "\n$pls\n"
			
			### BUG: bloc menu avec CTRL-C ###
			
			echo -e "Hit CTRL-C to exit playlist \n"
			sonos $loc $device play_m3u "$plst" pi
		fi

	else
		echo "Folder $folder doesn't exist !'"
	fi
}

# Search artist in library -> add album to queue -> play it
play_artist_from_library() {
	read -e -p "Search artist in library: " search
	
	if [ -n "$search" ]; then
		a=$(sonos $loc $device search_artists "$search")
		if [ -n "$a" ]; then
			echo -e "$a\n"
			read -e -p "Album to play (n°): " number
	
			if [[ "$number" =~ ^[+-]?[0-9]+$ ]]; then
				b=$(echo "$a" | grep -m 1 "$number: ")
				album=$(echo "$b" | awk -F ": " '{print $3}' | awk -F "|" '{print $1}' | sed 's/ *$//g')
				artist=$(echo "$b" | awk -F ": " '{print $4}')

				playing="Playing $album from $artist..."
	    		echo -e "\n${bold} $playing ${reset}"
	
				sonos $loc $device queue_search_result_number $number first : $device play_from_queue > /dev/null
			else echo "Please, enter the number of the album to play !"
			fi
		else echo -e "Artist ${underline}$search${reset} was not found !"
		fi
	else echo "Empty query !"
	fi
	}

# Search album in library -> add to queue -> play it
play_album_from_library() {
	read -e -p "Search album in library: " search

	if [ -n "$search" ]; then	
		a=$(sonos $loc $device search_albums "$search")
		if [ -n "$a" ]; then
			echo -e "$a\n"
			read -e -p "Album to play (n°): " number
	
			if [[ "$number" =~ ^[+-]?[0-9]+$ ]]; then
				b=$(echo "$a" | grep -m 1 "$number: ")	
				album=$(echo "$b" | awk -F ": " '{print $3}' | awk -F "|" '{print $1}' | sed 's/ *$//g')
				artist=$(echo "$b" | awk -F ": " '{print $4}')
	
				playing="Playing $album from $artist..."
		    	echo -e "\n${bold} $playing ${reset}"

				sonos $loc $device queue_search_result_number $number first : $device play_from_queue > /dev/null
			else echo "Please, enter the number of the album to play !"
			fi
		else echo -e "Album ${underline}$search${reset} was not found !"
		fi			
	else echo "Empty query !"
	fi
	}

# Search track in library -> add to queue -> play it
play_track_from_library() {
	read -e -p "Search track in library: " search
	
	if [ -n "$search" ]; then	
		a=$(sonos $loc $device search_tracks "$search")
		if [ -n "$a" ]; then
			echo -e "$a\n"
			read -e -p "Track to play: " number

			if [[ "$number" =~ ^[+-]?[0-9]+$ ]]; then
				b=$(echo "$a" | grep -m 1 "$number: ")
				# 1: Artist: Alain Souchon | Album: Collection (1984-2001) | Title: J'veux du cuir	
				track=$(echo "$b" | awk -F ": " '{print $5}')
				artist=$(echo "$b" | awk -F ": " '{print $3}' | awk -F "|" '{print $1}' | sed 's/ *$//g')

				playing="Playing $track from $artist..."
		    	echo -e "\n${bold} $playing ${reset}"
	
				sonos $loc $device queue_search_result_number $number first : $device play_from_queue > /dev/null
			else echo "Please, enter the number of the track to play !"
			fi
		else echo -e "Track ${underline}$search${reset} was not found !"
		fi			
	else echo "Empty query !"
	fi
	}

# Play URI
play_uri() {
	playing=""
    echo -e "\n${bold} Play radio stream... ${reset}\n"
    
    read -p "Enter radio stream URL [.mp3|.aac|.m3u|.pls]: " url
    #url="http://jazzradio.ice.infomaniak.ch/jazzradio-high.aac"
    
    read -p "Enter radio stream name: " title

    if [[ "$url" =~ ^http ]]; then
    	if [ -n "$title" ]; then playing="Playing $title radio stream..."
    	else playing="Playing $url radio stream..."; fi
    	echo -e "\n${bold} $playing ${reset}"
    	sonos $loc $device play_uri $url "$title"
    else
    	echo -e "\nWrong radio stream URL !"
    fi
    sleep 2
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
    		1|d|D) sleeep_duration
    		break;;
    		2|t|T) sleeep_timer
    		break;;
    		3|c|C) sleeep_cancel
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
sleeep_cancel() {
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
sleeep_timer() { 
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
sleeep_duration() {
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
shazaaaam() {
    echo -e "\n${bold} Shazaaaam... ${reset}"

    echo -e "\n${underline}On air:${reset}"
    
    on_air="$(shazam)"
    curr=$(echo -e "$on_air" | sed -n '1p')
	echo -e "$on_air \n"

	sleep 1.5
	read -p "< Press Enter >"

	#if [ -z "$playing" ]; then
   # 	on_air="$(shazam)"
	#	curr=$(echo -e "$on_air" | sed -n '1p')
	#	playing="Playing $curr..."
	#fi

	if [ -n "$curr" ]; then
    	echo -e "\n${bold} $curr ${reset}"
    else
		playing="Shazaaam..."
		echo -e "\n${bold} $playing ${reset}"
	fi
	}

# 507

shazam() {
	sz=$(sonos $loc $device -n 1.0 track)
	
	# http://jazzradio.ice.infomaniak.ch/jazzradio-high.aac
	# https://www.deezer.com/en/playlist/5390258182
	
	playback=$(echo "$sz" | sed -n '2p')
	
	if [[ "$playback" =~ "Playback is in progress" ]] || [[ "$playback" =~ "Playback is in a transitioning state" ]]; then

		if [[ "$sz" =~ "Artist" ]]; then artist=$(echo "$sz" | grep "Artist" | awk -F"[=:]" '{print $2}' | xargs);
		else artist=""; fi

		if [[ "$sz" =~ "Title" ]]; then title=$(echo "$sz" | grep "Title" | awk -F"[=:]" '{print $2}' | xargs);
		else title=""; fi
	
		if [[ "$sz" =~ "Album" ]]; then album=$(echo "$sz" | grep "Album" | awk -F"[=:]" '{print $2}' | xargs);
		else album=""; fi

		if [[ "$sz" =~ "Channel" ]]; then channel=$(echo "$sz" | grep "Channel" | awk -F"[=:]" '{print $2}' | xargs);
		else channel=""; fi
		
		if [ -n "$channel" ]; then # non vide => channel existe
		
			if [ -n "$artist" ] && [ -n "$title" ]; then
				# Tune-in / Deezer
				local shazam="${cyanita}$channel${reset}\n${greenita}$title${reset} of ${greenita}$artist${reset}"
			else
				# Favorites radio / radio stream
				local shazam="${cyanita}$channel${reset}"
			fi
			
		else
			# shared link deezer / Play local directory
			local shazam="${greenita}$title${reset} from ${greenita}$album${reset} of ${greenita}$artist${reset}"
		fi
		echo "$shazam"
	fi

: <<'END_COMMENT'
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
END_COMMENT
	
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
	
	while :
	do
		_list="Sonos $device lists Menu "
		pad=$((((78-${#_list})/2)+${#_list}))

		clear
        echo -e ""
        echo -e "${bold} 🔊 Sonos lists $device ${reset}"
        echo -e ""
		echo -e " "
		echo -e "------------------------------------------------------------------------------"
		#echo -e "    Sonos $device lists Menu                                                  "
		printf "%*s\n" $pad "$_list"
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
		echo -e "10)                          " " | " " 20) ${bgd}H${reset}ome                                " " | "
		echo -e "=============================================================================="
		echo -e "Enter your menu choice [1-20]: \c "
		read lists
	
		case "$lists" in

			1|s|S) favourite_radio_stations;;
			2|f|F) list_favs;;
			3|q|Q) list_queue;;
			4|m|M) remove_from_queue;;
			5|c|C) clear_queue;;
			7|a|A) list_artists;;
			8|b|B) list_albums;;
			11|p|P) create_playlist;;
			12|i|I) list_playlists;;
			13|e|E) delete_playlist;;
			14|l|L) list_all_playlist_tracks;;
			15|d|D) add_playlist_to_queue;;
			16|k|K) remove_from_playlist;;
			20|h|H) exec "$0";;
			*) echo -e "\n${red}Oops!!! Please Select Correct Choice${reset}";
			   echo -e "Press ${bold}ENTER${reset} To Continue..." ; read ;;
		esac
	done
	}


# Favourite radio stations
favourite_radio_stations() {
    echo -e "\n${bold} Favourite radio stations... ${reset}"
    s=$(sonos $loc $device favourite_radio_stations)
    echo -e "\n $s \n"
    read -p "< Press Enter>"
	}

# Favourites
list_favs() {
    echo -e "\n${bold} Favourites... ${reset}"
    f=$(sonos $loc $device list_favs)
    echo -e "\n $f \n"
    read -p "< Press Enter>"
	}

# Queue
list_queue() {
    echo -e "\n${bold} Queue... ${reset}"
    q=$(sonos $loc $device list_queue)
    echo -e "\n $q \n"
    read -p "< Press Enter>"
	}

# Remove from queue
remove_from_queue() {
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
clear_queue() {
    echo -e "\n${bold} Clear queue... ${reset}"
    sonos $loc $device clear_queue
    q=$(sonos $loc $device queue_length)
    if [ $q -eq 0 ]; then echo "Queue is empty"; else echo "Queue is not empty"; fi
    sleep 1.5
	}

# List Artists
list_artists() {
    echo -e "\n${bold} List artists... ${reset}"
    a=$(sonos $loc $device list_artists | more)
    echo -e "\n $a \n"
    read -p "< Press Enter>"
	}

# Lists Albums
list_albums() {
    echo -e "\n${bold} List albums... ${reset}"
    b=$(sonos $loc $device list_albums | more)
    echo -e "\n $b \n"
    read -p "< Press Enter>"
	}

# Create Sonos playlist
create_playlist() {
    echo -e "\n${bold} Create Sonos playlist... ${reset}"
    echo -e "\n"
    read -p "Input a name for playlist: " name
   	sonos $loc $device create_playlist "$name"
	}

#list_playlists
list_playlists() {
	 echo -e "\n${bold} List Sonos playlist... ${reset}"
	l=$(sonos $loc $device list_playlists)
    echo -e "\n $l \n"
    read -p "< Press Enter>"
	}

#delete_playlist
delete_playlist() {
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
list_all_playlist_tracks() {
    echo -e "\n${bold} List tracks in all Sonos Playlists... ${reset}"
   	c=$(sonos $loc $device list_all_playlist_tracks)
    echo -e "\n $c \n"
    read -p "< Press Enter>"
	}

# Add a Sonos playlist to queue
add_playlist_to_queue() {
	playing="Add Sonos playlist to queue..."
    echo -e "\n${bold} $playing ${reset}"

	echo -e "\nList of Sonos playlist:"
	sonos $loc $device list_playlists
	
	read -p "Enter a playlist name: " lsp
	sonos $loc $device add_playlist_to_queue "$lsp"
	# Give an error if empty playlist
	}
	
# Remove a track from a Sonos playlist
remove_from_playlist() {
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
	
	while :
	do
		_info="Sonos $device infos Menu"
		pad=$((((43-${#_info})/2)+${#_info}))

		clear
        echo -e ""
        echo -e "${bold} 🔊 Sonos $device infos ${reset}"
        echo -e ""
		echo -e " "
		echo -e "-------------------------------------------"
		#echo -e "    Sonos $device infos Menu      "
		printf "%*s\n" $pad "$_info"
		echo -e "-------------------------------------------"
		echo -e " 1)                                     " " | " 
		echo -e " 2)                                     " " | "
		echo -e " 3) ${bgd}G${reset}roups                              " " | "
		echo -e " 4) ${bgd}I${reset}nfo                                " " | "
		echo -e " 5) ${bgd}S${reset}hares                              " " | "
		echo -e " 6) Reinde${bgd}x${reset} shares                      " " | "
		echo -e " 7) S${bgd}y${reset}sinfo                             " " | "
		echo -e " 8) All ${bgd}z${reset}ones                           " " | "
		echo -e " 9) Re${bgd}f${reset}reshing the Local Speaker List   " " | "
		echo -e " 10) ${bgd}D${reset}elete the local speaker cache file" " | " 
		echo -e " 11) ${bgd}H${reset}ome                               " " | "
		echo -e "==========================================="
		echo -e "Enter your menu choice [1-11]: \c "
		read infos
	
		case "$infos" in

			3|g|G) info_groups;;
			4|i|I) infos;;
			5|s|S) shares;;
			6|x|X) reindex;;
			7|y|Y) sysinfo;;
			8|z|Z) all_zones;;
			9|f|F) refresh_speaker_list;;
			10|d|D) delete_speaker_cache;;
			11|h|H) exec "$0";;
			*) echo -e "\n${red}Oops!!! Please Select Correct Choice${reset}";
			   echo -e "Press ${bold}ENTER${reset} To Continue..." ; read ;;
		esac
	done
	}


# Groups
info_groups() {
    echo -e "\n${bold} Groups... ${reset}"
    g=$(sonos $loc $device groups)
	echo -e "\n $g \n"
    read -p "< Press Enter>"
	}

# Infos
infos() {
    inform $device
	read -p "< Press Enter>"
	}

# Shares
shares() {
    echo -e "\n${bold} Shares... ${reset}"
    s=$(sonos $loc $device shares)
    echo -e "\n $s \n"
    read -p "< Press Enter>"
	}

# Reindex
reindex() {
    echo -e "\n${bold} Reindex shares... ${reset}"
    y=$(sonos $loc $device reindex)
    echo -e "\n $y \n"
    read -p "< Press Enter>"
	}

# Sysinfo
sysinfo() {
    echo -e "\n${bold} Sysinfo... ${reset}"
    s=$(sonos $loc $device sysinfo)
    echo -e "\n $s \n"
    read -p "< Press Enter>"
	}

# All Zones (rooms)
all_zones() {
    echo -e "\n${bold} All Zones... ${reset}"
    z=$(sonos $loc $device all_zones)
    echo -e "\n $z \n"
    read -p "< Press Enter>"
	}

# Refreshing the Local Speaker List
refresh_speaker_list() {
    echo -e "\n${bold} Refreshing the Local Speaker List... ${reset}"
    r=$(sonos -lr $device groups)
    echo -e "\n $r \n"
    read -p "< Press Enter>"
	}

# Delete the local speaker cache file
delete_speaker_cache() {
    echo -e "\n${bold} Delete the local speaker cache file... ${reset}"
    r=$(sonos-discover -d)
    echo -e "\n $r \n"
    read -p "< Press Enter>"
	}



# Soco device Alarms Menu

soco_alarms() {
	clear
	
	while :
	do
		_alarm="Sonos $device alarms Menu"
		pad=$((((43-${#_alarm})/2)+${#_alarm}))

		clear
        echo -e ""
        echo -e "${bold} 🔊 Sonos $device alarms ${reset}"
        echo -e ""
		echo -e " "
		echo -e "--------------------------------------------"
		#echo -e "    Sonos $device alarms Menu      "
		printf "%*s\n" $pad "$_alarm"
		echo -e "--------------------------------------------"
		echo -e " 1) ${bgd}A${reset}larms                               " " | " 
		echo -e " 2) ${bgd}C${reset}reate alarms                        " " | "
		echo -e " 3) ${bgd}R${reset}emove alarms                        " " | "
		echo -e " 4) ${bgd}M${reset}odify alarms                        " " | "
		echo -e " 5) ${bgd}E${reset}nable/disable alarms                " " | "
		echo -e " 6) Mo${bgd}v${reset}e alarm                           " " | "
		echo -e " 7)                                      " " | "
		echo -e " 8)                                      " " | "
		echo -e " 9)                                      " " | "
		echo -e " 10) ${bgd}H${reset}ome                                " " | "
		echo -e "============================================"
		echo -e "Enter your menu choice [1-10]: \c "
		read infos
	
		case "$infos" in

			1|a|A) alarms;;
			2|c|C) create_alarms;;
			3|r|R) remove_alarms;;
			4|m|M) modify_alarms;;
			5|e|E) enable_alarms;;
			6|v|V) move_alarms;;
			10|h|H) exec "$0";;
			*) echo -e "\n${red}Oops!!! Please Select Correct Choice${reset}";
			   echo -e "Press ${bold}ENTER${reset} To Continue..." ; read ;;
		esac
	done
	}

# Alarms
alarms() {
    echo -e "\n${bold} Alarms... ${reset}"

    list_alarms
    echo "$court_ala"
    echo
    read -p "< Press Enter>"
	}

list_alarms() {
    long_ala=$(sonos $loc $device alarms)
	court_ala=$(echo "$long_ala" | cut -d "|" -f 1,2,3,4,5,6,7,8,9)

	#long_ala=$(cat long_alarm.txt)
	
}

remove_alarms() {
    echo -e "\n${bold} Remove alarms... ${reset}"
    
    list_alarms
    echo "$court_ala"
    echo
    
   	while :
	do    
    	read -p "Enter the <Alarm ID> alarm to remove or [q] to quit: " trk
		if [[ "$trk" == "q" || "$trk" == "Q" ]]; then 
			break
		else
			ala_id=$(echo "$court_ala" | sed '1,3d' | awk -F "|" '{print $2}')						
			if [[ $ala_id =~ "$trk" ]]; then
				sonos $loc $device remove_alarm $trk
				[ $? != 0 ] && echo -e "${red}Error !${reset}"
				break
			else
				echo "Wrong <Alarm ID> !"
			fi
		fi
	done
	
    read -p "< Press Enter>"
}


move_alarms() {
    echo -e "\n${bold} Move alarm to speaker... ${reset}"
    
    list_alarms
    echo "$court_ala"
    echo
    
    #y=($((awk '{print $1}' | grep -v $device) <<< $dev))
   	#echo ${y[@]}
    
   	while :
	do    
    	read -p "Enter the <Alarm ID> alarm to move or [q] to quit: " trk
		if [[ "$trk" == "q" || "$trk" == "Q" ]]; then 
			break
		else
			ala_id=$(echo "$court_ala" | sed '1,3d' | awk -F "|" '{print $2}')						
			if [[ $ala_id =~ "$trk" ]]; then
			
				actual_speaker=$(echo "$long_ala" | awk -F "|" -v var="$trk" '($2 == var) {print $3}' | xargs | sed 's/ , /,/g')				
				other_speakers=$(echo "$dev" | grep -v $actual_speaker | cut -d ' ' -f1)

				read -p "Move Alarm ID <$trk> to Speaker <$other_speakers> (enter target name): " target
				if [[ $other_speakers =~ "$target" ]]; then
					sonos $loc $target move_alarm $trk
					[ $? != 0 ] && echo -e "${red}Error !${reset}"
					break
				else echo "Wrong target name !"
				fi
			else
				echo "Wrong <Alarm ID> !"
			fi
		fi
	done
	
    read -p "< Press Enter>"
}

spec() {

	echo "--"
	echo "$1"
	echo "$2"
	echo "$3"
	echo "$4"
	echo "$5"
	echo "$6"
	echo "$7"
	echo "$8"
	echo "--"
	
   	while :
	do
    	read -e -p "Input start time (HH:MM): " -i $1 start_time 
    	REGEX="^(0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]$"
    	#[[ $start_time == "_" ]] && break
    	#[[ $start_time =~ $REGEX ]] && break
    	[[ $start_time == "_" ]] || [[ $start_time =~ $REGEX ]] && break
 	done

    while :
	do
    	read -e -p "Input duration (HH:MM): " -i $2 duration
    	REGEX="^(0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]$"
    	#[[ $duration == "_" ]] && break
    	#[[ $duration =~ $REGEX ]] && break
    	[[ $duration == "_" ]] || [[ $duration =~ $REGEX ]] && break
 	done
 
 	ddd=""
    while :
	do
    	read -e -p "Input recurrence (DAILY, ONCE, WEEKDAYS, WEEKENDS, ON_DDDDDD): " -i $3 recurrence
	    REGEX="DAILY|ONCE|ONCE|WEEKDAYS|WEEKENDS"
	    [[ $recurrence == "_" ]] && break
    	if [[ $recurrence =~ $REGEX ]]; then
    		MATCH0="${BASH_REMATCH[0]}"
    		break
    	else
    		REGEX2="ON_([0-6]{1,6})$"
    		if [[ $recurrence =~ $REGEX2 ]]; then
    			MATCH0="${BASH_REMATCH[0]}"   			
				if (! grep -qE '([0-6])\1{1}' <<< "$MATCH0"); then
					dddddd=$(echo "$MATCH0" | awk -F"_" '{print $2}')
					[[ $dddddd =~ 0 ]] && ddd+="Sunday "
					[[ $dddddd =~ 1 ]] && ddd+="Monday "
					[[ $dddddd =~ 2 ]] && ddd+="Tuesday "
					[[ $dddddd =~ 3 ]] && ddd+="Wednesday "
					[[ $dddddd =~ 4 ]] && ddd+="Thursday "
					[[ $dddddd =~ 5 ]] && ddd+="Friday "
					[[ $dddddd =~ 6 ]] && ddd+="Saturday "
					
					read -p "Recurrence: $ddd OK ? (y/n)" rep_alarm
	    			REGEX3="Y|y|O|o"
    				[[ $rep_alarm =~ $REGEX3 ]] && break
 					ddd=""
					
				else echo "Repeated character !"
				fi
    		fi
 		fi
 	done
    
   	while :
	do
	    read -e -p "Enable (ON/OFF or YES/NO): " -i $4 enabled
	    REGEX="ON|OFF|YES|NO"
    	[[ $enabled =~ $REGEX ]] || [[ $enabled == "_" ]] && break
  	done
   
   echo $5
   
    while :
	do
    	read -e -p "Play (CHIME or URI): " -i "$5" to_play
    	REGEX="CHIME|^(http|https)://"
    	#if [[ $to_play =~ $REGEX ]]; then
    	if [[ $to_play =~ $REGEX ]] || [[ $to_play == "_" ]]; then
    		#MATCH0="${BASH_REMATCH[0]}"
    		#echo $MATCH0
    		#[ $MATCH0 != "CHIME" ] && 
    		break  		
 		fi
   	done
   
    while :
	do
	    read -e -p "Play mode (NORMAL, SHUFFLE_NOREPEAT, SHUFFLE, REPEAT_ALL, REPEAT_ONE, SHUFFLE_REPEAT_ONE): " -i $6 play_mode
 	    REGEX="NORMAL|SHUFFLE_NOREPEAT|SHUFFLE|REPEAT_ALL|REPEAT_ONE|SHUFFLE_REPEAT_ONE"
    	[[ $play_mode =~ $REGEX ]] || [[ $play_mode == "_" ]] && break
  	done
   
   	while :
	do
    	read -e -p "Volume (0 - 100): " -i $7 volume
    	[ $volume == "_" ] && break
    	if [ $volume -ge 0 ] && [ $volume -le 100 ]; then
    		break
    	else echo "Enter a number betwenn 0 and 100 !"
 		fi
  	done
    
   	while :
	do
	    read -e -p "Grouped speakers (ON/OFF , YES/NO): " -i $8 grouped
	    REGEX="ON|OFF|YES|NO"
    	[[ $grouped =~ $REGEX ]] && break
  	done

	#alarm_spec="$start_time,$duration,$recurrence,$enabled,$to_play,$play_mode,$volume,$grouped"

	#start_time="_"
	#duration="_"
	alarm_spec="$start_time,$duration,$recurrence,$enabled,$to_play,$play_mode,$volume,$grouped"

}

modify_alarms() {
    echo -e "\n${bold} Modify alarms... ${reset}"
    
    list_alarms
    echo "$court_ala"
    echo
    
   	while :
	do    
    	read -p "Enter the <Alarm ID> alarm to modify or [q] to quit: " trk
		if [[ "$trk" == "q" || "$trk" == "Q" ]]; then 
			break
		else
			ala=$(echo "$court_ala" | sed '1,3d')
			ala_id=$(echo "$court_ala" | sed '1,3d' | awk -F "|" '{print $2}')						
			if [[ $ala_id =~ "$trk" ]]; then
			
				to_modify=$(echo "$long_ala" | awk -F "|" -v var="$trk" '($2 == var) {print $3","$4","$5","$6","$7","$8","$9","$10","$11}' | xargs | sed 's/ , /,/g')
				echo "$to_modify"
				
				# Avant modif
				# Chambre,06:00,00:30,WEEKDAYS,No,France Inter 95.9 (Émissions-débats France),SHUFFLE,25,No
				
				IFS=, read -a ids <<< "${to_modify}"
				
				speaker="${ids[0]}"
				start_time="${ids[1]}"
				duration="${ids[2]}"
				recurrence="${ids[3]}"
				enabled="${ids[4]^^}"
				to_play="\"${ids[5]}\""
				play_mode="${ids[6]}"
				volume="${ids[7]}"
				grouped="${ids[8]^^}"

: <<'END_COMMENT2'				
				echo "$speaker"
				echo "$start_time"
				echo "$duration"
				echo "$recurrence"
				echo "$enabled"
				echo "$to_play"	#
				
				#get_uri
				
				echo "$play_mode"
				echo "$volume"
				echo "$grouped"
				echo
END_COMMENT2				
				spec $start_time $duration $recurrence $enabled "$to_play" $play_mode $volume $grouped
				
				
				# 07:00,01:30,WEEKDAYS,ON,"http://stream.live.vc.bbcmedia.co.uk/bbc_radio_fourfm",NORMAL,50,OFF
   				
   				echo $alarm_spec
   				# 06:00,00:30,WEEKDAYS,NO,CHIME,SHUFFLE,25,ON
   				
   				# https://jazzradio.ice.infomaniak.ch/frequencejazz-high.mp3
   				
   				sonos $loc $device modify_alarm $trk $alarm_spec
				[ $? != 0 ] && echo -e "${red}Error !${reset}"

				break
			else
				echo "Wrong <Alarm ID> !"
			fi
		fi
	done

    read -p "< Press Enter>"
}

enable_alarms() {
    echo -e "\n${bold} Enable alarms... ${reset}"

    list_alarms
    echo "$court_ala"
    echo
    
   	while :
	do    
    	read -p "Enter the <Alarm ID> alarm to enable/disable or [q] to quit: " trk
		if [[ "$trk" == "q" || "$trk" == "Q" ]]; then 
			break
		else
			ala=$(echo "$court_ala" | sed '1,3d')
			ala_id=$(echo "$court_ala" | sed '1,3d' | awk -F "|" '{print $2}')						
			if [[ $ala_id =~ "$trk" ]]; then
				enabled=$(echo "$ala" | awk -F "|" -v var="$trk" '($2 == var) {print $7}' | xargs)
				case $enabled in
				Yes) sonos $loc $device disable_alarm $trk;;
				No) sonos $loc $device enable_alarm $trk;;
				esac
				[ $? != 0 ] && echo -e "${red}Error !${reset}"
				break
			else
				echo "Wrong <Alarm ID> !"
			fi
		fi
	done

    read -p "< Press Enter>"
}

create_alarms() {

	# start time (HH:MM)
	# duration (HH:MM)
	# recurrence (DAILY, ONCE, WEEKDAYS, WEEKENDS, ON_DDDDDD)
	#	ON_DDDDDD (0=Sun 1=Mon 2=Tue 3=Wen 4 =Thu 5=Fri 6=Sat)
	#	ON_034 Sunday, Wednesday and Thursday
	# enabled (ON/OFF , YES/NO)
	# play (CHIME or URI)
	# play mode (NORMAL, SHUFFLE_NOREPEAT, SHUFFLE, REPEAT_ALL, REPEAT_ONE, SHUFFLE_REPEAT_ONE)
	# volume (0 - 100)
	# grouped speakers (ON/OFF , YES/NO)
	# 07:00,01:30,WEEKDAYS,ON,"http://stream.live.vc.bbcmedia.co.uk/bbc_radio_fourfm",NORMAL,50,OFF

    echo -e "\n${bold} Create Sonos alarms... ${reset}"
    echo -e "\n"

    list_alarms
    echo "$court_ala"
    echo

   	while :
	do
    	read -p "Input start time (HH:MM): " start_time    
    	REGEX="^(0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]$"
    	[[ $start_time =~ $REGEX ]] && break
 	done

    while :
	do
    	read -p "Input duration (HH:MM): " duration
    	REGEX="^(0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]$"
    	[[ $duration =~ $REGEX ]] && break
 	done
 
 	ddd=""
    while :
	do
    	read -p "Input recurrence (DAILY, ONCE, WEEKDAYS, WEEKENDS, ON_DDDDDD): " recurrence
	    REGEX="DAILY|ONCE|ONCE|WEEKDAYS|WEEKENDS"
    	if [[ $recurrence =~ $REGEX ]]; then
    		MATCH0="${BASH_REMATCH[0]}"
    		break
    	else
    		REGEX2="ON_([0-6]{1,6})$"
    		if [[ $recurrence =~ $REGEX2 ]]; then
    			MATCH0="${BASH_REMATCH[0]}"   			
				if (! grep -qE '([0-6])\1{1}' <<< "$MATCH0"); then
					dddddd=$(echo "$MATCH0" | awk -F"_" '{print $2}')
					[[ $dddddd =~ 0 ]] && ddd+="Sunday "
					[[ $dddddd =~ 1 ]] && ddd+="Monday "
					[[ $dddddd =~ 2 ]] && ddd+="Tuesday "
					[[ $dddddd =~ 3 ]] && ddd+="Wednesday "
					[[ $dddddd =~ 4 ]] && ddd+="Thursday "
					[[ $dddddd =~ 5 ]] && ddd+="Friday "
					[[ $dddddd =~ 6 ]] && ddd+="Saturday "
					
					read -p "Recurrence: $ddd OK ? (y/n)" rep_alarm
	    			REGEX="Y|y|O|o"
    				[[ $rep_alarm =~ $REGEX ]] && break
 					ddd=""
					
				else echo "Repeated character !"
				fi
    		fi
 		fi
 	done
    
   	while :
	do
	    read -p "Enable (ON/OFF or YES/NO): " enabled
	    REGEX="ON|OFF|YES|NO"
    	[[ $enabled =~ $REGEX ]] && break
  	done
   
    while :
	do
    	read -p "Play (CHIME or URI): " to_play
    	REGEX="CHIME|^(http|https)://"
    	if [[ $to_play =~ $REGEX ]]; then
    		MATCH0="${BASH_REMATCH[0]}"
    		echo $MATCH0
    		[ $MATCH0 != "CHIME" ] && to_play="\"$to_play\""
    		break  		
 		fi
   	done
   
    while :
	do
	    read -p "Play mode (NORMAL, SHUFFLE_NOREPEAT, SHUFFLE, REPEAT_ALL, REPEAT_ONE, SHUFFLE_REPEAT_ONE): " play_mode
 	    REGEX="NORMAL|SHUFFLE_NOREPEAT|SHUFFLE|REPEAT_ALL|REPEAT_ONE|SHUFFLE_REPEAT_ONE"
    	[[ $play_mode =~ $REGEX ]] && break
  	done
   
   	while :
	do
    	read -p "Volume (0 - 100): " volume
    	if [ $volume -ge 0 ] && [ $volume -le 100 ]; then
    		break
 		fi
  	done
    
   	while :
	do
	    read -p "Grouped speakers (ON/OFF , YES/NO): " grouped
	    REGEX="ON|OFF|YES|NO"
    	[[ $grouped =~ $REGEX ]] && break
  	done
  	
	alarm_spec="$start_time,$duration,$recurrence,$enabled,$to_play,$play_mode,$volume,$grouped"
	echo -e "\nalarm_spec: $alarm_spec"
	 
  	#sonos $loc $device create_alarm "$alarm_spec"
    a=$(sonos $loc $device create_alarm "$alarm_spec")
    echo -e "\n $a \n"			# vide
    read -p "< Press Enter>"
  	
}


all() {
	clear

	while :
	do

		[ -z $cde ] && cde="Sonos All devices"
		pad=$((((42-${#cde})/2)+${#cde}))

		clear
        echo -e ""
        echo -e "${bold} 🔊 Sonos All devices ${reset}"
        echo -e ""
        echo -e "Below commands apply to all Sonos devices in the network."
		echo -e ""
		echo -e "------------------------------------------"
		#echo -e "       Sonos All devices                  "	
		printf "%*s\n" $pad "$cde"
		echo -e "------------------------------------------"
		echo -e " 1) S${bgd}w${reset}itch Status Light OFF            " " | " 
		echo -e " 2) ${bgd}S${reset}witch Status Light ON             " " | "
		echo -e " 3) ${bgd}M${reset}ute ON                            " " | "
		echo -e " 4) M${bgd}u${reset}te OFF                           " " | "
		echo -e " 5)                                    " " | "
		echo -e " 6)                                    " " | "
		echo -e " 7)                                    " " | "
		echo -e " 8)                                    " " | "
		echo -e " 9)                                    " " | " 
		echo -e "10) ${bgd}R${reset}eturn                             " " | "
		echo -e "=========================================="
		echo -e "Enter your menu choice [1-10]: \c "
		read infos
	
		case "$infos" in

			1|w|W) all_status_light_off;;
			2|s|S) all_status_light_on;;
			3|m|M) all_mute_on;;
			4|u|U) all_mute_off;;
			10|r|R) exec "$0";;
			*) echo -e "\n${red}Oops!!! Please Select Correct Choice${reset}";
			   echo -e "Press ${bold}ENTER${reset} To Continue..." ; read ;;
		esac
	done
	}

# Switch OFF status light
all_status_light_off() {
	g=""
	sasasloffslon=$(sonos _all_ status_light off)
	g=$(echo "$sasloff" | grep -v "OK")
	
	if [ -z "$g" ]; then
		mo="ALL devices"
	else
		g=$(echo "$sasloff" | grep "OK" | cut -d ':' -f 1 | xargs)
		mo="$g device"
	fi 
	
	cde="Status light is OFF on $mo"
	echo -e "\n${bold}$cde${reset}"
	sleep 2
	}

# Switch ON status light
all_status_light_on() {
	g=""
	saslon=$(sonos _all_ status_light on)
	g=$(echo "$saslon" | grep -v "OK")
	
	if [ -z "$g" ]; then
		mo="ALL devices"
	else
		g=$(echo "$saslon" | grep "OK" | cut -d ':' -f 1 | xargs)
		mo="$g device"
	fi 
	
	cde="Status light is ON on $mo"
	echo -e "\n${bold}$cde${reset}"
	sleep 2
	}

# Mute ON 
all_mute_on() {
	g=""
	samon=$(sonos _all_ mute on)
	g=$(echo "$samon" | grep -v "OK")
	
	if [ -z "$g" ]; then
		mo="ALL devices"
	else
		g=$(echo "$samon" | grep "OK" | cut -d ':' -f 1 | xargs)
		mo="$g device"
	fi 
	
	cde="Mute ON on $mo"
	echo -e "\n${bold}$cde${reset}"
	sleep 2
	}

# Mute OFF 
all_mute_off() {
	g=""
	samoff=$(sonos _all_ mute off)
	g=$(echo "$samoff" | grep -v "OK")

	if [ -z "$g" ]; then
		mo="ALL devices"
	else
		g=$(echo "$samoff" | grep "OK" | cut -d ':' -f 1 | xargs)
		mo="$g device"
	fi 

	cde="Mute OFF on $mo"
	echo -e "\n${bold}$cde${reset}"
	sleep 2
	}


# If a function is given with the script, the function is executed directly.
# infos -> ok / info -> nok

list_functions=$(declare -F | awk '{print $NF}' | sort | grep -E -v "^_")

help_functions(){
	echo -e "${bold}List of functions:${reset}"
	echo "$list_functions" | column
	#echo "$list_functions"
}

cli_help(){
	echo -e "${bold}Help soco-cli-gui:${reset}"
	echo
	echo "Run soco-cli-gui.sh <function> (eg. soco-cli-gui.sh deezer_flow)"
	echo
	printf "${greenbold}| %-25s | %-126s ${reset}\n" "Function name" "Role"
	printf "${bold}| %-25s | %-126s ${reset}\n" "-------------------------" "--------------------------------------------------------------------------"
	
	echo -e "\n${greenbold}Favorites${reset}"
	printf "| ${bold}%-25s${reset} | %-126s \n" "deezer_flow" "Play Deezer flow"
	printf "| ${bold}%-25s${reset} | %-126s \n" "franceinfo" "Play France Info radio"
	printf "| ${bold}%-25s${reset} | %-126s \n" "franceinter" "Play France Inter radio"
	printf "| ${bold}%-25s${reset} | %-126s \n" "k6fm" "Play K6FM radio"
	printf "| ${bold}%-25s${reset} | %-126s \n" "rires" "Play Rires et Chansons radio"
	printf "| ${bold}%-25s${reset} | %-126s \n" "rtl" "Play RTL radio"
	
	echo -e "\n${greenbold}Volume${reset}"	
	printf "| ${bold}%-25s${reset} | %-126s \n" "level_11" "Set volume level to 11"
	printf "| ${bold}%-25s${reset} | %-126s \n" "level_13" "Set volume level to 13"
	printf "| ${bold}%-25s${reset} | %-126s \n" "level_15" "Set volume level to 15"
	printf "| ${bold}%-25s${reset} | %-126s \n" "vol+" "Turn up the volume"
	printf "| ${bold}%-25s${reset} | %-126s \n" "vol-" "Lower the volume"
	printf "| ${bold}%-25s${reset} | %-126s \n" "mute_off" "Sets the mute setting of the speaker to 'off'."
	printf "| ${bold}%-25s${reset} | %-126s \n" "mute_on" "Sets the mute setting of the speaker to 'on'."
	printf "| ${bold}%-25s${reset} | %-126s \n" "all_mute_off" "Sets the mute setting of all speaker (coordinators) to 'off'."
	printf "| ${bold}%-25s${reset} | %-126s \n" "all_mute_on" "Sets the mute setting of all speaker (coordinators) to 'on'."

	echo -e "\n${greenbold}Sleep${reset}"
	printf "| ${bold}%-25s${reset} | %-126s \n" "sleeep" "Sleep menu"
	printf "| ${bold}%-25s${reset} | %-126s \n" "sleeep_duration" "Device goes to sleep in <duration>."
	printf "| ${bold}%-25s${reset} | %-126s \n" "sleeep_timer" "Device goes to sleep at <time>."
	printf "| ${bold}%-25s${reset} | %-126s \n" "sleeep_cancel" "Cancel timer"

	echo -e "\n${greenbold}Light${reset}"
	printf "| ${bold}%-25s${reset} | %-126s \n" "all_status_light_off" "Switch all speaker's status light off."
	printf "| ${bold}%-25s${reset} | %-126s \n" "all_status_light_on" "Switch all speaker's status light on."
	printf "| ${bold}%-25s${reset} | %-126s \n" "led" "Switch status light."

	echo -e "\n${greenbold}Playlist${reset}"
	printf "| ${bold}%-25s${reset} | %-126s \n" "create_playlist" "Create a Sonos playlist named <playlist>."
	printf "| ${bold}%-25s${reset} | %-126s \n" "delete_playlist" "Delete the Sonos playlist named <playlist>."
	printf "| ${bold}%-25s${reset} | %-126s \n" "make_playlist" "Create a playlist."
	printf "| ${bold}%-25s${reset} | %-126s \n" "remove_from_playlist" "Remove a track from a Sonos playlist."
	printf "| ${bold}%-25s${reset} | %-126s \n" "list_playlists" "Lists the Sonos playlists."

	echo -e "\n${greenbold}Queue${reset}"
	printf "| ${bold}%-25s${reset} | %-126s \n" "add_playlist_to_queue" "Add <playlist_name> to the queue. The number in the queue of the first track in the playlist will be returned. "
	printf "| ${bold}%-25s${reset} | %-126s \n" "remove_from_queue" "Remove tracks from the queue. Track numbers start from 1. (single integers, sequences ('4,7,3'), ranges ('5-10')"
	printf "| ${bold}%-25s${reset} | %-126s \n" "list_queue" "List the tracks in the queue."
	printf "| ${bold}%-25s${reset} | %-126s \n" "clear_queue" "Clears the current queue."

	echo -e "\n${greenbold}Command${reset}"
	printf "| ${bold}%-25s${reset} | %-126s \n" "pause" "Pause playback."
	printf "| ${bold}%-25s${reset} | %-126s \n" "next" "Move to the next track."
	printf "| ${bold}%-25s${reset} | %-126s \n" "prev" "Move to the previous track."
	printf "| ${bold}%-25s${reset} | %-126s \n" "start" "Start playback."
	printf "| ${bold}%-25s${reset} | %-126s \n" "stop" "Stop playback."

	echo -e "\n${greenbold}Infos / Help${reset}"
	printf "| ${bold}%-25s${reset} | %-126s \n" "about" "About soco-cli-gui"
	printf "| ${bold}%-25s${reset} | %-126s \n" "help" "Help"
	printf "| ${bold}%-25s${reset} | %-126s \n" "inform" "Device informations"
	#printf "| ${bold}%-25s${reset} | %-126s \n" "minfo" ""
	printf "| ${bold}%-25s${reset} | %-126s \n" "sysinfo" "Prints a table of information about all speakers in the system."
	printf "| ${bold}%-25s${reset} | %-126s \n" "shazam" "Identify current playing track, like Shazam"
	printf "| ${bold}%-25s${reset} | %-126s \n" "alarms" "List all of the alarms in the Sonos system."

	echo -e "\n${greenbold}Play${reset}"
	printf "| ${bold}%-25s${reset} | %-126s \n" "play_album_from_library" "Search album in library -> add to queue -> play."
	printf "| ${bold}%-25s${reset} | %-126s \n" "play_artist_from_library" "Search artist in library -> add to queue -> play."
	printf "| ${bold}%-25s${reset} | %-126s \n" "play_local_dir" "Play all of the audio files in the specified local directory (does not traverse into subdirectories)"
	printf "| ${bold}%-25s${reset} | %-126s \n" "play_local_file" "Play MP3, M4A, MP4, FLAC, OGG, WMA, WAV, or AIFF audio files from your computer. Multiple filenames can be provided and will be played in sequence."
	printf "| ${bold}%-25s${reset} | %-126s \n" "play_local_m3u" "Plays a local M3U/M3U8 playlist consisting of local audio files (in supported audio formats)"
	printf "| ${bold}%-25s${reset} | %-126s \n" "play_radio_from_tunein" "Play favorite from TuneIn radio."
	printf "| ${bold}%-25s${reset} | %-126s \n" "play_shared_link" "Play a shared link from Deezer,Spotify, Tidal or Apple Music."
	printf "| ${bold}%-25s${reset} | %-126s \n" "play_track_from_library" "Search track in library -> add to queue -> play."
	printf "| ${bold}%-25s${reset} | %-126s \n" "play_uri" "Plays the audio object given by the <uri> parameter (e.g., a radio stream URL)"

	echo -e "\n${greenbold}Lists${reset}"
	printf "| ${bold}%-25s${reset} | %-126s \n" "list_albums" "Lists all the albums in the music library."
	printf "| ${bold}%-25s${reset} | %-126s \n" "list_all_playlist_tracks" "Lists all tracks in all Sonos Playlists."
	printf "| ${bold}%-25s${reset} | %-126s \n" "list_artists" "Lists all the artists in the music library."
	printf "| ${bold}%-25s${reset} | %-126s \n" "list_favs" "Lists all Sonos favourites."
	printf "| ${bold}%-25s${reset} | %-126s \n" "favourite_radio_stations" "List the favourite radio stations."

	echo -e "\n${greenbold}Speaker${reset}"
	printf "| ${bold}%-25s${reset} | %-126s \n" "delete_speaker_cache" "Delete speaker cache"
	printf "| ${bold}%-25s${reset} | %-126s \n" "refresh_speaker_list" "Refresh speaker cache"
	printf "| ${bold}%-25s${reset} | %-126s \n" "rename_spk" "Rename speaker"

	echo -e "\n${greenbold}Shares${reset}"
	printf "| ${bold}%-25s${reset} | %-126s \n" "reindex" "Start a reindex of the local music libraries."
	printf "| ${bold}%-25s${reset} | %-126s \n" "shares" "List the local music library shares."

	echo -e "\n${greenbold}Groups / zones${reset}"
	printf "| ${bold}%-25s${reset} | %-126s \n" "party_mode" "Adds all speakers in the system into a single group. The target speaker becomes the group coordinator."
	printf "| ${bold}%-25s${reset} | %-126s \n" "ungroup_all" "Removes all speakers in the target speaker's household from all groups."
	printf "| ${bold}%-25s${reset} | %-126s \n" "groupstatus" "Indicates whether the speaker is part of a group, and whether it's part of a stereo pair or bonded home theatre configuration."
	printf "| ${bold}%-25s${reset} | %-126s \n" "info_groups" "Lists all groups in the Sonos system. Also includes single speakers as groups of one, and paired/bonded sets as groups."
	printf "| ${bold}%-25s${reset} | %-126s \n" "all_zones" "Prints a simple list of comma separated visible zone/room names. Use all_zones (or all_rooms) to return all devices including ones not visible in the Sonos controller apps."

	echo -e "\n${greenbold}Menus${reset}"
	printf "| ${bold}%-25s${reset} | %-126s \n" "soco_infos" "Sonos infos Menu."	
	printf "| ${bold}%-25s${reset} | %-126s \n" "soco_lists" "Sonos lists Menu."
	printf "| ${bold}%-25s${reset} | %-126s \n" "all" "Sonos _all_ Menu."	

}

if [ -n "$func" ]; then
	if [[ "${func:0:1}" == "-" ]]; then
		#opt=${func:1}


		optspec=":fh-:"
		while getopts "$optspec" opt
		do
			case $opt in
				-) case "${OPTARG}" in
					help) cli_help; exit;;
					functions) help_functions; exit;;
					*)
						if [ "$OPTERR" = 1 ] && [ "${optspec:0:1}" = ":" ]; then
							echo "Unknown option: '--${OPTARG}'" >&2
						fi
						exit 3
						;;
					esac;;
				h) cli_help; exit;;
				f) help_functions; exit;;
				*)
					if [ "$OPTERR" != 1 ] || [ "${optspec:0:1}" = ":" ]; then
						echo "Non-option argument: '-${OPTARG}'" >&2
					fi
					exit 4
					;;
			esac	
		done

#read -p "< Press Enter>"				
		
	elif grep -q -w "$func" <<< "$list_functions"; then
		#set device
		devices
		#Chambre           192.168.2.232  One             Visible       14.20.1
		#Salon             192.168.2.222  One             Visible       14.20.1

		echo $param
		
		if [[ "$dev" == *"$default"* ]]; then
			device="$default"
		else
			device=$(echo "$dev" | cut -d ' ' -f1 | grep -v $default | sed -n '1p')
		fi
		
		
		if [ -n "$param" ]; then
			$func $param
		else
			$func
		fi
		exit 
	else
		echo -e "${red}Function ${italic}$func${reset}${red} doesn't existe !${reset}"
		exit
	fi
fi


main
