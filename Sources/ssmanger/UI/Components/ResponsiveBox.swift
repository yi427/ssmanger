import Foundation

/// 响应式 Box 组件，支持百分比宽度
struct ResponsiveBox: Component {
    let content: String
    let title: String?
    let widthSize: Size
    let style: BoxStyle

    init(content: String, title: String? = nil, width: Size = .auto, style: BoxStyle = BoxStyle()) {
        self.content = content
        self.title = title
        self.widthSize = width
        self.style = style
    }

    func render(width: Int, height: Int) -> String {
        // 根据 Size 计算实际宽度
        let actualWidth = widthSize.calculate(available: width)

        // 使用 Box 的渲染逻辑
        let box = Box(content: content, title: title, minWidth: actualWidth, style: style)
        return box.render(width: actualWidth, height: height)
    }
}
