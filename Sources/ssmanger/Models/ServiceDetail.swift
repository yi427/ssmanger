import Foundation

struct ServiceDetail {
    let label: String
    let pid: String
    let lastExitStatus: String
    let program: String?
    let standardOutPath: String?
    let standardErrorPath: String?

    var isRunning: Bool {
        pid != "0" && pid != "-"
    }

    static func parse(from output: String) -> ServiceDetail? {
        var label = ""
        var pid = "-"
        var lastExitStatus = "0"
        var program: String?
        var standardOutPath: String?
        var standardErrorPath: String?

        let lines = output.split(separator: "\n")
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if trimmed.contains("\"Label\"") {
                label = extractValue(from: trimmed)
            } else if trimmed.contains("\"PID\"") {
                pid = extractValue(from: trimmed)
            } else if trimmed.contains("\"LastExitStatus\"") {
                lastExitStatus = extractValue(from: trimmed)
            } else if trimmed.contains("\"Program\"") {
                program = extractValue(from: trimmed)
            } else if trimmed.contains("\"StandardOutPath\"") {
                standardOutPath = extractValue(from: trimmed)
            } else if trimmed.contains("\"StandardErrorPath\"") {
                standardErrorPath = extractValue(from: trimmed)
            }
        }

        guard !label.isEmpty else { return nil }

        return ServiceDetail(
            label: label,
            pid: pid,
            lastExitStatus: lastExitStatus,
            program: program,
            standardOutPath: standardOutPath,
            standardErrorPath: standardErrorPath
        )
    }

    private static func extractValue(from line: String) -> String {
        if let range = line.range(of: "= ") {
            let value = line[range.upperBound...].trimmingCharacters(in: .whitespaces)
            return value.replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: ";", with: "")
        }
        return ""
    }
}
