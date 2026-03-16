import Foundation

/// 容器组件，为子组件提供虚拟终端环境
struct Container: Component {
    let child: Component
    let width: Size
    let height: Size?

    init(child: Component, width: Size = .auto, height: Size? = nil) {
        self.child = child
        self.width = width
        self.height = height
    }

    func render(width: Int, height: Int) -> String {
        // 计算虚拟终端的尺寸
        let virtualWidth = self.width.calculate(available: width)
        let virtualHeight = self.height?.calculate(available: height) ?? height

        // 子组件在虚拟终端中渲染
        let childOutput = child.render(width: virtualWidth, height: virtualHeight)

        // 填充到虚拟终端尺寸
        return fillToSize(childOutput, width: virtualWidth, height: virtualHeight)
    }

    /// 将输出填充到指定宽度
    private func fillToSize(_ output: String, width: Int, height: Int) -> String {
        let lines = output.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)

        var result: [String] = []

        // 只填充宽度，不填充高度
        for line in lines {
            let lineWidth = line.visibleDisplayWidth
            let padding = max(0, width - lineWidth)
            result.append(line + String(repeating: " ", count: padding))
        }

        return result.joined(separator: "\n")
    }
}
