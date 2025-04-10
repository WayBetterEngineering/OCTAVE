import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtCharts 2.15
import "." as App

Item {
    id: obdPage
    required property StackView stackView
    required property ApplicationWindow mainWindow

    // OBD Data Connections
    Connections {
        target: obdManager

        function onCoolantTempChanged(value) {
            coolantTempDisplay.value = value
        }

        function onVoltageChanged(value) {
            voltageDisplay.value = value
        }

        function onEngineLoadChanged(value) {
            loadDisplay.value = value
        }

        function onThrottlePositionChanged(value) {
            throttleDisplay.value = value
        }

        function onIntakeAirTempChanged(value) {
            intakeDisplay.value = value
        }

        function onTimingAdvanceChanged(value) {
            timingDisplay.value = value
        }

        function onMassAirFlowChanged(value) {
            mafDisplay.value = value
        }

        function onSpeedMPHChanged(value) {
            speedDisplay.value = value
        }
        
        function onRpmChanged(value) {
            rpmDisplay.value = value
        }
        
        function onAirFuelRatioChanged(value) {
            afrDisplay.value = value
        }

        function onIntakeManifoldPressureChanged(value) {
            mapDisplay.value = value
        }

        function onShortTermFuelTrimChanged(value) {
            stftDisplay.value = value
        }

        function onLongTermFuelTrimChanged(value) {
            ltftDisplay.value = value
        }

        function onOxygenSensorVoltageChanged(value) {
            o2SensorDisplay.value = value
        }

        function onFuelPressureChanged(value) {
            fuelPressureDisplay.value = value
        }

        function onEngineOilTempChanged(value) {
            oilTempDisplay.value = value
        }

        function onIgnitionTimingChanged(value) {
            ignitionTimingDisplay.value = value
        }
    }

    // Function to get all visible parameters
    function getVisibleParameters() {
        const allParams = [
            speedDisplay, rpmDisplay, coolantTempDisplay, oilTempDisplay,
            afrDisplay, loadDisplay, throttleDisplay, fuelLevelDisplay,
            stftDisplay, ltftDisplay, intakeDisplay, mapDisplay, 
            mafDisplay, timingDisplay, voltageDisplay, o2SensorDisplay, 
            fuelPressureDisplay, ignitionTimingDisplay
        ];
        
        return allParams.filter(param => 
            param.visible && settingsManager ? 
            settingsManager.get_obd_parameter_enabled(param.parameter, true) : 
            true
        );
    }
    
    // Function to update the layout
    function updateLayout() {
        const visibleParams = getVisibleParameters();
        const totalParams = visibleParams.length;
        
        // Calculate optimum layout (aiming for a more square grid)
        let columns = Math.max(2, Math.min(4, Math.ceil(Math.sqrt(totalParams))));
        
        // If we have many parameters, force 4 columns
        if (totalParams >= 12) columns = 4;
        
        // Update the gridLayout
        flowLayout.columns = columns;
        
        // Calculate available height considering the bottom bar
        // The bottom bar is approximately 60 pixels high
        const bottomBarHeight = 70; // Increased to account for bottom bar and any padding
        
        // Update each item's size based on column count and available height
        const itemWidth = (parent.width - (flowLayout.columnSpacing * (columns - 1)) - flowLayout.anchors.leftMargin - flowLayout.anchors.rightMargin) / columns;
        
        // Determine appropriate height based on number of rows
        const rows = Math.ceil(totalParams / columns);
        const itemHeight = (parent.height - bottomBarHeight - (flowLayout.rowSpacing * (rows - 1)) - flowLayout.anchors.topMargin - flowLayout.anchors.bottomMargin) / rows;
        
        // Apply sizes to all parameters
        visibleParams.forEach(param => {
            param.width = itemWidth;
            param.height = itemHeight;
        });
        
        // Make sure all params are actually in the layout
        visibleParams.forEach(param => param.parent = flowLayout);
        
        console.log("Layout updated: " + columns + " columns, " + rows + " rows, " + totalParams + " parameters");
    }

    // Enhanced Parameter Display with Slider
    component ParameterDisplay: Rectangle {
        property string title: ""
        property real value: 0
        property string unit: ""
        property real minValue: 0
        property real maxValue: 100
        property string parameter: ""  // Add parameter property

        color: App.Style.contentColor
        radius: 8
        visible: settingsManager ? settingsManager.get_obd_parameter_enabled(parameter, true) : true
        
        // Call updateLayout when visibility changes
        onVisibleChanged: {
            // Use a timer to allow all visibility changes to complete
            updateTimer.restart();
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 5

            Text {
                text: title
                color: App.Style.primaryTextColor
                font.pixelSize: 14
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: value.toFixed(1) + " " + unit
                color: App.Style.primaryTextColor
                font.pixelSize: 24
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }

            Rectangle {
                Layout.fillWidth: true
                height: 12
                color: App.Style.backgroundColor
                radius: 6

                Rectangle {
                    width: Math.max(6, parent.width * Math.min(1, (value - minValue) / (maxValue - minValue)))
                    height: parent.height
                    color: App.Style.accent
                    radius: 6
                    Behavior on width { NumberAnimation { duration: 200 } }
                }
            }
        }
    }

    // Timer to update layout when needed
    Timer {
        id: updateTimer
        interval: 100
        repeat: false
        onTriggered: updateLayout()
    }
    
    // Connections to settings manager to detect parameter toggling
    Connections {
        target: settingsManager
        function onObdParametersChanged() {
            updateTimer.restart();
        }
    }

    Rectangle {
        anchors.fill: parent
        color: App.Style.backgroundColor

        // Use GridLayout for more dynamic arrangement
        GridLayout {
            id: flowLayout
            anchors {
                fill: parent
                topMargin: -25 // Explicitly set to zero to remove top gap
                leftMargin: 10
                rightMargin: 10
                bottomMargin: 70 // Account for bottom bar height plus some padding
            }
            rowSpacing: 10
            columnSpacing: 10
            columns: 4 // Default number of columns
            
            // All parameters are created but will be managed by updateLayout()
            ParameterDisplay {
                id: speedDisplay
                title: "Speed"
                unit: "MPH"
                minValue: 0
                maxValue: 160
                parameter: "SPEED"
            }

            ParameterDisplay {
                id: rpmDisplay
                title: "Engine RPM"
                unit: "RPM"
                minValue: 0
                maxValue: 8000
                parameter: "RPM"
            }

            ParameterDisplay {
                id: coolantTempDisplay
                title: "Engine Temperature"
                unit: "°C"
                minValue: 0
                maxValue: 120
                parameter: "COOLANT_TEMP"
            }

            ParameterDisplay {
                id: oilTempDisplay
                title: "Oil Temperature"
                unit: "°C"
                minValue: 0
                maxValue: 150
                parameter: "OIL_TEMP"
            }

            ParameterDisplay {
                id: afrDisplay
                title: "Air-Fuel Ratio"
                unit: ":1"
                minValue: 10
                maxValue: 18
                parameter: "COMMANDED_EQUIV_RATIO"
            }

            ParameterDisplay {
                id: loadDisplay
                title: "Engine Load"
                unit: "%"
                minValue: 0
                maxValue: 100
                parameter: "ENGINE_LOAD"
            }

            ParameterDisplay {
                id: throttleDisplay
                title: "Throttle"
                unit: "%"
                minValue: 0
                maxValue: 100
                parameter: "THROTTLE_POS"
            }

            ParameterDisplay {
                id: fuelLevelDisplay
                title: "Fuel Level"
                unit: "%"
                minValue: 0
                maxValue: 100
                parameter: "FUEL_LEVEL"
            }

            ParameterDisplay {
                id: stftDisplay
                title: "Short Fuel Trim"
                unit: "%"
                minValue: -25
                maxValue: 25
                parameter: "SHORT_FUEL_TRIM_1"
            }

            ParameterDisplay {
                id: ltftDisplay
                title: "Long Fuel Trim"
                unit: "%"
                minValue: -25
                maxValue: 25
                parameter: "LONG_FUEL_TRIM_1"
            }

            ParameterDisplay {
                id: intakeDisplay
                title: "Intake Temp"
                unit: "°C"
                minValue: 0
                maxValue: 80
                parameter: "INTAKE_TEMP"
            }

            ParameterDisplay {
                id: mapDisplay
                title: "Intake Pressure"
                unit: "kPa"
                minValue: 0
                maxValue: 255
                parameter: "INTAKE_PRESSURE"
            }

            ParameterDisplay {
                id: mafDisplay
                title: "Mass Air Flow"
                unit: "g/s"
                minValue: 0
                maxValue: 100
                parameter: "MAF"
            }

            ParameterDisplay {
                id: timingDisplay
                title: "Timing Advance"
                unit: "°"
                minValue: -35
                maxValue: 35
                parameter: "TIMING_ADVANCE"
            }

            ParameterDisplay {
                id: voltageDisplay
                title: "System Voltage"
                unit: "V"
                minValue: 10
                maxValue: 15
                parameter: "CONTROL_MODULE_VOLTAGE"
            }

            ParameterDisplay {
                id: o2SensorDisplay
                title: "O2 Sensor"
                unit: "V"
                minValue: 0
                maxValue: 1.0
                parameter: "O2_B1S1"
            }

            ParameterDisplay {
                id: fuelPressureDisplay
                title: "Fuel Pressure"
                unit: "kPa"
                minValue: 0
                maxValue: 765
                parameter: "FUEL_PRESSURE"
            }

            ParameterDisplay {
                id: ignitionTimingDisplay
                title: "Ignition Timing"
                unit: "°"
                minValue: -10
                maxValue: 60
                parameter: "IGNITION_TIMING"
            }
        }
    }
    
    // Call the layout update after component completes
    Component.onCompleted: {
        updateTimer.start();
    }
    
    // Also update when the window size changes
    Connections {
        target: parent
        function onWidthChanged() { updateTimer.restart(); }
        function onHeightChanged() { updateTimer.restart(); }
    }

    // Add this connection to explicitly listen for parameter changes
    Connections {
        target: settingsManager
        function onObdParametersChanged() {
            // Force update of all parameter visibility states
            const allParams = [
                speedDisplay, rpmDisplay, coolantTempDisplay, oilTempDisplay,
                afrDisplay, loadDisplay, throttleDisplay, fuelLevelDisplay,
                stftDisplay, ltftDisplay, intakeDisplay, mapDisplay, 
                mafDisplay, timingDisplay, voltageDisplay, o2SensorDisplay, 
                fuelPressureDisplay, ignitionTimingDisplay
            ];
            
            allParams.forEach(param => {
                // Update visibility based on current setting
                param.visible = settingsManager.get_obd_parameter_enabled(param.parameter, true);
            });

            // Trigger layout update with a bit of delay to allow visibility changes to apply
            updateTimer.interval = 200;
            updateTimer.restart();
        }
    }
}