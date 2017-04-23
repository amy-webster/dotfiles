#!/bin/bash


FILE_NAMES=(
  .bashrc
  .gitconfig
  .profile
)
SOURCE_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
# Source functions
source ${SOURCE_DIR}/.functions


replace_file() {
    local basename=$1
    local origin="$SOURCE_DIR/$basename"
    local filename="$HOME/$basename"
    local newname="$HOME/${basename}_bak"

    if [ -f "$filename" ] || [ -d "$filename" ]; then
        log_info "Backing up '$basename'..."
        mv "$filename" "$newname"
    elif [ -L "$filename" ]; then
        log_info "Removing symlink '$filename' -> '$(readlink -f \"$filename\")'"
        rm "$filename"
    fi
    ln -s "$origin" "$filename"
}


process_files() {
  for f in ${FILE_NAMES[*]}; do
    replace_file $f
  done
}


setup_bash() {
  # Keep existing .bashrc but make sure it sources ~/.profile
  local profile_file="$HOME/.profile"
  local bashrc_file="$HOME/.bashrc"
  if ! silence grep -P '\..*?\.profile$' "$bashrc_file" && \
     ! silence grep -P 'source.*?\.profile$' "$bashrc_file"; then
    cat << EOF >> "$bashrc_file"

# Added automatically by dotfiles setup script
source ~/.profile
EOF
  fi
}


main() {
  . .profile

  setup_bash
  process_files

}


main
