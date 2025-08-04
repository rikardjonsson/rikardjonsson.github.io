# Pylon Development Makefile
# Quality gates and development commands

.PHONY: lint format lint-fix build test clean install-tools help

# Default target
help:
	@echo "Pylon Development Commands"
	@echo "=========================="
	@echo "make lint          - Run SwiftLint checks"
	@echo "make format        - Run SwiftFormat to fix formatting"
	@echo "make lint-fix      - Run SwiftLint with autocorrect"
	@echo "make build         - Build the project"
	@echo "make test          - Run tests"
	@echo "make clean         - Clean build artifacts"
	@echo "make install-tools - Install SwiftLint and SwiftFormat"
	@echo "make quality       - Run all quality checks (format + lint)"
	@echo ""

# Install development tools
install-tools:
	@echo "🔧 Installing development tools..."
	@command -v brew >/dev/null 2>&1 || { echo "❌ Homebrew required but not installed. Aborting."; exit 1; }
	brew install swiftlint swiftformat
	@echo "✅ Tools installed successfully"

# Run SwiftLint
lint:
	@echo "🔍 Running SwiftLint..."
	swiftlint --config .swiftlint.yml

# Run SwiftLint with autocorrect
lint-fix:
	@echo "🔧 Running SwiftLint with autocorrect..."
	swiftlint --fix --config .swiftlint.yml

# Run SwiftFormat
format:
	@echo "🎨 Running SwiftFormat..."
	swiftformat . --config .swiftformat

# Run all quality checks
quality: format lint
	@echo "✅ All quality checks completed"

# Build the project
build:
	@echo "🏗️ Building Pylon..."
	swift build

# Run tests
test:
	@echo "🧪 Running tests..."
	swift test

# Clean build artifacts
clean:
	@echo "🧹 Cleaning build artifacts..."
	swift package clean
	rm -rf .build

# Development workflow - run before committing
pre-commit: quality build test
	@echo "✅ Pre-commit checks completed successfully"