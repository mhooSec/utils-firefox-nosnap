#!/bin/bash

## NOTE: This script will prompt for the sudo password. Please review it before running it in your machine.

## Sudo permissions are needed for:
## * installFirefox() function:
##   - Moving firefox folder contents to /opt
##   - Creating a symlink of firefox binary from /opt/firefox to /usr/local/bin, so firefox command is available
##   - Downloading the firefox.desktop config file, so firefox is better integrated in the system
## * deleteSnap() function:
##   - Deleting firefox snap package from the system
## * deleteApt() function:
##   - Deleting firefox apt package from the system, including the config file in /usr/share/applications

## Global variables
DOWNLOAD_FOLDER="/tmp"
DOWNLOAD_FILE="firefox-latest.tar.bz2"
DOWNLOAD_URL="https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64&lang=en-US"
## End of global variables

installFirefox() {
    echo "[Installation] Downloading latest version of Firefox"
	wget -4 --output-document="$DOWNLOAD_FOLDER/$DOWNLOAD_FILE" "$DOWNLOAD_URL"

	if [[ -e $DOWNLOAD_FOLDER/$DOWNLOAD_FILE ]]; then
		echo "[Installation] Decompressing Firefox from bzip2 file"
		tar xjf $DOWNLOAD_FOLDER/$DOWNLOAD_FILE --directory $DOWNLOAD_FOLDER

		echo "[Installation] Moving Firefox folder to /opt"
		sudo mv $DOWNLOAD_FOLDER/firefox /opt

		echo "[Installation] Creating symlink"
		sudo ln -s /opt/firefox/firefox /usr/local/bin/firefox

		echo "[Installation] Creating .desktop for icon and quick exec"
		sudo wget -4 https://raw.githubusercontent.com/mozilla/sumo-kb/main/install-firefox-linux/firefox.desktop -P /usr/share/applications

		echo "[Installation] Cleaning up bzip2 file"
		rm -f $DOWNLOAD_FOLDER/$DOWNLOAD_FILE

	else
		echo "[Installation] There seems to have been a problem with the download of Firefox. Exiting"
		exit 1
	fi
}

importFirefoxProfile() {
	PROFILES_FILE="firefox-profiles.tar.gz"
	echo "[Import profile] Importing Firefox profiles"
	tar xzf $DOWNLOAD_FOLDER/$PROFILES_FILE --directory /home/$USER/.mozilla/firefox --overwrite
}

deleteSnap() {
	echo "[Checking snap] Deleting Firefox snap package"
	sudo snap remove firefox
	rm -rf /home/$USER/snap/firefox
}

deleteApt() {
	echo "[Checking apt] Checking if firefox is installed via apt"
	sudo apt remove firefox
}

scriptInit() {
	deleteApt
	installFirefox
	# importFirefoxProfile -- disabled in github version
	deleteSnap
}

echo "[Checking snap] Checking if Firefox is present as snap package"
snap list firefox
if [[ $? -eq 0 ]]; then
	echo "[Checking snap] Snap package found. Initiating script"
	scriptInit
elif [[ $1 -eq "force" ]]; then
	installFirefox
else
	echo "[Checking snap] Firefox seems to be running outside of snap scope. Exiting"
	exit 0
fi

