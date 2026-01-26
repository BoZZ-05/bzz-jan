# Clipboard Manager

这是一个基于 Swift 开发的 macOS 剪贴板管理工具，实现了以下核心功能：

1.  **自动监听**：后台轮询剪贴板变化，自动记录复制的文本。
2.  **全局热键**：使用 `Cmd + Shift + V` 快速呼出历史记录窗口。
3.  **无边框窗口**：使用 `NSPanel` 实现现代化、轻量级的悬浮窗口。
4.  **自动粘贴**：点击历史记录后，自动将内容粘贴到当前激活的应用程序中。

## 项目结构

*   `Package.swift`: Swift Package Manager 配置文件。
*   `Sources/ClipboardManager`: 源代码目录。
    *   `ClipboardManagerApp.swift`: 应用入口，负责生命周期和窗口管理。
    *   `Model/`: 数据模型。
    *   `Service/`: 核心服务（监听、热键、粘贴）。
    *   `UI/`: SwiftUI 界面视图。

## 运行方式

### 前置要求

*   macOS 13.0 或更高版本。
*   Xcode 14.0 或更高版本（如果使用 Xcode 开发）。
*   需要授予应用 **辅助功能 (Accessibility)** 权限以模拟键盘按键（用于自动粘贴）。

### 使用命令行运行

1.  在终端中进入项目目录：
    ```bash
    cd /Users/yeyuanbozhizhu/Desktop/2026/january/项目1
    ```

2.  编译并运行：
    ```bash
    swift run
    ```
    *(首次运行会拉取 `HotKey` 依赖，可能需要几分钟)*

### 使用 Xcode 开发

1.  在终端中生成 Xcode 项目：
    ```bash
    swift package generate-xcodeproj
    ```
2.  打开生成的 `ClipboardManager.xcodeproj`。
3.  点击运行按钮。

## 注意事项

*   **权限问题**：首次使用自动粘贴功能时，系统可能会拦截。请前往 `系统设置 -> 隐私与安全性 -> 辅助功能`，将 `ClipboardManager`（或终端，如果你是通过终端运行的）添加到允许列表中。
*   **热键冲突**：默认热键为 `Cmd + Shift + V`。如果与其他软件冲突，可以在 `Sources/ClipboardManager/Service/HotKeyService.swift` 中修改。

## 依赖库

*   [HotKey](https://github.com/soffes/HotKey): 用于注册全局快捷键。
