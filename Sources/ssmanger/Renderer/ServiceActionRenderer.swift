import Foundation

struct ServiceActionRenderer {
    private static func getErrorMessage(for exitCode: Int32, command: String) -> String {
        switch exitCode {
        case 3:
            return command == "start" ? "Service not found" : "Service is not running"
        case 5:
            return command == "start" ? "Service is already running or disabled" : "I/O error occurred"
        case 37, 150:
            return "Permission denied (try with sudo)"
        case 78:
            return "Configuration error or invalid plist"
        case 113:
            return "Service not found or already unloaded"
        default:
            return "Unknown error"
        }
    }

    static func start(_ service: String, plistPath: String, domainTarget: String) {
        guard FileManager.default.fileExists(atPath: plistPath) else {
            print("✗ Service not found: \(plistPath)".red)
            return
        }

        print("\n" + "Starting service: \(service)".bold.cyan)

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/launchctl")
        process.arguments = ["bootstrap", domainTarget, plistPath]
        try? process.run()
        process.waitUntilExit()

        if process.terminationStatus == 0 {
            print("✓ Service started successfully".green)
        } else {
            let errorMsg = getErrorMessage(for: process.terminationStatus, command: "start")
            print("✗ Failed to start service: \(errorMsg)".red)
            print("  Exit code: \(process.terminationStatus)".gray)
        }
    }

    static func stop(_ service: String, serviceTarget: String) {
        print("\n" + "Stopping service: \(service)".bold.cyan)

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/launchctl")
        process.arguments = ["bootout", serviceTarget]
        try? process.run()
        process.waitUntilExit()

        if process.terminationStatus == 0 {
            print("✓ Service stopped successfully".green)
        } else {
            let errorMsg = getErrorMessage(for: process.terminationStatus, command: "stop")
            print("✗ Failed to stop service: \(errorMsg)".red)
            print("  Exit code: \(process.terminationStatus)".gray)
        }
    }

    static func restart(_ service: String, serviceTarget: String) {
        print("\n" + "Restarting service: \(service)".bold.cyan)

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/launchctl")
        process.arguments = ["kickstart", "-k", serviceTarget]
        try? process.run()
        process.waitUntilExit()

        if process.terminationStatus == 0 {
            print("✓ Service restarted successfully".green)
        } else {
            let errorMsg = getErrorMessage(for: process.terminationStatus, command: "restart")
            print("✗ Failed to restart service: \(errorMsg)".red)
            print("  Exit code: \(process.terminationStatus)".gray)
        }
    }
}
