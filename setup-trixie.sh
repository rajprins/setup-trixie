
function setShellConfig() {
	echo;echo ">>> Setting shell configuration"
	cat << EOF >> ~/.bashrc
export PS1='\[\e]133;D;$?\e\\\e]133;A\e\\\]\[\e]0;\u@\h: \w\a\]\[\033[38;5;208m\][\[\033[38;5;148m\]\u\[\033[38;5;250m\]@\[\033[38;5;117m\]\h \[\033[38;5;211m\]\w\[\033[38;5;208m\]]\[\033[38;5;250m\]$ \[\033[0m\]\[\e]133;B\e\\\]'
EOF
}


### Set some aliases
function setAliases() {
	echo;echo ">>> Setting aliases"
	cat << EOF >> ~/.bash_aliases
alias edit='/usr/bin/subl'
alias git-revert='echo '\''Reverting local git repo to origin/master'\'';git fetch origin/master;git reset --hard origin/master'
alias gs='git status'
alias gp='git pull'
alias gc='git commit'
alias ls='ls --color=auto'
alias pbcopy='xsel --clipboard --input'
alias pbpaste='xsel --clipboard --output'
alias sudo='sudo -sE'
alias upd='sudo apt update;sudo apt upgrade -y;sudo apt autoremove -y'
alias sai='sudo apt install -y'
alias sap='sudo apt purge --autoremove -y'
EOF
}


### Add non-free repos
function setAptSources() {
	echo;echo ">>> Setting Apt repository sources"
	sudo cat << EOF >> /etc/apt/sources.list
deb http://deb.debian.org/debian/ trixie main contrib non-free-firmware non-free
deb-src http://deb.debian.org/debian/ trixie main contrib non-free-firmware non-free
deb http://security.debian.org/debian-security/ trixie-security main contrib non-free-firmware non-free
deb-src http://security.debian.org/debian-security/ trixie-security main contrib non-free-firmware non-free
deb http://deb.debian.org/debian/ trixie-updates main contrib non-free-firmware non-free
deb-src http://deb.debian.org/debian/ trixie-updates main contrib non-free-firmware non-free
EOF
}


### Install some generic/useful packages
function installCorePackages() {
	echo;echo ">>> Installing core utilities"
	sudo apt install mc curl wget synaptic xsel  -y
}


function installFontsInter() {
	echo;echo ">>> Installing and setting Inter fonts"
	sai fonts-inter fonts-inter-variable
	gsettings set org.gnome.desktop.interface font-name "Inter Variable 11"
	gsettings set org.gnome.desktop.interface document-font-name "Inter Variable 11"
	gsettings set org.gnome.desktop.interface font-hinting "full"
	gsettings set org.gnome.desktop.interface font-antialiasing "rgba"
}


function tweakGnome() {
	echo;echo ">>> Installing Gnome tweaks and extensions"
	sudo apt install gnome-tweaks gnome-shell-extension-manager gnome-shell-extension-dashtodock gnome-shell-extension-appindicator -y
	installAdwGtk3
	installAdwaitaQt6
	installFontsInter
	installPaperIconTheme
	gsettings set org.gnome.desktop.interface clock-format "24h"
	gsettings set org.gnome.desktop.interface show-battery-percentage true
	# Enable minimize, maximize and close toolbar buttons
	gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
}


function installFlatpak() {
	echo;echo ">>> Installing Flatpak"
	sudo apt install flatpak gnome-software-plugin-flatpak
	echo
	echo "Note: please reboot your machine after completing this script to activate Flatpak on your Debian system"
	echo -n "Press RETURN to continue..."
	read CONFIRM
}

function installSnap() {
	echo;echo ">>> Installing Snap"
	sudo apt install -y snapd gnome-software-plugin-snap
	echo
	echo "Note: please reboot your machine after completing this script to activate Snapd on your Debian system"
	echo -n "Press RETURN to continue..."
	read CONFIRM
}


