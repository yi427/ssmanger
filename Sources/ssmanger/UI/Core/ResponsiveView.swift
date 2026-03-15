import Foundation

/// 响应式视图，监听终端大小变化并自动重新渲染
class ResponsiveView {
    private let component: Component
    private var isRunning = false

    init(component: Component) {
        self.component = component
    }

    /// 启动响应式渲染
    func start() {
        isRunning = true

        // 监听终端大小变化
        Terminal.shared.onResize { [weak self] _, _ in
            self?.render()
        }

        // 初始渲染
        render()
    }

    /// 停止响应式渲染
    func stop() {
        isRunning = false
    }

    /// 渲染并显示
    private func render() {
        guard isRunning else { return }

        let terminal = Terminal.shared
        let output = component.render(width: terminal.width, height: terminal.height)

        // 清屏并显示
        print("\u{001B}[2J\u{001B}[H\(output)")
        fflush(stdout)
    }
}
