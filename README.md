# Clipboard Manager

> 一个优雅、轻量级的 macOS 剪贴板管理工具

[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![macOS](https://img.shields.io/badge/macOS-13%2B-blue.svg)](https://www.apple.com/macos)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

## 截图

暂无截图

## 功能特性

- **全局热键** - 使用 `Cmd + Shift + V` 快速唤起剪贴板历史
- **自动记录** - 后台静默监听剪贴板，自动保存所有复制内容
- **一键粘贴** - 双击历史条目即可自动粘贴到当前应用
- **置顶功能** - 将常用内容置顶，方便随时访问
- **悬浮窗口** - 优雅的悬浮窗设计，可拖动定位
- **历史持久化** - 关闭应用后历史记录不丢失
- **纯原生开发** - 使用 Swift + SwiftUI，占用资源极低

## 安装

### 从 DMG 安装

1. 下载最新的 `ClipboardManager.dmg`
2. 打开 DMG 文件
3. 将 `ClipboardManager.app` 拖入 **应用程序** 文件夹
4. 双击运行

## 首次运行设置

### 移除隔离属性

由于应用未进行 Apple 开发者签名，首次运行需要移除系统隔离标记：

```bash
sudo xattr -r -d com.apple.quarantine /Applications/ClipboardManager.app
```

### 授予辅助功能权限

应用需要辅助功能权限来实现自动粘贴功能：

1. 打开 **系统设置** → **隐私与安全性** → **辅助功能**
2. 点击锁图标解锁
3. 点击 `+` 按钮，添加 `ClipboardManager`
4. 确保开关已打开

> **注意**：如果更新了应用版本，请先删除列表中的旧条目，再重新添加

## 使用方法

| 操作 | 说明 |
|------|------|
| `Cmd + Shift + V` | 全局唤起/隐藏剪贴板窗口 |
| 双击条目 | 粘贴到当前应用 |
| 点击图钉图标 | 置顶/取消置顶 |
| 点击 X 图标 | 删除条目 |
| 拖动窗口 | 移动悬浮窗位置 |

## 开发构建

### 环境要求

- macOS 13.0+
- Xcode 15.0+
- Swift 5.9+

### 构建步骤

```bash
# 克隆仓库
git clone https://github.com/BoZZ-05/bzz-jan.git
cd bzz-jan

# 构建应用
swift build

# 运行应用
swift run ClipboardManager
```

### 打包 DMG

```bash
# 赋予打包脚本执行权限
chmod +x package_app.sh

# 执行打包
./package_app.sh
```

生成的 DMG 文件位于项目根目录。

## 技术栈

- **Swift** - 主要编程语言
- **SwiftUI** - 用户界面框架
- **AppKit** - 原生 macOS API
- **Combine** - 响应式编程
- **HotKey** - 全局热键支持

## 项目结构

```
Sources/ClipboardManager/
├── ClipboardManagerApp.swift    # 应用入口
├── Model/
│   └── ClipboardItem.swift      # 数据模型
├── Service/
│   ├── ClipboardMonitor.swift   # 剪贴板监控
│   ├── PasteService.swift       # 粘贴服务
│   └── HotKeyService.swift      # 热键服务
└── UI/
    ├── HistoryView.swift        # 历史记录视图
    └── FloatingPanel.swift      # 悬浮窗口
```

## 常见问题

**Q: 为什么粘贴功能不工作？**

A: 请确保已授予辅助功能权限。如果已经授权但仍不工作，请在系统设置中删除应用的辅助功能条目，然后重新添加。

**Q: 应用会在哪里存储历史记录？**

A: 历史记录存储在 `~/.clipboard_manager_history.json` 文件中。

**Q: 支持图片和文件吗？**

A: 目前仅支持文本内容。

## 贡献

欢迎提交 Issue 和 Pull Request！

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

## 致谢

- [HotKey](https://github.com/soffes/HotKey) - 优雅的全局热键库

---

Made with ❤️ by [BoZZ-05](https://github.com/BoZZ-05)
