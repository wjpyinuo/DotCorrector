import sys
import ctypes
from pathlib import Path
from PySide6.QtCore import QUrl, QTimer, Qt
from PySide6.QtGui import QGuiApplication, QFont
from PySide6.QtQml import QQmlApplicationEngine, qmlRegisterType
from PySide6.QtQuick import QQuickWindow

from backend import Backend


def enable_mica(hwnd):
    """Win11 Mica/云母特效"""
    try:
        DWMWA_SYSTEMBACKDROP_TYPE = 38
        DWMSBT_MAINWINDOW = 2  # Mica
        ctypes.windll.dwmapi.DwmSetWindowAttribute(
            hwnd, DWMWA_SYSTEMBACKDROP_TYPE,
            ctypes.byref(ctypes.c_int(DWMSBT_MAINWINDOW)),
            ctypes.sizeof(ctypes.c_int)
        )
    except Exception:
        pass  # 非Win11或失败时静默


def enable_acrylic(hwnd):
    """Win11 Acrylic/亚克力特效"""
    try:
        DWMWA_SYSTEMBACKDROP_TYPE = 38
        DWMSBT_TRANSIENTWINDOW = 3  # Acrylic
        ctypes.windll.dwmapi.DwmSetWindowAttribute(
            hwnd, DWMWA_SYSTEMBACKDROP_TYPE,
            ctypes.byref(ctypes.c_int(DWMSBT_TRANSIENTWINDOW)),
            ctypes.sizeof(ctypes.c_int)
        )
    except Exception:
        pass


if __name__ == "__main__":
    app = QGuiApplication(sys.argv)
    app.setFont(QFont("Microsoft YaHei", 9))

    qmlRegisterType(Backend, "App.Backend", 1, 0, "Backend")

    engine = QQmlApplicationEngine()
    qml_file = Path(__file__).parent / "qml" / "Main.qml"
    engine.load(QUrl.fromLocalFile(str(qml_file)))

    if not engine.rootObjects():
        sys.exit(-1)

    root_obj = engine.rootObjects()[0]

    # 启用窗口透明背景（关键：让 QML 透明区域能穿透到桌面）
    if isinstance(root_obj, QQuickWindow):
        root_obj.setColor(Qt.transparent)

    # 应用 Win11 Mica 特效（延迟调用，等窗口完全创建）
    def apply_mica():
        hwnd = int(root_obj.winId())
        enable_mica(hwnd)

    QTimer.singleShot(100, apply_mica)

    sys.exit(app.exec())
