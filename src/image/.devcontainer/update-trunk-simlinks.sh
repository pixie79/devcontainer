#!/bin/bash

# Navigate to the .trunk directory
cd .trunk || exit

# List of folders to relink
folders=("actions" "logs" "notifications" "out" "tools")

# Base path for the new symbolic links
basePath=$(trunk cache)/

for folder in "${folders[@]}"; do
    # Remove the existing symbolic link, if it exists
    rm -f "${folder}"

    # Create a new symbolic link
    ln -s "${basePath}${folder}" "${folder}"
done

echo "Symlinks have been updated."
