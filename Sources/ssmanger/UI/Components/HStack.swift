import Foundation

/// 水平布局容器，横向排列子组件
struct HStack: Component {
    let children: [Container]
    let spacing: Int

    init(children: [Container], spacing: Int = 1) {
        self.children = children
        self.spacing = spacing
    }

    func render(width: Int, height: Int) -> String {
        guard !children.isEmpty else { return "" }

        // 计算总的 spacing 占用空间
        let totalSpacing = spacing * (children.count - 1)
        // 可用于子组件的宽度
        let availableWidth = max(0, width - totalSpacing)

        // 渲染每个 Container（使用调整后的宽度）
        let outputs = children.map { $0.render(width: availableWidth, height: height) }

        // 横向拼接
        return joinHorizontally(outputs, spacing: spacing)
    }

    /// 横向拼接多个组件的输出
    private func joinHorizontally(_ outputs: [String], spacing: Int) -> String {
        // 将每个输出按行分割
        let allLines = outputs.map { $0.split(separator: "\n", omittingEmptySubsequences: false).map(String.init) }

        // 找出最大行数
        let maxLines = allLines.map { $0.count }.max() ?? 0

        // 逐行拼接
        var result: [String] = []
        for lineIndex in 0..<maxLines {
            var line = ""
            for (index, lines) in allLines.enumerated() {
                // 获取当前行，如果不存在则用空白填充
                let currentLine = lineIndex < lines.count ? lines[lineIndex] : ""
                line += currentLine

                // 添加间距（最后一个组件不需要）
                if index < allLines.count - 1 {
                    line += String(repeating: " ", count: spacing)
                }
            }
            result.append(line)
        }

        return result.joined(separator: "\n")
    }
}
