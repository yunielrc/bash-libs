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
  local -r to_directory="$2"

  bl::__files_apply_fn "$from_directory" "$to_directory" 'bl::__files_apply_fn_symlink'
}
export -f bl::recursive_slink
#
# Recursively add content from files inside 'from_directory' to files in 'to_directory'
#
# Arguments:
#   from_directory
#   to_directory
#
# Outputs:
#   Writes added content to stdout
#
bl::recursive_concat() {
  local -r from_directory="$1"
  local -r to_directory="$2"

  bl::__files_apply_fn "$from_directory" "$to_directory" 'bl::__files_apply_fn_concat'
}
export -f bl::recursive_concat

bl::__files_apply_fn() {
  local -r from_directory="$1"
  local -r to_directory="$2"
  local -r apply_fn="$3"

  local s
  if [[ ! -w "$to_directory" ]]; then
    readonly s=sudo
  fi

  (
    cd "$from_directory"
    # I don't use stow because it create symlinks to folders, I don't want this
    while read -r file; do
      local rel_file_path="${file#./}"
      local file="${rel_file_path##*/}"
      local from_file_path="${PWD}/${rel_file_path}"
      local to_file_path="${to_directory%/}/${rel_file_path}"
      local rel_base_path="${rel_file_path%/*}"
      local to_base_path="${to_directory%/}/${rel_base_path}"

      if [[ "$rel_file_path" != "$file" && ! -d "$to_base_path" ]]; then
        eval "${s:-}" mkdir --parents --verbose '"$to_base_path"'
      fi
      "$apply_fn" "$from_file_path" "$to_file_path" "$to_base_path" || :
    done < <(find . -type f)
  )
}
export -f bl::__files_apply_fn

bl::__files_apply_fn_symlink() {
  # shellcheck disable=SC2034
  local -r from_file_path="$1"
  local -r to_base_path="$3"

  if [[ ! -w "$to_base_path" ]]; then
    sudo ln --backup --symbolic --force --verbose "$from_file_path" "$to_base_path"
  else
    ln --symbolic --force --verbose "$from_file_path" "$to_base_path"
  fi
}
export -f bl::__files_apply_fn_symlink

bl::__files_apply_fn_concat() {
  # shellcheck disable=SC2034
  local -r from_file_path="$1"
  local -r to_file_path="$2"
  local -r to_base_path="$3"

  local -r mark='@CAT_SECTION'
  local -r sed_script="/${mark}\s*$/,/:${mark}\s*$/d"
  # set -x
  if [[ ( -f "$to_file_path" && ! -w "$to_file_path" ) || ! -w "$to_base_path" ]]; then
    sudo sed -i -e "$sed_script" "$to_file_path" || :
    envsubst < "$from_file_path" | sudo tee -a "$to_file_path"
  else
    sed -i -e "$sed_script" "$to_file_path"
    # sed -e "$sed_script" "$to_file_path" | tee "$to_file_path" > /dev/null
    envsubst < "$from_file_path" | tee -a "$to_file_path"
  fi
  # set +x
}
export -f bl::__files_apply_fn_concat
