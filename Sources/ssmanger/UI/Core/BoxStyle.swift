import Foundation

/// 边框样式
enum BorderStyle {
    case single   // 单线 ┌─┐│└┘
    case double   // 双线 ╔═╗║╚╝
    case rounded  // 圆角 ╭─╮│╰╯
    case bold     // 粗线 ┏━┓┃┗┛

    var chars: (topLeft: String, topRight: String, bottomLeft: String, bottomRight: String, horizontal: String, vertical: String) {
        switch self {
        case .single:
            return ("┌", "┐", "└", "┘", "─", "│")
        case .double:
            return ("╔", "╗", "╚", "╝", "═", "║")
        case .rounded:
            return ("╭", "╮", "╰", "╯", "─", "│")
        case .bold:
            return ("┏", "┓", "┗", "┛", "━", "┃")
        }
    }
}

/// 对齐方式
enum Alignment {
    case left
    case center
    case right
}

/// Box 样式配置
struct BoxStyle {
    let border: BorderStyle
    let alignment: Alignment
    let padding: Int
    let borderColor: String?
    let titleColor: String?

    init(
        border: BorderStyle = .single,
        alignment: Alignment = .left,
        padding: Int = 1,
        borderColor: String? = nil,
        titleColor: String? = nil
    ) {
        self.border = border
        self.alignment = alignment
        self.padding = padding
        self.borderColor = borderColor
        self.titleColor = titleColor
    }
}
