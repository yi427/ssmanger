import Foundation

/// 尺寸定义，支持固定、百分比和自动三种模式
enum Size {
    case fixed(Int)           // 固定字符数
    case percent(Double)      // 百分比 (0.0 - 1.0)
    case auto                 // 根据内容自动调整

    /// 计算实际尺寸
    /// - Parameter available: 可用空间大小
    /// - Returns: 实际尺寸
    func calculate(available: Int) -> Int {
        switch self {
        case .fixed(let value):
            return value
        case .percent(let ratio):
            return Int(Double(available) * ratio)
        case .auto:
            return available
        }
    }
}
