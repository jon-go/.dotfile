#/usr/bin/env bash

set -euxo pipefail

user=$USER
alias sudo='sudo -e'
sudo hostnamectl set-hostname fedorar

sudo cp -v /etc/vmware-tools/tools.conf.example /etc/vmware-tools/tools.conf
sudo sed -i '/^\[resolutionKMS/a enable=true' /etc/vmware-tools/tools.conf
sudo systemctl restart vmtoolsd
sudo sed -e 's/metalink/#metalink/g' -e 's|#baseurl=http://download.example/pub/|baseurl=https://mirror.sjtu.edu.cn/|g' -i.bak /etc/yum.repos.d/*
sudo mkdir -p /etc/yum.repos.d.bak/

sudo mv /etc/yum.repos.d/*.bak /etc/yum.repos.d.bak/
sudo rpm -v --import https://download.sublimetext.com/sublimehq-rpm-pub.gpg
sudo dnf config-manager --add-repo https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo

sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo dnf config-manager --add-repo https://packages.microsoft.com/yumrepos/edge
sudo mv /etc/yum.repos.d/packages.microsoft.com_yumrepos_edge.repo /etc/yum.repos.d/microsoft-edge-dev.repo

sudo dnf update -y
sudo dnf install neovim zsh java-latest-openjdk java-latest-openjdk-devel snapd maven util-linux-user microsoft-edge-dev git mycli tig gnome-tweaks chrome-gnome-shell chrome-gnome-shell sassc ibus-rime sublime-text -y

git config --global url."https://hub.fastgit.org/".insteadOf "https://github.com/"
git config --global user.name "zhonghao.wang"
git config --global user.email "wzhh1994@gmail.com"
git config --global protocol.https.allow always


sudo chsh -s /bin/zsh $user
sudo ln -fs /var/lib/snapd/snap /snap
sudo snap install --classic code
sudo snap install intellij-idea-ultimate --classic
sudo rm -rf $HOME/.oh-my-zsh/
sudo rm -rf $HOME/.zshrc*
echo "$(curl -fsSL https://raw.fastgit.org/ohmyzsh/ohmyzsh/master/tools/install.sh | sed 's/github.com/hub.fastgit.org/g')" > ./omy.install.sh
chmod +x ./omy.install.sh
./omy.install.sh --unattended
rm ./omy.install.sh
rm -rf $HOME/.oh-my-zsh/custom/themes/powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $HOME/.oh-my-zsh/custom/themes/powerlevel10k
rm -rf $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

rm -rf $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions

cat $HOME/.zshrc | sed  "$(cat $HOME/.zshrc  | grep -n ^ZSH_THEME | awk -F: '{ print $1 }')c ZSH_THEME=\"powerlevel10k/powerlevel10k\"" > $HOME/.zshrc

cat $HOME/.zshrc | sed  "$(cat $HOME/.zshrc  | grep -n ^plugins= | awk -F: '{ print $1 }')c plugins=(git zsh-syntax-highlighting zsh-autosuggestions)" > $HOME/.zshrc

# dock
rm -rf dash-to-dock
git clone -b ewlsh/gnome-40 https://github.com/ewlsh/dash-to-dock.git
export SASS=sassc && cd dash-to-dock && make && make install && cd ..
# themes
rm -rf WhiteSur-gtk-theme
git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git
cd WhiteSur-gtk-theme && ./install.sh -i fedora -N mojave && cd ..

git clone -b wallpapers --depth=1 https://github.com/vinceliuice/WhiteSur-gtk-theme.git WhiteSur-gtk-theme/wallpapers

rm -rf WhiteSur-icon-theme
git clone https://github.com/vinceliuice/WhiteSur-icon-theme.git
cd WhiteSur-icon-theme && ./install.sh  && cd ..
mkdir -p $HOME/.fonts
wget https://hub.fastgit.org/ryanoasis/nerd-fonts/releases/download/v2.1.0/Meslo.zip && unzip -o Meslo.zip -d $HOME/.fonts && rm Meslo.zip

cp .zsh_aliases $HOME/
cp .npmrc $HOME/
cp -r .cargo $HOME/
cp -r .gradle $HOME/
cp -r .m2 $HOME/
cp -r .pip $HOME/


