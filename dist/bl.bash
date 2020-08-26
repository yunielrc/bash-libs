#!/bin/bash
#
# Bash libs

set -euEo pipefail

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
