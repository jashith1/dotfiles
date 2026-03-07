#use `p10k configure` to retheme

#for GPG signing keys to know what tty you're on
export GPG_TTY=$(tty)

#pretty cool trick that tricks you into thinking shell start is instant by printing the first line
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

#git clone depth
zinit ice depth=1

#"load" loads with error/reporting whereas "light" does not
#zinit load romkatv/powerlevel10k
zinit light romkatv/powerlevel10k

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions #based on history
zinit light Aloxaf/fzf-tab

autoload -Uz compinit && compinit #enable completion definitions
zinit cdreplay -q #use cache

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

#keyBindings
bindkey '^p' history-search-backward #enforces prefix
bindkey '^n' history-search-forward

#aliases 
alias ls='ls --color'
alias c='clear'
grim="grimblast";
alias cmpl="g++ -std=c++17 -Wall -Wextra -pedantic-errors -Weffc++ -Wno-unused-parameter -fsanitize=undefined,address *.cpp"; #for CSCE120 cpp compiler options
alias wl="wl-copy";
alias ns="sudo nixos-rebuild switch --flake ~/nixos-config#bloppai";
alias lg="lazygit";

#history settings
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

#completion styling
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"
eval "$(direnv hook zsh)"

#custom functions
testCpp() {
   if [ -z "$1" ]; then
      make -C tests -j12 run-all -k
   else
      make -C tests -j12 run/$1
   fi
}

