import sys
import os
from PySide6.QtCore import QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QResource
from PySide6.QtWidgets import QApplication
# backend imports
from backend.clock import Clock
from backend.settings_manager import SettingsManager
from backend.media_manager import MediaManager
from backend.svg_manager import SVGManager
from backend.obd_manager import OBDManager



app = QApplication(sys.argv)
engine = QQmlApplicationEngine()

engine.addImportPath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "frontend"))


# Settings Manager
settings_manager = SettingsManager()
engine.rootContext().setContextProperty("settingsManager", settings_manager)

# Clock
clock = Clock(settings_manager)  # Modified this line
engine.rootContext().setContextProperty("clock", clock)

# Media Manager
media_manager = MediaManager()
engine.rootContext().setContextProperty("mediaManager", media_manager)

# SVG Manager
svg_manager = SVGManager()
engine.rootContext().setContextProperty("svgManager", svg_manager)

# OBD Manager
obd_manager = OBDManager()
engine.rootContext().setContextProperty("obdManager", obd_manager)

# Add the cleanup connection after creating media_manager:
app.aboutToQuit.connect(media_manager._clear_temp_files)

# Update the path to Main.qml
qml_file = os.path.join(os.path.dirname(os.path.abspath(__file__)), "frontend", "Main.qml")
engine.load(QUrl.fromLocalFile(qml_file))

if not engine.rootObjects():
    sys.exit(-1)

sys.exit(app.exec())