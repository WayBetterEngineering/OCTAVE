from PySide6.QtCore import QObject, Signal, Slot
import obd
from obd import OBDStatus

class OBDManager(QObject):
    # Signals for all OBD values
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

    def __init__(self):
        super().__init__()
        self._connection = None
        self._connected = False
        
        # Initialize values
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
        
        # Try to establish connection
        self._connect()

    def _connect(self):
        try:
            self._connection = obd.Async(portstr="/dev/rfcomm0", fast=True)  # Use Async connection
            
            if self._connection.status() == OBDStatus.CAR_CONNECTED:
                self._connected = True
                self.connectionStatusChanged.emit("Connected")
                
                # Set up watchers for each parameter
                self._connection.watch(obd.commands.COOLANT_TEMP, callback=self._update_coolant)
                self._connection.watch(obd.commands.CONTROL_MODULE_VOLTAGE, callback=self._update_voltage)
                self._connection.watch(obd.commands.ENGINE_LOAD, callback=self._update_load)
                self._connection.watch(obd.commands.THROTTLE_POS, callback=self._update_throttle)
                self._connection.watch(obd.commands.INTAKE_TEMP, callback=self._update_intake)
                self._connection.watch(obd.commands.TIMING_ADVANCE, callback=self._update_timing)
                self._connection.watch(obd.commands.MAF, callback=self._update_maf)
                self._connection.watch(obd.commands.SPEED, callback=self._update_speed)
                self._connection.watch(obd.commands.RPM, callback=self._update_rpm)
                self._connection.watch(obd.commands.COMMANDED_EQUIV_RATIO, callback=self._update_afr)
                
                # Start watching
                self._connection.start()
            else:
                self._connected = False
                self.connectionStatusChanged.emit("Not Connected")
                
        except Exception as e:
            print(f"OBD Connection error: {e}")
            self._connected = False
            self.connectionStatusChanged.emit("Error")

    # Callback functions for watchers
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

    # Getter methods for current values
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

    @Slot()
    def reconnect(self):
        """Attempt to reconnect to the OBD device"""
        if self._connection:
            self._connection.stop()
            self._connection.close()
        self._connect()

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