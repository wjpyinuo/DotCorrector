import sys
from pathlib import Path
from PySide6.QtCore import QUrl, QTimer, Qt
from PySide6.QtGui import QGuiApplication, QFont, QSurfaceFormat
from PySide6.QtQml import QQmlApplicationEngine, qmlRegisterType
from PySide6.QtQuick import QQuickWindow

from backend import Backend


if __name__ == "__main__":
    # 启用 alpha 通道（关键：让窗口四角支持逐像素透明）
    fmt = QSurfaceFormat()
    fmt.setAlphaBufferSize(8)
    QSurfaceFormat.setDefaultFormat(fmt)

    app = QGuiApplication(sys.argv)
    app.setFont(QFont("Microsoft YaHei", 9))

    qmlRegisterType(Backend, "App.Backend", 1, 0, "Backend")

    engine = QQmlApplicationEngine()
    qml_file = Path(__file__).parent / "qml" / "Main.qml"
    engine.load(QUrl.fromLocalFile(str(qml_file)))

    if not engine.rootObjects():
        sys.exit(-1)

    root_obj = engine.rootObjects()[0]

    # 设置窗口透明
    if isinstance(root_obj, QQuickWindow):
        root_obj.setColor(Qt.transparent)

    sys.exit(app.exec())
