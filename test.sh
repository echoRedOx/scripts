#! /bin/bash

echo "Starting..."

pyenv versions | grep -q 'ollama' && echo "ollamaui virtualenv installed" || pyenv virtualenv 3.11 ollama

# Activate the virtual environment


# Confirm the environment is activated
