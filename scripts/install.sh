#!/bin/bash
#     ____           __        ____   _____           _       __
#    /  _/___  _____/ /_____ _/ / /  / ___/__________(_)___  / /_
#    / // __ \/ ___/ __/ __ `/ / /   \__ \/ ___/ ___/ / __ \/ __/
#  _/ // / / (__  ) /_/ /_/ / / /   ___/ / /__/ /  / / /_/ / /_
# /___/_/ /_/____/\__/\__,_/_/_/   /____/\___/_/  /_/ .___/\__/
#                                                  /_/
clear

from="$HOME/swaydev"
cfgPath="$from/.config"

installPackages() {
  sudo pacman -Syu
  local packages=("gum" "network-manager-applet" "autotiling" "networkmanager-openvpn" "sway" "swaylock-effects" "zip" "man" "libreoffice" "rust-src" "mpv-mpris" "fastfetch" "glow" "swww" "grub" "os-prober" "kitty" "rofi-wayland" "ntfs-3g" "tree" "discord" "lazygit" "ufw" "zsh" "unzip" "wget" "yazi" "polkit-gnome" "neovim" "eza" "btop" "gamemode" "steam" "zoxide" "fzf" "bat" "jdk21-openjdk" "docker" "ripgrep" "cargo" "fd" "sddm" "starship" "okular" "cliphist" "swayidle" "rust-analyzer" "bluez" "bluez-utils" "networkmanager" "brightnessctl" "wine" "bluez-obex" "python-pip" "python-requests" "python-pipx" "pavucontrol" "openssh" "pam-u2f" "pipewire" "pipewire-pulse" "pipewire-alsa" "pipewire-jack" "pamixer" "ttf-font-awesome" "ttf-nerd-fonts-symbols" "ttf-jetbrains-mono-nerd" "noto-fonts-emoji" "wireplumber" "libfido2" "qt5-wayland" "qt6-wayland" "calc" "gnome-keyring" "piper" "xdg-desktop-portal-gtk" "xdg-desktop-portal-gnome" "xdg-desktop-portal-wlr" "gdb" "qt5-quickcontrols" "qt5-quickcontrols2" "qt5-graphicaleffects" "blueman" "pacman-contrib" "libimobiledevice" "usbmuxd" "gvfs-gphoto2" "ifuse" "python-dotenv" "openvpn" "ncdu" "texlive" "lynx" "grim" "slurp" "swappy" "inetutils" "net-tools" "wl-clipboard" "jq" "nodejs" "npm" "nm-connection-editor" "wlsunset" "thunar" "github-cli" "tumbler" "protonmail-bridge" "waybar" "proton-vpn-gtk-app" "systemd-resolved" "wireguard-tools")
  for pkg in "${packages[@]}"; do
    sudo pacman -S --noconfirm "$pkg"
  done
}

installAurPackages() {
  local packages=("google-chrome" "xwaylandvideobridge" "openvpn-update-systemd-resolved" "wlogout" "swaync" "lazydocker" "syshud" "qt-heif-image-plugin" "luajit-tiktoken-bin" "ani-cli")
  for pkg in "${packages[@]}"; do
    yay -S --noconfirm "$pkg"
  done
}

installYay() {
  git clone https://aur.archlinux.org/yay.git "$HOME/yay"
  cd "$HOME/yay"
  makepkg -si
  echo ">>> yay has been installed successfully."
}

installDeepCoolDriver() {
  echo ">>> Do you want to install DeepCool CPU-Fan driver?"
  deepcool=$(gum choose "Yes" "No")
  if [[ "$deepcool" == "Yes" ]]; then
    sudo cp "$from/DeepCool/deepcool-digital-linux" "/usr/sbin"
    sudo cp "$from/DeepCool/deepcool-digital.service" "/etc/systemd/system/"
    sudo systemctl enable deepcool-digital
  fi
}

configure_git() {
  echo ">>> Want to configure git?"
  answer=$(gum choose "Yes" "No")
  if [[ "$answer" == "Yes" ]]; then
    username=$(gum input --prompt ">>> What is your user name? ")
    git config --global user.name "$username"
    useremail=$(gum input --prompt ">>> What is your email? ")
    git config --global user.email "$useremail"
    git config --global pull.rebase true
  fi

  echo ">>> Want to create a ssh-key?"
  ssh=$(gum choose "Yes" "No")
  if [[ "$ssh" == "Yes" ]]; then
    ssh-keygen -t ed25519 -C "$useremail"
  fi
}

detect_nvidia() {
  gpu=$(lspci | grep -i '.* vga .* nvidia .*')

  shopt -s nocasematch

  if [[ $gpu == *' nvidia '* ]]; then
    echo ">>> Nvidia GPU is present"
    gum spin --spinner dot --title "Installaling nvidia drivers now..." -- sleep 2
    sudo pacman -S --noconfirm nvidia nvidia-utils nvidia-settings
  else
    echo ">>> It seems you are not using a Nvidia GPU"
    echo ">>> If you have a Nvidia GPU then download the drivers yourself please :)"
  fi
}