### Sublime Text
function installSublime() {
	echo;echo ">>> Installing Sublime Text"
	wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo tee /etc/apt/keyrings/sublimehq-pub.asc > /dev/null
	echo -e 'Types: deb\nURIs: https://download.sublimetext.com/\nSuites: apt/stable/\nSigned-By: /etc/apt/keyrings/sublimehq-pub.asc' | sudo tee /etc/apt/sources.list.d/sublime-text.sources
	sudo apt update
	sudo apt install sublime-text -y
}


### Brave Browser
function installBrave() {
	echo;echo ">>> Installing Brave browser"
	sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
	sudo curl -fsSLo /etc/apt/sources.list.d/brave-browser-release.sources https://brave-browser-apt-release.s3.brave.com/brave-browser.sources
	sudo apt update
	sudo apt install brave-browser -y
}


### Tor
function installTor() {
	echo;echo ">>> Installing Tor"
	# Install Tor and useful packages
	sudo apt install apt-transport-https gnupg tor -y
	# We don't want Tor to load automatically upon startup
	sudo systemctl disable tor
}


### ProtonVPN
function installProton() {
	echo;echo ">>> Installing Proton VPN"
	local VERSION=1.0.8
	local PACKAGE=protonvpn-stable-release_${VERSION}_all.deb
	wget https://repo.protonvpn.com/debian/dists/stable/main/binary-all/$PACKAGE
	sudo dpkg -i ./${PACKAGE}
	sudo apt update
	sudo apt install -y proton-vpn-gnome-desktop
	sudo apt install -y libayatana-appindicator3-1 gir1.2-ayatanaappindicator3-0.1 gnome-shell-extension-appindicator
	rm $PACKAGE
}


### Raspberry Pi Imager
function installRPImager() {
	echo;echo ">>> Installing Raspberry Pi Imager"
	if [[ $ARCH == "amd64" ]] ; then
		local PACKAGE=imager_latest_amd64.deb
		wget https://downloads.raspberrypi.com/imager/$PACKAGE
		sudo apt install libfuse2t64 -y
		sudo dpkg -i $PACKAGE
		rm $PACKAGE
	else
		echo "Sorry, RaspberryPi Imager is not supported on your platform architecture (${ARCH})."
	fi
}


### OpenSnitch is a GNU/Linux interactive application firewall inspired by Little Snitch.
function installOpensnitch() {
	echo;echo ">>> Installing OpenSnitch"
	local VERSION=1.7.2
	if [[ $ARCH == "amd64" || $ARCH == "arm64" ]] ; then
		wget https://github.com/evilsocket/opensnitch/releases/download/v${VERSION}/python3-opensnitch-ui_$VERSION-1_all.deb
		wget https://github.com/evilsocket/opensnitch/releases/download/v${VERSION}/opensnitch_$VERSION-1_${ARCH}.deb
		sudo apt install ./opensnitch_$VERSION-1_${ARCH}.deb ./python3-opensnitch-ui_$VERSION-1_all.deb -y
		rm python3-opensnitch-ui_$VERSION-1_all.deb
		rm opensnitch_$VERSION-1_${ARCH}.deb
	else
		echo "Sorry, OpenSnitch is not supported on your platform architecture (${ARCH})."
	fi
}


### Tor Browser, only AMD64 officially supported. Unofficial ARM port is available.
function installTorBrowser() {
	echo;echo ">>> Installing Tor Browser and dependencies"
	local VERSION=14.5.7
	if [[ $ARCH == "amd64" ]] ; then
		local VERSION=15.0a3
		local PACKAGE=tor-browser-linux-x86_64-${VERSION}.tar.xz
		local URL=https://www.torproject.org/dist/torbrowser/${VERSION}/${PACKAGE}
	elif [[ $ARCH == "arm64" ]] ; then
		local VERSION=14.5a1
		local PACKAGE=tor-browser-linux-aarch64-${VERSION}.tar.xz
		local URL=https://github.com/tnt2k/tor-browser-arm64/releases/download/Tor-Browser/${PACKAGE}
	else
		echo "Sorry, Tor Browser is not supported on your platform architecture (${ARCH})."
		return 1
	fi
	#
	wget $URL
	tar -xvJf $PACKAGE
	sudo mv tor-browser /usr/local/share/
	cd /usr/local/share/tor-browser
	sudo chmod +x start-tor-browser.desktop
	./start-tor-browser.desktop --register-app
	rm $PACKAGE
}


