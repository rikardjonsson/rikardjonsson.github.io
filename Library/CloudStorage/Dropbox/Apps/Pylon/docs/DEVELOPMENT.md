# Development Tooling Guide

This document outlines the development tools, quality gates, and best practices for contributing to Pylon.

## Quick Start

```bash
# Install development tools (if not already installed)
make install-tools

# Run quality checks before committing
make quality

# Complete pre-commit workflow
make pre-commit
```

## Development Tools

### SwiftLint
Static analysis tool for Swift code style and conventions.

**Configuration**: `.swiftlint.yml`
- Swift 6.0 compliance rules
- 120 character line limit (warning), 150 (error)
- 400 line file limit (warning), 500 (error)
- Custom rules for macOS development patterns

**Usage**:
```bash
make lint          # Check for violations
make lint-fix      # Auto-fix violations where possible
```

### SwiftFormat
Code formatter that ensures consistent code style.

**Configuration**: `.swiftformat`
- Swift 6.0 target
- 4-space indentation
- 120 character line width
- Automatic import organization

**Usage**:
```bash
make format        # Format all Swift files
```

## Quality Gates

### Pre-commit Hook
Automatically runs on every commit to ensure code quality:

1. **SwiftFormat**: Auto-formats staged Swift files
2. **SwiftLint**: Validates code against style rules
3. **Fail on violations**: Prevents commits with linting errors

**Location**: `.git/hooks/pre-commit`

**Bypass** (use sparingly): `git commit --no-verify`

### Build Integration

For Xcode projects, use the provided build scripts:

**SwiftLint Build Phase**:
```bash
./scripts/swiftlint-xcode.sh
```

**SwiftFormat Build Phase**:
```bash
./scripts/swiftformat-xcode.sh
```

## Makefile Commands

| Command | Description |
|---------|-------------|
| `make help` | Show all available commands |
| `make install-tools` | Install SwiftLint and SwiftFormat via Homebrew |
| `make lint` | Run SwiftLint checks |
| `make lint-fix` | Run SwiftLint with auto-correction |
| `make format` | Run SwiftFormat on all files |
| `make quality` | Run both format and lint |
| `make build` | Build the project |
| `make test` | Run tests |
| `make clean` | Clean build artifacts |
| `make pre-commit` | Full pre-commit workflow |

## Code Style Guidelines

### Swift 6.0 Specific Rules

1. **Concurrency**: Use `@MainActor` for UI classes, `actor` for background services
2. **Sendable**: Mark types as `Sendable` where appropriate
3. **Strict Concurrency**: All concurrency violations are errors

### Architecture Rules

1. **File Length**: Maximum 400 lines (warning), 500 (error)
2. **Function Length**: Maximum 50 lines (warning), 100 (error)
3. **Line Length**: Maximum 120 characters (warning), 150 (error)
4. **Nesting**: Maximum 2 type levels, 3 function levels

### Naming Conventions

- **Variables**: camelCase, minimum 2 characters
- **Types**: PascalCase, minimum 3 characters
- **Functions**: camelCase, descriptive names
- **Constants**: camelCase or UPPER_CASE for global constants

## Custom Rules

### MainActor UI Classes
Warns when UI classes (containing "View" in name) aren't marked with `@MainActor`.

### Force Unwrapping Prevention
Discourages force unwrapping (`!`) in production code.

## Configuration Files

- **`.swiftlint.yml`**: SwiftLint configuration with Swift 6.0 rules
- **`.swiftformat`**: SwiftFormat configuration for consistent styling
- **`Makefile`**: Development commands and workflows
- **`.git/hooks/pre-commit`**: Automated quality checks

## Troubleshooting

### SwiftLint Issues

**Command not found**: Install with `brew install swiftlint`

**Configuration errors**: Check `.swiftlint.yml` syntax and rule names

**Too many violations**: Run `make lint-fix` first, then address remaining issues

### SwiftFormat Issues

**Command not found**: Install with `brew install swiftformat`

**Formatting conflicts**: Check `.swiftformat` configuration options

### Pre-commit Hook

**Hook not running**: Ensure `.git/hooks/pre-commit` is executable:
```bash
chmod +x .git/hooks/pre-commit
```

**Permission denied**: Check script permissions and Homebrew installation

## Best Practices

1. **Run quality checks before committing**: `make quality`
2. **Keep functions small**: Break down complex functions
3. **Use descriptive names**: Avoid abbreviations and single letters
4. **Follow Swift API Design Guidelines**: Consistent with Apple's conventions
5. **Write tests**: Maintain good test coverage
6. **Document complex logic**: Use comments for non-obvious code

## IDE Integration

### Xcode
1. Add build phases using the provided scripts in `scripts/`
2. Configure SwiftLint as a run script phase
3. Set up SwiftFormat as a pre-build step

### VS Code
Install the Swift extensions and configure workspace settings to use the local tools.

## Continuous Integration

The quality gates can be integrated into CI/CD pipelines:

```bash
# CI script example
make install-tools
make quality
make build
make test
```

---

For questions or issues with the development tooling, please check the [troubleshooting section](#troubleshooting) or file an issue on GitHub.