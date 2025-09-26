
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
alias ls='ls --color=auto'
alias pbcopy='xsel --clipboard --input'
alias pbpaste='xsel --clipboard --output'
alias sudo='sudo -sE'
alias upd='sudo apt update;sudo apt upgrade -y;sudo apt autoremove -y'
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
	sudo apt install mc curl wget synaptic xsel -y
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
	wget https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.8_all.deb
	sudo dpkg -i ./protonvpn-stable-release_1.0.8_all.deb
	sudo apt update
	sudo apt install -y proton-vpn-gnome-desktop
	sudo apt install -y libayatana-appindicator3-1 gir1.2-ayatanaappindicator3-0.1 gnome-shell-extension-appindicator
}


### Raspberry Pi Imager
function installRPImager() {
	echo;echo ">>> Installing Raspberry Pi Imager"
	local PACKAGE=imager_latest_amd64.deb
	wget https://downloads.raspberrypi.com/imager/$PACKAGE
	sudo apt install libfuse2t64 -y
	sudo dpkg -i $PACKAGE
	rm $PACKAGE
}


### OpenSnitch is a GNU/Linux interactive application firewall inspired by Little Snitch.
function installOpensnitch() {
	echo;echo ">>> Installing OpenSnitch"
	local VERSION=1.7.2
	wget https://github.com/evilsocket/opensnitch/releases/download/v${VERSION}/python3-opensnitch-ui_$VERSION-1_all.deb
	wget https://github.com/evilsocket/opensnitch/releases/download/v${VERSION}/opensnitch_$VERSION-1_amd64.deb
	sudo apt install ./opensnitch*.deb ./python3-opensnitch-ui*.deb -y
}


function installTorBrowser() {
	echo;echo ">>> Installing Tor Browser and dependencies"
	local VERSION=14.5.7
	if [[ $ARCH == "amd64" ]] ; then
		local PACKAGE=tor-browser-linux-x86_64-${VERSION}.tar.xz
	else
		local PACKAGE=tor-browser-linux64-${version}_ALL.tar.xz
	fi
	#
	wget -q https://www.torproject.org/dist/torbrowser/${VERSION}/${PACKAGE}
	tar -xvJf $PACKAGE
	sudo mv tor-browser /usr/local/share/
	cd /usr/local/share/tor-browser
	sudo chmod +x start-tor-browser.desktop
	./start-tor-browser.desktop --register-app
	rm $PACKAGE

}

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


function installThonny() {
	echo;echo ">>> Installing Thonny Python IDE"
	sudo apt install thonny -y
}


function installSlack() {
	echo;echo ">>> Installing Slack"
	if [[ $ARCH == "amd64" ]] ; then
		local VERSION=4.46.96
		local PACKAGE=slack-desktop-${VERSION}-amd64.deb
		wget https://downloads.slack-edge.com/desktop-releases/linux/x64/${VERSION}/${PACKAGE}
		sudo apt install ./${PACKAGE}
		rm $PACKAGE
	else
		echo "Sorry, Slack is not support on your platform architecture (${ARCH})."
	fi
}


function installGithubDesktop() {
	echo;echo ">>> Installing Github Desktop"
	if [[ $ARCH == "amd64" ]] ; then
		wget -qO - https://mirror.mwt.me/shiftkey-desktop/gpgkey | gpg --dearmor | sudo tee /usr/share/keyrings/mwt-desktop.gpg > /dev/null
		sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/mwt-desktop.gpg] https://mirror.mwt.me/shiftkey-desktop/deb/ any main" > /etc/apt/sources.list.d/mwt-desktop.list'
		sudo apt update && sudo apt install github-desktop -y
	else
		echo "Sorry, Github Desktop is not support on your platform architecture (${ARCH})."
	fi
}


function installSignal() {
	echo;echo ">>> Installing Signal"
	wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg;
	cat signal-desktop-keyring.gpg | sudo tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null
	wget -O signal-desktop.sources https://updates.signal.org/static/desktop/apt/signal-desktop.sources;
	cat signal-desktop.sources | sudo tee /etc/apt/sources.list.d/signal-desktop.sources > /dev/null
	sudo apt update && sudo apt install signal-desktop
	rm signal-desktop-keyring.gpg
}

function installEnteAuthenticator() {
	echo;echo ">>> Installing Ente Authenticator"
	if [[ $ARCH == "amd64" ]] ; then
		local VERSION=4.4.4
		local PACKAGE=ente-auth-v${VERSION}-x86_64.deb
		wget https://github.com/ente-io/ente/releases/download/auth-v${VERSION}/${PACKAGE}
		sudo dpkg -i ./${PACKAGE}
		rm ${PACKAGE}
	else
		echo "Sorry, Github Desktop is not support on your platform architecture (${ARCH})."
	fi
}


################################################################################
# Main
################################################################################

ARCH=$(dpkg --print-architecture)

### Local configuration
#setAptSources
#setShellConfig
#setAliases


### Installing packages, global
#installCorePackages
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
