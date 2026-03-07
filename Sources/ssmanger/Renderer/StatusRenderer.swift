import Foundation

struct StatusRenderer {
    static func render(_ detail: ServiceDetail) {
        print("\n" + "╔══════════════════════════════════════════════════════╗".styled(ANSIColor.bold, ANSIColor.blue))
        print("║".styled(ANSIColor.bold, ANSIColor.blue) + "  " + "Service Status".styled(ANSIColor.bold, ANSIColor.magenta).paddedToWidth(50) + "  " + "║".styled(ANSIColor.bold, ANSIColor.blue))
        print("╠══════════════════════════════════════════════════════╣".styled(ANSIColor.bold, ANSIColor.blue))

        printRow("Name", detail.label)

        let status = detail.isRunning ? "Running".green : "Stopped".red
        printRow("Status", status)

        printRow("PID", detail.pid)
        printRow("Exit", detail.lastExitStatus)

        if let program = detail.program {
            printRow("Program", program)
        }

        print("╚══════════════════════════════════════════════════════╝".styled(ANSIColor.bold, ANSIColor.blue) + "\n")
    }

    private static func printRow(_ label: String, _ value: String) {
        let content = (label.bold + ": " + value).paddedToWidth(50)
        print("║".styled(ANSIColor.bold, ANSIColor.blue) + "  " + content + "  " + "║".styled(ANSIColor.bold, ANSIColor.blue))
    }
}
