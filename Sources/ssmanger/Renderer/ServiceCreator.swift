import Foundation

struct ServiceCreator {
    static func create(service: String, plistPath: String) -> Bool {
        printHeader(service)

        guard let programInput = promptRequired("Program Path") else {
            return false
        }
        let program = expandPath(programInput)

        let argsInput = promptOptional("Program Arguments", hint: "space-separated")
        let stdOutInput = promptOptional("Stdout Log Path")
        let stdOutPath = stdOutInput.isEmpty ? nil : expandPath(stdOutInput)

        let stdErrInput = promptOptional("Stderr Log Path", hint: "leave empty to use stdout path")
        let stdErrPath = stdErrInput.isEmpty ? stdOutPath : expandPath(stdErrInput)

        let plistContent = generatePlist(label: service, program: program, args: argsInput, stdOutPath: stdOutPath, stdErrPath: stdErrPath)

        do {
            try plistContent.write(toFile: plistPath, atomically: true, encoding: .utf8)
            print("\n" + "✓ Service created successfully".green)
            print("  " + "Location: \(plistPath)".gray)
            return true
        } catch {
            print("\n" + "✗ Failed to create service: \(error.localizedDescription)".red)
            return false
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

    private static func printHeader(_ service: String) {
        print("\n" + "╭─────────────────────────────────────╮".cyan)
        print("│".cyan + "  " + "Create New Service".bold + "                 " + "│".cyan)
        print("│".cyan + "  " + service.magenta + String(repeating: " ", count: 35 - service.count) + "│".cyan)
        print("╰─────────────────────────────────────╯".cyan + "\n")
    }

    private static func promptRequired(_ label: String) -> String? {
        print("  " + "▸".cyan + " " + label.bold + " " + "(required)".gray)
        print("    ", terminator: "")
        guard let input = readLine(), !input.isEmpty else {
            print("    " + "✗ This field is required".red)
            return nil
        }
        return input
    }

    private static func promptOptional(_ label: String, hint: String? = nil) -> String {
        let hintText = hint.map { " (\($0))" } ?? ""
        print("  " + "▸".cyan + " " + label.bold + hintText.gray)
        print("    ", terminator: "")
        return readLine() ?? ""
    }

    private static func generatePlist(label: String, program: String, args: String, stdOutPath: String?, stdErrPath: String?) -> String {
        let builder = PlistBuilder().header().plist(0) { b in
            b.dict(0) { b in
                b.key("Label", 1).string(label, 1)
                b.key("ProgramArguments", 1).array(1) { b in
                    b.string(program, 2)
                    if !args.isEmpty {
                        for arg in args.split(separator: " ") {
                            b.string(expandPath(String(arg)), 2)
                        }
                    }
                }
                b.key("RunAtLoad", 1).true(1)
                b.key("KeepAlive", 1).true(1)
                if let stdOut = stdOutPath {
                    b.key("StandardOutPath", 1).string(stdOut, 1)
                }
                if let stdErr = stdErrPath {
                    b.key("StandardErrorPath", 1).string(stdErr, 1)
                }
            }
        }
        return builder.build()
    }
}
