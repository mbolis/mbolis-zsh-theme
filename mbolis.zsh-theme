# vim:ft=zsh ts=4 sw=4 sts=4
# 

# Handle root user
local main_color
local path_color
if [[ "$UID" == "0" ]] ; then
    main_color=203
    path_color=167
else
    main_color=40
    path_color=34
fi

# PROMPT
local user_host="%F{$main_color}%B%n@%m%b"
local pwd="%F{$path_color}%~%f"
local jobs='%(1j. %F{67}⦗%F{103}⚙ %F{116}%j%F{67}⦘%f.)'

function jenv_prompt () {
	if [[ "$JENV_LOADED" -eq "1" ]] ; then
		local jenv_version=$(jenv version-name 2>/dev/null)
		if [[ "$jenv_version" != "system" ]] ; then
			local jenv_origin="$(jenv version-origin 2>/dev/null)"
			if [[ "$jenv_origin" = "$JENV_ROOT/version" ]] ; then
				jenv_origin=
			elif [[ "$jenv_origin" =~ ".*\\.java-version$" ]] ; then
				jenv_origin='%F{167}%B.%b%F{95}/'
			else
				jenv_origin='%F{178}$'
			fi
			echo " %F{69}(${jenv_origin}%F{167}jdk%F{69}:%F{117}${jenv_version}%F{69})%f"
		fi
	fi
}

# Prompt char: either add `status` visual clue or `ignore`
prompt_char_status="%(?.%F{$main_color}.%F{196}%S)%B%(!.#.$)%b%s%f"
prompt_char_ignore="%F{$main_color}%B%(!.#.$)%b%f"
prompt_char=$prompt_char_status

PROMPT='%{%f%b%k%s%}${user_host} ${pwd}$(git_prompt_info)${jobs}$(jenv_prompt) ${prompt_char} '

# RPROMPT

# Return code: either add `status` visual clue or `ignore`
return_code_status="%(?..%F{196}%B%? ↵%b%f)"
return_code_ignore=
return_code=$return_code_status

RPROMPT='${return_code}$(git_prompt_short_sha)'

# Ignore exit code if no command issued
function accept-line-or-clear-warning () {
	if [[ -z ${BUFFER// } ]]; then
		prompt_char=$prompt_char_ignore
		return_code=$return_code_ignore
	else
		prompt_char=$prompt_char_status
		return_code=$return_code_status
	fi
	zle accept-line
}
zle -N accept-line-or-clear-warning
bindkey '^M' accept-line-or-clear-warning

# PROMPT2 - indent and track
parser_status='%_'
function prompt2 () {
    emulate -L zsh
    setopt extended_glob
    echo "${1//([a-z])##/.}"
}
PROMPT2=' $(prompt2 "${${(%)parser_status}% cmdsubst}") '

reverse_parser_status='%^'
RPROMPT2='< %F{248}${${(%)reverse_parser_status}// /" %f|%F{248} "}%f'

# Git
ZSH_THEME_GIT_PROMPT_PREFIX=" %F{69}(%F{167}git%F{69}:%F{117}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%F{69})%f"
ZSH_THEME_GIT_PROMPT_DIRTY="%F{208}%B*%b%f"
ZSH_THEME_GIT_PROMPT_CLEAN=
ZSH_THEME_GIT_PROMPT_SHA_BEFORE=' %F{69}[%F{117}'
ZSH_THEME_GIT_PROMPT_SHA_AFTER='%F{69}]%f'
