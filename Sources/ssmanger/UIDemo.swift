import Foundation

/// UI 演示 - 展示响应式布局和双栏布局
func testResponsiveUI() {
    print("UI 演示 - 调整终端大小查看效果，按 Ctrl+C 退出\n")
    sleep(1)

    struct UIDemo: Component {
        func render(width: Int, height: Int) -> String {
            // 双栏布局演示
            let leftBox = Box(
                content: "左侧栏位\n\n这是左侧的内容\n占据 50% 宽度",
                title: "左栏 (50%)",
                style: BoxStyle(border: .double, borderColor: ANSIColor.cyan)
            )

            let rightBox = Box(
                content: "右侧栏位\n\n这是右侧的内容\n占据 50% 宽度",
                title: "右栏 (50%)",
                style: BoxStyle(border: .double, borderColor: ANSIColor.magenta)
            )

            let twoColumn = HStack(children: [
                Container(child: leftBox, width: .percent(0.5)),
                Container(child: rightBox, width: .percent(0.5))
            ])

            // 响应式宽度演示
            let box1 = ResponsiveBox(content: "100% 宽度", title: "全宽", width: .auto)
            let box2 = ResponsiveBox(content: "50% 宽度", title: "半宽", width: .percent(0.5))
            let box3 = ResponsiveBox(content: "30% 宽度", title: "30%", width: .percent(0.3))

            return """
            终端大小: \(width) x \(height)

            双栏布局演示:
            \(twoColumn.render(width: width, height: height))

            响应式宽度演示:
            \(box1.render(width: width, height: height))

            \(box2.render(width: width, height: height))

            \(box3.render(width: width, height: height))

            按 Ctrl+C 退出
            """
        }
    }

    let view = ResponsiveView(component: UIDemo())
    view.start()

    RunLoop.main.run()
}
