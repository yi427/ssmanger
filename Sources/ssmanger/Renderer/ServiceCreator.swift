import Foundation

struct ServiceCreator {
    static func create(service: String, plistPath: String, expandPath: (String) -> String) -> Bool {
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
        var programArgs = ["<string>\(program)</string>"]

        if !args.isEmpty {
            let argList = args.split(separator: " ").map { "<string>\($0)</string>" }
            programArgs.append(contentsOf: argList)
        }

        let programArgsIndented = programArgs.map { "        \($0)" }.joined(separator: "\n")

        var plist = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
            <key>Label</key>
            <string>\(label)</string>
            <key>ProgramArguments</key>
            <array>
        \(programArgsIndented)
            </array>
            <key>RunAtLoad</key>
            <true/>
            <key>KeepAlive</key>
            <true/>
        """

        if let stdOut = stdOutPath {
            plist += """

            <key>StandardOutPath</key>
            <string>\(stdOut)</string>
        """
        }

        if let stdErr = stdErrPath {
            plist += """

            <key>StandardErrorPath</key>
            <string>\(stdErr)</string>
        """
        }

        plist += """

        </dict>
        </plist>
        """

        return plist
    }
}
