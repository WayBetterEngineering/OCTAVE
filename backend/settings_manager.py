import json
from PySide6.QtCore import QObject, Property, Signal, Slot
import os
from typing import List


class SettingsManager(QObject):
    # Existing signals
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
    uiScaleChanged = Signal(float)
    obdBluetoothPortChanged = Signal(str)
    obdFastModeChanged = Signal(bool)
    obdParametersChanged = Signal()
    mediaFolderChanged = Signal(str)
    showBackgroundOverlayChanged = Signal(bool)
    directoryHistoryChanged = Signal()
    homeOBDParametersChanged = Signal()
    customThemesChanged = Signal() 
    
    def __init__(self):
        super().__init__()
        self.backend_dir = os.path.dirname(os.path.abspath(__file__))
        self.settings_file = os.path.join(self.backend_dir, 'settingsConfigure.json')
        
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
            "uiScale": 1.0,
            "obdBluetoothPort": "/dev/rfcomm0",
            "obdFastMode": True,
            "showBackgroundOverlay": True,
            "fuelTankCapacity": 15.0,  # Add fuel tank capacity setting in gallons
            "obdParameters": {
                "COOLANT_TEMP": True,
                "CONTROL_MODULE_VOLTAGE": True,
                "ENGINE_LOAD": True,
                "THROTTLE_POS": True,
                "INTAKE_TEMP": True,
                "TIMING_ADVANCE": True,
                "MAF": True,
                "SPEED": True,
                "RPM": True,
                "COMMANDED_EQUIV_RATIO": True,
                "FUEL_LEVEL": True,
                "INTAKE_PRESSURE": True,
                "SHORT_FUEL_TRIM_1": True,
                "LONG_FUEL_TRIM_1": True,
                "O2_B1S1": True,
                "FUEL_PRESSURE": True,
                "OIL_TEMP": True,
                "FUEL_ECONOMY": True,
                "DISTANCE_TO_EMPTY": True,
                "IGNITION_TIMING": True,
            },
            "homeOBDParameters": ["SPEED", "RPM", "COOLANT_TEMP", "CONTROL_MODULE_VOLTAGE"],
        }
            
    
        
        self._default_settings["directoryHistory"] = []
            
        # Load settings at startup
        self._settings = self.load_settings()
        
        # Initialize directory history
        self._directory_history = self._settings.get("directoryHistory", [])
            
        # Load settings at startup
        self._settings = self.load_settings()
        
        # Initialize existing settings
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
        self._ui_scale = self._settings.get("uiScale", self._default_settings["uiScale"])
        self._obd_bluetooth_port = self._settings.get("obdBluetoothPort", self._default_settings["obdBluetoothPort"])
        self._obd_fast_mode = self._settings.get("obdFastMode", self._default_settings["obdFastMode"])
        self._media_folder = self._settings.get("mediaFolder", os.path.join(self.backend_dir, 'media'))
        self._show_background_overlay = self._settings.get("showBackgroundOverlay", self._default_settings["showBackgroundOverlay"])
        self._fuel_tank_capacity = self._settings.get("fuelTankCapacity", self._default_settings["fuelTankCapacity"])
        self._home_obd_parameters = self._settings.get("homeOBDParameters", self._default_settings["homeOBDParameters"])


        
        # Handle OBD parameters with a default if not present
        if "obdParameters" in self._settings:
            self._obd_parameters = self._settings["obdParameters"]
            
            # Add any missing parameters from defaults
            for param, value in self._default_settings["obdParameters"].items():
                if param not in self._obd_parameters:
                    self._obd_parameters[param] = value
        else:
            self._obd_parameters = self._default_settings["obdParameters"]
                    
        settings = self.load_settings()
        settings["obdParameters"] = self._obd_parameters
        self.save_settings(settings)
            
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

    @Property(float, notify=uiScaleChanged)
    def uiScale(self):
        return self._ui_scale
    
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
    
    @Property(str, notify=obdBluetoothPortChanged)
    def obdBluetoothPort(self):
        return self._obd_bluetooth_port
    
    @Property(bool, notify=obdFastModeChanged)
    def obdFastMode(self):
        return self._obd_fast_mode
    
    @Property(str, notify=mediaFolderChanged)
    def mediaFolder(self):
        return self._media_folder
    
    @Property(bool, notify=showBackgroundOverlayChanged)
    def showBackgroundOverlay(self):
        return self._show_background_overlay
    
    @Property('QVariantList', notify=directoryHistoryChanged)
    def directoryHistory(self):
        return self._directory_history
    
    @Property('QVariantList', notify=homeOBDParametersChanged)
    def homeOBDParameters(self):
        return self._home_obd_parameters
    
    @Property('QVariantList', notify=customThemesChanged)
    def customThemes(self):
        """Return list of custom theme names"""
        settings = self.load_settings()
        if "customThemes" in settings:
            return list(settings["customThemes"].keys())
        return []

    # Existing save methods
    @Slot(float)
    def save_ui_scale(self, scale):
        print(f"Saving UI scale: {scale}")
        self._ui_scale = scale
        self.update_setting("uiScale", scale, self.uiScaleChanged)
    
    @Slot(int)
    def save_background_blur_radius(self, radius):
        print(f"Saving background blur radius: {radius}")
        self._background_blur_radius = radius
        self.update_setting("backgroundBlurRadius", radius, self.backgroundBlurRadiusChanged)
    
    @Slot(str)
    def save_device_name(self, name):
        print(f"Saving device name: {name}")
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
    
    # New OBD save methods
    @Slot(str)
    def save_obd_bluetooth_port(self, port):
        print(f"Saving OBD Bluetooth port: {port}")
        self._obd_bluetooth_port = port
        self.update_setting("obdBluetoothPort", port, self.obdBluetoothPortChanged)
    
    @Slot(bool)
    def save_obd_fast_mode(self, enabled):
        print(f"Saving OBD fast mode: {enabled}")
        self._obd_fast_mode = enabled
        self.update_setting("obdFastMode", enabled, self.obdFastModeChanged)
    


    @Slot(str, bool)
    def save_obd_parameter_enabled(self, parameter, enabled):
        print(f"Saving OBD parameter {parameter}: {enabled}")
        
        # Load current settings to not overwrite other changes
        settings = self.load_settings()
        
        # Make sure obdParameters exists in settings
        if "obdParameters" not in settings:
            settings["obdParameters"] = {}
        
        # Add or update the parameter in internal state and settings
        self._obd_parameters[parameter] = enabled
        settings["obdParameters"][parameter] = enabled
        
        # Save the updated settings
        self.save_settings(settings)
        
        # Emit the change signal
        self.obdParametersChanged.emit()
        
    # Make sure the get_obd_parameter_enabled method is correct
    @Slot(str, bool, result=bool)
    def get_obd_parameter_enabled(self, parameter, default=True):
        # First check internal state
        if parameter in self._obd_parameters:
            return self._obd_parameters[parameter]
        
        # If not in internal state, check settings file
        settings = self.load_settings()
        if "obdParameters" in settings and parameter in settings["obdParameters"]:
            # Update internal state
            self._obd_parameters[parameter] = settings["obdParameters"][parameter]
            return settings["obdParameters"][parameter]
        
        # If parameter doesn't exist yet, add it with default value
        self._obd_parameters[parameter] = default
        
        # Save to settings
        settings = self.load_settings()
        if "obdParameters" not in settings:
            settings["obdParameters"] = {}
        settings["obdParameters"][parameter] = default
        self.save_settings(settings)
        
        return default

    @Slot(str)
    def save_media_folder(self, folder_path):
        print(f"Saving media folder path: {folder_path}")
        self._media_folder = folder_path
        self.update_setting("mediaFolder", folder_path, self.mediaFolderChanged)
        
    @Slot(bool)
    def save_show_background_overlay(self, show):
        print(f"Saving show background overlay setting: {show}")
        self._show_background_overlay = show
        self.update_setting("showBackgroundOverlay", show, self.showBackgroundOverlayChanged)
        
    # Add new signal for fuel tank capacity
    fuelTankCapacityChanged = Signal(float)

    # Add property for fuel tank capacity
    @Property(float, notify=fuelTankCapacityChanged)
    def fuelTankCapacity(self):
        return self._fuel_tank_capacity

    # Add a method to save fuel tank capacity
    @Slot(float)
    def save_fuel_tank_capacity(self, capacity):
        print(f"Saving fuel tank capacity: {capacity}")
        self._fuel_tank_capacity = capacity
        self.update_setting("fuelTankCapacity", capacity, self.fuelTankCapacityChanged)
        
    @Slot(str)
    def save_to_directory_history(self, folder_path):
        print(f"Adding directory to history: {folder_path}")
        # Don't add duplicates
        if folder_path not in self._directory_history:
            # Add to the beginning of the list
            self._directory_history.insert(0, folder_path)
            
            # Limit the number of saved directories to 10
            if len(self._directory_history) > 10:
                self._directory_history = self._directory_history[:10]
                
            # Save to settings
            settings = self.load_settings()
            settings["directoryHistory"] = self._directory_history
            self.save_settings(settings)
            
            # Emit signal
            self.directoryHistoryChanged.emit()

    @Slot(str)
    def remove_from_directory_history(self, folder_path):
        print(f"Removing directory from history: {folder_path}")
        if folder_path in self._directory_history:
            self._directory_history.remove(folder_path)
            
            # Save to settings
            settings = self.load_settings()
            settings["directoryHistory"] = self._directory_history
            self.save_settings(settings)
            
            # Emit signal
            self.directoryHistoryChanged.emit()

    @Slot(result='QVariantList')
    def get_directory_history(self):
        return self._directory_history
    
    @Slot('QVariantList')
    def save_home_obd_parameters(self, parameters):
        print(f"Saving home OBD parameters: {parameters}")
        self._home_obd_parameters = parameters
        self.update_setting("homeOBDParameters", parameters, self.homeOBDParametersChanged)

    @Slot('QVariantList')
    def save_home_obd_parameters(self, parameters):
        print(f"Saving home OBD parameters: {parameters}")
        self._home_obd_parameters = parameters
        
        # Update the settings file
        settings = self.load_settings()
        settings["homeOBDParameters"] = parameters
        self.save_settings(settings)
        
        # Emit signal WITHOUT parameters
        self.homeOBDParametersChanged.emit()  # Don't pass any parameters here
        
    @Slot(result='QVariantList')
    def get_home_obd_parameters(self):
        """Return the list of OBD parameters to display on home screen"""
        return self._home_obd_parameters
    
    @Slot(str, str)
    def save_custom_theme(self, name, theme_json):
        """Save a custom theme with the given name"""
        print(f"Saving custom theme: {name}")
        
        # Load current settings to not overwrite other changes
        settings = self.load_settings()
        
        # Make sure customThemes exists in settings
        if "customThemes" not in settings:
            settings["customThemes"] = {}
        
        # Parse the theme from JSON
        theme_obj = json.loads(theme_json)
        
        # Save the theme
        settings["customThemes"][name] = theme_obj
        
        # Save the updated settings
        self.save_settings(settings)
        
        # Emit the change signal
        self.customThemesChanged.emit()
        
    @Slot(str, result=str)
    def get_custom_theme(self, name):
        """Get a custom theme by name as JSON string"""
        settings = self.load_settings()
        if "customThemes" in settings and name in settings["customThemes"]:
            return json.dumps(settings["customThemes"][name])
        return "{}"

    @Slot(str)
    def delete_custom_theme(self, name):
        """Delete a custom theme by name"""
        settings = self.load_settings()
        if "customThemes" in settings and name in settings["customThemes"]:
            del settings["customThemes"][name]
            self.save_settings(settings)
            self.customThemesChanged.emit()

    @Slot()
    def reset_to_defaults(self):
        # Save default settings
        self.save_settings(self._default_settings)
        
        # Reset existing settings
        self._device_name = self._default_settings["deviceName"]
        self.deviceNameChanged.emit(self._device_name)
        
        self._theme_setting = self._default_settings["themeSetting"]
        self.themeSettingChanged.emit(self._theme_setting)
        
        self._start_volume = self._default_settings["startUpVolume"]
        self.startUpVolumeChanged.emit(self._start_volume)
        
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
        
        self._ui_scale = self._default_settings["uiScale"]
        self.uiScaleChanged.emit(self._ui_scale)
        
        self._obd_bluetooth_port = self._default_settings["obdBluetoothPort"]
        self.obdBluetoothPortChanged.emit(self._obd_bluetooth_port)
        
        self._obd_fast_mode = self._default_settings["obdFastMode"]
        self.obdFastModeChanged.emit(self._obd_fast_mode)
        
        self._obd_parameters = self._default_settings["obdParameters"]
        self.obdParametersChanged.emit()
        
        self._media_folder = self._default_settings["mediaFolder"]
        self.mediaFolderChanged.emit(self._media_folder)

        self._show_background_overlay = self._default_settings["showBackgroundOverlay"]
        self.showBackgroundOverlayChanged.emit(self._show_background_overlay)
        
        self._fuel_tank_capacity = self._default_settings["fuelTankCapacity"]
        self.fuelTankCapacityChanged.emit(self._fuel_tank_capacity)
            
