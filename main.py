import sys
from pathlib import Path
from PySide6.QtCore import QUrl
from PySide6.QtGui import QGuiApplication, QFont
from PySide6.QtQml import QQmlApplicationEngine, qmlRegisterType

from backend import Backend

if __name__ == "__main__":
    app = QGuiApplication(sys.argv)
    app.setFont(QFont("Microsoft YaHei", 9))

    # 注册后端类给QML使用
    qmlRegisterType(Backend, "App.Backend", 1, 0, "Backend")

    engine = QQmlApplicationEngine()
    qml_file = Path(__file__).parent / "qml" / "Main.qml"
    engine.load(QUrl.fromLocalFile(str(qml_file)))

    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec())
