#!/bin/bash
#
# Bash libs

set -euEo pipefail

## Colors

# shellcheck disable=SC2034
export NOCOLOR='\033[0m'
# shellcheck disable=SC2034
export RED='\033[0;31m'
# shellcheck disable=SC2034
export GREEN='\033[0;32m'
# shellcheck disable=SC2034
export ORANGE='\033[0;33m'
export BLUE='\033[0;34m'
# shellcheck disable=SC2034
export PURPLE='\033[0;35m'
# shellcheck disable=SC2034
export CYAN='\033[0;36m'
# shellcheck disable=SC2034
export LIGHTGRAY='\033[0;37m'
# shellcheck disable=SC2034
export DARKGRAY='\033[1;30m'
# shellcheck disable=SC2034
export LIGHTRED='\033[1;31m'
# shellcheck disable=SC2034
export LIGHTGREEN='\033[1;32m'
# shellcheck disable=SC2034
export YELLOW='\033[1;33m'
# shellcheck disable=SC2034
export LIGHTBLUE='\033[1;34m'
# shellcheck disable=SC2034
export LIGHTPURPLE='\033[1;35m'
# shellcheck disable=SC2034
export LIGHTCYAN='\033[1;36m'
# shellcheck disable=SC2034
export WHITE='\033[1;37m'

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
