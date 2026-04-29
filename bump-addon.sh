#!/bin/bash
set -e

if [ -z "$1" ]; then
  echo "Usage: ./bump-addon.sh <new-version>"
  echo "Example: ./bump-addon.sh 1.0.3"
  echo ""
  echo "Note: This script bumps the *Home Assistant Addon* version."
  echo "To update the upstream pv2mqtt dependency, manually edit pv2mqtt/Dockerfile."
  exit 1
fi

NEW_VERSION=$1
CONFIG_FILE="pv2mqtt/config.yaml"

# Ensure the config file exists
if [ ! -f "$CONFIG_FILE" ]; then
  echo "Error: $CONFIG_FILE not found!"
  exit 1
fi

echo "Bumping Addon version to $NEW_VERSION in $CONFIG_FILE..."
# Update the version line in config.yaml
sed -i "s/^version: \".*\"/version: \"$NEW_VERSION\"/" "$CONFIG_FILE"

echo "Creating commit and tag for v$NEW_VERSION..."
git add "$CONFIG_FILE"
git commit -m "Bump addon version to v$NEW_VERSION"
git tag "v$NEW_VERSION"

echo ""
echo "Done! The new version tag is ready."
echo "Run the following command to push the changes and trigger the GitHub Action build:"
echo "  git push origin main --tags"
