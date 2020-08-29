#!/bin/bash
#
# Bash libs

set -euEo pipefail

# Constants

## Colors

export NOCOLOR='\033[0m'
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export ORANGE='\033[0;33m'
export BLUE='\033[0;34m'
export PURPLE='\033[0;35m'
export CYAN='\033[0;36m'
export LIGHTGRAY='\033[0;37m'
export DARKGRAY='\033[1;30m'
export LIGHTRED='\033[1;31m'
export LIGHTGREEN='\033[1;32m'
export YELLOW='\033[1;33m'
export LIGHTBLUE='\033[1;34m'
export LIGHTPURPLE='\033[1;35m'
export LIGHTCYAN='\033[1;36m'
export WHITE='\033[1;37m'
readonly NOCOLOR RED GREEN ORANGE BLUE PURPLE CYAN LIGHTGRAY DARKGRAY LIGHTRED \
         LIGHTGREEN YELLOW LIGHTBLUE LIGHTPURPLE LIGHTCYAN WHITE

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


