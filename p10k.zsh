# Sources p10k's bundled `rainbow` preset and overrides only what differs.
# Do not run `p10k configure`; it would replace this file with a full dump.

# Must come first: the preset opens with `unset -m 'POWERLEVEL9K_*'`.
if [[ -r ${__p9k_root_dir-}/config/p10k-rainbow.zsh ]]; then
  source ${__p9k_root_dir}/config/p10k-rainbow.zsh
else
  print -ru2 -- "p10k.zsh: no rainbow preset under '${__p9k_root_dir-<unset>}'"
fi

'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

# No `unset -m` in here — it would discard the preset.
() {
  emulate -L zsh -o extended_glob

  [[ $ZSH_VERSION == (5.<1->*|<6->.*) ]] || return

  ###############################[ global ]################################

  # The preset's default is `os_icon dir vcs` plus a 40-segment right prompt.
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    dir                     # current directory
    vcs                     # git status
    newline                 # \n
    prompt_char             # prompt symbol
  )
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()

  # Redundant today, but this prompt needs only a powerline font, not a Nerd Font.
  typeset -g POWERLEVEL9K_MODE=powerline

  # Drop the preset's leading blank line and its ╭─ ├─ ╰─ frame.
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=false
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=
  typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_PREFIX=
  typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX=
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_SUFFIX=
  typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_SUFFIX=
  typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_SUFFIX=

  ################################[ dir ]##################################

  # Darken the text on the preset's blue background.
  typeset -g POWERLEVEL9K_DIR_FOREGROUND=0
  typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=0

  typeset -g POWERLEVEL9K_LOCK_ICON='∅'

  # An empty list disables the preset's per-directory styling examples.
  typeset -g POWERLEVEL9K_DIR_CLASSES=()

  ################################[ vcs ]##################################

  # Yellow, not the preset's green, so untracked is as visible as uncommitted.
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND=3

  # Drop the icon before the branch name.
  typeset -g POWERLEVEL9K_VCS_VISUAL_IDENTIFIER_EXPANSION=

  ##############################[ behavior ]###############################

  # Stop re-reading every POWERLEVEL9K_* param each prompt; edits then need `p10k reload`.
  typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=true

  (( ! $+functions[p10k] )) || p10k reload
}

# Must follow the source: the preset points this at itself.
typeset -g POWERLEVEL9K_CONFIG_FILE=${${(%):-%x}:a}

(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'
