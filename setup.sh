#!/bin/bash
cd      "$(dirname "${BASH_SOURCE[0]:-${(%):-%x}}")"
info    "Current directory: $(pwd)"
source ./colors.sh


info    "Updating package list and installing Zsh..."

sudo apt update && sudo apt install zsh -y && chsh -s $(which zsh)
if [ $? -eq 0 ]; then
    success "Zsh installed and set as default shell."
else
    error   "Failed to install Zsh or set it as default shell."
    exit 1
fi

./zsh_setup.sh
if [ $? -eq 0 ]; then
    success "Zsh setup completed successfully."
else
    error   "Zsh setup failed."
    exit 1
fi

success "finish setup"
info    "You can now restart your terminal or run 'exec zsh' to apply the changes."
