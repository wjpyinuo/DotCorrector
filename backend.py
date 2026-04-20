from PySide6.QtCore import QObject, Signal, Slot, Property, QThread


class CorrectWorker(QThread):
    """模拟纠错耗时任务"""
    progress = Signal(int)
    finished_result = Signal(str)

    def __init__(self, files):
        super().__init__()
        self.files = files

    def run(self):
        import time
        for i in range(101):
            time.sleep(0.02)
            self.progress.emit(i)
        self.finished_result.emit(f"已处理 {len(self.files)} 个文件")


class Backend(QObject):
    progressChanged = Signal(int)
    statusChanged = Signal(str)
    busyChanged = Signal(bool)

    def __init__(self):
        super().__init__()
        self._progress = 0
        self._status = "就绪"
        self._busy = False
        self._worker = None

    # ---- progress 属性 ----
    def _get_progress(self):
        return self._progress

    def _set_progress(self, v):
        if self._progress != v:
            self._progress = v
            self.progressChanged.emit(v)

    progress = Property(int, _get_progress, _set_progress, notify=progressChanged)

    # ---- status 属性 ----
    def _get_status(self):
        return self._status

    def _set_status(self, v):
        if self._status != v:
            self._status = v
            self.statusChanged.emit(v)

    status = Property(str, _get_status, _set_status, notify=statusChanged)

    # ---- busy 属性 ----
    def _get_busy(self):
        return self._busy

    def _set_busy(self, v):
        if self._busy != v:
            self._busy = v
            self.busyChanged.emit(v)

    busy = Property(bool, _get_busy, _set_busy, notify=busyChanged)

    # ---- QML 可调用方法 ----
    @Slot(list)
    def startCorrect(self, files):
        if self._busy:
            return
        self._set_busy(True)
        self._set_status(f"正在处理 {len(files)} 个文件...")
        self._worker = CorrectWorker(files)
        self._worker.progress.connect(self._set_progress)
        self._worker.finished_result.connect(self._on_done)
        self._worker.start()

    def _on_done(self, msg):
        self._set_status(msg)
        self._set_busy(False)
        self._set_progress(0)