get_wallpaper() {
  echo ">>> Do you want to download cool wallpaper?"
  local ans=$(gum choose "Yes" "No")
  if [[ "$ans" == "Yes" ]]; then
    git clone "https://github.com/lixdroid-sys/WallFlex.git" "$HOME/WallFlex"
    cp -r "$HOME/WallFlex/wallpaper/" "$HOME/Pictures/Wallpaper/"
    rm -rf "$HOME/WallFlex/"
  fi
}

copy_config() {
  gum spin --spinner dot --title "Creating Home..." -- sleep 2
  mkdir -p "$HOME/Documents/"
  mkdir -p "$HOME/Music/"
  mkdir -p "$HOME/Desktop/"
  mkdir -p "$HOME/Downloads/"
  mkdir -p "$HOME/Pictures/"
  mkdir -p "$HOME/Videos/"
  mkdir -p "$HOME/Templates/"
  mkdir -p "$HOME/Public/"

  if [[ ! -d "$HOME/Pictures/Screenshots/" ]]; then
    mkdir -p "$HOME/Pictures/Screenshots/"
  fi

  cp "$from/.zshrc" "$HOME/"
  cp -r "$cfgPath" "$HOME/"
  get_wallpaper
  echo ">>> Are you using a laptop?"
  laptop=$(gum choose "Yes" "No")
  if [[ "$laptop" == "Yes" ]]; then
    cp "$from/scripts/battery.sh" "$HOME/.config/sway/"
  fi

  sudo cp -r "$from/Cursor/Bibata-Modern-Ice" "/usr/share/icons"
  sudo cp -r "$from/fonts/" "/usr/share"
  sudo cp "$from/etc/pacman.conf" "/etc/pacman.conf"
  sudo cp "$cfgPath/waybar/weather" "/usr/bin/"

  sudo cp -r "$from/icons/" "/usr/share/"

  echo ">>> Want to install Vencord?"
  vencord=$(gum choose "Yes" "No")

  if [[ "$vencord" == "Yes" ]]; then
    bash "$from/Vencord/VencordInstaller.sh"
    cp -r "$from/Vencord/themes/" "$HOME/.config/Vencord/"
  fi

  sudo cp -r "$from/sddm/catppuccin-mocha" "/usr/share/sddm/themes/"
  sudo cp "$from/sddm/sddm.conf" "/etc/"

  echo ">>> Trying to change the shell..."
  chsh -s "/bin/zsh"
}

setup_ufw() {
  gum spin --spinner dot --title "Trying to setup firewall (ufw)..." -- sleep 2
  sudo ufw enable
  sudo ufw default deny incoming
  sudo ufw default allow outgoing
  sudo ufw status
}

MAGENTA='\033[0;35m'
NONE='\033[0m'

# Header
echo -e "${MAGENTA}"
cat <<"EOF"
   ____         __       ____
  /  _/__  ___ / /____ _/ / /__ ____
 _/ // _ \(_-</ __/ _ `/ / / -_) __/
/___/_//_/___/\__/\_,_/_/_/\__/_/

EOF

echo "HanmaDevin Sway Setup"
echo -e "${NONE}"
while true; do
  read -r -p ">>> Do you want to start the installation now? (y/n): " yn
  case $yn in
  [Yy]*)
    echo ">>> Installation started."
    echo
    break
    ;;
  [Nn]*)
    echo ">>> Installation canceled"
    exit
    ;;
  *)
    echo ">>> Please answer yes or no."
    ;;
  esac
done

echo ">>> Installing required packages..."
installPackages
installYay
installAurPackages

gum spin --spinner dot --title "Starting setup now..." -- sleep 2
copy_config
detect_nvidia
installDeepCoolDriver
configure_git
setup_ufw

sudo systemctl enable sddm
sudo systemctl enable NetworkManager
sudo systemctl enable bluetooth

echo -e "${MAGENTA}"
cat <<"EOF"
    ____       __                __  _                                   
   / __ \___  / /_  ____  ____  / /_(_)___  ____ _   ____  ____ _      __
  / /_/ / _ \/ __ \/ __ \/ __ \/ __/ / __ \/ __ `/  / __ \/ __ \ | /| / /
 / _, _/  __/ /_/ / /_/ / /_/ / /_/ / / / / /_/ /  / / / / /_/ / |/ |/ / 
/_/ |_|\___/_.___/\____/\____/\__/_/_/ /_/\__, /  /_/ /_/\____/|__/|__/  
                                         /____/                         
EOF
echo "and thank you for choosing my config :)"
echo -e "${NONE}"

sleep 2
sudo systemctl reboot
