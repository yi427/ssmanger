import Foundation

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

/// 终端管理类，负责获取终端大小和监听变化
final class Terminal: @unchecked Sendable {
    static let shared = Terminal()

    private(set) var width: Int = 80
    private(set) var height: Int = 24

    private var onResizeCallbacks: [(Int, Int) -> Void] = []

    private init() {
        updateSize()
        setupResizeHandler()
    }

    /// 获取当前终端大小
    func updateSize() {
        var w = winsize()
        if ioctl(STDOUT_FILENO, TIOCGWINSZ, &w) == 0 {
            width = Int(w.ws_col)
            height = Int(w.ws_row)
            notifyResize()
        }
    }

    /// 注册终端大小变化回调
    func onResize(_ callback: @escaping (Int, Int) -> Void) {
        onResizeCallbacks.append(callback)
    }

    /// 手动触发大小变化（用于测试）
    func triggerResize(width: Int, height: Int) {
        self.width = width
        self.height = height
        notifyResize()
    }

    /// 设置 SIGWINCH 信号处理
    private func setupResizeHandler() {
        signal(SIGWINCH) { _ in
            Terminal.shared.updateSize()
        }
    }

    private func notifyResize() {
        for callback in onResizeCallbacks {
            callback(width, height)
        }
    }
}