### Google Chrome, x86 only
function installGoogleChrome() {
	echo;echo ">>> Installing Google Chrome"
	if [[ $ARCH == "amd64" ]] ; then
		local PACKAGE=google-chrome-stable_current_amd64.deb
		wget https://dl.google.com/linux/direct/${PACKAGE}
		sudo apt install ./${PACKAGE}
		rm $PACKAGE
	else
		echo "Sorry, Google Chrome is not supported on your platform architecture (${ARCH})."
	fi
}


### Thonny Python IDE
function installThonny() {
	echo;echo ">>> Installing Thonny Python IDE"
	sudo apt install thonny -y
}


### Slack, x86 only
function installSlack() {
	echo;echo ">>> Installing Slack"
	if [[ $ARCH == "amd64" ]] ; then
		local VERSION=4.46.96
		local PACKAGE=slack-desktop-${VERSION}-amd64.deb
		wget https://downloads.slack-edge.com/desktop-releases/linux/x64/${VERSION}/${PACKAGE}
		sudo apt install ./${PACKAGE}
		rm $PACKAGE
	else
		echo "Sorry, Slack is not supported on your platform architecture (${ARCH})."
	fi
}


### Github Desktop
function installGithubDesktop() {
	echo;echo ">>> Installing Github Desktop"
	if [[ $ARCH == "amd64" ]] ; then
		wget -qO - https://mirror.mwt.me/shiftkey-desktop/gpgkey | gpg --dearmor | sudo tee /usr/share/keyrings/mwt-desktop.gpg > /dev/null
		sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/mwt-desktop.gpg] https://mirror.mwt.me/shiftkey-desktop/deb/ any main" > /etc/apt/sources.list.d/mwt-desktop.list'
		sudo apt update && sudo apt install github-desktop -y
	elif [[ $ARCH == "arm64" ]] ; then
		local VERSION=3.4.13-linux1
		local PACKAGE=GitHubDesktop-linux-arm64-${VERSION}.deb
		wget https://github.com/shiftkey/desktop/releases/download/release-${VERSION}/${PACKAGE}
		sudo apt install ./${PACKAGE}
		rm $PACKAGE
	else
		echo "Sorry, Github Desktop is not supported on your platform architecture (${ARCH})."
	fi
}


### Signal secure messenger
function installSignal() {
	echo;echo ">>> Installing Signal"
	wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg;
	cat signal-desktop-keyring.gpg | sudo tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null
	wget -O signal-desktop.sources https://updates.signal.org/static/desktop/apt/signal-desktop.sources;
	cat signal-desktop.sources | sudo tee /etc/apt/sources.list.d/signal-desktop.sources > /dev/null
	sudo apt update && sudo apt install signal-desktop
	rm signal-desktop-keyring.gpg
}


### Ente Authenticator, x86 only
function installEnteAuthenticator() {
	echo;echo ">>> Installing Ente Authenticator"
	if [[ $ARCH == "amd64" ]] ; then
		local VERSION=4.4.4
		local PACKAGE=ente-auth-v${VERSION}-x86_64.deb
		wget https://github.com/ente-io/ente/releases/download/auth-v${VERSION}/${PACKAGE}
		sudo dpkg -i ./${PACKAGE}
		rm ${PACKAGE}
	else
		echo "Sorry, Ente Auth is not supported on your platform architecture (${ARCH})."
	fi
}


