import json
from PySide6.QtCore import QObject, Property, Signal, Slot
import os

class SettingsManager(QObject):
    # Add uiScaleChanged signal
    deviceNameChanged = Signal(str)
    themeSettingChanged = Signal(str)
    startUpVolumeChanged = Signal(str)
    showClockChanged = Signal(bool)
    clockFormatChanged = Signal(bool)
    clockSizeChanged = Signal(int)
    backgroundGridChanged = Signal(str)
    screenWidthChanged = Signal(int)
    screenHeightChanged = Signal(int)
    backgroundBlurRadiusChanged = Signal(int)
    uiScaleChanged = Signal(float)  # New signal for UI scaling
    
    def __init__(self):
        super().__init__()
        self.backend_dir = os.path.dirname(os.path.abspath(__file__))
        self.settings_file = os.path.join(self.backend_dir, 'settingsConfigure.json')
        # Add default value for UI scale
        self._default_settings = {
            "deviceName": "Default Device",
            "themeSetting": "Dark",
            "startUpVolume": 0.1,
            "showClock": True,
            "clockFormat24Hour": True,
            "clockSize": 18,
            "backgroundGrid": "4x4",
            "screenWidth": 1280,
            "screenHeight": 720,
            "backgroundBlurRadius": 40,
            "uiScale": 1.0  # Default UI scale
        }
        
        # Load settings at startup
        self._settings = self.load_settings()
        
        # Initialize all settings
        self._device_name = self._settings.get("deviceName", self._default_settings["deviceName"])
        self._theme_setting = self._settings.get("themeSetting", self._default_settings["themeSetting"])
        self._start_volume = self._settings.get("startUpVolume", self._default_settings["startUpVolume"])
        self._show_clock = self._settings.get("showClock", self._default_settings["showClock"])
        self._clock_format_24hour = self._settings.get("clockFormat24Hour", self._default_settings["clockFormat24Hour"])
        self._clock_size = self._settings.get("clockSize", self._default_settings["clockSize"])
        self._background_grid = self._settings.get("backgroundGrid", self._default_settings["backgroundGrid"])
        self._screen_width = self._settings.get("screenWidth", self._default_settings["screenWidth"])
        self._screen_height = self._settings.get("screenHeight", self._default_settings["screenHeight"])
        self._background_blur_radius = self._settings.get("backgroundBlurRadius", self._default_settings["backgroundBlurRadius"])
        self._ui_scale = self._settings.get("uiScale", self._default_settings["uiScale"])  # Initialize UI scale

    def load_settings(self):
        try:
            with open(self.settings_file, 'r') as f:
                return json.load(f)
        except FileNotFoundError:
            self.save_settings(self._default_settings)
            return self._default_settings

    def save_settings(self, settings):
        with open(self.settings_file, 'w') as f:
            json.dump(settings, f, indent=4)

    def update_setting(self, key, value, signal=None):
        settings = self.load_settings()
        settings[key] = value
        self.save_settings(settings)
        if signal:
            signal.emit(value)

    # Add UI scale property getter
    @Property(float, notify=uiScaleChanged)
    def uiScale(self):
        return self._ui_scale
    
    # Existing getters
    @Property(int, notify=backgroundBlurRadiusChanged)
    def backgroundBlurRadius(self):
        return self._background_blur_radius
    
    @Property(str, notify=deviceNameChanged)
    def deviceName(self):
        return self._device_name
    
    @Property(str, notify=themeSettingChanged)
    def themeSetting(self):
        return self._theme_setting

    @Property(float, notify=startUpVolumeChanged)
    def startUpVolume(self):
        return self._start_volume
    
    @Property(bool, notify=showClockChanged)
    def showClock(self):
        return self._show_clock
    
    @Property(bool, notify=clockFormatChanged)
    def clockFormat24Hour(self):
        return self._clock_format_24hour
    
    @Property(int, notify=clockSizeChanged)
    def clockSize(self):
        return self._clock_size
    
    @Property(str, notify=backgroundGridChanged)
    def backgroundGrid(self):
        return self._background_grid
    
    @Property(int, notify=screenWidthChanged)
    def screenWidth(self):
        return self._screen_width

    @Property(int, notify=screenHeightChanged)
    def screenHeight(self):
        return self._screen_height

    # Add save method for UI scale
    @Slot(float)
    def save_ui_scale(self, scale):
        print(f"Saving UI scale: {scale}")
        self._ui_scale = scale
        self.update_setting("uiScale", scale, self.uiScaleChanged)
    
    # Existing save methods
    @Slot(int)
    def save_background_blur_radius(self, radius):
        print(f"Saving background blur radius: {radius}")
        self._background_blur_radius = radius
        self.update_setting("backgroundBlurRadius", radius, self.backgroundBlurRadiusChanged)
    
    @Slot(str)
    def save_device_name(self, name):
        print(f"Saving device name: {name}")  # Fixed the log message
        self._device_name = name
        self.update_setting("deviceName", name, self.deviceNameChanged)
        
    @Slot(str)
    def save_theme_setting(self, theme):
        print(f"Saving theme setting: {theme}")
        self._theme_setting = theme
        self.update_setting("themeSetting", theme, self.themeSettingChanged)
        
    @Slot(float)
    def save_start_volume(self, volume):
        print(f"Saving volume setting: {volume}")
        self._start_volume = volume
        self.update_setting("startUpVolume", volume, self.startUpVolumeChanged)
        
    @Slot(bool)
    def save_show_clock(self, show):
        print(f"Saving show clock setting: {show}")
        self._show_clock = show
        self.update_setting("showClock", show, self.showClockChanged)

    @Slot(bool)
    def save_clock_format(self, is_24hour):
        print(f"Saving clock format setting: {is_24hour}")
        self._clock_format_24hour = is_24hour
        self.update_setting("clockFormat24Hour", is_24hour, self.clockFormatChanged)

    @Slot(int)
    def save_clock_size(self, size):
        print(f"Saving clock size setting: {size}")
        self._clock_size = size
        self.update_setting("clockSize", size, self.clockSizeChanged)
        
    @Slot(str)
    def save_background_grid(self, grid_setting):
        print(f"Saving background grid setting: {grid_setting}")
        self._background_grid = grid_setting
        self.update_setting("backgroundGrid", grid_setting, self.backgroundGridChanged)
        
    @Slot(int)
    def save_screen_width(self, width):
        print(f"Saving screen width: {width}")
        self._screen_width = width
        self.update_setting("screenWidth", width, self.screenWidthChanged)

    @Slot(int)
    def save_screen_height(self, height):
        print(f"Saving screen height: {height}")
        self._screen_height = height
        self.update_setting("screenHeight", height, self.screenHeightChanged)

    @Slot()
    def reset_to_defaults(self):
        self.save_settings(self._default_settings)
        
        self._device_name = self._default_settings["deviceName"]
        self.deviceNameChanged.emit(self._device_name)
        
        self._theme_setting = self._default_settings["themeSetting"]
        self.themeSettingChanged.emit(self._theme_setting)
        
        self._start_volume = self._default_settings["startUpVolume"]
        self.startUpVolumeChanged.emit(self._start_volume)  # Fixed typo in signal name
        
        self._show_clock = self._default_settings["showClock"]
        self.showClockChanged.emit(self._show_clock)
        
        self._clock_format_24hour = self._default_settings["clockFormat24Hour"]
        self.clockFormatChanged.emit(self._clock_format_24hour)
        
        self._clock_size = self._default_settings["clockSize"]
        self.clockSizeChanged.emit(self._clock_size)
        
        self._background_grid = self._default_settings["backgroundGrid"]
        self.backgroundGridChanged.emit(self._background_grid)
                
        self._screen_width = self._default_settings["screenWidth"]
        self.screenWidthChanged.emit(self._screen_width)
        
        self._screen_height = self._default_settings["screenHeight"]
        self.screenHeightChanged.emit(self._screen_height)
        
        self._background_blur_radius = self._default_settings["backgroundBlurRadius"]
        self.backgroundBlurRadiusChanged.emit(self._background_blur_radius)
        
        # Reset UI scale
        self._ui_scale = self._default_settings["uiScale"]
        self.uiScaleChanged.emit(self._ui_scale)