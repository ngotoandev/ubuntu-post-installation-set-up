#!/bin/bash

echo "Toan's Ubuntu post-installation set up!"

echo "update & upgrade & dist-upgrade & autoremove"
sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get dist-upgrade -y && sudo apt autoremove -y

echo "Install git & curl"
sudo apt-get install -y git curl

echo "Installing ZSH..."
if ! which zsh >/dev/null 2>&1; then
  echo "Install zsh"
  sudo apt-get install zsh -y
  chsh -s $(which zsh)
  touch ~/.zshrc
  echo "Please log out, log in, and run the script again"
  exit 1
else
  echo "ZSH is installed"
fi

if [ "$(basename "$SHELL")" != "zsh" ]; then
  echo "This script requires Zsh as the default shell"
  exit 1
fi

echo "Installing nvm and latest node lts..."
if [ ! -d ~/.nvm ]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
  source ~/.zshrc
  latest_lts=$(nvm ls-remote --lts | grep -oP 'v\d+\.\d+\.\d+' | tail -n 1)
  nvm install $latest_lts
else
  echo "nvm is already installed."
fi

echo "Installing pyenv..."
if [ ! -d ~/.pyenv ]; then
  sudo apt update; sudo apt install -y build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev curl libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
  curl https://pyenv.run | bash
  echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
  echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
  echo 'eval "$(pyenv init -)"' >> ~/.zshrc
  source ~/.zshrc
  latest_python_version=$(curl -s https://www.python.org/downloads/ | grep -Eo 'Python [0-9]+\.[0-9]+\.[0-9]+' | head -n1 | cut -d ' ' -f 2)
  pyenv install $latest_python_version
  pyenv global $latest_python_version
else
  echo "pyenv is already installed"
fi

echo "Installing docker desktop..."
if command -v docker &> /dev/null; then
  echo "Docker is already installed."
else
  sudo apt-get install -y ca-certificates curl gnupg
  sudo mkdir -m 0755 -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  url="https://docs.docker.com/desktop/install/ubuntu/"
  html=$(curl -s $url)
  link=$(echo $html | grep -o '<a href="[^"]*" class="button primary-btn">DEB package</a>' | sed 's/<a href="//' | sed 's/" class="button primary-btn">DEB package<\/a>//')
  clean_link=$(echo $link | cut -d '?' -f 1)
  wget $clean_link
  sudo apt-get install -y ./docker-desktop-*-amd64.deb
fi

echo "Generating ssh key..."
if [ -f ~/.ssh/id_ed25519.pub ]; then
  echo "Seems like an ssh key already exists."
else
  eval "$(ssh-agent -s)"
  ssh-keygen -t ed25519 -C "ngotoan.dev@gmail.com"
  ssh-add ~/.ssh/id_ed25519
fi

echo "Install Java 11 and jenv"
sudo apt-get install -y openjdk-11-jdk
if [ ! -d ~/.jenv ]; then
  git clone https://github.com/jenv/jenv.git ~/.jenv
  echo 'export PATH="$HOME/.jenv/bin:$PATH"' >> ~/.zshrc
  echo 'eval "$(jenv init -)"' >> ~/.zshrc
  source ~/.zshrc
  jenv add /usr/lib/jvm/java-11-openjdk-amd64/
  jenv global 11
else
  echo "~/.jenv already exists"
fi

echo "Installing flatpak..."
sudo apt install -y flatpak
sudo apt install -y gnome-software-plugin-flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

echo "Installing JetBrains Mono fonts..."
wget https://download.jetbrains.com/fonts/JetBrainsMono-2.304.zip
unzip JetBrainsMono-2.304.zip
mkdir -p ~/.fonts
cp -r JetBrainsMono-2.304/ttf/* ~/.fonts/
fc-cache -f -v
rm -rf JetBrainsMono-2.304
rm JetBrainsMono-2.304.zip

echo "Install software: vscode, beekeper-studio, slack, thunderbird, smartgit, brave browser, steam"
sudo snap install code --classic
sudo snap install beekeeper-studio
sudo snap install slack
sudo snap install thunderbird
sudo snap install flameshot
flatpak install flathub com.syntevo.SmartGit

dpkg -s brave-browser &> /dev/null
if [ $? -eq 0 ]; then
  echo "Brave Browser is installed."
else
  sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list
  sudo apt update
  sudo apt install -y brave-browser
fi

echo "Installing steam..."
wget https://cdn.cloudflare.steamstatic.com/client/installer/steam.deb
sudo apt-get install -y ./steam.deb

echo "Installing FDM..."
wget https://dn3.freedownloadmanager.org/6/latest/freedownloadmanager.deb
sudo apt-get install -y ./freedownloadmanager.deb

if [ ! -d ~/powerlevel10k ]; then
  echo "Install powerlevel10k"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
  echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
fi

echo "Set up complete! Please restart your computer!"
