{lib, ...}: let
  # Helper to convert Nix values to Zsh typeset commands
  toZsh = name: value:
    if builtins.isList value
    then "typeset -g ${name}=(${lib.concatStringsSep " " (map (v:
      if builtins.isString v
      then v # Assume strings in lists are already shell-safe or identifiers
      else builtins.toString v)
    value)})"
    else if builtins.isBool value
    then "typeset -g ${name}=${
      if value
      then "true"
      else "false"
    }"
    else if builtins.isString value && (lib.hasPrefix "''" value || lib.hasPrefix "'" value)
    then "typeset -g ${name}=${value}"
    else if builtins.isInt value
    then "typeset -g ${name}=${builtins.toString value}"
    else "typeset -g ${name}='${builtins.toString value}'";

  # Refined p10k settings to match the original "rainbow" style precisely
  settings = {
    POWERLEVEL9K_MODE = "nerdfont-v3";
    POWERLEVEL9K_ICON_PADDING = "none";
    POWERLEVEL9K_ICON_BEFORE_CONTENT = "";
    POWERLEVEL9K_PROMPT_ADD_NEWLINE = true;

    # Left Prompt: OS, Dir, VCS on Line 1, Newline for Line 2
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS = [
      "os_icon"
      "dir"
      "vcs"
      "newline"
    ];

    # Right Prompt: Only status and execution time
    POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS = [
      "status"
      "command_execution_time"
      "nix_shell" # Added nix_shell back as it's very relevant for NixOS
      "direnv" # Added direnv back for development workflow
    ];

    # Multiline Ornaments
    POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX = "%244F╭─";
    POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_PREFIX = "%244F├─";
    POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX = "%244F╰─";
    POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_CHAR = " ";

    # Separators (Slanted/Round as per p10k wizard options)
    POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR = "\\u2571";
    POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR = "\\u2571";
    POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR = "\\uE0BC";
    POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR = "\\uE0BA";
    POWERLEVEL9K_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL = "\\uE0B4";
    POWERLEVEL9K_RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL = "\\uE0B6";
    POWERLEVEL9K_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL = "\\uE0B6";
    POWERLEVEL9K_RIGHT_PROMPT_LAST_SEGMENT_END_SYMBOL = "\\uE0B4";

    # Disable ornaments for lines without segments
    POWERLEVEL9K_EMPTY_LINE_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL = "";
    POWERLEVEL9K_EMPTY_LINE_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL = "";

    # OS Icon Styling
    POWERLEVEL9K_OS_ICON_FOREGROUND = 232;
    POWERLEVEL9K_OS_ICON_BACKGROUND = 7;

    # Prompt Char Styling - Fully disabled to keep second line clean
    POWERLEVEL9K_PROMPT_CHAR_BACKGROUND = "";
    POWERLEVEL9K_PROMPT_CHAR_OK_VIINS_CONTENT_EXPANSION = "";
    POWERLEVEL9K_PROMPT_CHAR_OK_VICMD_CONTENT_EXPANSION = "";
    POWERLEVEL9K_PROMPT_CHAR_ERROR_VIINS_CONTENT_EXPANSION = "";
    POWERLEVEL9K_PROMPT_CHAR_ERROR_VICMD_CONTENT_EXPANSION = "";
    POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL = "";
    POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL = "";
    POWERLEVEL9K_PROMPT_CHAR_LEFT_LEFT_WHITESPACE = "";
    POWERLEVEL9K_PROMPT_CHAR_LEFT_RIGHT_WHITESPACE = "";

    # Directory Styling
    POWERLEVEL9K_DIR_BACKGROUND = 4;
    POWERLEVEL9K_DIR_FOREGROUND = 254;
    POWERLEVEL9K_DIR_SHORTENED_FOREGROUND = 250;
    POWERLEVEL9K_DIR_ANCHOR_FOREGROUND = 255;
    POWERLEVEL9K_DIR_ANCHOR_BOLD = true;
    POWERLEVEL9K_SHORTEN_STRATEGY = "truncate_to_unique";
    POWERLEVEL9K_SHORTEN_DIR_LENGTH = 1;
    POWERLEVEL9K_DIR_MAX_LENGTH = 80;

    # VCS (Git) Styling
    POWERLEVEL9K_VCS_CLEAN_BACKGROUND = 2;
    POWERLEVEL9K_VCS_MODIFIED_BACKGROUND = 3;
    POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND = 2;
    POWERLEVEL9K_VCS_CONFLICTED_BACKGROUND = 3;
    POWERLEVEL9K_VCS_LOADING_BACKGROUND = 8;
    POWERLEVEL9K_VCS_BRANCH_ICON = "\\uF126 ";

    # Status Styling
    POWERLEVEL9K_STATUS_EXTENDED_STATES = true;
    POWERLEVEL9K_STATUS_OK = true;
    POWERLEVEL9K_STATUS_OK_VISUAL_IDENTIFIER_EXPANSION = "✔";
    POWERLEVEL9K_STATUS_OK_FOREGROUND = 2;
    POWERLEVEL9K_STATUS_OK_BACKGROUND = 0;
    POWERLEVEL9K_STATUS_ERROR = true;
    POWERLEVEL9K_STATUS_ERROR_VISUAL_IDENTIFIER_EXPANSION = "✘";
    POWERLEVEL9K_STATUS_ERROR_FOREGROUND = 3;
    POWERLEVEL9K_STATUS_ERROR_BACKGROUND = 1;

    # Command Execution Time Styling
    POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD = 3;
    POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION = 0;
    POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND = 0;
    POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND = 3;
    POWERLEVEL9K_COMMAND_EXECUTION_TIME_FORMAT = "d h m s";

    # Nix Shell Styling
    POWERLEVEL9K_NIX_SHELL_FOREGROUND = 0;
    POWERLEVEL9K_NIX_SHELL_BACKGROUND = 4;

    # Direnv Styling
    POWERLEVEL9K_DIRENV_FOREGROUND = 3;
    POWERLEVEL9K_DIRENV_BACKGROUND = 0;

    # Explicitly hide segments that were empty/hidden in original
    POWERLEVEL9K_CONTEXT_DEFAULT_CONTENT_EXPANSION = "";
    POWERLEVEL9K_CONTEXT_SUDO_CONTENT_EXPANSION = "";
    POWERLEVEL9K_VI_INSERT_MODE_STRING = "";
    POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE = false;

    # Transient Prompt and Instant Prompt settings
    POWERLEVEL9K_TRANSIENT_PROMPT = "always";
    POWERLEVEL9K_INSTANT_PROMPT = "verbose";
    POWERLEVEL9K_DISABLE_HOT_RELOAD = true;
  };

  # problematic expansion escaped for use in p10k.zsh
  vcsExpansion = "'\${$((my_git_formatter()))+\${my_git_format}}'";
