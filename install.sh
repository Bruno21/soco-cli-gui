#/usr/bin/env bash

# /opt/homebrew/etc/bash_completion.d/soco-cli-gui-completion.bash


italic="\033[3m"
underline="\033[4m"
bold="\033[1m"
reset="\033[0m"

SCRIPT_PATH=`pwd`
completion_path="/opt/homebrew/etc/bash_completion.d"


# Make soco-cli-gui accessible in PATH

if [ -d $HOME/.local/bin ]; then
	dest="$HOME/.local/bin"
	ln -fs "${SCRIPT_PATH}"/soco-cli-gui.sh $dest/soco-cli-gui
	
else
	dest="/usr/local/bin"
	sudo ln -fs "${SCRIPT_PATH}"/soco-cli-gui.sh $dest/soco-cli-gui
fi

echo -e "Installing ${bold}soco-cli-gui${reset} in ${bold}$dest${reset} ..."


# Install completions

ln -fs "${SCRIPT_PATH}"/soco-cli-gui-completion.bash $completion_path/soco-cli-gui-completion.bash

echo -e "\n${bold}soco-cli-gui${reset} has been installed. Run ${bold}soco-cli-gui${reset} command!"
