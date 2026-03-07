import Foundation

struct ServiceCreator {
    static func create(service: String, plistPath: String, expandPath: (String) -> String) {
        print("\n" + "创建新服务: \(service)".bold.cyan)
        print("─────────────────────────────────────\n".cyan)

        print("程序路径: ".bold, terminator: "")
        guard let programInput = readLine(), !programInput.isEmpty else {
            print("错误: 程序路径不能为空".red)
            return
        }

        let program = expandPath(programInput)

        print("程序参数 (可选，多个参数用空格分隔): ".bold, terminator: "")
        let argsInput = readLine() ?? ""

        print("标准输出日志路径 (可选): ".bold, terminator: "")
        let stdOutInput = readLine() ?? ""
        let stdOutPath = stdOutInput.isEmpty ? nil : expandPath(stdOutInput)

        print("标准错误日志路径 (可选，留空则与标准输出相同): ".bold, terminator: "")
        let stdErrInput = readLine() ?? ""
        let stdErrPath = stdErrInput.isEmpty ? stdOutPath : expandPath(stdErrInput)

        let plistContent = generatePlist(label: service, program: program, args: argsInput, stdOutPath: stdOutPath, stdErrPath: stdErrPath)

        do {
            try plistContent.write(toFile: plistPath, atomically: true, encoding: .utf8)
            print("\n" + "✓ 服务创建成功: \(plistPath)".green)
        } catch {
            print("\n" + "✗ 创建失败: \(error.localizedDescription)".red)
        }
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
