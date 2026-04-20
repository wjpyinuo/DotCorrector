import sys
import ctypes
from pathlib import Path
from PySide6.QtCore import QUrl
from PySide6.QtGui import QGuiApplication, QFont
from PySide6.QtQml import QQmlApplicationEngine, qmlRegisterType

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

    # 应用 Win11 Mica 特效
    root_obj = engine.rootObjects()[0]
    hwnd = int(root_obj.winId())
    enable_mica(hwnd)

    sys.exit(app.exec())
