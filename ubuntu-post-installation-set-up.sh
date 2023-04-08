#!/bin/bash

set -e

echo "Toan's Ubuntu post-installation set up!"

echo "update & upgrade & dist-upgrade & autoremove"
sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get dist-upgrade -y && sudo apt autoremove -y

echo "Install git & curl"
sudo apt-get install git curl

echo "Install powerlevel10k"
if [ ! -d "~/powerlevel10k" ]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
  echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
fi

if ! which zsh >/dev/null 2>&1; then
  echo "Zsh is not installed"
	echo "Install zsh"
	sudo apt-get install zsh -y
	chsh -s $(which zsh)
	echo "Please log out, log in, and run the script again"
  exit 1
fi

echo "Zsh is installed"

if [ "$(basename "$SHELL")" != "zsh" ]; then
  echo "This script requires Zsh as the default shell"
  exit 1
fi

echo "Install NVM"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
source ~/.zshrc
nvm install v18.12.0

echo "Install pyenv"
sudo apt update; sudo apt install -y build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev curl libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
curl https://pyenv.run | bash
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(pyenv init -)"' >> ~/.zshrc

echo "Install docker"
sudo apt-get install ca-certificates curl gnupg
sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
url="https://docs.docker.com/desktop/install/ubuntu/"
html=$(curl -s $url)
link=$(echo $html | grep -o '<a href="[^"]*" class="button primary-btn">DEB package</a>' | sed 's/<a href="//' | sed 's/" class="button primary-btn">DEB package<\/a>//')
wget $link
sudo apt-get install -y ./docker-desktop-*-amd64.deb

echo "Generate ssh key"
ssh-keygen -t ed25519 -C "ngotoan.dev@gmail.com" -N '' <<< y

echo "Install Java 11 and jenv"
sudo apt-get install -y openjdk-11-jdk
git clone https://github.com/jenv/jenv.git ~/.jenv
echo 'export PATH="$HOME/.jenv/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(jenv init -)"' >> ~/.zshrc
source ~/.zshrc
jenv add /usr/lib/jvm/java-11-openjdk-amd64/

echo "Install software: vscode, beekeper-studio, brave browser, steam"
sudo snap install code --classic
sudo snap install beekeeper-studio
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo apt update
sudo apt install brave-browser
wget https://cdn.cloudflare.steamstatic.com/client/installer/steam.deb
sudo apt-get install -y steam.deb

