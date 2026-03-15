import Foundation

/// 边框容器组件
struct Box: Component {
    let content: String
    let title: String?
    let minWidth: Int
    let style: BoxStyle

    init(content: String, title: String? = nil, minWidth: Int = 0, style: BoxStyle = BoxStyle()) {
        self.content = content
        self.title = title
        self.minWidth = minWidth
        self.style = style
    }

    func render(width: Int, height: Int) -> String {
        let lines = content.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        let chars = style.border.chars

        // 计算内容最大宽度（使用显示宽度）
        let contentWidth = lines.map { $0.visibleDisplayWidth }.max() ?? 0
        let titleWidth = title?.displayWidth ?? 0
        let innerPadding = style.padding * 2
        let boxWidth = max(minWidth, min(width, max(contentWidth + innerPadding + 2, titleWidth + 6)))

        // 生成顶部边框
        let topBorder = generateTopBorder(boxWidth: boxWidth, chars: chars)

        // 生成内容行
        var result = [topBorder]
        for line in lines {
            result.append(generateContentLine(line: line, boxWidth: boxWidth, chars: chars))
        }

        // 生成底部边框
        let bottomBorder = generateBottomBorder(boxWidth: boxWidth, chars: chars)
        result.append(bottomBorder)

        return result.joined(separator: "\n")
    }

    private func generateTopBorder(boxWidth: Int, chars: (topLeft: String, topRight: String, bottomLeft: String, bottomRight: String, horizontal: String, vertical: String)) -> String {
        let border: String
        if let title = title {
            let coloredTitle = style.titleColor != nil ? title.styled(style.titleColor!) : title
            let titlePart = "\(chars.horizontal) \(coloredTitle) "
            let titlePartWidth = 2 + title.displayWidth + 1
            let remainingWidth = max(0, boxWidth - titlePartWidth - 2)
            border = chars.topLeft + titlePart + String(repeating: chars.horizontal, count: remainingWidth) + chars.topRight
        } else {
            border = chars.topLeft + String(repeating: chars.horizontal, count: boxWidth - 2) + chars.topRight
        }
        return style.borderColor != nil ? border.styled(style.borderColor!) : border
    }

    private func generateBottomBorder(boxWidth: Int, chars: (topLeft: String, topRight: String, bottomLeft: String, bottomRight: String, horizontal: String, vertical: String)) -> String {
        let border = chars.bottomLeft + String(repeating: chars.horizontal, count: boxWidth - 2) + chars.bottomRight
        return style.borderColor != nil ? border.styled(style.borderColor!) : border
    }

    private func generateContentLine(line: String, boxWidth: Int, chars: (topLeft: String, topRight: String, bottomLeft: String, bottomRight: String, horizontal: String, vertical: String)) -> String {
        let innerPadding = style.padding * 2
        let availableWidth = boxWidth - innerPadding - 2
        let truncated = line.truncate(to: availableWidth)
        let contentWidth = truncated.visibleDisplayWidth

        let aligned = alignContent(truncated, contentWidth: contentWidth, availableWidth: availableWidth)
        let leftPad = String(repeating: " ", count: style.padding)
        let rightPad = String(repeating: " ", count: style.padding)

        let vert = style.borderColor != nil ? chars.vertical.styled(style.borderColor!) : chars.vertical
        return vert + leftPad + aligned + rightPad + vert
    }

    private func alignContent(_ text: String, contentWidth: Int, availableWidth: Int) -> String {
        let totalPadding = availableWidth - contentWidth
        switch style.alignment {
        case .left:
            return text + String(repeating: " ", count: max(0, totalPadding))
        case .center:
            let leftPad = totalPadding / 2
            let rightPad = totalPadding - leftPad
            return String(repeating: " ", count: leftPad) + text + String(repeating: " ", count: rightPad)
        case .right:
            return String(repeating: " ", count: max(0, totalPadding)) + text
        }
    }
}
