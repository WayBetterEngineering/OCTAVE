// HomeOBDView.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "." as App

Item {
    id: homeOBDView
    
    // Properties - expanded to include all possible OBD parameters
    property var parameterInfo: {
        "SPEED": {title: "Speed", unit: "MPH", minValue: 0, maxValue: 160},
        "RPM": {title: "RPM", unit: "RPM", minValue: 0, maxValue: 8000},
        "COOLANT_TEMP": {title: "Temp", unit: "°C", minValue: 0, maxValue: 120},
        "CONTROL_MODULE_VOLTAGE": {title: "Voltage", unit: "V", minValue: 10, maxValue: 15},
        "ENGINE_LOAD": {title: "Load", unit: "%", minValue: 0, maxValue: 100},
        "THROTTLE_POS": {title: "Throttle", unit: "%", minValue: 0, maxValue: 100},
        "INTAKE_TEMP": {title: "Intake", unit: "°C", minValue: 0, maxValue: 80},
        "TIMING_ADVANCE": {title: "Timing", unit: "°", minValue: -35, maxValue: 35},
        "MAF": {title: "MAF", unit: "g/s", minValue: 0, maxValue: 100},
        "COMMANDED_EQUIV_RATIO": {title: "AFR", unit: ":1", minValue: 10, maxValue: 18},
        "FUEL_LEVEL": {title: "Fuel", unit: "%", minValue: 0, maxValue: 100},
        "INTAKE_PRESSURE": {title: "MAP", unit: "kPa", minValue: 0, maxValue: 255},
        "SHORT_FUEL_TRIM_1": {title: "STFT", unit: "%", minValue: -25, maxValue: 25},
        "LONG_FUEL_TRIM_1": {title: "LTFT", unit: "%", minValue: -25, maxValue: 25},
        "O2_B1S1": {title: "O2", unit: "V", minValue: 0, maxValue: 1.0},
        "FUEL_PRESSURE": {title: "FP", unit: "kPa", minValue: 0, maxValue: 765},
        "OIL_TEMP": {title: "Oil", unit: "°C", minValue: 0, maxValue: 150},
        "IGNITION_TIMING": {title: "Ign", unit: "°", minValue: -10, maxValue: 60}
    }
    
    // Refreshes all OBD values in the display
    function refreshOBDValues() {
        if (obdManager) {
            const repeaterCount = obdRepeater.count;
            for (let i = 0; i < repeaterCount; i++) {
                const item = obdRepeater.itemAt(i);
                if (item) {
                    const param = item.param;
                    
                    // Map of parameter names to their getter functions in obdManager
                    const getterMap = {
                        "SPEED": "get_speed_mph",
                        "RPM": "get_rpm",
                        "COOLANT_TEMP": "get_coolant_temp",
                        "CONTROL_MODULE_VOLTAGE": "get_voltage",
                        "ENGINE_LOAD": "get_engine_load",
                        "THROTTLE_POS": "get_throttle_position",
                        "INTAKE_TEMP": "get_intake_air_temp",
                        "TIMING_ADVANCE": "get_timing_advance",
                        "MAF": "get_mass_air_flow",
                        "COMMANDED_EQUIV_RATIO": "get_air_fuel_ratio",
                        "FUEL_LEVEL": "get_fuel_level",
                        "INTAKE_PRESSURE": "get_intake_manifold_pressure",
                        "SHORT_FUEL_TRIM_1": "get_short_term_fuel_trim",
                        "LONG_FUEL_TRIM_1": "get_long_term_fuel_trim",
                        "O2_B1S1": "get_oxygen_sensor_voltage",
                        "FUEL_PRESSURE": "get_fuel_pressure",
                        "OIL_TEMP": "get_engine_oil_temp",
                        "IGNITION_TIMING": "get_ignition_timing"
                    };
                    
                    // Get the getter function name for this parameter
                    const getterName = getterMap[param];
                    
                    // If we have a matching getter, call it and update the value
                    if (getterName && obdManager[getterName]) {
                        const value = obdManager[getterName]();
                        if (value !== undefined) {
                            item.value = value;
                        }
                    }
                }
            }
        }
    }
    
    // Timer for delayed refresh after model changes
    Timer {
        id: refreshTimer
        interval: 50  // Short delay
        repeat: false
        onTriggered: {
            if (obdManager && obdManager.refresh_values) {
                obdManager.refresh_values();
            }
            refreshOBDValues();
        }
    }
    
    // Layout
    GridLayout {
        id: gridLayout
        anchors.fill: parent
        anchors.margins: 10
        columnSpacing: 10
        rowSpacing: 10
        columns: 2
        
        // Statically create displays
        Repeater {
            id: obdRepeater
            model: {
                // Use the settings if available, or default to standard params
                if (settingsManager && settingsManager.get_home_obd_parameters) {
                    return settingsManager.get_home_obd_parameters()
                } else {
                    return ["SPEED", "RPM", "COOLANT_TEMP", "CONTROL_MODULE_VOLTAGE"]
                }
            }
            
            delegate: Rectangle {
                id: display
                property string param: modelData
                property var info: homeOBDView.parameterInfo[param] || 
                                {title: param, unit: "", minValue: 0, maxValue: 100}
                property real value: 0
                
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: App.Style.backgroundColor
                border.color: App.Style.accent
                border.width: 1
                radius: 3
                
                // Dynamic signal connection based on parameter type
                Component.onCompleted: {
                    if (obdManager) {
                        // Map of parameter names to their signal names in obdManager
                        const signalMap = {
                            "SPEED": "speedMPHChanged",
                            "RPM": "rpmChanged",
                            "COOLANT_TEMP": "coolantTempChanged",
                            "CONTROL_MODULE_VOLTAGE": "voltageChanged",
                            "ENGINE_LOAD": "engineLoadChanged",
                            "THROTTLE_POS": "throttlePositionChanged",
                            "INTAKE_TEMP": "intakeAirTempChanged",
                            "TIMING_ADVANCE": "timingAdvanceChanged",
                            "MAF": "massAirFlowChanged",
                            "COMMANDED_EQUIV_RATIO": "airFuelRatioChanged",
                            "FUEL_LEVEL": "fuelLevelChanged",
                            "INTAKE_PRESSURE": "intakeManifoldPressureChanged",
                            "SHORT_FUEL_TRIM_1": "shortTermFuelTrimChanged",
                            "LONG_FUEL_TRIM_1": "longTermFuelTrimChanged",
                            "O2_B1S1": "oxygenSensorVoltageChanged",
                            "FUEL_PRESSURE": "fuelPressureChanged",
                            "OIL_TEMP": "engineOilTempChanged",
                            "IGNITION_TIMING": "ignitionTimingChanged"
                        };
                        
                        // Get the signal name for this parameter
                        const signalName = signalMap[param];
                        
                        // If we have a matching signal, connect to it
                        if (signalName && obdManager[signalName]) {
                            obdManager[signalName].connect(function(val) { 
                                display.value = val; 
                            });
                        }
                    }
                }
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 5
                    spacing: 5
                    
                    Text {
                        text: info.title.toUpperCase()
                        font.pixelSize: App.Spacing.mainMenuOBDTextSize
                        color: App.Style.secondaryTextColor
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: value.toFixed(1) + " " + info.unit
                        font.pixelSize: App.Spacing.mainMenuOBDDataSize
                        font.bold: true
                        color: App.Style.primaryTextColor
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        height: 8
                        color: App.Style.backgroundColor
                        radius: 4
                        Layout.topMargin: 2
                        
                        Rectangle {
                            width: Math.max(4, parent.width * Math.min(1, (value - info.minValue) / (info.maxValue - info.minValue)))
                            height: parent.height
                            color: App.Style.accent
                            radius: 4
                            Behavior on width { NumberAnimation { duration: 200 } }
                        }
                    }
                }
            }
        }
    }
    
    // Single connection to settings changes
    Connections {
        target: settingsManager
        function onHomeOBDParametersChanged() {
            // Force refresh of the repeater
            let currentParams = settingsManager.get_home_obd_parameters();
            
            // First set model to empty array to force re-creation of all delegates
            obdRepeater.model = [];
            
            // Then delay setting the new model to ensure clean refresh
            Qt.callLater(function() {
                obdRepeater.model = currentParams;
                
                // Wait for the repeater to create items, then refresh values
                refreshTimer.start();
            });
        }
    }
    
    // Connection to OBD updates
    Connections {
        target: obdManager
        function onReadingsUpdated() {
            refreshOBDValues();
        }
    }
    
    // Refresh on component completion
    Component.onCompleted: {
        if (obdManager && obdManager.refresh_values) {
            obdManager.refresh_values();
        }
    }
}