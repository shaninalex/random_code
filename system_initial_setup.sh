# create .fonts/ if not exist
if [!-d ~/.fonts]; then
    mkdir -p ~/.fonts;
fi;

mkdir ~/utils
mkdir ~/projects

# donwload font and install
curl https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/Hack.zip -o ~/.fonts/Hack.zip
fc-cache -f -v

# install nvm
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
source ~/.bashrc

# install latest npm
nvm install --lts

# install yarn and angular cli
npm install -g yarn @angular/cli

# install rust
curl --proto '=https' --tlsv1.3 https://sh.rustup.rs -sSf | sh

# install go
wget -c https://go.dev/dl/go1.20.3.linux-amd64.tar.gz -o ~/utils/
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.20.3.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
source ~/.bashrc
go version

# install docker
sudo apt-get remove docker docker-engine docker.io containerd runc
sudo apt-get update
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker $USER

# install x11 libraries ( fyne-go for some reason does not want to work without it )
sudo apt-get install build-essential gcc libgl1-mesa-dev xorg-dev python3-pip

# Install nvim and LunarVim
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
chmod u+x nvim.appimage
./nvim.appimage --appimage-extract
./squashfs-root/AppRun --version
sudo mv squashfs-root /
sudo ln -s /squashfs-root/AppRun /usr/bin/nvim
echo 'PATH=/home/alex/.local/bin:$PATH' >> ~/.bashrc
bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh) 

# update default lunarvim config by my own config
rm ~/.config/lvim/config.lua
curl https://raw.githubusercontent.com/shaninalex/my-lvim-config/main/config.lua > ~/.config/lvim/config.lua

# required dependenciec for PCloud
sudo add-apt-repository universe
sudo apt install libfuse2
# NOTE: this is not working because of website
curl https://www.pcloud.com/how-to-install-pcloud-drive-linux.html?download=electron-64 > ~/utils/pcloud
chmod +x ~/utils/pcloud

git config --global user.name "shaninalex"
git config --global user.email "shanin.x@gmail.com"

# install lazygit
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin
