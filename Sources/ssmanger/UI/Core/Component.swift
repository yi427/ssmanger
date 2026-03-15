/// UI 组件协议
protocol Component {
    /// 渲染组件，返回终端输出字符串
    /// - Parameters:
    ///   - width: 可用宽度
    ///   - height: 可用高度
    /// - Returns: 渲染后的字符串
    func render(width: Int, height: Int) -> String
}
