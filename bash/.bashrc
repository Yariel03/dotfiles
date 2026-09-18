#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

zsh


# Added by Antigravity CLI installer
export PATH="/home/yariel/.local/bin:$PATH"
export HSA_OVERRIDE_GFX_VERSION=10.3.0
. "$HOME/.cargo/env"