### Client for iCloud Notes
function installIcloudNotes() {
	echo;echo ">>> Installing iCloud Notes client"
    sudo apt install curl
 	sudo curl -fsSLo /usr/share/keyrings/himel.gpg https://66355b217734305f6607e3f6--mirror-himelrana.netlify.app/himel.gpg
 	echo "deb [signed-by=/usr/share/keyrings/himel.gpg] https://66355b217734305f6607e3f6--mirror-himelrana.netlify.app/ stable main"|sudo tee /etc/apt/sources.list.d/himel-release.list
    sudo apt update
    sudo apt install icloud-notes
}


### Microsoft Visual Studio Code
function installVisualStudioCode() {
	echo;echo ">>> Installing VisualStudio Code (might take some time!)"
	if [[ $ARCH == "amd64" || $ARCH == "arm64" || $ARCH == "armhf" ]] ; then
		wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
		sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
		echo "deb [arch=${ARCH} signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list 
		sudo apt update
		sudo apt install code
		rm packages.microsoft.gpg
	else
		echo "Sorry, VisualStudio Code is not supported on your platform architecture (${ARCH})."
	fi
}



### Adwaita theme for old GTK3 apps
function installAdwGtk3() {
	echo;echo ">>> Installing and setting libAdwaita theme for GTK3"
	curl -s https://julianfairfax.codeberg.page/package-repo/pub.gpg | gpg --dearmor | sudo dd of=/usr/share/keyrings/julians-package-repo.gpg
	echo 'deb [ signed-by=/usr/share/keyrings/julians-package-repo.gpg ] https://julianfairfax.codeberg.page/package-repo/debs packages main' | sudo tee /etc/apt/sources.list.d/julians-package-repo.list
	sudo apt update
	sudo apt install adw-gtk3 -y
	gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3' 
	gsettings set org.gnome.desktop.interface color-scheme 'default'
}



### Adwaita theme for QT
function installAdwaitaQt6() {
	echo;echo ">>> Installing Adwaita theme for Qt6"
	sudo apt install -y adwaita-qt6	qt6ct
	echo "QT_QPA_PLATFORMTHEME=qt6ct" | sudo tee -a /etc/environment
}



### Angry IP Scanner, depends on Java runtime
function installAngryIpScanner() {
	echo;echo ">>> Installing Angry IP Scanner"
	VERSION=3.9.2
	if [[ $ARCH == "amd64" ]] ; then
		local PACKAGE=ipscan_${VERSION}_amd64.deb
		local URL=https://github.com/angryip/ipscan/releases/download/${VERSION}/${PACKAGE}
		sudo apt install default-jre -y
		wget $URL
		sudo dpkg -i ./${PACKAGE}
		rm $PACKAGE
	elif [[ $ARCH == "arm64" || $ARCH == "armhf" ]] ; then
		local PACKAGE=ipscan_${VERSION}_all.deb
		local URL=https://github.com/angryip/ipscan/releases/download/${VERSION}/${PACKAGE}
		sudo apt install default-jre libswt-gtk-4-java libswt-cairo-gtk-4-jni -y
		wget $URL
		sudo dpkg -i ./${PACKAGE}
		rm $PACKAGE
	else
		echo "Sorry, Angry IP Scanner is not supported on your platform architecture (${ARCH})."
	fi
}



### Nice looking icon theme
function installPapirusIconTheme() {
	echo;echo ">>> Installing and setting Papirus icon theme"
	sudo apt install papirus-icon-theme -y
	gsettings set org.gnome.desktop.interface icon-theme 'Papirus'
}



### Nice looking icon theme
function installPaperIconTheme() {
	sudo apt install paper-icon-theme -y
	gsettings set org.gnome.desktop.interface icon-theme 'Paper'
}


### Gimp image editor
function installGimp() {
	echo;echo ">>> Installing GIMP image editor"
	sudo apt install gimp gimp-data gimp-data-extras -y
}



### Firefox theme to match Gnome look and feel
function installFirefoxGnomeTheme() {
	echo;echo ">>> Installing Firefox Gnome-like theme"
	curl -s -o- https://raw.githubusercontent.com/rafaelmardojai/firefox-gnome-theme/master/scripts/install-by-curl.sh | bash
}


