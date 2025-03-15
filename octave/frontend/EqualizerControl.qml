import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    id: equalizerControl
    
    required property var mediaManager
    required property var stackView

    ColumnLayout {
        anchors.fill: parent
        spacing: 20

        // Header with back button
        Rectangle {
            Layout.fillWidth: true
            height: 50
            color: "#2c2c2c"

            RowLayout {
                anchors.fill: parent
                spacing: 10

                Button {
                    text: "←"
                    onClicked: stackView.pop()
                    Layout.margins: 10
                }

                Text {
                    text: "Equalizer"
                    color: "white"
                    font.pixelSize: 20
                    Layout.fillWidth: true
                }
            }
        }

        // Equalizer sliders
        Row {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 5
            padding: 10

            Repeater {
                model: 10

                ColumnLayout {
                    width: (parent.width - parent.padding * 2 - parent.spacing * 9) / 10
                    height: parent.height - parent.padding * 2
                    spacing: 5

                    // dB value label
                    Text {
                        text: slider.value.toFixed(1) + " dB"
                        color: "white"
                        Layout.alignment: Qt.AlignHCenter
                    }

                    // Vertical slider
                    Slider {
                        id: slider
                        Layout.fillHeight: true
                        orientation: Qt.Vertical
                        from: -12
                        to: 12
                        stepSize: 0.1
                        value: mediaManager ? mediaManager.get_band_gain(index) : 0

                        onValueChanged: {
                            if (mediaManager) {
                                mediaManager.set_band_gain(index, value)
                            }
                        }
                    }

                    // Frequency label
                    Text {
                        text: {
                            let freq = mediaManager ? mediaManager.get_band_frequency(index) : 0
                            return freq >= 1000 ? (freq/1000) + " kHz" : freq + " Hz"
                        }
                        color: "white"
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
        }

        // Preset buttons
        RowLayout {
            Layout.fillWidth: true
            Layout.margins: 10
            spacing: 10

            Button {
                text: "Flat"
                Layout.fillWidth: true
                onClicked: {
                    if (mediaManager) mediaManager.reset_equalizer()
                }
            }

            Button {
                text: "Bass Boost"
                Layout.fillWidth: true
                onClicked: {
                    if (mediaManager) mediaManager.apply_bass_boost_preset()
                }
            }

            Button {
                text: "Treble Boost"
                Layout.fillWidth: true
                onClicked: {
                    if (mediaManager) mediaManager.apply_treble_boost_preset()
                }
            }
        }
    }

    // Background
    Rectangle {
        anchors.fill: parent
        z: -1
        color: "#1a1a1a"
    }
}