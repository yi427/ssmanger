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
        case "test_ui":
            testResponsiveUI()
        case "help":
            printUsage()
        default:
            print("错误: 未知命令 '\(command)'")
            printUsage()
            exit(1)
        }
    }

    static func testResponsiveUI() {
        print("响应式 UI 测试 - 调整终端大小查看效果，按 Ctrl+C 退出\n")
        sleep(1)

        // 创建一个组合组件
        struct DemoComponent: Component {
            func render(width: Int, height: Int) -> String {
                let box1 = ResponsiveBox(content: "这个 Box 占据 100% 宽度", title: "全宽 (100%)", width: .auto)
                let box2 = ResponsiveBox(content: "这个 Box 占据 50% 宽度", title: "半宽 (50%)", width: .percent(0.5))
                let box3 = ResponsiveBox(content: "这个 Box 占据 30% 宽度", title: "30%", width: .percent(0.3))
                let box4 = ResponsiveBox(content: "固定 40 字符宽度", title: "固定宽度", width: .fixed(40))

                let output1 = box1.render(width: width, height: height)
                let output2 = box2.render(width: width, height: height)
                let output3 = box3.render(width: width, height: height)
                let output4 = box4.render(width: width, height: height)

                return """
                终端大小: \(width) x \(height)

                \(output1)

                \(output2)

                \(output3)

                \(output4)

                按 Ctrl+C 退出
                """
            }
        }

        let view = ResponsiveView(component: DemoComponent())
        view.start()

        // 保持运行
        RunLoop.main.run()
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
          test_ui            测试响应式 UI（调整终端大小查看效果）
        """)
    }
}

SSManager.main()
