import Foundation

struct LogRenderer {
    static func render(_ detail: ServiceDetail) {
        print("\n" + "Service Logs: \(detail.label)".bold.cyan)
        print("─────────────────────────────────────\n".cyan)

        if let stdOut = detail.standardOutPath {
            print("Stdout Log: ".bold.green + stdOut.blue)
            showLog(stdOut)
        }

        if let stdErr = detail.standardErrorPath, stdErr != detail.standardOutPath {
            print("\nStderr Log: ".bold.red + stdErr.blue)
            showLog(stdErr)
        }

        if detail.standardOutPath == nil && detail.standardErrorPath == nil {
            print("No log files configured for this service".yellow)
        }
    }

    private static func showLog(_ path: String) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/tail")
        process.arguments = ["-n", "20", path]
        try? process.run()
        process.waitUntilExit()
    }
}
