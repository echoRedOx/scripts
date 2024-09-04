#!/bin/bash

# Check if a filename was provided as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <filename>"
    exit 1
fi

# Get the filename from the first argument
FILE=$1

# Determine the interpreter based on the file extension
# Modify this section to support other interpreters if needed
case "${FILE##*.}" in
    py)
        INTERPRETER="python3"
        ;;
    sh)
        INTERPRETER="bash"
        ;;
    js)
        INTERPRETER="node"
        ;;
    *)
        echo "Unsupported file type. Please edit the script to add support for your file type."
        exit 1
        ;;
esac

# Run the entr command to watch the file and execute it on changes
ls $FILE | entr -r $INTERPRETER $FILE