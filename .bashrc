# Base exports

export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_CACHE_HOME="${HOME}/.cache"
export XDG_DATA_HOME="${HOME}/.local/share"
export XDG_STATE_HOME="${HOME}/.local/state"
export XDG_SRC_HOME="${HOME}/.local/src"
export XDG_BIN_HOME="${HOME}/.local/bin"
export XDG_DATA_DIRS="${XDG_DATA_HOME}:${XDG_DATA_DIRS}"

# Global exports
export VISUAL=vim
export EDITOR=$VISUAL

# Bash exports
export HISTFILESIZE=
export HISTSIZE=

# PATH
export PATH="/sbin:/bin:/usr/bin:/usr/local/bin:/usr/sbin:${XDG_BIN_HOME}"


#export DOCKER_CONFIG="$XDG_CONFIG_HOME"/docker
#export NODE_REPL_HISTORY="$XDG_DATA_HOME"/node_repl_history



# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

reset="\[\033[0m\]"
bold="\[\033[1m\]"
default="\[\033[39m\]"
black="\[\033[30m\]"
red="\[\033[31m\]"
green="\[\033[32m\]"
yellow="\[\033[33m\]"
blue="\[\033[34m\]"
magenta="\[\033[35m\]"
cyan="\[\033[36m\]"
white="\[\033[97m\]"

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes


# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

#CASE INSENSITIVE
bind "set completion-ignore-case on"
bind "set show-all-if-ambiguous on"

# Prompt settings
PS1="\n$bold$red[$green\u$blue@$green\h:$yellow\w$bold$red]$default$ $reset\[$(tput sgr0)\]"

# Alias definitions

alias l='ls -XCF --group-directories-first'
alias ll='ls -lXh --group-directories-first'
alias la='ls -lXha --group-directories-first'
alias xx='startx'
alias gg="systemctl restart gdm"
alias vim="nvim"
alias yarn='yarn --use-yarnrc "$XDG_CONFIG_HOME/yarn/config"'

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# fnm
FNM_PATH="/home/am/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "$(fnm env)"
  eval "$(fnm completions --shell bash)"
fi


# Enable linuxbrew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"

if type brew &>/dev/null
then
  HOMEBREW_PREFIX="$(brew --prefix)"
  if [[ -r "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh" ]]
  then
    source "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"
  else
    for COMPLETION in "${HOMEBREW_PREFIX}/etc/bash_completion.d/"*
    do
      [[ -r "${COMPLETION}" ]] && source "${COMPLETION}"
    done
  fi
fi

export PATH="/home/linuxbrew/.linuxbrew/opt/php@8.4/bin:$PATH"
export PATH="/home/linuxbrew/.linuxbrew/opt/php@8.4/sbin:$PATH"
#export PATH="/home/linuxbrew/.linuxbrew/opt/php@8.3/bin:$PATH"
#export PATH="/home/linuxbrew/.linuxbrew/opt/php@8.3/sbin:$PATH"
#export PATH="/home/linuxbrew/.linuxbrew/opt/php@8.2/bin:$PATH"
#export PATH="/home/linuxbrew/.linuxbrew/opt/php@8.2/bin:$PATH"
#export PATH="/home/linuxbrew/.linuxbrew/opt/php@8.1/sbin:$PATH"
#export PATH="/home/linuxbrew/.linuxbrew/opt/php@8.1/sbin:$PATH"


#Enable JDK and JENV
export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"


# DOTFILES ENV, VARS AND FUNCTIONS

function dotfiles.git {
  git --git-dir=${HOME}/.dotfiles --work-tree=${HOME} $@
}


# PALM ENV, VARS AND FUNCTIONS

MAIN_AWS_PROFILE="palm-production"

function palm.aws.auth {
  aws sso login --profile $MAIN_AWS_PROFILE &&
    eval "$(aws configure export-credentials --profile $MAIN_AWS_PROFILE --format env)"
}

function palm.data-pipeline.run {
	test -z "$1" && return 0;
	test -z "$2" && return 0;
	test -z "$3" && return 0;
	set -a && source .env && set +a;
	START_DATE="$2" END_DATE="$3" ./gradlew --no-daemon run -Penvironment=local --args="local $1";
}

function palm.identity-service.clean-env {
	docker compose down --remove-orphans && \
		docker volume prune --all --force && \
		docker compose up -d && \
		yarn migration:init-schema && \
		yarn migration:run

	if test "$1" == "start"; then
		yarn start:debug
	fi
}
