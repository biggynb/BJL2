#!/bin/bash

# Hardcoded Variables
CURRENT_VERSION_FILE="/etc/bjlpm-version"  # File that stores the current version
LATEST_VERSION_FILE_URL="https://www.bjlinux.xyz/mirror/latest_version.txt"  # URL to fetch the latest version
SERVER_URL="https://www.bjlinux.xyz/mirror/"  # Base URL for downloading updates
DOWNLOAD_DIR="/tmp/bjldl"  # Directory for downloading and extracting updates

# Function to get the current version from /etc/bjlpm-version
get_current_version() {
    if [[ -f "$CURRENT_VERSION_FILE" ]]; then
        cat "$CURRENT_VERSION_FILE"
    else
        echo "2.1.0"  # Default starting version if no file exists
    fi
}

# Function to fetch the latest version from the server
get_latest_version() {
    wget -qO- "$LATEST_VERSION_FILE_URL"
    if [[ $? -ne 0 ]]; then
        echo "Error: Unable to fetch the latest version."
        exit 1
    fi
}

# Function to download a specific version
download_update() {
    local version=$1
    wget -O "$DOWNLOAD_DIR/update-$version.tar" "$SERVER_URL/update-$version.tar"
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to download update $version."
        exit 1
    fi
}

# Function to apply the update (extract and run update.sh)
apply_update() {
    local version=$1
    mkdir -p "$DOWNLOAD_DIR/extracted-$version"
    tar -xf "$DOWNLOAD_DIR/update-$version.tar" -C "$DOWNLOAD_DIR/extracted-$version"
    
    # Run the update.sh script inside the extracted update folder
    bash "$DOWNLOAD_DIR/extracted-$version/update.sh"
    
    # Update the current version file
    echo "$version" > "$CURRENT_VERSION_FILE"
    echo "Updated to version $version"
}

# Function to compare versions (assumes versions are in 'X.Y.Z' format)
version_compare() {
    [ "$(printf '%s\n' "$1" "$2" | sort -V | head -n1)" != "$1" ]
}

# Main script logic
CURRENT_VERSION=$(get_current_version)
LATEST_VERSION=$(get_latest_version)

if [[ -z "$LATEST_VERSION" ]]; then
    echo "Error: Unable to fetch the latest version."
    exit 1
fi

echo "Current version: $CURRENT_VERSION"
echo "Latest version: $LATEST_VERSION"

NEXT_VERSION=$CURRENT_VERSION

# Loop to download and apply updates until the latest version is reached
while version_compare "$NEXT_VERSION" "$LATEST_VERSION"; do
    # Increment to the next version (e.g., from 2.1.0 to 2.1.1)
    IFS='.' read -r -a version_parts <<< "$NEXT_VERSION"
    ((version_parts[2]++))  # Increment patch version
    NEXT_VERSION="${version_parts[0]}.${version_parts[1]}.${version_parts[2]}"

    echo "Fetching update for version $NEXT_VERSION"
    
    # Download and apply the next update
    download_update "$NEXT_VERSION"
    apply_update "$NEXT_VERSION"
done

echo "All updates applied. System is up to date."
