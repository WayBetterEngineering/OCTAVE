// ParameterDisplay.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "." as App

Rectangle {
    property string title: ""
    property real value: 0
    property string unit: ""
    property real minValue: 0
    property real maxValue: 100
    property string parameter: ""

    color: App.Style.backgroundColor
    border.color: App.Style.accent
    border.width: 1
    radius: 3

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 5
        spacing: 5

        Text {
            text: title.toUpperCase()
            font.pixelSize: App.Spacing.mainMenuOBDTextSize
            color: App.Style.secondaryTextColor
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: value.toFixed(1) + " " + unit
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
                width: Math.max(4, parent.width * Math.min(1, (value - minValue) / (maxValue - minValue)))
                height: parent.height
                color: App.Style.accent
                radius: 4
                Behavior on width { NumberAnimation { duration: 200 } }
            }
        }
    }
}