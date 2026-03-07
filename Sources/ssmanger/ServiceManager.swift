import Foundation

struct ServiceManager {
    static func execute(_ command: String, service: String) {
        let args: [String]
        switch command {
        case "start":
            args = ["load", "\(NSHomeDirectory())/Library/LaunchAgents/\(service).plist"]
            runLaunchctl(args)
        case "stop":
            args = ["unload", "\(NSHomeDirectory())/Library/LaunchAgents/\(service).plist"]
            runLaunchctl(args)
        case "restart":
            args = ["kickstart", "-k", "gui/\(getuid())/\(service)"]
            runLaunchctl(args)
        case "status":
            showStatus(service)
        default:
            return
        }
    }

    static func listAll() {
        let output = runLaunchctlWithOutput(["list"])
        let services = parseServices(from: output)
        TableRenderer.renderServicesTable(services)
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
