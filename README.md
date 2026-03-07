# SSManager

一个现代化的 macOS 系统服务管理工具，使用 Swift 编写，提供简洁友好的命令行界面。

## 功能特性

- 🚀 启动/停止/重启 LaunchAgent 服务
- 📊 交互式服务列表，支持分页浏览
- 🔍 实时搜索服务名称
- 📋 详细的服务状态信息
- ➕ 交互式创建新服务
- 🎨 彩色终端输出，界面美观

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

交互式操作：
- `j` 或 `↓` - 下一页
- `k` 或 `↑` - 上一页
- `/` - 搜索服务
- `ESC` - 清除搜索
- `q` - 退出

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

## 系统要求

- macOS
- Swift 5.5+

## 许可证

MIT
