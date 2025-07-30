#!/bin/bash
# ~/.bashrc: executed by bash(1) for non-login shells.

# Debug: Log that bashrc is being sourced
echo "Loading .bashrc..." >&2

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Force terminal settings
export TERM=xterm-256color
export COLORTERM=truecolor

# Set proper locale
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Configure readline for proper arrow key handling
export INPUTRC=/home/vscode/.inputrc

# Set input mode for proper arrow key handling
set -o emacs

# Ensure proper terminal settings
stty sane 2>/dev/null
stty erase ^?

# Set the prompt to show user:path (without hostname)
# Using PROMPT_COMMAND to ensure it's always set correctly
export PS1='\[\033[01;32m\]\u\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
export PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"'

# History settings
export HISTCONTROL=ignoreboth:erasedups
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTTIMEFORMAT="%F %T "

# Append to history file instead of overwriting
shopt -s histappend

# Save history after each command
export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r"

# Check window size after each command
shopt -s checkwinsize

# Enable extended globbing
shopt -s extglob

# Case-insensitive globbing
shopt -s nocaseglob

# Autocorrect typos in path names when using `cd`
shopt -s cdspell

# Make less more friendly for non-text input files
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Enable color support for ls and add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Common aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias lt='ls -altr'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias h='history'
alias hgrep='history | grep'
alias mkdir='mkdir -pv'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias vi='vim'
alias cls='clear'
alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%T"'
alias nowdate='date +"%d-%m-%Y"'
alias ports='netstat -tulanp'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate'
alias gp='git push'
alias gpl='git pull'
alias gb='git branch'
alias gco='git checkout'
alias gm='git merge'
alias gr='git remote'
alias grs='git remote show'
alias glg='git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit'

# Docker aliases
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias drm='docker rm'
alias drmi='docker rmi'
alias dexec='docker exec -it'
alias dlogs='docker logs'
alias dstop='docker stop'
alias dstart='docker start'

# Python aliases
alias py='python3'
alias pip='pip3'
alias venv='python3 -m venv'
alias activate='source venv/bin/activate'
alias pipreq='pip freeze > requirements.txt'
alias pipinst='pip install -r requirements.txt'

# Node/npm aliases
alias ni='npm install'
alias ns='npm start'
alias nt='npm test'
alias nr='npm run'
alias nrd='npm run dev'
alias nrb='npm run build'

# System aliases
alias meminfo='free -m -l -t'
alias psmem='ps auxf | sort -nr -k 4'
alias pscpu='ps auxf | sort -nr -k 3'
alias cpuinfo='lscpu'
alias gpumeminfo='grep -i --color memory /var/log/Xorg.0.log'
alias claude-insec='claude --dangerously-skip-permissions'
alias bmad-install='npx bmad-method install'
# Enable programmable completion
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Configure readline for proper arrow key handling
bind '"\e[A": history-search-backward' 2>/dev/null
bind '"\e[B": history-search-forward' 2>/dev/null
bind '"\e[C": forward-char' 2>/dev/null
bind '"\e[D": backward-char' 2>/dev/null
bind '"\e[1;5C": forward-word' 2>/dev/null
bind '"\e[1;5D": backward-word' 2>/dev/null
bind '"\e[H": beginning-of-line' 2>/dev/null
bind '"\e[F": end-of-line' 2>/dev/null
bind '"\e[3~": delete-char' 2>/dev/null

# Fix Home/End keys
bind '"\e[1~": beginning-of-line' 2>/dev/null
bind '"\e[4~": end-of-line' 2>/dev/null

# Enable git completion if available
if [ -f /usr/share/bash-completion/completions/git ]; then
    . /usr/share/bash-completion/completions/git
    # Add git completion to aliases
    __git_complete gco _git_checkout
    __git_complete gm _git_merge
    __git_complete gpl _git_pull
    __git_complete gp _git_push
    __git_complete gb _git_branch
    __git_complete ga _git_add
    __git_complete gd _git_diff
    __git_complete gc _git_commit
fi

# Docker completion
if [ -f /usr/share/bash-completion/completions/docker ]; then
    . /usr/share/bash-completion/completions/docker
fi

# Add local bin to PATH if it exists
if [ -d "$HOME/.local/bin" ] ; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# Add npm global bin to PATH if it exists
if [ -d "$HOME/.npm-global/bin" ] ; then
    export PATH="$HOME/.npm-global/bin:$PATH"
fi

# Source any custom configurations if they exist
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

if [ -f ~/.bash_local ]; then
    . ~/.bash_local
fi

# Set up the terminal properly
if [ -t 1 ]; then
    # We have a terminal
    # Reset terminal to sane defaults
    reset -I 2>/dev/null || true
    # Clear any garbage
    clear
fi

# Functions
# Extract various archive types
extract() {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar e $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)     echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Create a directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Multiline input helpers for Claude Code
# Function to help with multiline input
multiline_helper() {
    echo "💡 Multiline input tips:"
    echo "   • End lines with \\ for continuation"
    echo "   • Press Ctrl+J for newline"
    echo "   • Use Ctrl+V then Enter for literal newline"
    echo "   • Type 'exit' on its own line to finish"
}

# Add to help alias
alias mlhelp='multiline_helper'

# Debug: Confirm bashrc loaded
echo ".bashrc loaded successfully" >&2

# Claude wrapper alias (will be added by Dockerfile)
