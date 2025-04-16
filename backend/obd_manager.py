from PySide6.QtCore import QObject, Signal, Slot
import obd
from obd import OBDStatus
import time
import os
import threading

class OBDManager(QObject):
    # Original Signals
    coolantTempChanged = Signal(float)
    voltageChanged = Signal(float)
    engineLoadChanged = Signal(float)
    throttlePositionChanged = Signal(float)
    intakeAirTempChanged = Signal(float)
    timingAdvanceChanged = Signal(float)
    massAirFlowChanged = Signal(float)
    speedMPHChanged = Signal(float)
    rpmChanged = Signal(float)
    airFuelRatioChanged = Signal(float)
    connectionStatusChanged = Signal(str)
    fuelLevelChanged = Signal(float)
    intakeManifoldPressureChanged = Signal(float)
    shortTermFuelTrimChanged = Signal(float)
    longTermFuelTrimChanged = Signal(float)
    oxygenSensorVoltageChanged = Signal(float)
    fuelPressureChanged = Signal(float)
    engineOilTempChanged = Signal(float)
    ignitionTimingChanged = Signal(float)
    connectionStatusChanged = Signal(str)
    connectionStatusDetailChanged = Signal(str)
    connectionProgressChanged = Signal(int)  # 0-100 for progress indication
    devicePresenceChanged = Signal(bool)

    def __init__(self, settings_manager=None):
        super().__init__()
        self._connection = None
        self._connected = False
        self._settings_manager = settings_manager
        
        # Original values
        self._coolant_temp = 0.0
        self._voltage = 0.0
        self._engine_load = 0.0
        self._throttle_pos = 0.0
        self._intake_temp = 0.0
        self._timing_advance = 0.0
        self._mass_airflow = 0.0
        self._speed_mph = 0.0
        self._rpm = 0.0
        self._air_fuel_ratio = 0.0
        
        # New values for added parameters (removed fuel economy related)
        self._fuel_level = 0.0
        self._intake_pressure = 0.0
        self._short_term_fuel_trim = 0.0
        self._long_term_fuel_trim = 0.0
        self._o2_sensor_voltage = 0.0
        self._fuel_pressure = 0.0
        self._oil_temp = 0.0
        self._ignition_timing = 0.0
        
        self._connection_attempts = 0
        self._max_connection_attempts = 5
        
        # Detailed connection status
        self._connection_status = "Not Connected"
        self._connection_detail = "No connection attempt yet"
        
        # Flag to detect if connection process is already running
        self._is_connecting = False
        
        # Connection monitor thread
        self._monitor_thread = None
        self._stop_monitor = False
        
        # Original values and signals remain the same...
        
        # Try to establish connection
        self._connect()
        
        # Connect to settings changes if a settings manager is provided
        if self._settings_manager:
            self._settings_manager.obdBluetoothPortChanged.connect(self.reconnect)
            self._settings_manager.obdFastModeChanged.connect(self.reconnect)
            self._settings_manager.obdParametersChanged.connect(self.reconnect)
        
        # Try to establish connection
        self._connect()

    def _connect(self):
        # Don't start a new connection attempt if one is already in progress
        if self._is_connecting:
            self.connectionStatusDetailChanged.emit("Connection attempt already in progress")
            return
            
        self._is_connecting = True
        self._connection_attempts += 1
        
        try:
            # Reset connection status
            self._connected = False
            self.connectionStatusChanged.emit("Connecting")
            self.connectionStatusDetailChanged.emit(f"Attempt {self._connection_attempts}/{self._max_connection_attempts}")
            self.connectionProgressChanged.emit(10)
            
            # Use settings values if available, otherwise use defaults
            port = "/dev/rfcomm0"
            fast_mode = True
            
            if self._settings_manager:
                port = self._settings_manager.obdBluetoothPort
                fast_mode = self._settings_manager.obdFastMode
            
            # Check if device exists
            if not os.path.exists(port):
                self._connected = False
                self.connectionStatusChanged.emit("Device Not Found")
                self.connectionStatusDetailChanged.emit(f"Port {port} not available")
                self.connectionProgressChanged.emit(0)
                self.devicePresenceChanged.emit(False)
                print(f"OBD device port {port} not found. Skipping connection attempt.")
                self._is_connecting = False
                return
                
            self.devicePresenceChanged.emit(True)
            self.connectionProgressChanged.emit(30)
            self.connectionStatusDetailChanged.emit("Device found. Connecting...")
            
            print(f"Connecting to OBD on port {port} with fast_mode={fast_mode}")
            
            # Set a reasonable timeout for connection
            connection_timeout = 10  # seconds
            
            # Create the connection with timeout
            self._connection = obd.Async(portstr=port, fast=fast_mode, timeout=connection_timeout)
            self.connectionProgressChanged.emit(60)
            
            if self._connection.status() == OBDStatus.CAR_CONNECTED:
                self._connected = True
                self._connection_attempts = 0  # Reset counter on successful connection
                self.connectionStatusChanged.emit("Connected")
                self.connectionStatusDetailChanged.emit("OBD interface connected successfully")
                self.connectionProgressChanged.emit(100)
                
                # Set up watchers for each parameter
                self._setup_watchers()
                
                # Start watching
                self._connection.start()
                
                # Start connection monitor thread
                self._start_connection_monitor()
            else:
                self._connected = False
                status_message = "Connection Failed"
                detail_message = f"Status: {self._connection.status()}"
                
                if self._connection.status() == OBDStatus.NOT_CONNECTED:
                    detail_message = "Could not connect to OBD adapter"
                elif self._connection.status() == OBDStatus.ELM_CONNECTED:
                    detail_message = "Connected to adapter but not to vehicle"
                    status_message = "No Vehicle"
                
                self.connectionStatusChanged.emit(status_message)
                self.connectionStatusDetailChanged.emit(detail_message)
                self.connectionProgressChanged.emit(0)
                
        except Exception as e:
            print(f"OBD Connection error: {e}")
            self._connected = False
            self.connectionStatusChanged.emit("Error")
            self.connectionStatusDetailChanged.emit(f"Error: {str(e)}")
            self.connectionProgressChanged.emit(0)
        
        self._is_connecting = False
        
        
    def _start_connection_monitor(self):
        """Start a thread to monitor connection status"""
        if self._monitor_thread and self._monitor_thread.is_alive():
            self._stop_monitor = True
            self._monitor_thread.join(timeout=1.0)
            
        self._stop_monitor = False
        self._monitor_thread = threading.Thread(target=self._monitor_connection)
        self._monitor_thread.daemon = True
        self._monitor_thread.start()
    
    def _monitor_connection(self):
        """Thread function to monitor connection status"""
        check_interval = 2.0  # seconds
        last_status = self._connection.status() if self._connection else None
        
        while not self._stop_monitor and self._connection:
            try:
                current_status = self._connection.status()
                
                # If status changed, emit signal
                if current_status != last_status:
                    if current_status != OBDStatus.CAR_CONNECTED and last_status == OBDStatus.CAR_CONNECTED:
                        # We lost connection
                        self._connected = False
                        self.connectionStatusChanged.emit("Disconnected")
                        self.connectionStatusDetailChanged.emit("Connection to vehicle lost")
                        self.connectionProgressChanged.emit(0)
                    
                    last_status = current_status
                
                # Periodically check if the device is still available
                if not os.path.exists(self._settings_manager.obdBluetoothPort if self._settings_manager else "/dev/rfcomm0"):
                    self._connected = False
                    self.connectionStatusChanged.emit("Device Lost")
                    self.connectionStatusDetailChanged.emit("Bluetooth device disconnected")
                    self.connectionProgressChanged.emit(0)
                    self.devicePresenceChanged.emit(False)
                    break
                    
            except Exception as e:
                print(f"Error monitoring connection: {e}")
                
            time.sleep(check_interval)
    def _setup_watchers(self):
        """Set up watchers based on settings"""
        if not self._connection:
            return
            
        commands_to_watch = {
            # Original parameters
            "COOLANT_TEMP": (obd.commands.COOLANT_TEMP, self._update_coolant),
            "CONTROL_MODULE_VOLTAGE": (obd.commands.CONTROL_MODULE_VOLTAGE, self._update_voltage),
            "ENGINE_LOAD": (obd.commands.ENGINE_LOAD, self._update_load),
            "THROTTLE_POS": (obd.commands.THROTTLE_POS, self._update_throttle),
            "INTAKE_TEMP": (obd.commands.INTAKE_TEMP, self._update_intake),
            "TIMING_ADVANCE": (obd.commands.TIMING_ADVANCE, self._update_timing),
            "MAF": (obd.commands.MAF, self._update_maf),
            "SPEED": (obd.commands.SPEED, self._update_speed),
            "RPM": (obd.commands.RPM, self._update_rpm),
            "COMMANDED_EQUIV_RATIO": (obd.commands.COMMANDED_EQUIV_RATIO, self._update_afr),
            
            # New parameters (removed fuel economy related)
            "FUEL_LEVEL": (obd.commands.FUEL_LEVEL, self._update_fuel_level),
            "INTAKE_PRESSURE": (obd.commands.INTAKE_PRESSURE, self._update_intake_pressure),
            "SHORT_FUEL_TRIM_1": (obd.commands.SHORT_FUEL_TRIM_1, self._update_short_term_fuel_trim),
            "LONG_FUEL_TRIM_1": (obd.commands.LONG_FUEL_TRIM_1, self._update_long_term_fuel_trim),
            "O2_B1S1": (obd.commands.O2_B1S1, self._update_o2_sensor),
            "FUEL_PRESSURE": (obd.commands.FUEL_PRESSURE, self._update_fuel_pressure),
            "OIL_TEMP": (obd.commands.OIL_TEMP, self._update_oil_temp),
            "IGNITION_TIMING": (obd.commands.TIMING_ADVANCE, self._update_ignition_timing),
        }
        
        for param, (command, callback) in commands_to_watch.items():
            # Check if we should watch this parameter
            should_watch = True
            if self._settings_manager:
                should_watch = self._settings_manager.get_obd_parameter_enabled(param, True)
                
            if should_watch:
                print(f"Watching OBD parameter: {param}")
                self._connection.watch(command, callback=callback)
            else:
                print(f"Not watching OBD parameter: {param}")

    # Original Callback functions
    def _update_coolant(self, r):
        if not r.is_null():
            self._coolant_temp = float(r.value.magnitude)
            self.coolantTempChanged.emit(self._coolant_temp)

    def _update_voltage(self, r):
        if not r.is_null():
            self._voltage = float(r.value.magnitude)
            self.voltageChanged.emit(self._voltage)

    def _update_load(self, r):
        if not r.is_null():
            self._engine_load = float(r.value.magnitude)
            self.engineLoadChanged.emit(self._engine_load)

    def _update_throttle(self, r):
        if not r.is_null():
            self._throttle_pos = float(r.value.magnitude)
            self.throttlePositionChanged.emit(self._throttle_pos)

    def _update_intake(self, r):
        if not r.is_null():
            self._intake_temp = float(r.value.magnitude)
            self.intakeAirTempChanged.emit(self._intake_temp)

    def _update_timing(self, r):
        if not r.is_null():
            self._timing_advance = float(r.value.magnitude)
            self.timingAdvanceChanged.emit(self._timing_advance)

    def _update_maf(self, r):
        if not r.is_null():
            self._mass_airflow = float(r.value.magnitude)
            self.massAirFlowChanged.emit(self._mass_airflow)

    def _update_speed(self, r):
        if not r.is_null():
            self._speed_mph = float(r.value.to("mph").magnitude)
            self.speedMPHChanged.emit(self._speed_mph)
            
    def _update_rpm(self, r):
        if not r.is_null():
            self._rpm = float(r.value.magnitude)
            self.rpmChanged.emit(self._rpm)
            
    def _update_afr(self, r):
        if not r.is_null():
            # The equivalence ratio is lambda, multiply by 14.7 to get AFR for gasoline
            self._air_fuel_ratio = float(r.value.magnitude) * 14.7
            self.airFuelRatioChanged.emit(self._air_fuel_ratio)

    # New callback functions for added parameters (removed fuel economy related)
    def _update_fuel_level(self, r):
        if not r.is_null():
            self._fuel_level = float(r.value.magnitude)
            self.fuelLevelChanged.emit(self._fuel_level)

    def _update_intake_pressure(self, r):
        if not r.is_null():
            self._intake_pressure = float(r.value.magnitude)
            self.intakeManifoldPressureChanged.emit(self._intake_pressure)

    def _update_short_term_fuel_trim(self, r):
        if not r.is_null():
            self._short_term_fuel_trim = float(r.value.magnitude)
            self.shortTermFuelTrimChanged.emit(self._short_term_fuel_trim)

    def _update_long_term_fuel_trim(self, r):
        if not r.is_null():
            self._long_term_fuel_trim = float(r.value.magnitude)
            self.longTermFuelTrimChanged.emit(self._long_term_fuel_trim)

    def _update_o2_sensor(self, r):
        if not r.is_null():
            self._o2_sensor_voltage = float(r.value.magnitude)
            self.oxygenSensorVoltageChanged.emit(self._o2_sensor_voltage)

    def _update_fuel_pressure(self, r):
        if not r.is_null():
            self._fuel_pressure = float(r.value.magnitude)
            self.fuelPressureChanged.emit(self._fuel_pressure)

    def _update_oil_temp(self, r):
        if not r.is_null():
            self._oil_temp = float(r.value.magnitude)
            self.engineOilTempChanged.emit(self._oil_temp)

    def _update_ignition_timing(self, r):
        if not r.is_null():
            self._ignition_timing = float(r.value.magnitude)
            self.ignitionTimingChanged.emit(self._ignition_timing)

    # Original Getter methods for current values
    @Slot(result=float)
    def coolantTemp(self):
        return self._coolant_temp

    @Slot(result=float)
    def voltage(self):
        return self._voltage

    @Slot(result=float)
    def engineLoad(self):
        return self._engine_load

    @Slot(result=float)
    def throttlePosition(self):
        return self._throttle_pos

    @Slot(result=float)
    def intakeTemp(self):
        return self._intake_temp

    @Slot(result=float)
    def timingAdvance(self):
        return self._timing_advance

    @Slot(result=float)
    def massAirFlow(self):
        return self._mass_airflow

    @Slot(result=float)
    def speedMPH(self):
        return self._speed_mph
        
    @Slot(result=float)
    def rpm(self):
        return self._rpm
        
    @Slot(result=float)
    def airFuelRatio(self):
        return self._air_fuel_ratio

    # New getter methods for added parameters (removed fuel economy related)
    @Slot(result=float)
    def fuelLevel(self):
        return self._fuel_level
        
    @Slot(result=float)
    def intakeManifoldPressure(self):
        return self._intake_pressure
        
    @Slot(result=float)
    def shortTermFuelTrim(self):
        return self._short_term_fuel_trim
        
    @Slot(result=float)
    def longTermFuelTrim(self):
        return self._long_term_fuel_trim
        
    @Slot(result=float)
    def oxygenSensorVoltage(self):
        return self._o2_sensor_voltage
        
    @Slot(result=float)
    def fuelPressure(self):
        return self._fuel_pressure
        
    @Slot(result=float)
    def engineOilTemp(self):
        return self._oil_temp
        
    @Slot(result=float)
    def ignitionTiming(self):
        return self._ignition_timing

    @Slot()
    def reconnect(self):
        """Attempt to reconnect to the OBD device with exponential backoff"""
        # Add import for time
        import time
        
        # Track last reconnection attempt time
        current_time = time.time()
        
        # Implement exponential backoff
        if not hasattr(self, '_last_reconnect_time'):
            self._last_reconnect_time = 0
        
        # Calculate backoff time based on connection attempts
        backoff_time = min(30, 2 ** (self._connection_attempts - 1)) if self._connection_attempts > 0 else 0
        time_since_last = current_time - self._last_reconnect_time
        
        # Only reconnect if sufficient time has passed based on backoff
        if time_since_last > backoff_time:
            print(f"Reconnecting to OBD device (attempt {self._connection_attempts + 1})...")
            if self._connection:
                self._stop_monitor = True
                if self._monitor_thread and self._monitor_thread.is_alive():
                    self._monitor_thread.join(timeout=1.0)
                self._connection.stop()
                self._connection.close()
                
            self._last_reconnect_time = current_time
            self._connect()
        else:
            remaining = backoff_time - time_since_last
            self.connectionStatusDetailChanged.emit(f"Please wait {remaining:.1f}s before retrying")
            print(f"Reconnection attempt ignored - waiting {remaining:.1f}s for backoff")
        """Attempt to reconnect to the OBD device with debounce protection"""
        # Add import for time
        import time
        
        # Add a class variable to track last reconnection attempt
        current_time = time.time()
        
        # Only reconnect if at least 5 seconds have passed since last attempt
        if not hasattr(self, '_last_reconnect_time') or (current_time - self._last_reconnect_time) > 5:
            print("Reconnecting to OBD device...")
            if self._connection:
                self._connection.stop()
                self._connection.close()
            self._last_reconnect_time = current_time
            self._connect()
        else:
            print(f"Reconnection attempt ignored - last attempt was {current_time - self._last_reconnect_time:.1f} seconds ago")
        
    @Slot(result=bool)
    def is_connected(self):
        """Return current connection status"""
        return self._connected

    @Slot(result=str)
    def get_connection_status(self):
        """Get detailed connection status"""
        if not self._connection:
            return "No Connection"
        return str(self._connection.status())

    @Slot()
    def close(self):
        """Cleanup connection"""
        self._stop_monitor = True
        if self._monitor_thread and self._monitor_thread.is_alive():
            self._monitor_thread.join(timeout=1.0)
            
        if self._connection:
            self._connection.stop()
            self._connection.close()
            self._connected = False
            
    @Slot()
    def reset_connection(self):
        """Hard reset the connection, resetting the attempt counter"""
        self._connection_attempts = 0
        if self._connection:
            self._stop_monitor = True
            if self._monitor_thread and self._monitor_thread.is_alive():
                self._monitor_thread.join(timeout=1.0)
            self._connection.stop()
            self._connection.close()
            self._connection = None
        self._connect()
        
    @Slot()
    def check_device_presence(self):
        """Check if the configured device is present"""
        port = self._settings_manager.obdBluetoothPort if self._settings_manager else "/dev/rfcomm0"
        device_present = os.path.exists(port)
        self.devicePresenceChanged.emit(device_present)
        return device_present