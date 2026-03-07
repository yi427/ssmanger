import Foundation

struct ServiceManager {
    static func execute(_ command: String, service: String) {
        let args: [String]
        let plistPath = getServicePath(service)
        let domainTarget = getDomainTarget()
        let serviceTarget = getServiceTarget(service)

        switch command {
        case "start":
            args = ["bootstrap", domainTarget, plistPath]
            runLaunchctl(args)
        case "stop":
            args = ["bootout", serviceTarget]
            runLaunchctl(args)
        case "restart":
            args = ["kickstart", "-k", serviceTarget]
            runLaunchctl(args)
        case "status":
            showStatus(service)
        default:
            return
        }
    }

    private static func isRoot() -> Bool {
        return getuid() == 0
    }

    private static func getServicePath(_ service: String) -> String {
        if isRoot() {
            return "/Library/LaunchDaemons/\(service).plist"
        } else {
            return "\(NSHomeDirectory())/Library/LaunchAgents/\(service).plist"
        }
    }

    private static func getDomainTarget() -> String {
        if isRoot() {
            return "system"
        } else {
            return "gui/\(getuid())"
        }
    }

    private static func getServiceTarget(_ service: String) -> String {
        if isRoot() {
            return "system/\(service)"
        } else {
            return "gui/\(getuid())/\(service)"
        }
    }

    private static func expandPath(_ path: String) -> String {
        guard path.hasPrefix("~") else {
            return path
        }

        if let sudoUser = ProcessInfo.processInfo.environment["SUDO_USER"] {
            return path.replacingOccurrences(of: "~", with: "/Users/\(sudoUser)")
        }

        return NSString(string: path).expandingTildeInPath
    }

    static func listAll() {
        let output = runLaunchctlWithOutput(["list"])
        let services = parseServices(from: output)
        TableRenderer.renderServicesTable(services)
    }

    static func addService(_ service: String) {
        let plistPath = getServicePath(service)
        ServiceCreator.create(service: service, plistPath: plistPath, expandPath: expandPath)
    }

    private static func showStatus(_ service: String) {
        let output = runLaunchctlWithOutput(["list", service])

        guard let detail = ServiceDetail.parse(from: output) else {
            print("Service not found: \(service)".red)
            return
        }

        StatusRenderer.render(detail)
    }

    private static func parseServices(from output: String) -> [Service] {
        let lines = output.split(separator: "\n")
        guard lines.count > 1 else { return [] }

        return lines.dropFirst().compactMap { line in
            let parts = line.split(separator: "\t", maxSplits: 2).map(String.init)
            guard parts.count >= 3 else { return nil }
            return Service(pid: parts[0], status: parts[1], label: parts[2])
        }
    }

    private static func runLaunchctl(_ args: [String]) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/launchctl")
        process.arguments = args
        try? process.run()
        process.waitUntilExit()
    }

    private static func runLaunchctlWithOutput(_ args: [String]) -> String {
        let process = Process()
        let pipe = Pipe()
        process.executableURL = URL(fileURLWithPath: "/bin/launchctl")
        process.arguments = args
        process.standardOutput = pipe
        try? process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8) ?? ""
    }
}
