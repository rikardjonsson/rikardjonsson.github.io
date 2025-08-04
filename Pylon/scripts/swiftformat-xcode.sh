#!/bin/bash

# SwiftFormat Build Phase Script for Xcode
# Add this as a "Run Script Phase" in your Xcode target (before compilation)

# Exit on any error
set -e

# Check if SwiftFormat is installed
if ! command -v swiftformat &> /dev/null; then
    echo "warning: SwiftFormat not installed, download from https://github.com/nicklockwood/SwiftFormat"
    exit 0
fi

# Run SwiftFormat on source files
echo "Running SwiftFormat..."
swiftformat "${SRCROOT}" --config "${SRCROOT}/.swiftformat"