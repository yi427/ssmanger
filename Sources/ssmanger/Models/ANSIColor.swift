import Foundation

enum ANSIColor {
    static let green = "\u{001B}[92m"
    static let cyan = "\u{001B}[96m"
    static let blue = "\u{001B}[94m"
    static let red = "\u{001B}[91m"
    static let gray = "\u{001B}[90m"
    static let magenta = "\u{001B}[95m"
    static let yellow = "\u{001B}[93m"

    static let bold = "\u{001B}[1m"
    static let reset = "\u{001B}[0m"

    static func styled(_ text: String, _ styles: String...) -> String {
        let combined = styles.joined()
        return "\(combined)\(text)\(reset)"
    }
}

extension String {
    func styled(_ styles: String...) -> String {
        let combined = styles.joined()
        return "\(combined)\(self)\(ANSIColor.reset)"
    }

    var green: String { styled(ANSIColor.green) }
    var cyan: String { styled(ANSIColor.cyan) }
    var blue: String { styled(ANSIColor.blue) }
    var red: String { styled(ANSIColor.red) }
    var gray: String { styled(ANSIColor.gray) }
    var magenta: String { styled(ANSIColor.magenta) }
    var yellow: String { styled(ANSIColor.yellow) }
    var bold: String { styled(ANSIColor.bold) }

    var visibleLength: Int {
        let pattern = "\u{001B}\\[[0-9;]*m"
        let stripped = self.replacingOccurrences(of: pattern, with: "", options: .regularExpression)
        return stripped.count
    }

    func paddedToWidth(_ width: Int) -> String {
        let visible = self.visibleLength
        let padding = max(0, width - visible)
        return self + String(repeating: " ", count: padding)
    }
}
