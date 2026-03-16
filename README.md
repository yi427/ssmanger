# SSManager

一个现代化的 macOS 系统服务管理工具，使用 Swift 编写，提供简洁友好的命令行界面。

## 功能特性

- 🚀 启动/停止/重启 LaunchAgent 服务
- 📊 交互式服务列表，支持分页浏览
- 🔍 实时搜索服务名称
- 📋 详细的服务状态信息
- ➕ 交互式创建新服务（使用 DSL 生成 plist）
- 📝 查看服务日志
- 🎨 彩色终端输出，界面美观
- 🔧 智能错误提示，基于 launchctl 退出码映射
- 🖼️ 响应式 UI 系统，支持多种边框样式和布局
- 📐 双栏布局和百分比宽度支持
- 🌏 完整的 CJK 字符支持

## 安装

```bash
swift build -c release
cp .build/release/ssmanger /usr/local/bin/
```

## 使用方法

### 列出所有服务
```bash
ssmanger list
```

列出所有正在运行的服务。

交互式操作：
- `↑`/`↓` - 移动选中行
- `j`/`k` - 翻页
- `Enter` - 查看选中服务的详细状态
- `l` - 查看选中服务的日志
- `/` - 搜索服务
- `q` - 退出

### 列出已安装的服务
```bash
ssmanger list-services
```

列出所有已安装的服务（读取 plist 文件）。

### 启动服务
```bash
ssmanger start <service-name>
```

### 停止服务
```bash
ssmanger stop <service-name>
```

### 重启服务
```bash
ssmanger restart <service-name>
```

### 查看服务状态
```bash
ssmanger status <service-name>
```

### 创建新服务
```bash
ssmanger add <service-name>
```

交互式创建服务，会提示输入：
- 程序路径（必需）
- 程序参数（可选）
- 标准输出日志路径（可选）
- 标准错误日志路径（可选）

支持 `~` 路径展开，sudo 模式下会正确识别实际用户目录。

### 查看服务日志
```bash
ssmanger logs <service-name>
```

显示服务的标准输出和标准错误日志（最后 20 行）。

### UI 演示
```bash
ssmanger test_ui
```

展示响应式 UI 系统的功能：
- 双栏布局（HStack + Container）
- 响应式宽度（百分比和固定宽度）
- 多种边框样式（单线、双线、圆角、粗线）
- 终端大小调整时自动重新渲染

## TODO / Roadmap

### 核心功能扩展
- [ ] **edit** - 编辑现有服务配置
- [ ] **remove** - 删除服务及其 plist 文件
- [x] **logs** - 查看和跟踪服务日志
- [ ] **validate** - 验证 plist 配置和路径

### 高级功能
- [ ] **templates** - 预定义服务模板（HTTP 服务、定时任务等）
- [ ] **schedule** - 友好的定时任务配置（StartCalendarInterval）
- [ ] **batch** - 批量操作和服务分组管理
- [ ] **import/export** - 配置导入导出（JSON/YAML）
- [ ] **health** - 服务健康检查和资源监控
- [ ] **dependencies** - 服务依赖关系管理

## 系统要求

- macOS
- Swift 5.5+

## 许可证

MIT
