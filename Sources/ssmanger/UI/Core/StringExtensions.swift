import Foundation

extension String {
    /// 计算字符串的实际显示宽度（考虑汉字占2个字符宽度）
    var displayWidth: Int {
        var width = 0
        for scalar in unicodeScalars {
            // 跳过 ANSI 转义序列
            if scalar.value == 0x001B {
                continue
            }

            // CJK 字符和全角字符占2个宽度
            if (0x4E00...0x9FFF).contains(scalar.value) ||  // CJK统一汉字
               (0x3400...0x4DBF).contains(scalar.value) ||  // CJK扩展A
               (0x20000...0x2A6DF).contains(scalar.value) || // CJK扩展B
               (0xFF00...0xFFEF).contains(scalar.value) {   // 全角字符
                width += 2
            } else {
                width += 1
            }
        }
        return width
    }

    /// 计算可见字符的显示宽度（去除 ANSI 颜色代码后）
    var visibleDisplayWidth: Int {
        let pattern = "\u{001B}\\[[0-9;]*m"
        let stripped = self.replacingOccurrences(of: pattern, with: "", options: .regularExpression)
        return stripped.displayWidth
    }

    /// 截断字符串到指定显示宽度，超出部分用 ... 替代
    /// 支持 ANSI 颜色代码和汉字，基于实际显示宽度截断
    /// - Parameter maxWidth: 最大显示宽度
    /// - Returns: 截断后的字符串
    func truncate(to maxWidth: Int) -> String {
        if visibleDisplayWidth <= maxWidth {
            return self
        }
        if maxWidth <= 3 {
            return String(prefix(maxWidth))
        }

        var result = ""
        var currentWidth = 0
        var i = startIndex

        while i < endIndex && currentWidth < maxWidth - 3 {
            let char = self[i]

            // 处理 ANSI 转义序列
            if char == "\u{001B}" {
                result.append(char)
                i = index(after: i)
                while i < endIndex {
                    let c = self[i]
                    result.append(c)
                    i = index(after: i)
                    if c == "m" { break }
                }
                continue
            }

            // 计算字符宽度
            let charWidth = String(char).displayWidth
            if currentWidth + charWidth > maxWidth - 3 {
                break
            }

            result.append(char)
            currentWidth += charWidth
            i = index(after: i)
        }

        return result + "..."
    }
}
