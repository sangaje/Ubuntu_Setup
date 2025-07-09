#!/bin/zsh
source ./color.sh

info "Setting up Zsh..."

sudo apt install curl git -y
if [ $? -eq 0 ]; then
    success "Required packages (curl, git) installed successfully."
else
    error "Failed to install required packages (curl, git)."
    exit 1
fi 

info "Installing Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
if [ $? -eq 0 ]; then
    success "Oh My Zsh installed successfully."
else
    error   "Failed to install Oh My Zsh."
    exit 1
fi

FONT_DIR="$HOME/.local/share/fonts"

mkdir -p "$FONT_DIR"

info    "Downloading MesloLGS NF fonts..."

download_font() {
    style="$1"
    filename="MesloLGS NF ${style}.ttf"
    url="https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/MesloLGS%20NF%20${style}.ttf"
    wget -qO "$FONT_DIR/$filename" "$url"
    if [ $? -eq 0 ]; then
        success "$filename downloaded successfully."
    else
        error   "Failed to download $filename."
        exit 1
    fi
}

# 다운로드 실행
download_font "Regular"
download_font "Bold"
download_font "Italic"
download_font "Bold Italic"

fc-cache -fv

info "Fonts installed and cache updated."
set -e
PROFILE_ID=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d \')
PROFILE_PATH="org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE_ID/"
gsettings set "$PROFILE_PATH" font 'MesloLGS NF 12'
set +e
success "Terminal font set to MesloLGS NF."

info "Setting up Oh My Zsh..."
./ohmyzsh_setup.sh
if [ $? -eq 0 ]; then
    success "Oh My Zsh setup completed successfully."
else
    error   "Oh My Zsh setup failed."
    exit 1
fi
