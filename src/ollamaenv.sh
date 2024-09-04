#!/bin/bash

update_system() {
    while true; do
        echo "Updating system"
        sudo apt update && sudo apt upgrade -y
        break
    done
}

curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash

# Check for exists at declared paths and look for the command to avoid dupes
append_if_exists() {
  local file="$1"
  local content="$2"
  
  if [ -f "$file" ]; then
    # Check if the content is already in the file
    grep -qxF "$content" "$file" || echo "$content" >> "$file"
  fi
}

# declarations
brc="$HOME/.bashrc"
profile="$HOME/.profile"
brc_profile="$HOME/.bash_profile"

pyenv_root_command='export PYENV_ROOT="$HOME/.pyenv"'
pyenv_path_command='command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"'
pyenv_init_command='eval "$(pyenv init -)"'

# .bashrc
append_if_exists "$brc" "$pyenv_root_command"
append_if_exists "$brc" "$pyenv_path_command"
append_if_exists "$brc" "$pyenv_init_command"

# .profile
append_if_exists "$profile" "$pyenv_root_command"
append_if_exists "$profile" "$pyenv_path_command"
append_if_exists "$profile" "$pyenv_init_command"

# .bash_profile
append_if_exists "$brc_profile" "$pyenv_root_command"
append_if_exists "$brc_profile" "$pyenv_path_command"
append_if_exists "$brc_profile" "$pyenv_init_command"

source "$brc" || source "$profile" || source "$brc_profile"

# Install additional deps
sudo apt update; sudo apt install build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev curl git libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

# download and Install Ollama. During installation, Ollama creates a new service and uses localhost:11434 as an open port for inferencing which I believes opens up some vulnerabilites for privilege escalation, remote exec and/or insecure env vars. I'm sure future me will be ready to tackle that problem when needed, lol.
# you will need to provide sudo during install and it will automatically check for GPU acceleration (one of the many many reasons Ollama is the best).
# Check if Ollama is installed
if ! command -v ollama &> /dev/null; then
    echo "Ollama is not installed. Ollama will now be installed."
    curl -fsSL https://ollama.com/install.sh | sh
else
    echo "Ollama is already installed."
fi

# create virtualenv - Open-WebUi requires python 3.11
if pyenv versions | grep -q "ollamaui"; then
    echo "Virtual environment 'ollamaui' already exists."
else
    echo "Creating virtual environment 'ollamaui'..."
    pyenv virtualenv 3.11 ollamaui
    pyenv activate ollamaui
fi

# activate virtualenv
# pyenv activate ollamaui

# update/install pip, setuptools and wheel before open-webui
pip install --upgrade pip setuptools wheel
pip install open-webui

#ollama pull mistral-nemo
ollama pull llama3.1
#ollama pull llava
#ollama pull codellama
#ollama pull deepseek-coder-v2

# Ask the user if they want to run the server
while true; do
    read -p "Would you like to run the server now? [y/n] " yn
    case $yn in
        [Yy]* ) 
            echo "Starting the server..."
            open-webui serve
            break
            ;;
        [Nn]* ) 
            echo "Server will not be started."
            break
            ;;
        * ) 
            echo "Please answer Y or n."
            ;;
    esac
done