in ''
  # Powerlevel10k Nix-native configuration
  # Generated from modules/common/programs/zsh/p10k.nix

  'builtin' 'local' '-a' 'p10k_config_opts'
  [[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
  [[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
  [[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
  'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

  () {
    emulate -L zsh -o extended_glob
    unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'
    [[ $ZSH_VERSION == (5.<1->*|<6->.*) ]] || return

    ${lib.concatStringsSep "\n    " (lib.mapAttrsToList toZsh settings)}

    function my_git_formatter() {
      emulate -L zsh
      if [[ -n $P9K_CONTENT ]]; then
        typeset -g my_git_format=$P9K_CONTENT
        return
      fi
      local meta='%7F' clean='%0F' modified='%0F' untracked='%0F' conflicted='%1F'
      local res
      if [[ -n $VCS_STATUS_LOCAL_BRANCH ]]; then
        local branch=''${(V)VCS_STATUS_LOCAL_BRANCH}
        (( $#branch > 32 )) && branch[13,-13]="…"
        res+=''${clean}''${(g::)POWERLEVEL9K_VCS_BRANCH_ICON}''${branch//\%/%%}
      fi
      if [[ -n $VCS_STATUS_TAG && -z $VCS_STATUS_LOCAL_BRANCH ]]; then
        local tag=''${(V)VCS_STATUS_TAG}
        (( $#tag > 32 )) && tag[13,-13]="…"
        res+=''${meta}#''${clean}''${tag//\%/%%}
      fi
      [[ -z $VCS_STATUS_LOCAL_BRANCH && -z $VCS_STATUS_TAG ]] && res+=''${meta}@''${clean}''${VCS_STATUS_COMMIT[1,8]}
      if [[ -n ''${VCS_STATUS_REMOTE_BRANCH:#$VCS_STATUS_LOCAL_BRANCH} ]]; then
        res+=''${meta}:''${clean}''${(V)VCS_STATUS_REMOTE_BRANCH//\%/%%}
      fi
      if [[ $VCS_STATUS_COMMIT_SUMMARY == (|*[^[:alnum:]])(wip|WIP)(|[^[:alnum:]]*) ]]; then
        res+=" ''${modified}wip"
      fi
      if (( VCS_STATUS_COMMITS_AHEAD || VCS_STATUS_COMMITS_BEHIND )); then
        (( VCS_STATUS_COMMITS_BEHIND )) && res+=" ''${clean}⇣''${VCS_STATUS_COMMITS_BEHIND}"
        (( VCS_STATUS_COMMITS_AHEAD && !VCS_STATUS_COMMITS_BEHIND )) && res+=" "
        (( VCS_STATUS_COMMITS_AHEAD )) && res+=''${clean}⇡''${VCS_STATUS_COMMITS_AHEAD}
      fi
      (( VCS_STATUS_PUSH_COMMITS_BEHIND )) && res+=" ''${clean}⇠''${VCS_STATUS_PUSH_COMMITS_BEHIND}"
      (( VCS_STATUS_PUSH_COMMITS_AHEAD && !VCS_STATUS_PUSH_COMMITS_BEHIND )) && res+=" "
      (( VCS_STATUS_PUSH_COMMITS_AHEAD )) && res+=''${clean}⇢''${VCS_STATUS_PUSH_COMMITS_AHEAD}
      (( VCS_STATUS_STASHES )) && res+=" ''${clean}*''${VCS_STATUS_STASHES}"
      [[ -n $VCS_STATUS_ACTION ]] && res+=" ''${conflicted}''${VCS_STATUS_ACTION}"
      (( VCS_STATUS_NUM_CONFLICTED )) && res+=" ''${conflicted}~''${VCS_STATUS_NUM_CONFLICTED}"
      (( VCS_STATUS_NUM_STAGED )) && res+=" ''${modified}+''${VCS_STATUS_NUM_STAGED}"
      (( VCS_STATUS_NUM_UNSTAGED )) && res+=" ''${modified}!''${VCS_STATUS_NUM_UNSTAGED}"
      (( VCS_STATUS_NUM_UNTRACKED )) && res+=" ''${untracked}''${(g::)POWERLEVEL9K_VCS_UNTRACKED_ICON:-'?'}''${VCS_STATUS_NUM_UNTRACKED}"
      (( VCS_STATUS_HAS_UNSTAGED == -1 )) && res+=" ''${modified}─"
      typeset -g my_git_format=$res
    }
    functions -M my_git_formatter 2>/dev/null
    typeset -g POWERLEVEL9K_VCS_DISABLE_GITSTATUS_FORMATTING=true
    typeset -g POWERLEVEL9K_VCS_CONTENT_EXPANSION=${vcsExpansion}

    # If p10k is already loaded, reload configuration.
    (( ! $+functions[p10k] )) || p10k reload
  }

  (( ''${#p10k_config_opts} )) && setopt ''${p10k_config_opts[@]}
  'builtin' 'unset' 'p10k_config_opts'
''
