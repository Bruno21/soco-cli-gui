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
			echo $fa
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
			
			[ $? != 0 ] && echo -e "${red}Error !${reset}"; break
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


# Search artist in library -> add album to queue -> play it
play_artist_from_library() {
	read -e -p "Search artist in library: " search
	
	if [ -n "$search" ]; then
		a=$(sonos $loc $device search_artists "$search")
		
		# fzf
		
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


search_tracks_from_youtube_ytdlp() {

	# https://github.com/mps-youtube/yewtube
	# https://github.com/pystardust/ytfzf
	
	# https://stackoverflow.com/questions/49804874/download-the-best-quality-audio-file-with-youtube-dl
	
	#yt-dlp ytsearch5:"the clash" --get-id --get-title
	
	# yt-dlp -f 'ba' -ciw --extract-audio --audio-quality 0 --audio-format aac -o "%(title)s.%(ext)s" -v --downloader aria2c 'https://www.youtube.com/watch?v=l0Q8z1w0KGY'
	# yt-dlp -f 251 'https://www.youtube.com/watch?v=l0Q8z1w0KGY'	(webm opus)
	# yt-dlp -f 140 'https://www.youtube.com/watch?v=l0Q8z1w0KGY' (m4a)
	
	# cache: ~/.cache/yt-dlp/ ~/.cache/youtube-dl/

	# dl
	# yt-dlp -- bJ9r8LMU9bQ
	# yt-dlp -o - "https://www.youtube.com/watch?v=bJ9r8LMU9bQ" | vlc -
	# audio='yt-dIp -f 'ba' -x --audio-format mp3'
	# -o '%(id)s.%(ext)s'
	# ytfzf
	
	if (! type yt-dlp > /dev/null 2>&1); then 
		echo -e "Install ${bold}yt-dlp${reset} for searching / downloading from YouTube !"
		echo -e "https://github.com/yt-dlp/yt-dlp"
		echo -e "${italic}brew install yt-dlp${reset}"
		exit
	fi

	tmp_path=/tmp/soco-cli-gui
	[ -d $tmp_path ] && rm -rf $tmp_path
	mkdir $tmp_path
	tempfile=$(mktemp)
	youtube_dl_log=$(mktemp)
	
	read -e -p $'\e[1mSearch in YouTube: \e[1m' search

	yt-dlp -j "ytsearch20:$search" | jq -r '{"Title": .fulltitle,"URL": .webpage_url,"Id": .id,"Thumbnail": .thumbnail,"Duration": .duration_string,"Description": .description}' | sed 's/\\\"/*/g' > $tempfile
	# --match-filter "description !~= '\"'" 
	
	img=$(_sanitize $search)
	#cat $tempfile | jq
	
	echo

	declare -a yt_urls=()
	declare -a yt_titles=()
	declare -a yt_durations=()
	j=1

	while read i; do
		#echo "$i"
		title=$(jq -r '.Title' <<< "$i")
		url=$(jq -r '.URL' <<< "$i")
   		idx=$(jq -r '.Id' <<< "$i")
   		desc=$(jq -r '.Description' <<< "$i")
   		thumb=$(jq -r '.Thumbnail' <<< "$i")
   		duration=$(jq -r '.Duration' <<< "$i")
		[ ${#duration} -le 2 ] && duration="0:$duration"
   		echo -e "${bold}$j. $title${reset} ($duration)"
   		# "Title": "Arno \"Je serais devenu un gangster sans la scène\" #INA #short",
   		echo -e "${desc:0:200}" | fold -w 80 -s
   		echo "$url"
 		#echo "$thumb"
  		#echo "$idx"
   		yt_urls+=("$url")
   		yt_titles+=("$title")
   		yt_durations+=("$duration")
   		
   		if [ -n "$thumb" ]; then
   			name="$img$j.png"
   			magick "$thumb" -quality 75 -resize 300x300\> $tmp_path/$name
   			
   			if [ -f "$tmp_path/$name" ]; then
				printf "\n\t\033]1337;File=;width=300px;inline=1:`cat $tmp_path/$name | base64`\a\n"
			fi

   		fi
   		echo
   		((j++))
	done <<< $(jq -c '.' "$tempfile")
		
	nb=${#yt_urls[@]}
	
	while :
	do
    	read -e -p $'\e[1mEnter video number to download/listen or q to quit: \e[1m' i
    	echo

    	[ "$i" == "q" ] && break
    	if ((i >= 1 && i <= $nb)); then
        	((i=i-1))
        	youtube_title=${yt_titles[$i]}
        	youtube_duration=${yt_durations[$i]}
        	youtube_url=${yt_urls[$i]}

			if [ -n "$youtube_url" ]; then
				yt-dlp -f 140 $youtube_url -P $dest_yt -o "%(title)s.%(ext)s" --restrict-filenames
				filename=$(yt-dlp -f 140 $youtube_url -P $dest_yt -o "%(title)s.%(ext)s" --restrict-filenames --get-filename)

				echo -e "\nPlaying ${bold}$youtube_title${reset} ($youtube_duration) (Ctrl-C to quit)\n"
				sonos  $loc $device play_file "$filename"
			fi

    	fi
	done

}


s_ar_f_l() {
######################@
	while :
	do    
		echo
		read -e -p "Search artist in library: " search
	
		if [ -n "$search" ]; then	

			artists=$(sonos "$loc" "$device" list_artists | tail -n+4 | fzf "${fzf_music_folder_args[@]}")
			#artists=$(sonos "$loc" "$device" search_artists "$search" | tail -n+4 | awk NF | grep -v -E "^  ===" | sort)
			#tracks=$(cat search_tracks.txt| tail -n+4)
			echo "$artists"
			nb=$(echo -n "$artists" | grep -c '^')
		
			if [ "$nb" -gt 0 ]; then

				if [ $fzf_bin -eq 1 ]; then
 		
					fzf_music_folder_args=(
    					--border
	    				--exact
	    				--header="ENTER for select artist; ESC for a new search"
						)
					alb=$(echo "$artists" | fzf "${fzf_music_folder_args[@]}")
					[ -n "$alb" ] && break
			
				else
					[ "$nb" -gt 1 ] && echo "Artists found:" || echo "Artist found:"
					echo -e "$artists\n"
		
					while :
					do
						read -e -p "Choose index of artist or (q) to re-search: " research
			
						if [ "$research" != "q" ] && [ -n "$research" ]; then
							alb=$(echo "$artists" | grep -E ^[[:blank:]]+"$research:")
							[ -n "$art" ] && break 2 || echo "Wrong Choice !"
							
						else break
						fi	
					done

				fi
			fi
		fi
	done
	
	if [ -n "$alb" ]; then
		echo "$alb"
	fi
}

s_al_f_l() {

	while :
	do    
		echo
		read -e -p "Search album in library: " search
	
		if [ -n "$search" ]; then	

			albums=$(sonos "$loc" "$device" search_albums "$search" | tail -n+4)
			nb=$(echo -n "$albums" | grep -c '^')
		
			if [ "$nb" -gt 0 ]; then

				#fzf_bin=0
				if [ $fzf_bin -eq 1 ]; then
 		
					fzf_music_folder_args=(
    					--border
	    				--exact
	    				--header="ENTER for select album; ESC for a new search"
	    				--prompt="Search album..."
						)
					alb=$(echo "$albums" | fzf "${fzf_music_folder_args[@]}")
					[ -n "$alb" ] && break
			
				else
					[ "$nb" -gt 1 ] && echo "Albums found:" || echo "Album found:"
					echo -e "$albums\n"
		
					while :
					do
						read -e -p "Choose index of album, (s) to re-search, (q) to quit: " research
			
						[ "$research" == "s" ] && break
						[ "$research" == "q" ] && break 2
						if [[ $research == ?(-)+([[:digit:]]) ]]; then
							if [ $research -gt 0 ] && [ $research -le $nb ]; then 
								alb=$(echo "$albums" | grep -E ^[[:blank:]]+"$research:")
								#result=$research
								[ -n "$alb" ] && break 2 || echo "Wrong Choice !"
							fi
						fi	
					done

				fi
			fi
		fi
	done

	if [ -n "$alb" ]; then
		
		track=$(echo "$alb" | awk -F ": " '{print $1}' | sed 's/^[[:blank:]]*//;s/[[:blank:]]*$//')
		artist=$(echo "$alb" | awk -F ": " '{print $3}' | awk -F "|" '{print $1}' | sed 's/^[[:blank:]]*//;s/[[:blank:]]*$//')
		album=$(echo "$alb" | awk -F ": " '{print $4}' | awk -F "|" '{print $1}' | sed 's/^[[:blank:]]*//;s/[[:blank:]]*$//')
		#title=$(echo "$alb" | awk -F ": " '{print $5}' | sed 's/^[[:blank:]]*//;s/[[:blank:]]*$//')
		
		echo -e "\nPlaying album ${bold}$album${reset} of ${bold}$artist${reset}..."
		
		sonos "$loc" "$device" queue_search_result_number $track first : $device play_from_queue > /dev/null
		
		art			
	fi

}
