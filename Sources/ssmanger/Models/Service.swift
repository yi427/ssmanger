import Foundation

struct Service {
    let pid: String
    let status: String
    let label: String

    var isRunning: Bool {
        pid != "-"
    }
}
