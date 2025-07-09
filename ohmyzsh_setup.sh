#!/bin/zsh
source ./color.sh

info "Setting up Zsh with Oh My Zsh and plugins..."
set -e
git clone https://github.com/MichaelAquilina/zsh-you-should-use.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/you-should-use`
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/fdellwing/zsh-bat.git $ZSH_CUSTOM/plugins/zsh-bat
git clone https://github.com/ohmyzsh/ohmyzsh.git --depth=1 && cp -r plugins/fzf ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/
set +e
success "Zsh plugins installed successfully."

if grep -q '^plugins=' "$ZSHRC"; then
  tmpfile=$(mktemp)
  awk '
    BEGIN { done=0 }
    /^plugins=\(/ && done==0 {
      print "#" $0
      print "plugins=(\n  git\n  zsh-autosuggestions\n  zsh-syntax-highlighting\n  zsh-bat\n  you-should-use\n  conda\n  conda-env\n  fzf\n)"
      done=1
      next
    }
    { print }
  ' "$ZSHRC" > "$tmpfile" && mv "$tmpfile" "$ZSHRC"
  success "Updated plugins list in .zshrc"
else
  echo "\n# Auto-added plugins" >> "$ZSHRC"
  echo "plugins=(\n  git\n  zsh-autosuggestions\n  zsh-syntax-highlighting\n  zsh-bat\n  you-should-use\n  conda\n  conda-env\n  fzf\n)" >> "$ZSHRC"
  note "plugins list appended to bottom of .zshrc"
fi

info "Installing bat and fzf..."
sudo apt install bat fzf -y
if [ $? -eq 0 ]; then
    success "bat and fzf installed successfully."
else
    error "Failed to install bat or fzf."
    exit 1
fi


ZSHRC="$HOME/.zshrc"
if ! grep -q "alias cat='batcat'" "$ZSHRC"; then
  echo "alias cat='batcat'  # zsh-bat alias" >> "$ZSHRC"
  info "alias cat='batcat' added to .zshrc"
else
  info "alias cat='batcat' already present, skipping."
fi

if ! grep -q 'export MANPAGER=' "$ZSHRC"; then
  echo "export MANPAGER=\"sh -c 'sed -u -e \\\"s/\\\\x1B\\\\[[0-9;]*m//g; s/.\\\\x08//g\\\" | batcat -p -lman'\"" >> "$ZSHRC"
  info "MANPAGER export added to .zshrc"
else
  info "MANPAGER export already present, skipping."
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
THEME_DIR="$ZSH_CUSTOM/themes/powerlevel10k"

info "Setting up Powerlevel10k theme..."
if [ ! -d "$THEME_DIR" ]; then
  info "Installing powerlevel10k theme..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$THEME_DIR"
else
  info "Powerlevel10k already installed. Skipping."
fi

if grep -q 'ZSH_THEME="powerlevel10k/powerlevel10k"' "$ZSHRC"; then
  echo "[INFO] ZSH_THEME already set to powerlevel10k. Skipping."
else
  echo "[INFO] Setting ZSH_THEME in .zshrc..."

  tmpfile=$(mktemp)
  awk '
    BEGIN { inserted=0 }
    /^ZSH_THEME=/ {
      print "#" $0
      print "ZSH_THEME=\"powerlevel10k/powerlevel10k\""
      inserted=1
      next
    }
    { print }
    END {
      if (inserted == 0) {
        print "\n# Theme auto-added"
        print "ZSH_THEME=\"powerlevel10k/powerlevel10k\""
      }
    }
  ' "$ZSHRC" > "$tmpfile" && mv "$tmpfile" "$ZSHRC"
fi
