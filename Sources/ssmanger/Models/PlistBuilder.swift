import Foundation

class PlistBuilder {
    private var lines: [String] = []

    private func indent(_ level: Int) -> String {
        String(repeating: "    ", count: level)
    }


    @discardableResult
    func header() -> PlistBuilder {
        lines.append("""
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        """)
        return self
    }

    @discardableResult
    func dict(_ level: Int, _ content: (PlistBuilder) -> Void) -> PlistBuilder {
        lines.append(indent(level) + "<dict>")
        content(self)
        lines.append(indent(level) + "</dict>")
        return self
    }

    @discardableResult
    func key(_ content: String, _ level: Int) -> PlistBuilder {
        lines.append(indent(level) + "<key>\(content)</key>")
        return self
    }

    @discardableResult
    func string(_ content: String, _ level: Int) -> PlistBuilder {
        lines.append(indent(level) + "<string>\(content)</string>")
        return self
    }

    @discardableResult
    func array(_ level: Int, _ content: (PlistBuilder) -> Void) -> PlistBuilder {
        lines.append(indent(level) + "<array>")
        content(self)
        lines.append(indent(level) + "</array>")
        return self
    }

    @discardableResult
    func `true`(_ level: Int) -> PlistBuilder {
        lines.append(indent(level) + "<true/>")
        return self
    }

    @discardableResult
    func plist(_ level: Int = 0, _ content: (PlistBuilder) -> Void) -> PlistBuilder {
        lines.append(indent(level) + "<plist version=\"1.0\">")
        content(self)
        lines.append(indent(level) + "</plist>")
        return self
    }

    func build() -> String {
        lines.joined(separator: "\n")
    }
}
