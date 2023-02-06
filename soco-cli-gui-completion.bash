#/usr/bin/env bash

# https://iridakos.com/programming/2018/03/01/bash-programmable-completion-tutorial#registering-the-completion-script

_soco-cli-gui_completions()
{
	COMPREPLY=($(compgen -W "deezer_flow franceinfo franceinter k6fm rires rtl level_11 level_13 level_15 vol+ vol- mute_off mute_on pause next prev start stop alarms inform sysinfo play_local_file play_local_dir list_favs clear_queue list_queue alarms create_alarms move_alarms remove_alarms enable_alarms modify_alarms snooze_alarms" "${COMP_WORDS[1]}"))

}

complete -F _soco-cli-gui_completions soco-cli-gui


#complete -W "deezer_flow franceinfo franceinfo k6fm rires rtl level_11 level_13 level_15 vol+ vol- mute_off mute_on pause next prev start stop alarms inform sysinfo" soco-cli-gui.sh