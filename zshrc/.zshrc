zstyle :omz:plugins:ssh-agent identities gitfile
zstyle :omz:plugins:ssh-agent lifetime 4h

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source ~/zshrc/rc
source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Created by `pipx` on 2026-03-11 04:56:09
export PATH="$PATH:/home/stellanova/.local/bin"
