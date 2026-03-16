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
│   ├── ANSIColor.swift     # Terminal color utilities with ANSI-aware padding
│   ├── Service.swift       # Service list model
│   ├── ServiceDetail.swift # Detailed service information model
│   └── PlistBuilder.swift  # DSL for generating plist XML with closure-based API
├── Renderer/
│   ├── TableRenderer.swift         # Interactive service list UI
│   ├── StatusRenderer.swift        # Service status detail UI
│   ├── ServiceCreator.swift        # Interactive service creation UI
│   ├── LogRenderer.swift           # Service log display UI
│   ├── ServiceListRenderer.swift   # Installed services list UI
│   └── ServiceActionRenderer.swift # Service start/stop/restart with error feedback
└── UI/
    ├── Core/
    │   ├── Terminal.swift          # Terminal size detection and resize callbacks
    │   ├── Component.swift         # UI component protocol
    │   ├── Size.swift              # Size definition (fixed, percent, auto)
    │   ├── BoxStyle.swift          # Box styling (border, alignment, colors)
    │   ├── StringExtensions.swift  # String utilities (truncate, display width)
    │   └── ResponsiveView.swift    # Auto re-render on terminal resize
    └── Components/
        ├── Box.swift               # Border container with styling support
        └── ResponsiveBox.swift     # Box with percentage-based width

Tests/ssmangerTests/
├── test_plist_builder.swift # PlistBuilder DSL tests
├── test_ui.swift            # UI system tests
└── test.swift               # Swift Testing framework examples and demos
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

### Service Creation (add command)
Interactive plist file generation with `ServiceCreator`:

**Features**:
- Prompts for program path, arguments, and log paths
- Handles `~` path expansion correctly in sudo context
- Supports separate stdout/stderr log paths
- Uses `PlistBuilder` DSL for clean XML generation

**Path Expansion**:
- Detects `SUDO_USER` environment variable
- Expands `~` to actual user's home directory, not root's
- Prevents `/var/root` paths when using sudo

**PlistBuilder DSL**:
- Closure-based API for automatic tag management
- Method chaining with `@discardableResult`
- Clean, readable plist generation without manual string concatenation
- Example:
```swift
PlistBuilder().header().plist(0) { b in
    b.dict(0) { b in
        b.key("Label", 1).string("com.example.service", 1)
        b.key("ProgramArguments", 1).array(1) { b in
            b.string("/usr/bin/python3", 2)
        }
    }
}.build()
```

**Generated plist includes**:
- Label, ProgramArguments (required)
- RunAtLoad, KeepAlive (default: true)
- StandardOutPath, StandardErrorPath (optional)

### Service Action Rendering (start/stop/restart commands)
`ServiceActionRenderer` handles service lifecycle operations with intelligent error feedback:

**Exit Code Mapping**:
- Maps launchctl exit codes to user-friendly error messages
- Exit code 3: Service not found or not running
- Exit code 5: Service already running/disabled (start) or I/O error
- Exit code 37/150: Permission denied (suggests sudo)
- Exit code 78: Configuration error or invalid plist
- Exit code 113: Service not found or already unloaded

**Benefits**:
- Immediate, precise error diagnosis instead of generic suggestions
- Reduces troubleshooting time for users
- Based on official launchctl behavior documentation

### Responsive UI System

A modern terminal UI framework with responsive layout and styling support.

**Core Components**:
- `Terminal` - Manages terminal size detection and SIGWINCH signal handling
- `Component` protocol - Base interface for all UI components
- `ResponsiveView` - Automatically re-renders components on terminal resize
- `Size` enum - Supports fixed, percentage, and auto sizing

**Box Component**:
Full-featured container with extensive styling options:
- Border styles: single (`┌─┐`), double (`╔═╗`), rounded (`╭─╮`), bold (`┏━┓`)
- Alignment: left, center, right
- Customizable padding and colors (border, title)
- Automatic truncation with `...` for overflow
- Multi-line content support

**CJK Character Support**:
Proper handling of Chinese/Japanese/Korean characters:
- `displayWidth` calculates actual terminal width (CJK = 2 chars)
- `visibleDisplayWidth` handles both ANSI colors and CJK
- Ensures perfect border alignment with mixed ASCII/CJK text

**Responsive Layout**:
```swift
ResponsiveBox(
    content: "内容",
    width: .percent(0.5),  // 50% of terminal width
    style: BoxStyle(border: .double, alignment: .center)
)
```

**Test Command**:
Run `ssmanger test_ui` to see responsive layout demo with terminal resize support.

## Testing

The project uses Swift Testing framework for unit tests.

**Test Structure**:
- `Tests/ssmangerTests/test_plist_builder.swift` - Tests for PlistBuilder DSL
- `Tests/ssmangerTests/test_ui.swift` - UI system tests (18 tests)
- `Tests/ssmangerTests/test.swift` - Comprehensive Swift Testing examples and demos

**Running Tests**:
```bash
swift test
```

**Test Configuration**:
- Configured in `Package.swift` with `testTarget` dependency on main executable
- Uses Swift Testing framework (not XCTest)
- Tests use `@Test` macro, `#expect` assertions, and `@Suite` for organization

**UI System Tests**:
- Terminal size detection and resize callbacks
- Box component rendering (borders, alignment, colors)
- String truncation with ANSI colors and CJK characters
- Responsive layout with percentage-based sizing
- Display width calculation for mixed ASCII/CJK text

**PlistBuilder Tests**:
- Validates closure-based API generates correct XML
- Tests method chaining and nested structures
- Ensures proper indentation and formatting

## Development Guidelines

- Keep code minimal and focused
- Use ANSI-aware padding for all formatted output
- Test alignment with colored text
- Follow existing commit message style (feat/fix/refactor)
- Run `swift test` before committing changes
