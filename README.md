# 墨正 DotCorrector

一键多格式文件错别字纠正工具，保留原排版。

## 功能

- 📂 支持 docx / xlsx / pptx / txt 格式
- 🎨 异形渐变动画窗口（PySide6 + QML）
- 🖱️ 文件拖拽批量处理
- 🌗 深色/浅色主题切换
- 🪟 Win11 Mica 亚克力特效
- 📐 窗口边缘自由缩放
- ⚡ 本地纠错 + AI 精校（可选）

## 技术栈

- Python + PySide6 + QML
- python-docx / openpyxl / python-pptx（文件解析）
- 错别字词典 + pycorrector（本地纠错）
- 大模型 API（AI 精校）

## 运行

```bash
pip install PySide6
python main.py
```

## 项目结构

```
corrector_app/
├── main.py              # Python 入口 + DWM 特效
├── backend.py           # 业务桥接类
└── qml/
    ├── Main.qml         # 主窗口 + 主题系统 + 页面路由
    ├── FileDropZone.qml # 文件拖拽区
    ├── TitleBar.qml     # 自定义标题栏
    ├── GlowButton.qml   # 发光按钮
    ├── WinButton.qml    # 窗口按钮
    ├── SettingsPage.qml # 设置页
    └── ToggleSwitch.qml # 开关组件
```

## License

MIT
