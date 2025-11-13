#!/bin/bash
# Build script for Godot plugin packaging

PLUGIN_DIR="addons/made_with_godot"
BUILD_DIR="build"
ZIP_NAME="made_with_godot_plugin.zip"

# Create build directory if it doesn't exist
mkdir -p "$BUILD_DIR"

# Zip the plugin folder (excluding build dir itself)
zip -r "$BUILD_DIR/$ZIP_NAME" "$PLUGIN_DIR" -x "$BUILD_DIR/*"

echo "Plugin zipped to $BUILD_DIR/$ZIP_NAME"