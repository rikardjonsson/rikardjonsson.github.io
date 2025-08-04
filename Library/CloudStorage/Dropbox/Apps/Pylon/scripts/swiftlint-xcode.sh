#!/bin/bash

# SwiftLint Build Phase Script for Xcode
# Add this as a "Run Script Phase" in your Xcode target

# Exit on any error
set -e

# Check if SwiftLint is installed
if ! command -v swiftlint &> /dev/null; then
    echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
    exit 0
fi

# Run SwiftLint
echo "Running SwiftLint..."
swiftlint --config "${SRCROOT}/.swiftlint.yml"