### Simplex chat app
function installSimplex() {
	echo;echo ">>> Installing Simplex"
	if [[ $ARCH == "amd64" ]] ; then
		#local PACKAGE=simplex-desktop-ubuntu-22_04-x86_64.deb
		local PACKAGE=simplex-desktop-ubuntu-24_04-x86_64.deb
		local URL=https://github.com/simplex-chat/simplex-chat/releases/latest/download/${PACKAGE}
		wget $URL
		sudo dpkg -i ./${PACKAGE}
		rm $PACKAGE
	elif [[ $ARCH == "arm64" ]] ; then
				#local PACKAGEsimplex-desktop-ubuntu-22_04-aarch64.deb
		local PACKAGE=simplex-desktop-ubuntu-24_04-aarch64.deb
		local URL=https://github.com/simplex-chat/simplex-chat/releases/latest/download/${PACKAGE}
		wget $URL
		sudo dpkg -i ./${PACKAGE}
		rm $PACKAGE
	else
		echo "Sorry, Simplex is not supported on your platform architecture (${ARCH})."
	fi
}


### Balena Etcher
function installBalenaEtcher() {
	echo;echo ">>> Installing Balena Etcher"
	if [[ $ARCH == "amd64" ]] ; then
		VERSION="2.1.4"
		PACKAGE=balena-etcher_${VERSION}_amd64.deb
		URL="https://github.com/balena-io/etcher/releases/download/v${VERSION}/${PACKAGE}"
		wget $URL
		sudo dpkg -i ./${PACKAGE}
		rm $PACKAGE
	else
		echo "Sorry, Balena Etcher is not supported on your platform architecture (${ARCH})."
	fi
}


### FreeLens Kubernetes IDE
function installFreeLens() {
	#https://github.com/freelensapp/freelens/releases/download/v1.6.1/Freelens-1.6.1-linux-amd64.deb
	#https://github.com/freelensapp/freelens/releases/download/v1.6.1/Freelens-1.6.1-linux-arm64.deb
	echo;echo ">>> Installing FreeLens Kubernetes IDE"
	if [[ $ARCH == "amd64" || $ARCH == "arm64" ]] ; then
		VERSION=1.6.1
		PACKAGE=Freelens-${VERSION}-linux-${ARCH}.deb
		URL=https://github.com/freelensapp/freelens/releases/download/v${VERSION}/${PACKAGE}
		wget $URL
		sudo dpkg -i ./${PACKAGE}
		rm $PACKAGE
	else
		echo "Sorry, FreeLens is not supported on your platform architecture (${ARCH})."
	fi
}


### Cockpit linux systems management software
function installCockpit() {
    echo;echo ">>> Installing Cockpit web-based graphical systems management interface"
    sudo apt install cockpit cockpit-networkmanager cockpit-system cockpit-packagekit cockpit-doc cockpit-sosreport  python3-pcp  udisks2-btrfs  udisks2-lvm2  mdadm  lastlog2  sssd-dbus
}


################################################################################
# Main
################################################################################

source /etc/os-release
if [[ $ID != "debian" ]]; then
	echo
	echo "Sorry, this script is for Debian only."
	echo "Exiting..."
	echo 
	exit 1
fi

ARCH=$(dpkg --print-architecture)

alias sai='sudo apt install -y'

### Configuration
#setAptSources
#setShellConfig
#setAliases
#installCorePackages
#tweakGnome
#installFlatpak
#installSnap


### Installing packages
#installRPImager
#installSublime
#installBrave
#installTor
#installTorBrowser
#installProton
#installOpensnitch
#installGoogleChrome
#installSlack
#installGithubDesktop
#installSignal
#installEnteAuthenticator
#installIcloudNotes
#installVisualStudioCode
#installAngryIpScanner
#installGimp
#installFirefoxGnomeTheme
#installSimplex
#installBalenaEtcher
#installFreeLens
#installCockpit