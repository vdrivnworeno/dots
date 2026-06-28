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
# PALM ENV, VARS AND FUNCTIONS


function palm.aws.auth {

  PROD_AWS_PROFILE="palm-production"
  DEV_AWS_PROFILE="palm-development"
  DEFAULT_PROFILE="$DEV_AWS_PROFILE"

  if test -z $1; then
    return 1;
  fi;

  if test "$1" == "PROD"; then
    DEFAULT_PROFILE="$PROD_AWS_PROFILE";
  fi

  aws sso login --profile $DEFAULT_PROFILE && \
    eval "$(aws configure export-credentials --profile $DEFAULT_PROFILE --format env)"
  export AWS_PROFILE="$DEFAULT_PROFILE"
}

function palm.aws.k8s.auth {
  local env="$1"
  local region="us-east-1"
  local profile cluster account context

  case "${env:-DEV}" in
    PROD)
      profile="palm-production"
      cluster="prod-eks"
      ;;
    DEV)
      profile="palm-development"
      cluster="dev-eks"
      ;;
    *)
      echo "uso: palm.k8s.auth DEV|PROD"
      return 1
      ;;
  esac

  aws sso login --profile "$profile" || return 1
  eval "$(aws configure export-credentials --profile "$profile" --format env)" || return 1

  aws eks update-kubeconfig \
    --region "$region" \
    --name "$cluster" \
    --profile "$profile" || return 1

  account="$(aws sts get-caller-identity --query Account --output text)" || return 1
  context="arn:aws:eks:${region}:${account}:cluster/${cluster}"

  kubectl config use-context "$context" || return 1

  export PALM_AWS_PROFILE="$profile"
  export PALM_EKS_CLUSTER="$cluster"
  export PALM_KUBE_CONTEXT="$context"

  echo "$PALM_KUBE_CONTEXT"
}

function palm.airflow.scheduler-pod {
  local namespace="${1:-ops-airflow}"

  kubectl --context "$PALM_KUBE_CONTEXT" get pods -n "$namespace" \
    -o name | grep scheduler | head -n 1 | sed 's|^pod/||'
}

function palm.airflow.enable {
  local dag_id="$1"
  local namespace="${2:-ops-airflow}"
  local pod

  if [[ -z "$dag_id" ]]; then
    echo "uso: palm.airflow.enable DAG_ID [NAMESPACE]"
    return 1
  fi

  pod="$(palm.airflow.scheduler-pod "$namespace")" || return 1
  echo $pod

  if [[ -z "$pod" ]]; then
    echo "scheduler pod no encontrado"
    return 1
  fi

  kubectl --context "$PALM_KUBE_CONTEXT" exec -n "$namespace" "$pod" -- \
    airflow dags unpause "$dag_id"
}

function palm.airflow.disable {
  local dag_id="$1"
  local namespace="${2:-ops-airflow}"
  local pod

  if [[ -z "$dag_id" ]]; then
    echo "uso: palm.airflow.enable DAG_ID [NAMESPACE]"
    return 1
  fi

  pod="$(palm.airflow.scheduler-pod "$namespace")" || return 1
  echo $pod

  if [[ -z "$pod" ]]; then
    echo "scheduler pod no encontrado"
    return 1
  fi

  kubectl --context "$PALM_KUBE_CONTEXT" exec -n "$namespace" "$pod" -- \
    airflow dags pause "$dag_id"
}


function palm.airflow.trigger {
  local dag_id="$1"
  local config="$2"
  local namespace="${3:-ops-airflow}"
  local pod

  #if [[ -z "$dag_id" || -z "$config" ]]; then
  if [[ -z "$dag_id" ]]; then
    echo "uso: palm.airflow.trigger DAG_ID LOGICAL_DATE [NAMESPACE]"
    return 1
  fi

  pod="$(palm.airflow.scheduler-pod "$namespace")" || return 1
  echo $pod

  if [[ -z "$pod" ]]; then
    echo "scheduler pod no encontrado"
    return 1
  fi

  kubectl --context "$PALM_KUBE_CONTEXT" exec -n "$namespace" "$pod" -- \
    airflow dags trigger "$dag_id" --conf "$config"
}

function palm.data-pipeline.prepare {

  PROD_AWS_PROFILE="palm-production"
  DEV_AWS_PROFILE="palm-development"
  DEFAULT_PROFILE="$DEV_AWS_PROFILE"

  if test -z $1; then
    return 1;
  fi;

  if test "$1" == "PROD"; then
    DEFAULT_PROFILE="$PROD_AWS_PROFILE";
  fi
  palm.aws.auth ${DEFAULT_PROFILE};
  bash script/credentials.sh;
  set -a && source .env && set +a;
}

function palm.data-pipeline.run {
  test -z "$1" && return 0;
  test -z "$2" && return 0;
  test -z "$3" && return 0;
  set -a && source .env && set +a;
  START_DATE="$2" END_DATE="$3" ./gradlew --no-daemon run -Penvironment=local --args="local event$1";
}

function palm.identity-service.clean-env {
  docker compose down --remove-orphans --volumes && \
    docker compose up -d && \
    yarn migration:init-schema && \
    yarn migration:run

  if test "$1" == "start"; then
    yarn start:debug
  fi
}

function opencode.palm {
  HME="${HOME}/.opencode.palm"
  XDG_CONFIG_HOME="$HME/config" \
  XDG_DATA_HOME="$HME/data" \
  XDG_CACHE_HOME="$HME/cache" \
  XDG_STATE_HOME="$HME/state" \
  opencode "$@"
}
function opencode.me {
  HME="${HOME}/.opencode.me"
  XDG_CONFIG_HOME="$HME/config" \
  XDG_DATA_HOME="$HME/data" \
  XDG_CACHE_HOME="$HME/cache" \
  XDG_STATE_HOME="$HME/state" \
  opencode "$@"
}
alias oc.palm="opencode.palm"
alias oc.me="opencode.me"

export PROXY_VPN_PATH=~/.local/vpn-proxy

function proxy.random.file {
  FILENAME="vpn.conf"
  CURRENT_PATH=$(pwd)
  cd ${PROXY_VPN_PATH}/gluetun
  FILE=$(find . -iname '*ovpn*' | shuf -n 1)
  ln -rsf $FILE $FILENAME
  cd $CURRENT_PATH
}
function proxy.start {
  proxy.random.file
  CURRENT_PATH=$(pwd)
  cd ${PROXY_VPN_PATH}
  docker compose up -d
  cd $CURRENT_PATH
}

function proxy.stop {
  CURRENT_PATH=$(pwd)
  cd ${PROXY_VPN_PATH}
  docker compose down --volumes
  cd $CURRENT_PATH
}

function proxy.status {
  CURRENT_PATH=$(pwd)
  cd ${PROXY_VPN_PATH}
  docker compose logs -f
  cd $CURRENT_PATH
}

function proxy.enable {
  export http_proxy=http://127.0.0.1:8888
  export https_proxy=http://127.0.0.1:8888
}
