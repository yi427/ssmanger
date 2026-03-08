import Foundation

struct SSManager {
    static func main() {
        let args = CommandLine.arguments

        guard args.count >= 2 else {
            printUsage()
            exit(1)
        }

        let command = args[1]

        switch command {
        case "start", "stop", "restart", "status":
            guard args.count >= 3 else {
                print("错误: 需要指定服务名称")
                exit(1)
            }
            let service = args[2]
            ServiceManager.execute(command, service: service)
        case "list":
            ServiceManager.listAll()
        case "list-services":
            ServiceManager.listServices()
        case "add":
            guard args.count >= 3 else {
                print("错误: 需要指定服务名称")
                exit(1)
            }
            let service = args[2]
            ServiceManager.addService(service)
        case "logs":
            guard args.count >= 3 else {
                print("错误: 需要指定服务名称")
                exit(1)
            }
            let service = args[2]
            ServiceManager.showLogs(service)
        case "help":
            printUsage()
        default:
            print("错误: 未知命令 '\(command)'")
            printUsage()
            exit(1)
        }
    }

    static func printUsage() {
        print("""
        用法: ssmanager <命令> [服务名]

        命令:
          start <service>    启动服务
          stop <service>     停止服务
          restart <service>  重启服务
          status <service>   查看服务状态
          list               列出所有运行中的服务
          list-services      列出所有已安装的服务
          add <service>      添加新服务
          logs <service>     查看服务日志
        """)
    }
}

SSManager.main()
