# shellcheck shell=bash
# shellcheck disable=SC2034
#
# Load the `bash-preexec.sh` library, and define helper functions

## Prepare, load, fix, and install `bash-preexec.sh`
: "${PROMPT_COMMAND:=}"

# Disable immediate `$PROMPT_COMMAND` modification
__bp_delay_install="delayed"

# shellcheck source-path=SCRIPTDIR/../vendor/github.com/rcaloras/bash-preexec
source "${BASH_IT?}/vendor/github.com/rcaloras/bash-preexec/bash-preexec.sh"

# Block damanaging user's `$HISTCONTROL`
function __bp_adjust_histcontrol() { :; }

# Don't fail on readonly variables
function __bp_require_not_readonly() { :; }

# Disable trap DEBUG on subshells - https://github.com/Bash-it/bash-it/pull/1040
__bp_enable_subshells= # blank
set +T

# Modify `$PROMPT_COMMAND` now
__bp_install_after_session_init

## Helper functions
function __check_precmd_conflict() {
	local f # TODO: trim whitespace like preexec does
	for f in "${precmd_functions[@]}"; do
		if [[ "${f}" == "${1}" ]]; then
			return 0
		fi
	done
	return 1
}

function __check_preexec_conflict() {
	local f # TODO: trim whitespace like preexec does
	for f in "${preexec_functions[@]}"; do
		if [[ "${f}" == "${1}" ]]; then
			return 0
		fi
	done
	return 1
}

function safe_append_prompt_command {
	local prompt_re

	if [ "${__bp_imported:-missing}" == "defined" ]; then
		# We are using bash-preexec
		if ! __check_precmd_conflict "${1}"; then
			precmd_functions+=("${1}")
		fi
	else
		# Set OS dependent exact match regular expression
		if [[ ${OSTYPE} == darwin* ]]; then
			# macOS
			prompt_re="[[:<:]]${1}[[:>:]]"
		else
			# Linux, FreeBSD, etc.
			prompt_re="\<${1}\>"
		fi

		if [[ ${PROMPT_COMMAND} =~ ${prompt_re} ]]; then
			return
		elif [[ -z ${PROMPT_COMMAND} ]]; then
			PROMPT_COMMAND="${1}"
		else
			PROMPT_COMMAND="${1};${PROMPT_COMMAND}"
		fi
	fi
}

function safe_append_preexec {
	local prompt_re

	if [ "${__bp_imported:-missing}" == "defined" ]; then
		# We are using bash-preexec
		if ! __check_preexec_conflict "${1}"; then
			preexec_functions+=("${1}")
		fi
	else
		: #can't...
	fi
}
