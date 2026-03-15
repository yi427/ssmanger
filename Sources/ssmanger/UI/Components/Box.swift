import Foundation

/// 边框容器组件
struct Box: Component {
    let content: String
    let title: String?
    let minWidth: Int

    init(content: String, title: String? = nil, minWidth: Int = 0) {
        self.content = content
        self.title = title
        self.minWidth = minWidth
    }

    func render(width: Int, height: Int) -> String {
        let lines = content.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)

        // 计算内容最大宽度（使用显示宽度）
        let contentWidth = lines.map { $0.visibleDisplayWidth }.max() ?? 0
        let titleWidth = title?.displayWidth ?? 0
        let boxWidth = max(minWidth, min(width, max(contentWidth + 4, titleWidth + 6)))

        // 生成顶部边框
        let topBorder: String
        if let title = title {
            let titlePart = "─ \(title) "
            let titlePartWidth = 2 + title.displayWidth + 1  // "─ " + title + " "
            let remainingWidth = max(0, boxWidth - titlePartWidth - 2)
            topBorder = "┌" + titlePart + String(repeating: "─", count: remainingWidth) + "┐"
        } else {
            topBorder = "┌" + String(repeating: "─", count: boxWidth - 2) + "┐"
        }

        // 生成内容行
        var result = [topBorder]
        for line in lines {
            let truncated = line.truncate(to: boxWidth - 4)
            let padding = String(repeating: " ", count: boxWidth - truncated.visibleDisplayWidth - 4)
            result.append("│ \(truncated)\(padding) │")
        }

        // 生成底部边框
        let bottomBorder = "└" + String(repeating: "─", count: boxWidth - 2) + "┘"
        result.append(bottomBorder)

        return result.joined(separator: "\n")
    }
}
