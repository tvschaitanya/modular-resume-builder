#!/usr/bin/env bash
set -e

echo "This will remove the 'output' directory."
read -r -p "Continue? [y/N] " answer

if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
    echo "Cancelled."
    exit 0
fi

if [[ -d output ]]; then
    rm -rf output
    echo "'output' removed."
else
    echo "'output' does not exist."
fi