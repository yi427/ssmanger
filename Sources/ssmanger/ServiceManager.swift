import Foundation

struct ServiceManager {
    static func execute(_ command: String, service: String) {
        let args: [String]
        switch command {
        case "start":
            args = ["load", "\(NSHomeDirectory())/Library/LaunchAgents/\(service).plist"]
        case "stop":
            args = ["unload", "\(NSHomeDirectory())/Library/LaunchAgents/\(service).plist"]
        case "restart":
            args = ["kickstart", "-k", "gui/\(getuid())/\(service)"]
        case "status":
            args = ["list", service]
        default:
            return
        }
        runLaunchctl(args)
    }

    static func listAll() {
        runLaunchctl(["list"])
    }

    private static func runLaunchctl(_ args: [String]) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/launchctl")
        process.arguments = args
        try? process.run()
        process.waitUntilExit()
    }
}
