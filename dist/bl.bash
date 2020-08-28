#!/bin/bash
#
# Bash libs

set -euEo pipefail

# Constants

## Colors

# shellcheck disable=SC2034
declare -rx NOCOLOR='\033[0m'
# shellcheck disable=SC2034
declare -rx RED='\033[0;31m'
# shellcheck disable=SC2034
declare -rx GREEN='\033[0;32m'
# shellcheck disable=SC2034
declare -rx ORANGE='\033[0;33m'
declare -rx BLUE='\033[0;34m'
# shellcheck disable=SC2034
declare -rx PURPLE='\033[0;35m'
# shellcheck disable=SC2034
declare -rx CYAN='\033[0;36m'
# shellcheck disable=SC2034
declare -rx LIGHTGRAY='\033[0;37m'
# shellcheck disable=SC2034
declare -rx DARKGRAY='\033[1;30m'
# shellcheck disable=SC2034
declare -rx LIGHTRED='\033[1;31m'
# shellcheck disable=SC2034
declare -rx LIGHTGREEN='\033[1;32m'
# shellcheck disable=SC2034
declare -rx YELLOW='\033[1;33m'
# shellcheck disable=SC2034
declare -rx LIGHTBLUE='\033[1;34m'
# shellcheck disable=SC2034
declare -rx LIGHTPURPLE='\033[1;35m'
# shellcheck disable=SC2034
declare -rx LIGHTCYAN='\033[1;36m'
# shellcheck disable=SC2034
declare -rx WHITE='\033[1;37m'

# Functions

## echo functions

echoec() {
  local -r color="${2-$BLUE}"

  if [[ -z "${ENV:-}" || "${ENV,,}" != 'production' ]]; then
    echo -e "$*"
  else
    echo -e "${color}$*${NOCOLOR}" >&2
  fi
}
export -f echoec

echoc() {
  local -r color="${2-$BLUE}"

  if [[ -z "${ENV:-}" || "${ENV,,}" != 'production' ]]; then
    echo -e "$*"
  else
    echo -e "${color}$*${NOCOLOR}"
  fi
}
export -f echoc

err() {
  local -r color="${2-$RED}"

  if [[ -z "${ENV:-}" || "${ENV,,}" != 'production' ]]; then
    echo -e "ERROR> $*" >&2
  else
    echo -e "${color}ERROR> $*${NOCOLOR}" >&2
  fi
}
export -f err

inf() {
  local -r color="${2-$LIGHTBLUE}"

  if [[ -z "${ENV:-}" || "${ENV,,}" != 'production' ]]; then
    echo -e "INFO> $*"
  else
    echo -e "${color}INFO> $*${NOCOLOR}"
  fi
}
export -f inf

infn() {
  local -r color="${2-$LIGHTBLUE}"

  if [[ -z "${ENV:-}" || "${ENV,,}" != 'production' ]]; then
    echo -e -n "INFO> $*"
  else
    echo -e -n "${color}INFO> $*${NOCOLOR}"
  fi
}
export -f infn

debug() {
  if [[ -z "${ENV:-}" || "${ENV,,}" != 'production' ]]; then
    echo "DEBUG> $*"
  fi
}
export -f debug

## :echo functions


#
# Recursively create symbolic links for files inside 'from_directory' to 'to_directory'
#
# Arguments:
#   from_directory
#   to_directory
#
# Outputs:
#   Writes created symbolic links to stdout
#
bl::recursive_slink() {
  local -r from_directory="$1"
  local to_directory="${2:-}"

  if [[ -z "${to_directory:-}" ]]; then
    to_directory=~
  fi
  readonly to_directory

  local s
  local b
  if [[ ! -w "$to_directory" ]]; then
    s=sudo
    b='--backup'
  fi
  readonly s b

  (
    cd "$from_directory"
    # I don't use stow because it create symlinks to folders, I don't want this
    while read -r file; do
      local rel_file_path="${file#./}"
      local file="${rel_file_path##*/}"
      local rel_base_path="${rel_file_path%/*}"

      if [[ "$rel_file_path" != "$file" && ! -d "${to_directory%/}/${rel_base_path}" ]]; then
        eval "${s:-}" mkdir --parents --verbose '"${to_directory%/}/${rel_base_path}"'
      fi
      # shellcheck disable=SC2016
      eval "${s:-}" ln "${b:-}" --symbolic --force --verbose '"${PWD}/${rel_file_path}"' '"${to_directory%/}/${rel_base_path}"' || :
    done < <(find . -type f)
  )
}


