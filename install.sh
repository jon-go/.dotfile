#/usr/bin/env bash

set -euxo pipefail

user=$USER
git_home=$(pwd)
sudo -E hostnamectl set-hostname fedora

sudo -E cp -v /etc/vmware-tools/tools.conf.example /etc/vmware-tools/tools.conf
sudo -E sed -i '/^\[resolutionKMS/a enable=true' /etc/vmware-tools/tools.conf
sudo -E systemctl restart vmtoolsd
sudo -E sed -e 's/metalink/#metalink/g' -e 's|#baseurl=http://download.example/pub/|baseurl=https://mirror.sjtu.edu.cn/|g' -i.bak /etc/yum.repos.d/*
sudo -E mkdir -p /etc/yum.repos.d.bak/

sudo -E mv /etc/yum.repos.d/*.bak /etc/yum.repos.d.bak/
sudo -E rpm -v --import https://download.sublimetext.com/sublimehq-rpm-pub.gpg
sudo -E dnf config-manager --add-repo https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo

sudo -E rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo -E dnf config-manager --add-repo https://packages.microsoft.com/yumrepos/edge
sudo -E mv /etc/yum.repos.d/packages.microsoft.com_yumrepos_edge.repo /etc/yum.repos.d/microsoft-edge-dev.repo

sudo -E dnf update -y
sudo -E dnf install neovim zsh java-latest-openjdk java-latest-openjdk-devel snapd maven util-linux-user microsoft-edge-dev git mycli tig gnome-tweaks chrome-gnome-shell chrome-gnome-shell sassc ibus-rime sublime-text glib2-devel -y

sudo -E dnf remove -y docker docker-common docker-selinux docker-engine
sudo -E wget -O /etc/yum.repos.d/docker-ce.repo https://download.docker.com/linux/fedora/docker-ce.repo
sudo sed -i 's+download.docker.com+mirror.sjtu.edu.cn/docker-ce+' /etc/yum.repos.d/docker-ce.repo
sudo mkdir -p /etc/docker/
sudo bash -c "echo '{\"registry-mirrors\": [\"https://docker.mirrors.sjtug.sjtu.edu.cn\"]}' > /etc/docker/daemon.json"
sudo -E dnf install -y yum-utils device-mapper-persistent-data lvm2 docker-ce


sudo -E flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
sudo -E flatpak remote-modify flathub --url=https://mirror.sjtu.edu.cn/flathub

git config --global url."https://hub.fastgit.org/".insteadOf "https://github.com/"
git config --global user.name "zhonghao.wang"
git config --global user.email "wzhh1994@gmail.com"
git config --global protocol.https.allow always


sudo -E chsh -s /bin/zsh $user
sudo -E ln -fs /var/lib/snapd/snap /snap
sudo -E snap install --classic code
sudo -E snap install libxml2-utils
sudo -E snap install intellij-idea-ultimate --classic
sudo -E rm -rf $HOME/.oh-my-zsh/
sudo -E rm -rf $HOME/.zshrc*
echo "$(curl -fsSL https://raw.fastgit.org/ohmyzsh/ohmyzsh/master/tools/install.sh | sed 's/github.com/hub.fastgit.org/g')" > ./omy.install.sh
chmod +x ./omy.install.sh
./omy.install.sh --unattended
rm ./omy.install.sh
rm -rf $HOME/.oh-my-zsh/custom/themes/powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $HOME/.oh-my-zsh/custom/themes/powerlevel10k
rm -rf $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

rm -rf $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions

cat $HOME/.zshrc | sed  "$(cat $HOME/.zshrc  | grep -n ^ZSH_THEME | awk -F: '{ print $1 }')c ZSH_THEME=\"powerlevel10k/powerlevel10k\"" > $HOME/.zshrc

cat $HOME/.zshrc | sed  "$(cat $HOME/.zshrc  | grep -n ^plugins= | awk -F: '{ print $1 }')c plugins=(git zsh-syntax-highlighting zsh-autosuggestions)" > $HOME/.zshrc

# dock
rm -rf dash-to-dock
git clone -b ewlsh/gnome-40 https://github.com/ewlsh/dash-to-dock.git
export SASS=sassc && cd dash-to-dock && make && make install && cd $git_home
# themes
rm -rf WhiteSur-gtk-theme
git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git
cd WhiteSur-gtk-theme && ./install.sh -i fedora -N mojave && ./tweaks.sh -f -d -c dark && cd $git_home

git clone -b wallpapers --depth=1 https://github.com/vinceliuice/WhiteSur-gtk-theme.git WhiteSur-gtk-theme/wallpapers

cd WhiteSur-gtk-theme/wallpapers && sudo ./install-gnome-backgrounds.sh && ./install-wallpapers.sh && cd $git_home

rm -rf WhiteSur-icon-theme
git clone https://github.com/vinceliuice/WhiteSur-icon-theme.git
cd WhiteSur-icon-theme && ./install.sh  && cd $git_home
mkdir -p $HOME/.fonts
wget https://hub.fastgit.org/ryanoasis/nerd-fonts/releases/download/v2.1.0/Meslo.zip && unzip -o Meslo.zip -d $HOME/.fonts && rm Meslo.zip
cd $git_home
cp -rf .zsh_aliases $HOME/
cp -rf .npmrc $HOME/
cp -rf .cargo $HOME/
cp -rf .gradle $HOME/
cp -rf .m2 $HOME/
cp -rf .pip $HOME/

curl -sLf https://spacevim.org/install.sh | bash
rm -rf $git_home/.tmux
git clone https://github.com/gpakosz/.tmux.git $git_home/.tmux
ln -s -f $git_home/.tmux/.tmux.conf ~/.tmux.conf
cp $git_home/.tmux/.tmux.conf.local ~/.tmux.conf.local
echo "tmux_conf_theme_status_right='#{prefix}#{pairing}#{synchronized}#{?battery_bar, #{battery_bar},}#{?battery_percentage, #{battery_percentage},} |temp |#(curl wttr.in?format=\"%%c%%20%%t\") |\uF017 %R |\uF007 #{username}#{root} | \uFBC5#{hostname} '" >>  ~/.tmux.conf
