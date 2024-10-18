#!/bin/bash

# Variables
CURRENT_VERSION_FILE="/opt/yourapp/version.txt"  # File that stores the current version
SERVER_URL="https://your-private-server.com/updates"
DOWNLOAD_DIR="/tmp"
INSTALL_DIR="/opt/yourapp"

# Function to get current version
get_current_version() {
    if [[ -f "$CURRENT_VERSION_FILE" ]]; then
        cat "$CURRENT_VERSION_FILE"
    else
        echo "2.1.0"  # Default starting version if no file exists
    fi
}

# Function to download a specific version
download_update() {
    local version=$1
    wget -O "$DOWNLOAD_DIR/update-$version.tar.gz" "$SERVER_URL/$version/update.tar.gz"
}

# Function to apply update (extract and run commands)
apply_update() {
    local version=$1
    tar -xf "$DOWNLOAD_DIR/update-$version.tar.gz" -C "$DOWNLOAD_DIR/extracted-$version"
    
    # Extract commands from HTML (assumes the tarball includes HTML files with commands)
    OUTPUT_SCRIPT="$DOWNLOAD_DIR/extracted-$version/commands.sh"
    > "$OUTPUT_SCRIPT"  # Clear previous contents if any

    for html_file in "$DOWNLOAD_DIR/extracted-$version"/*.html; do
        grep -oP '(?<=<pre class="userinput"><kbd class="command">)[^<]+' "$html_file" >> "$OUTPUT_SCRIPT"
    done

    chmod +x "$OUTPUT_SCRIPT"
    bash "$OUTPUT_SCRIPT"  # Run the extracted commands
    
    # Update the version file
    echo "$version" > "$CURRENT_VERSION_FILE"
    echo "Updated to version $version"
}

# Function to compare versions (assumes versions are in 'X.Y.Z' format)
version_compare() {
    [ "$(printf '%s\n' "$1" "$2" | sort -V | head -n1)" != "$1" ]
}

# Main script logic
CURRENT_VERSION=$(get_current_version)
LATEST_VERSION="2.5.0"  # You can set this dynamically if needed

echo "Current version: $CURRENT_VERSION"
echo "Latest version: $LATEST_VERSION"

NEXT_VERSION=$CURRENT_VERSION

# Loop to download and apply updates until the latest version
while version_compare "$NEXT_VERSION" "$LATEST_VERSION"; do
    # Increment to the next version (e.g., from 2.1.0 to 2.2.0)
    IFS='.' read -r -a version_parts <<< "$NEXT_VERSION"
    ((version_parts[2]++))  # Increment patch version
    NEXT_VERSION="${version_parts[0]}.${version_parts[1]}.${version_parts[2]}"

    echo "Fetching update for version $NEXT_VERSION"
    
    # Download and apply the next update
    download_update "$NEXT_VERSION"
    if [[ $? -eq 0 ]]; then
        apply_update "$NEXT_VERSION"
    else
        echo "Failed to download update for version $NEXT_VERSION. Exiting."
        exit 1
    fi
done

echo "All updates applied. System is up to date."
