from PySide6.QtCore import QObject, Signal, Slot
import obd
from obd import OBDStatus
import time

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
        
        # Connect to settings changes if a settings manager is provided
        if self._settings_manager:
            self._settings_manager.obdBluetoothPortChanged.connect(self.reconnect)
            self._settings_manager.obdFastModeChanged.connect(self.reconnect)
            self._settings_manager.obdParametersChanged.connect(self.reconnect)
        
        # Try to establish connection
        self._connect()

    def _connect(self):
        try:
            # Use settings values if available, otherwise use defaults
            port = "/dev/rfcomm0"
            fast_mode = True
            
            if self._settings_manager:
                port = self._settings_manager.obdBluetoothPort
                fast_mode = self._settings_manager.obdFastMode
            
            import os
            if not os.path.exists(port):
                print(f"OBD device port {port} not found. Skipping connection attempt.")
                self._connected = False
                self.connectionStatusChanged.emit("Device Not Found")
                return  # Exit the method early
                
            print(f"Connecting to OBD on port {port} with fast_mode={fast_mode}")
            self._connection = obd.Async(portstr=port, fast=fast_mode)
            
            if self._connection.status() == OBDStatus.CAR_CONNECTED:
                self._connected = True
                self.connectionStatusChanged.emit("Connected")
                
                # Set up watchers for each parameter
                self._setup_watchers()
                
                # Start watching
                self._connection.start()
            else:
                self._connected = False
                self.connectionStatusChanged.emit("Not Connected")
                
        except Exception as e:
            print(f"OBD Connection error: {e}")
            self._connected = False
            self.connectionStatusChanged.emit("Error")
        
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
        if self._connection:
            self._connection.stop()
            self._connection.close()
            self._connected = False