# SSManager - System Service Manager

## Project Overview

A Swift-based CLI tool for managing macOS LaunchAgent and LaunchDaemon services. Provides a modern, colorful interface as a simplified alternative to `launchctl`. Supports both regular user and root (sudo) modes.

## Architecture

### Directory Structure
```
Sources/ssmanger/
├── main.swift              # Entry point and CLI argument parsing
├── ServiceManager.swift    # Core service management logic
├── Models/
│   ├── ANSIColor.swift    # Terminal color utilities with ANSI-aware padding
│   ├── Service.swift      # Service list model
│   └── ServiceDetail.swift # Detailed service information model
└── Renderer/
    ├── TableRenderer.swift  # Interactive service list UI
    └── StatusRenderer.swift # Service status detail UI
```

## Key Design Decisions

### ANSI Color Handling
The project uses ANSI escape sequences for terminal colors. A critical challenge was text alignment - ANSI codes affect string length calculations but are invisible.

**Solution**: `visibleLength` property and `paddedToWidth()` method in `ANSIColor.swift`:
- Strips ANSI codes using regex pattern `\u{001B}\\[[0-9;]*m`
- Calculates padding based on visible characters only
- Ensures proper alignment in tables and bordered layouts

### Interactive UI
- Terminal raw mode (termios) for keyboard input without Enter
- Pagination (20 items per page)
- Real-time search with `/` key
- Keyboard navigation: j/k or arrow keys

### Service Information Parsing
LaunchAgent services output plist-format data. `ServiceDetail.parse()` extracts key-value pairs from `launchctl list <service>` output.

### Privilege Detection and Path Management
The tool automatically detects execution context and adjusts behavior:

**Root Mode (sudo)**:
- Operates on `/Library/LaunchDaemons/`
- Uses `system` domain-target
- Uses `system/<service>` service-target

**User Mode**:
- Operates on `~/Library/LaunchAgents/`
- Uses `gui/<uid>` domain-target
- Uses `gui/<uid>/<service>` service-target

**Modern launchctl Commands**:
- `bootstrap` for starting services (replaces deprecated `load`)
- `bootout` for stopping services (replaces deprecated `unload`)
- `kickstart -k` for restarting services

**Key Implementation**:
- `isRoot()` checks `getuid() == 0`
- `getDomainTarget()` returns domain for bootstrap/bootout
- `getServiceTarget()` returns full service path for bootout/kickstart

## Development Guidelines

- Keep code minimal and focused
- Use ANSI-aware padding for all formatted output
- Test alignment with colored text
- Follow existing commit message style (feat/fix/refactor)
