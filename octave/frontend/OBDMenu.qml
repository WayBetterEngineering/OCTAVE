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
    }

    // Enhanced Parameter Display with Slider
    component ParameterDisplay: Rectangle {
        property string title: ""
        property real value: 0
        property string unit: ""
        property real minValue: 0
        property real maxValue: 100

        Layout.fillWidth: true
        Layout.preferredHeight: 80
        color: App.Style.contentColor
        radius: 8

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

    Rectangle {
        anchors.fill: parent
        color: App.Style.backgroundColor

        GridLayout {
            anchors.fill: parent
            anchors.margins: 10
            columns: 2
            rowSpacing: 15
            columnSpacing: 15

            // Parameter Displays
            ParameterDisplay {
                id: coolantTempDisplay
                title: "Engine Temperature"
                unit: "°C"
                minValue: 60
                maxValue: 120
            }

            ParameterDisplay {
                id: voltageDisplay
                title: "System Voltage"
                unit: "V"
                minValue: 10
                maxValue: 15
            }

            ParameterDisplay {
                id: speedDisplay
                title: "Speed"
                unit: "MPH"
                minValue: 0
                maxValue: 160
            }

            ParameterDisplay {
                id: loadDisplay
                title: "Engine Load"
                unit: "%"
                minValue: 0
                maxValue: 100
            }

            ParameterDisplay {
                id: throttleDisplay
                title: "Throttle"
                unit: "%"
                minValue: 0
                maxValue: 100
            }

            ParameterDisplay {
                id: intakeDisplay
                title: "Intake Temp"
                unit: "°C"
                minValue: 0
                maxValue: 80
            }

            ParameterDisplay {
                id: timingDisplay
                title: "Timing"
                unit: "°"
                minValue: -35
                maxValue: 35
                
                // Override the default progress bar to handle the centered zero value
                Rectangle {
                    Layout.fillWidth: true
                    height: 12
                    color: App.Style.backgroundColor
                    radius: 6

                    Rectangle {
                        x: parent.width * 0.5 + (value < 0 ? parent.width * 0.5 * (value / minValue) : 0)
                        width: Math.abs(parent.width * 0.5 * (value / (value < 0 ? Math.abs(minValue) : maxValue)))
                        height: parent.height
                        color: App.Style.accent
                        radius: 6
                        Behavior on width { NumberAnimation { duration: 200 } }
                        Behavior on x { NumberAnimation { duration: 200 } }
                    }

                    // Center line indicator
                    Rectangle {
                        anchors.centerIn: parent
                        width: 1
                        height: parent.height
                        color: App.Style.primaryTextColor
                        opacity: 0.5
                    }
                }
            }

            ParameterDisplay {
                id: mafDisplay
                title: "Mass Air Flow"
                unit: "g/s"
                minValue: 0
                maxValue: 100
            }
            
            ParameterDisplay {
                id: rpmDisplay
                title: "Engine RPM"
                unit: "RPM"
                minValue: 0
                maxValue: 8000
            }
            
            ParameterDisplay {
                id: afrDisplay
                title: "Air-Fuel Ratio"
                unit: ":1"
                minValue: 10
                maxValue: 18
                
                // Override the default progress bar to highlight stoichiometric (14.7:1)
                Rectangle {
                    Layout.fillWidth: true
                    height: 12
                    color: App.Style.backgroundColor
                    radius: 6
                    
                    // Indicator for stoichiometric ratio
                    Rectangle {
                        x: parent.width * ((14.7 - minValue) / (maxValue - minValue))
                        width: 2
                        height: parent.height
                        color: "white"
                        opacity: 0.8
                    }

                    Rectangle {
                        width: Math.max(6, parent.width * Math.min(1, (value - minValue) / (maxValue - minValue)))
                        height: parent.height
                        color: value < 14.6 ? "#eb4034" : (value > 14.8 ? "#34c3eb" : "#34eb52")  // Rich (red), Lean (blue), or Optimal (green)
                        radius: 6
                        Behavior on width { NumberAnimation { duration: 200 } }
                        Behavior on color { ColorAnimation { duration: 200 } }
                    }
                }
            }

            // Connection Status
            Rectangle {
                Layout.columnSpan: 2
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                color: obdManager.is_connected ? App.Style.accent : "#F44336"
                radius: 4

                Text {
                    anchors.centerIn: parent
                    text: obdManager.get_connection_status()
                    color: "white"
                    font.pixelSize: 14
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: obdManager.reconnect()
                }
            }
        }
    }
}