import Foundation

struct ServiceListRenderer {
    static func render(services: [String], directory: String) {
        print("\n" + "Installed Services".bold.cyan)
        print("Directory: \(directory)".gray)
        print("─────────────────────────────────────\n".cyan)

        for service in services {
            print("  • ".cyan + service)
        }

        print("\n" + "Total: \(services.count) services".gray)
    }
}
