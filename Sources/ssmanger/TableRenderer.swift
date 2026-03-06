import Foundation

struct TableRenderer {
    static let pageSize = 20

    static func renderServicesTable(_ services: [Service]) {
        let pages = services.chunked(into: pageSize)
        var currentPage = 0
        var originalTermios: termios?

        var term = termios()
        tcgetattr(STDIN_FILENO, &term)
        originalTermios = term
        term.c_lflag &= ~(UInt(ECHO | ICANON))
        tcsetattr(STDIN_FILENO, TCSANOW, &term)

        defer {
            if var term = originalTermios {
                tcsetattr(STDIN_FILENO, TCSANOW, &term)
            }
        }

        var shouldContinue = true
        while shouldContinue {
            clearScreen()
            printPage(services, pages: pages, currentPage: currentPage)

            if let key = readKey() {
                switch key {
                case "q", "Q":
                    shouldContinue = false
                case "j", "\u{1B}[B":
                    if currentPage < pages.count - 1 {
                        currentPage += 1
                    }
                case "k", "\u{1B}[A":
                    if currentPage > 0 {
                        currentPage -= 1
                    }
                default:
                    break
                }
            }
        }
        clearScreen()
    }

    private static func clearScreen() {
        print("\u{001B}[2J\u{001B}[H", terminator: "")
        fflush(stdout)
    }

    private static func printPage(_ services: [Service], pages: [[Service]], currentPage: Int) {
        let runningCount = services.filter { $0.isRunning }.count
        let totalCount = services.count

        guard currentPage < pages.count else { return }
        let page = pages[currentPage]

        let col0Width = max(8, page.map { $0.pid.count }.max() ?? 0)
        let col1Width = max(8, page.map { $0.status.count }.max() ?? 0)
        let col2Width = 50
        let tableWidth = col0Width + col1Width + col2Width + 10

        let headerBorder = String(repeating: "═", count: tableWidth)
        print("\n" + "╔\(headerBorder)╗".styled(ANSIColor.bold, ANSIColor.blue))

        let title = "⚡ System Service Manager"
        let titlePadding = String(repeating: " ", count: tableWidth - title.count - 3)
        print("║".styled(ANSIColor.bold, ANSIColor.blue) + "  " + title.styled(ANSIColor.bold, ANSIColor.magenta) + titlePadding + "║".styled(ANSIColor.bold, ANSIColor.blue))

        print("╠\(headerBorder)╣".styled(ANSIColor.bold, ANSIColor.blue))

        let statsLine = "Total \(totalCount) services  │  ✓ \(runningCount) Running  │  ✗ \(totalCount - runningCount) Stopped"
        let statsPadding = String(repeating: " ", count: tableWidth - statsLine.count - 2)
        print("║".styled(ANSIColor.bold, ANSIColor.blue) + "  " + statsLine.cyan + statsPadding + "║".styled(ANSIColor.bold, ANSIColor.blue))

        print("╚\(headerBorder)╝".styled(ANSIColor.bold, ANSIColor.blue) + "\n")

        print("╭\(String(repeating: "─", count: col0Width + 2))┬\(String(repeating: "─", count: col1Width + 2))┬\(String(repeating: "─", count: col2Width + 2))╮".styled(ANSIColor.bold, ANSIColor.cyan))

        let header0 = "PID".padding(toLength: col0Width, withPad: " ", startingAt: 0)
        let header1 = "Status".padding(toLength: col1Width, withPad: " ", startingAt: 0)
        let header2 = "Service Name".padding(toLength: col2Width, withPad: " ", startingAt: 0)
        print("│".styled(ANSIColor.bold, ANSIColor.cyan) + " " + header0.bold + " " + "│".styled(ANSIColor.bold, ANSIColor.cyan) + " " + header1.bold + " " + "│".styled(ANSIColor.bold, ANSIColor.cyan) + " " + header2.bold + " " + "│".styled(ANSIColor.bold, ANSIColor.cyan))

        print("├\(String(repeating: "─", count: col0Width + 2))┼\(String(repeating: "─", count: col1Width + 2))┼\(String(repeating: "─", count: col2Width + 2))┤".styled(ANSIColor.bold, ANSIColor.cyan))

        for service in page {
            let pid = service.pid.padding(toLength: col0Width, withPad: " ", startingAt: 0)
            let status = service.status.padding(toLength: col1Width, withPad: " ", startingAt: 0)

            var label = service.label
            if label.count > col2Width - 2 {
                label = String(label.prefix(col2Width - 5)) + "..."
            }
            label = label.padding(toLength: col2Width - 2, withPad: " ", startingAt: 0)

            let statusIcon = service.isRunning ? "✓".green : "✗".red
            let pidColor = service.isRunning ? pid.styled(ANSIColor.green) : pid.gray

            print("│".cyan + " " + pidColor + " " + "│".cyan + " " + status + " " + "│".cyan + " " + statusIcon + " " + label + " " + "│".cyan)
        }

        print("╰\(String(repeating: "─", count: col0Width + 2))┴\(String(repeating: "─", count: col1Width + 2))┴\(String(repeating: "─", count: col2Width + 2))╯".styled(ANSIColor.bold, ANSIColor.cyan))

        print("\n  " + "[\(currentPage + 1)/\(pages.count)]".styled(ANSIColor.gray) + "  " + "↑".blue + "/" + "k".blue + " Prev  " + "↓".blue + "/" + "j".blue + " Next  " + "q".red + " Quit")
    }

    private static func readKey() -> String? {
        var buffer = [UInt8](repeating: 0, count: 3)
        let count = read(STDIN_FILENO, &buffer, 3)
        guard count > 0 else { return nil }
        return String(bytes: buffer[0..<count], encoding: .utf8)
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
