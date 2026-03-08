import Foundation

struct TableRenderer {
    static let pageSize = 20

    static func renderServicesTable(_ services: [Service]) {
        var searchQuery = ""
        var currentPage = 0
        var selectedIndex = 0
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
            let filteredServices = searchQuery.isEmpty ? services : services.filter {
                $0.label.lowercased().contains(searchQuery.lowercased())
            }
            let pages = filteredServices.chunked(into: pageSize)

            if currentPage >= pages.count && !pages.isEmpty {
                currentPage = pages.count - 1
            }

            clearScreen()
            printPage(filteredServices, pages: pages, currentPage: currentPage, searchQuery: searchQuery, selectedIndex: selectedIndex)

            if let key = readKey() {
                let pageSize = pages.isEmpty ? 0 : pages[currentPage].count

                switch key {
                case "q", "Q":
                    shouldContinue = false
                case "j":
                    if currentPage < pages.count - 1 {
                        currentPage += 1
                        selectedIndex = 0
                    }
                case "k":
                    if currentPage > 0 {
                        currentPage -= 1
                        selectedIndex = 0
                    }
                case "\u{1B}[B":
                    if selectedIndex < pageSize - 1 {
                        selectedIndex += 1
                    }
                case "\u{1B}[A":
                    if selectedIndex > 0 {
                        selectedIndex -= 1
                    }
                case "\n", "\r":
                    showSelectedServiceDetail(pages: pages, currentPage: currentPage, selectedIndex: selectedIndex, originalTermios: originalTermios, action: showServiceStatus)
                case "l", "L":
                    showSelectedServiceDetail(pages: pages, currentPage: currentPage, selectedIndex: selectedIndex, originalTermios: originalTermios, action: showServiceLogs)
                case "/":
                    if var term = originalTermios {
                        tcsetattr(STDIN_FILENO, TCSANOW, &term)
                    }
                    searchQuery = promptSearch()
                    currentPage = 0
                    term.c_lflag &= ~(UInt(ECHO | ICANON))
                    tcsetattr(STDIN_FILENO, TCSANOW, &term)
                case "\u{1B}":
                    searchQuery = ""
                    currentPage = 0
                default:
                    break
                }
            }
        }
        clearScreen()
    }

    private static func showSelectedServiceDetail(pages: [[Service]], currentPage: Int, selectedIndex: Int, originalTermios: termios?, action: (String) -> Void) {
        guard !pages.isEmpty && currentPage < pages.count else { return }
        let page = pages[currentPage]
        guard selectedIndex < page.count else { return }

        let selectedService = page[selectedIndex]
        var term = termios()

        if var original = originalTermios {
            tcsetattr(STDIN_FILENO, TCSANOW, &original)
        }

        action(selectedService.label)

        print("\nPress " + "Enter".blue + " to continue...".gray)
        _ = readKey()

        tcgetattr(STDIN_FILENO, &term)
        term.c_lflag &= ~(UInt(ECHO | ICANON))
        tcsetattr(STDIN_FILENO, TCSANOW, &term)
    }

    private static func showServiceStatus(_ service: String) {
        withServiceDetail(service) { StatusRenderer.render($0) }
    }

    private static func showServiceLogs(_ service: String) {
        withServiceDetail(service) { LogRenderer.render($0) }
    }

    private static func withServiceDetail(_ service: String, action: (ServiceDetail) -> Void) {
        let process = Process()
        let pipe = Pipe()
        process.executableURL = URL(fileURLWithPath: "/bin/launchctl")
        process.arguments = ["list", service]
        process.standardOutput = pipe
        try? process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""

        if let detail = ServiceDetail.parse(from: output) {
            action(detail)
        } else {
            print("Service not found: \(service)".red)
        }
    }

    private static func clearScreen() {
        print("\u{001B}[2J\u{001B}[H", terminator: "")
        fflush(stdout)
    }

    private static func promptSearch() -> String {
        print("\n  Search: ", terminator: "")
        fflush(stdout)
        return readLine() ?? ""
    }

    private static func readKey() -> String? {
        var buffer = [UInt8](repeating: 0, count: 3)
        let count = read(STDIN_FILENO, &buffer, 3)
        guard count > 0 else { return nil }
        return String(bytes: buffer[0..<count], encoding: .utf8)
    }

    private static func printPage(_ services: [Service], pages: [[Service]], currentPage: Int, searchQuery: String, selectedIndex: Int) {
        let runningCount = services.filter { $0.isRunning }.count
        let totalCount = services.count

        let page = (currentPage < pages.count && !pages.isEmpty) ? pages[currentPage] : []

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

        if !pages.isEmpty && currentPage < pages.count {
            let page = pages[currentPage]


            for (index, service) in page.enumerated() {
                let arrow = (index == selectedIndex) ? ">" : " "
                let pidWithArrow = (arrow + " " + service.pid).padding(toLength: col0Width, withPad: " ", startingAt: 0)
                let status = service.status.padding(toLength: col1Width, withPad: " ", startingAt: 0)

                var label = service.label
                if label.count > col2Width - 2 {
                    label = String(label.prefix(col2Width - 5)) + "..."
                }
                label = label.padding(toLength: col2Width - 2, withPad: " ", startingAt: 0)

                let statusIcon = service.isRunning ? "✓".green : "✗".red
                let pidColor = service.isRunning ? pidWithArrow.styled(ANSIColor.green) : pidWithArrow.gray

                print("│".cyan + " " + pidColor + " " + "│".cyan + " " + status + " " + "│".cyan + " " + statusIcon + " " + label + " " + "│".cyan)
            }
        }

        print("╰\(String(repeating: "─", count: col0Width + 2))┴\(String(repeating: "─", count: col1Width + 2))┴\(String(repeating: "─", count: col2Width + 2))╯".styled(ANSIColor.bold, ANSIColor.cyan))

        let searchInfo = searchQuery.isEmpty ? "" : "  Search: \"\(searchQuery)\"".styled(ANSIColor.magenta)
        print("\n  " + "[\(currentPage + 1)/\(pages.count)]".styled(ANSIColor.gray) + searchInfo + "  " + "k".blue + " Prev  " + "j".blue + " Next  " + "/".magenta + " Search  " + "l".blue + " log  " +  "q".red + " Quit")
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
