#!/bin/bash
# Bash wrapper script to ensure proper terminal initialization

# Set terminal environment
export TERM=xterm-256color
export COLORTERM=truecolor
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Configure readline
export INPUTRC=/home/vscode/.inputrc

# Reset terminal to sane defaults
stty sane 2>/dev/null
stty erase ^? 2>/dev/null

# Force interactive mode
set -o emacs

# Source bashrc explicitly
if [ -f /home/vscode/.bashrc ]; then
    source /home/vscode/.bashrc
fi

# Execute bash with proper settings
exec /bin/bash --init-file /home/vscode/.bashrc "$@"