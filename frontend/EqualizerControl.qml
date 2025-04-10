import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Basic 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects
import "." as App

Item {
    id: equalizerControl
    required property StackView stackView
    
    // Properties for equalizer data
    property var frequencies: equalizerManager ? equalizerManager.get_equalizer_frequencies() : []
    property var values: equalizerManager ? equalizerManager.get_equalizer_values() : []
    property var presets: equalizerManager ? equalizerManager.get_available_presets() : []
    property var builtinPresets: equalizerManager ? equalizerManager.get_builtin_presets() : []
    property string currentPreset: equalizerManager ? equalizerManager.get_current_preset() : "Flat"

    property var mediaManager: null
    
    // System equalizer properties
    property bool systemEqualizerAvailable: equalizerManager ? equalizerManager.is_system_equalizer_available() : false
    property bool equalizerActive: equalizerManager ? equalizerManager.is_equalizer_active() : false
    
    // Visual properties
    property color backgroundColor: "black"
    property color transparentColor: "transparent"
    property color sliderGradientStart: "#a11212"  // Match your app's accent color
    property color sliderGradientEnd: "#000000"
    property real visualizerHeight: height * 0.3
    
    // Background element with album art blur effect
    Rectangle {
        id: backgroundContainer
        anchors.fill: parent
        color: App.Style.backgroundColor
        z: -1
        
        // Add connection to listen for media changes
        Connections {
            target: mediaManager
            function onCurrentMediaChanged() {
                // Update background image when song changes
                backgroundImage.source = mediaManager ? 
                        (mediaManager.get_current_file() ? 
                            mediaManager.get_album_art(mediaManager.get_current_file()) || "./assets/missing_art.png" : 
                            "./assets/missing_art.png") : 
                        "./assets/missing_art.png"
            }
        }
        
        Image {
            id: backgroundImage
            anchors.fill: parent
            source: mediaManager ? 
                    (mediaManager.get_current_file() ? 
                        mediaManager.get_album_art(mediaManager.get_current_file()) || "./assets/missing_art.png" : 
                        "./assets/missing_art.png") : 
                    "./assets/missing_art.png"
            fillMode: Image.PreserveAspectCrop
            opacity: 0.4
            visible: false
            
            // Optional: Add a smooth transition when changing images
            Behavior on source {
                SequentialAnimation {
                    PropertyAnimation {
                        target: backgroundImage
                        property: "opacity"
                        to: 0.0
                        duration: 300
                        easing.type: Easing.InOutQuad
                    }
                    PropertyAction {
                        target: backgroundImage
                        property: "opacity"
                        value: 0.4
                    }
                }
            }
        }
        
        FastBlur {
            id: backgroundBlur
            anchors.fill: backgroundImage
            source: backgroundImage
            radius: 64
            visible: true
        }
        
        // Dark overlay
        Rectangle {
            anchors.fill: parent
            color: "#B0000000"
            opacity: settingsManager && settingsManager.showBackgroundOverlay ? 1.0 : 0.0
            
            // Add behavior for smooth transitions when overlay setting changes
            Behavior on opacity {
                NumberAnimation { duration: 300; easing.type: Easing.InOutQuad }
            }
        }
    }
    
    // Main content
    Rectangle {
        anchors.fill: parent
        color: transparentColor

        // Back button
        Button {
            id: backButton
            implicitHeight: App.Spacing.mediaRoomMediaPlayerButtonHeight
            implicitWidth: App.Spacing.mediaRoomMediaPlayerButtonWidth
            background: null
            anchors {
                left: parent.left
                top: parent.top
                margins: App.Spacing.overallMargin
            }
            z: 10 // Ensure it's above other elements

            contentItem: Item {
                Image {
                    id: leftArrowImage
                    anchors.centerIn: parent
                    source: "./assets/left_arrow.svg"
                    fillMode: Image.PreserveAspectFit
                    width: parent.width
                    height: parent.height
                    smooth: true
                    antialiasing: true
                    sourceSize: Qt.size(width * 2, height * 2)
                    mipmap: true
                    visible: false
                }
                ColorOverlay {
                    anchors.fill: leftArrowImage
                    source: leftArrowImage
                    color: App.Style.mediaRoomLeftButton
                }
            }

            onClicked: stackView.pop()
        }


        // Main content area
        Rectangle {
            id: mainContent
            anchors {
                top: backButton.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                margins: App.Spacing.overallMargin
            }
            color: "transparent"

            // Presets row
            Rectangle {
                id: presetsContainer
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }
                height: App.Spacing.overallMargin * 6
                color: Qt.rgba(0, 0, 0, 0.5)
                radius: 5

                RowLayout {
                    anchors {
                        fill: parent
                        margins: App.Spacing.overallMargin
                    }
                    spacing: App.Spacing.overallMargin

                    Text {
                        text: "PRESET:"
                        color: App.Style.primaryTextColor
                        font.pixelSize: App.Spacing.mediaPlayerTextSize
                        font.bold: true
                    }

                    ComboBox {
                        id: presetComboBox
                        Layout.fillWidth: true
                        model: presets
                        currentIndex: presets && currentPreset ? Math.max(0, presets.indexOf(currentPreset)) : 0
                        onActivated: {
                            equalizerManager.apply_preset(presets[currentIndex])
                        }
                        
                        background: Rectangle {
                            color: Qt.rgba(0.1, 0.1, 0.1, 0.7)
                            radius: 5
                            border.color: App.Style.accent
                            border.width: 1
                        }
                        
                        contentItem: Text {
                            text: presetComboBox.displayText
                            color: App.Style.primaryTextColor
                            font.pixelSize: App.Spacing.mediaPlayerTextSize
                            font.bold: true
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            leftPadding: App.Spacing.overallMargin
                        }
                        
                        popup: Popup {
                            y: presetComboBox.height
                            width: presetComboBox.width
                            height: Math.min(300, contentItem.implicitHeight)
                            padding: 1
                            
                            background: Rectangle {
                                color: Qt.rgba(0.1, 0.1, 0.1, 0.9)
                                border.color: App.Style.accent
                                border.width: 1
                                radius: 5
                            }
                            
                            contentItem: ListView {
                                clip: true
                                implicitHeight: contentHeight
                                model: presetComboBox.popup.visible ? presetComboBox.delegateModel : null
                                
                                ScrollBar.vertical: ScrollBar {
                                    active: true
                                }
                            }
                        }
                        
                        delegate: ItemDelegate {
                            width: presetComboBox.width
                            height: App.Spacing.overallMargin * 4
                            
                            contentItem: Text {
                                text: modelData
                                color: App.Style.primaryTextColor
                                font.pixelSize: App.Spacing.mediaPlayerTextSize
                                font.bold: equalizerManager && equalizerManager.is_builtin_preset(modelData)
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignLeft
                            }
                            
                            background: Rectangle {
                                color: highlighted ? App.Style.accent : Qt.rgba(0.1, 0.1, 0.1, 0.5)
                            }
                            
                            highlighted: presetComboBox.highlightedIndex === index
                        }
                    }

                    Button {
                        text: "SAVE"
                        implicitHeight: App.Spacing.overallMargin * 3
                        implicitWidth: App.Spacing.overallMargin * 8
                        
                        background: Rectangle {
                            color: App.Style.accent
                            radius: 5
                        }
                        
                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            font.pixelSize: App.Spacing.mediaPlayerTextSize
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        onClicked: {
                            savePresetDialog.open()
                        }
                    }

                    Button {
                        text: "RESET"
                        implicitHeight: App.Spacing.overallMargin * 3
                        implicitWidth: App.Spacing.overallMargin * 8
                        
                        background: Rectangle {
                            color: App.Style.accent
                            radius: 5
                        }
                        
                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            font.pixelSize: App.Spacing.mediaPlayerTextSize
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        onClicked: {
                            equalizerManager.apply_preset("Flat")
                        }
                    }
                }
            }

            // System equalizer controls
            Rectangle {
                id: systemEqContainer
                anchors {
                    top: presetsContainer.bottom
                    left: parent.left
                    right: parent.right
                    topMargin: App.Spacing.overallMargin
                }
                height: App.Spacing.overallMargin * 6
                color: Qt.rgba(0, 0, 0, 0.5)
                radius: 5
                visible: systemEqualizerAvailable

                RowLayout {
                    anchors {
                        fill: parent
                        margins: App.Spacing.overallMargin
                    }
                    spacing: App.Spacing.overallMargin

                    Switch {
                        id: eqActiveSwitch
                        text: "System Equalizer"
                        checked: equalizerActive
                        onToggled: {
                            if (equalizerManager) {
                                equalizerManager.set_equalizer_active(checked)
                            }
                        }
                        
                        indicator: Rectangle {
                            implicitWidth: 40
                            implicitHeight: 20
                            x: eqActiveSwitch.leftPadding
                            y: parent.height / 2 - height / 2
                            radius: 10
                            color: eqActiveSwitch.checked ? App.Style.accent : "#555555"
                            border.color: eqActiveSwitch.checked ? App.Style.accent : "#999999"

                            Rectangle {
                                x: eqActiveSwitch.checked ? parent.width - width - 2 : 2
                                y: 2
                                width: 16
                                height: 16
                                radius: 8
                                color: "white"
                                
                                Behavior on x {
                                    NumberAnimation { duration: 150 }
                                }
                            }
                        }
                        
                        contentItem: Text {
                            text: eqActiveSwitch.text
                            font.pixelSize: App.Spacing.mediaPlayerTextSize
                            color: App.Style.primaryTextColor
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: eqActiveSwitch.indicator.width + 10
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Button {
                        text: "Open System Equalizer"
                        implicitHeight: App.Spacing.overallMargin * 3
                        implicitWidth: App.Spacing.overallMargin * 12
                        
                        background: Rectangle {
                            color: App.Style.accent
                            radius: 5
                        }
                        
                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            font.pixelSize: App.Spacing.mediaPlayerTextSize
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        onClicked: {
                            if (equalizerManager) {
                                equalizerManager.open_system_equalizer()
                            }
                        }
                    }
                }
            }

            // No System Equalizer Warning
            Rectangle {
                id: noSystemEqContainer
                anchors {
                    top: presetsContainer.bottom
                    left: parent.left
                    right: parent.right
                    topMargin: App.Spacing.overallMargin
                }
                height: App.Spacing.overallMargin * 6
                color: "#30FF0000"  // Semi-transparent red
                radius: 5
                visible: !systemEqualizerAvailable

                RowLayout {
                    anchors {
                        fill: parent
                        margins: App.Spacing.overallMargin
                    }
                    spacing: App.Spacing.overallMargin

                    Text {
                        text: "No system equalizer detected"
                        color: App.Style.primaryTextColor
                        font.pixelSize: App.Spacing.mediaPlayerTextSize
                    }

                    Item { Layout.fillWidth: true }

                    // In the noSystemEqContainer section
                    Button {
                        text: "Install EasyEffects"
                        implicitHeight: App.Spacing.overallMargin * 3
                        implicitWidth: App.Spacing.overallMargin * 12
                        
                        background: Rectangle {
                            color: App.Style.accent
                            radius: 5
                        }
                        
                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            font.pixelSize: App.Spacing.mediaPlayerTextSize
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        onClicked: {
                            var url = "";
                            if (Qt.platform.os === "windows") {
                                url = "https://sourceforge.net/projects/equalizerapo/";
                            } else if (Qt.platform.os === "linux") {
                                url = "https://flathub.org/apps/com.github.wwmm.easyeffects";
                            } else if (Qt.platform.os === "osx") {
                                url = "https://eqmac.app/";
                            }
                            
                            if (url) {
                                Qt.openUrlExternally(url);
                            }
                        }
                    }
                }
            }

            // Equalizer sliders
            Flickable {
                id: sliderFlickable
                anchors {
                    top: systemEqualizerAvailable ? systemEqContainer.bottom : noSystemEqContainer.bottom
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                    topMargin: App.Spacing.overallMargin
                }
                contentWidth: sliderRow.width
                contentHeight: height
                clip: true
                flickableDirection: Flickable.HorizontalFlick
                
                // Add fade effect on edges
                Rectangle {
                    anchors.left: parent.left
                    height: parent.height
                    width: 30
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.8) }
                        GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0) }
                    }
                    z: 1
                }
                
                Rectangle {
                    anchors.right: parent.right
                    height: parent.height
                    width: 30
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0) }
                        GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.8) }
                    }
                    z: 1
                }

                Row {
                    id: sliderRow
                    spacing: Math.max(10, (sliderFlickable.width - frequencies.length * 70) / (frequencies.length - 1))
                    height: sliderFlickable.height

                    Repeater {
                        model: frequencies.length
                        delegate: Column {
                            id: sliderColumn
                            spacing: 5
                            height: parent.height
                            width: 70

                            // dB labels
                            Text {
                                text: "+12 dB"
                                color: App.Style.secondaryTextColor
                                font.pixelSize: App.Spacing.mediaPlayerTextSize * 0.8
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            // Slider
                            Slider {
                                id: bandSlider
                                orientation: Qt.Vertical
                                height: parent.height - 150 // Leave room for labels
                                width: 60
                                anchors.horizontalCenter: parent.horizontalCenter
                                from: 12.0
                                to: -12.0
                                value: values[index]
                                stepSize: 0.1
                                enabled: equalizerActive || !systemEqualizerAvailable

                                background: Rectangle {
                                    x: bandSlider.width / 2 - width / 2
                                    y: 0
                                    width: 6
                                    height: bandSlider.height
                                    radius: 3
                                    color: bandSlider.enabled ? "#424242" : "#222222"

                                    // Colored portion
                                    Rectangle {
                                        width: parent.width
                                        height: bandSlider.visualPosition * parent.height
                                        y: bandSlider.height - height
                                        radius: 3
                                        
                                        gradient: Gradient {
                                            orientation: Gradient.Vertical
                                            GradientStop { 
                                                position: 0.0
                                                color: values[index] > 0 ? 
                                                       (bandSlider.enabled ? Qt.lighter(App.Style.accent, 1.2) : Qt.darker(App.Style.accent, 1.5)) : 
                                                       (bandSlider.enabled ? "#2979ff" : "#193a77") 
                                            }
                                            GradientStop { 
                                                position: 1.0 
                                                color: values[index] > 0 ? 
                                                       (bandSlider.enabled ? App.Style.accent : Qt.darker(App.Style.accent, 1.2)) : 
                                                       (bandSlider.enabled ? "#1565C0" : "#0d3c76")
                                            }
                                        }
                                    }
                                }

                                handle: Rectangle {
                                    x: bandSlider.leftPadding + bandSlider.availableWidth / 2 - width / 2
                                    y: bandSlider.topPadding + bandSlider.visualPosition * bandSlider.availableHeight - height / 2
                                    width: 24
                                    height: 12
                                    radius: 6
                                    color: bandSlider.pressed ? "#666666" : (bandSlider.enabled ? "#808080" : "#505050")
                                    border.color: bandSlider.pressed ? "#ffffff" : (bandSlider.enabled ? "#cccccc" : "#888888")
                                    opacity: bandSlider.enabled ? 1.0 : 0.7
                                    
                                    // Drop shadow for better visibility
                                    layer.enabled: bandSlider.enabled
                                    layer.effect: DropShadow {
                                        transparentBorder: true
                                        horizontalOffset: 2
                                        verticalOffset: 2
                                        radius: 8.0
                                        samples: 17
                                        color: "#80000000"
                                    }

                                    // Center line
                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: parent.width * 0.6
                                        height: 1
                                        color: bandSlider.enabled ? "#cccccc" : "#888888"
                                    }
                                }

                                onMoved: {
                                    equalizerManager.set_equalizer_band(index, value)
                                }
                                
                                // Double-click to reset band
                                MouseArea {
                                    anchors.fill: parent
                                    onDoubleClicked: {
                                        bandSlider.value = 0.0
                                        equalizerManager.set_equalizer_band(index, 0.0)
                                    }
                                    
                                    onPressed: function(mouse) {
                                        mouse.accepted = false  // Allow the Slider to receive the event
                                    }
                                }
                            }

                            // Zero line
                            Rectangle {
                                width: 30
                                height: 2
                                color: "#cccccc"
                                anchors.horizontalCenter: parent.horizontalCenter
                                
                                // Add a small pulse animation when value is near zero
                                NumberAnimation on opacity {
                                    from: 0.6
                                    to: 1.0
                                    duration: 1000
                                    running: Math.abs(values[index]) < 0.5
                                    loops: Animation.Infinite
                                    easing.type: Easing.InOutQuad
                                }
                            }

                            // -12 dB label
                            Text {
                                text: "-12 dB"
                                color: App.Style.secondaryTextColor
                                font.pixelSize: App.Spacing.mediaPlayerTextSize * 0.8
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            // Frequency label
                            Text {
                                text: frequencies[index] >= 1000 ? 
                                      (frequencies[index] / 1000) + "K" : 
                                      frequencies[index] + "Hz"
                                color: App.Style.primaryTextColor
                                font.pixelSize: App.Spacing.mediaPlayerTextSize
                                font.bold: true
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            // Value label
                            Text {
                                text: values[index].toFixed(1) + " dB"
                                color: values[index] > 0 ? 
                                       Qt.lighter(App.Style.accent, 1.3) :
                                       (values[index] < 0 ? "#2979ff" : App.Style.secondaryTextColor)
                                font.pixelSize: App.Spacing.mediaPlayerTextSize * 0.8
                                font.bold: Math.abs(values[index]) > 0.1
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }
                }

                // Add scrollbar if needed
                ScrollBar.horizontal: ScrollBar {
                    active: sliderRow.width > sliderFlickable.width
                    
                    background: Rectangle {
                        implicitHeight: 8
                        color: "transparent"
                        radius: height / 2
                    }
                    
                    contentItem: Rectangle {
                        implicitHeight: 8
                        implicitWidth: 100
                        radius: height / 2
                        color: App.Style.accent
                        opacity: 0.7
                    }
                }
            }
        }

        // Save preset dialog
        Dialog {
            id: savePresetDialog
            title: "Save Equalizer Preset"
            anchors.centerIn: parent
            width: parent.width * 0.8
            height: parent.height * 0.3
            modal: true
            
            background: Rectangle {
                color: Qt.rgba(0.1, 0.1, 0.1, 0.9)
                radius: 10
                border.color: App.Style.accent
                border.width: 1
            }
            
            header: Rectangle {
                height: App.Spacing.overallMargin * 5
                color: App.Style.accent
                radius: 10
                
                Text {
                    text: savePresetDialog.title
                    color: "white"
                    font.pixelSize: App.Spacing.mediaPlayerTextSize * 1.2
                    font.bold: true
                    anchors.centerIn: parent
                }
            }

            contentItem: ColumnLayout {
                spacing: App.Spacing.overallMargin
                
                Text {
                    text: "Preset Name:"
                    color: App.Style.primaryTextColor
                    font.pixelSize: App.Spacing.mediaPlayerTextSize
                    font.bold: true
                }
                
                TextField {
                    id: presetNameField
                    Layout.fillWidth: true
                    placeholderText: "Enter preset name"
                    color: App.Style.primaryTextColor
                    font.pixelSize: App.Spacing.mediaPlayerTextSize
                    
                    background: Rectangle {
                        color: Qt.rgba(0.15, 0.15, 0.15, 1.0)
                        radius: 5
                        border.color: App.Style.accent
                        border.width: 1
                    }
                    
                    // Visual feedback when invalid
                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        border.color: "red"
                        border.width: 2
                        radius: 5
                        visible: presetNameField.text.trim() === "" || 
                                 presetNameField.text.trim() === "Custom" ||
                                 presetNameField.text.trim() === "Flat"
                        opacity: 0.7
                    }
                    
                    // Show warning text
                    Text {
                        anchors {
                            top: parent.bottom
                            left: parent.left
                            topMargin: 5
                        }
                        color: "red"
                        font.pixelSize: App.Spacing.mediaPlayerTextSize * 0.7
                        text: {
                            if (presetNameField.text.trim() === "")
                                return "Preset name cannot be empty"
                            else if (presetNameField.text.trim() === "Custom" || 
                                    presetNameField.text.trim() === "Flat")
                                return "Reserved name, please choose another"
                            else if (equalizerManager && equalizerManager.is_builtin_preset(presetNameField.text.trim()))
                                return "Will overwrite built-in preset"
                            else
                                return ""
                        }
                        visible: text !== ""
                    }
                }
                
                Item { 
                    Layout.fillHeight: true 
                }
            }
            
            footer: DialogButtonBox {
                background: Rectangle {
                    color: "transparent"
                }
                
                Button {
                    text: "SAVE"
                    DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
                    enabled: presetNameField.text.trim() !== "" && 
                             presetNameField.text.trim() !== "Custom"
                    
                    background: Rectangle {
                        color: parent.enabled ? App.Style.accent : Qt.darker(App.Style.accent, 2.0)
                        radius: 5
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        color: parent.enabled ? "white" : "#aaaaaa"
                        font.pixelSize: App.Spacing.mediaPlayerTextSize
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                
                Button {
                    text: "CANCEL"
                    DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
                    
                    background: Rectangle {
                        color: "#666666"
                        radius: 5
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.pixelSize: App.Spacing.mediaPlayerTextSize
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                
                onAccepted: {
                    if (presetNameField.text.trim() !== "" && 
                        presetNameField.text.trim() !== "Custom") {
                        equalizerManager.save_preset(presetNameField.text.trim())
                        savePresetDialog.close()
                        
                        // Refresh the preset list
                        presets = equalizerManager.get_available_presets()
                        currentPreset = equalizerManager.get_current_preset()
                    }
                }
                
                onRejected: {
                    savePresetDialog.close()
                }
            }
        }
        
        // Context menu for presets
        Menu {
            id: presetContextMenu
            property string selectedPreset: ""
            
            background: Rectangle {
                color: Qt.rgba(0.1, 0.1, 0.1, 0.95)
                border.color: App.Style.accent
                border.width: 1
                radius: 5
            }
            
            MenuItem {
                text: "Delete Preset"
                enabled: equalizerManager && !equalizerManager.is_builtin_preset(presetContextMenu.selectedPreset)
                
                contentItem: Text {
                    text: parent.text
                    color: parent.enabled ? App.Style.primaryTextColor : "#666666"
                    font.pixelSize: App.Spacing.mediaPlayerTextSize
                }
                
                background: Rectangle {
                    color: parent.highlighted ? Qt.rgba(0.3, 0.3, 0.3, 0.5) : "transparent"
                }
                
                onTriggered: {
                    if (equalizerManager) {
                        equalizerManager.delete_preset(presetContextMenu.selectedPreset)
                        
                        // Refresh the preset list
                        presets = equalizerManager.get_available_presets()
                        currentPreset = equalizerManager.get_current_preset()
                    }
                }
            }
        }

        // Info button
        Button {
            id: infoButton
            width: 30
            height: 30
            anchors {
                right: parent.right
                top: parent.top
                margins: App.Spacing.overallMargin
            }
            
            background: Rectangle {
                radius: width / 2
                color: "#444444"
                border.color: "#999999"
                border.width: 1
            }
            
            contentItem: Text {
                text: "i"
                color: "white"
                font.pixelSize: 16
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            
            onClicked: {
                helpDialog.open()
            }
        }
        
        // Help dialog
        Dialog {
            id: helpDialog
            title: "Equalizer Help"
            width: parent.width * 0.8
            height: parent.height * 0.6
            anchors.centerIn: parent
            modal: true
            
            background: Rectangle {
                color: Qt.rgba(0.1, 0.1, 0.1, 0.95)
                radius: 10
                border.color: App.Style.accent
                border.width: 1
            }
            
            header: Rectangle {
                height: App.Spacing.overallMargin * 5
                color: App.Style.accent
                radius: 10
                
                Text {
                    text: helpDialog.title
                    color: "white"
                    font.pixelSize: App.Spacing.mediaPlayerTextSize * 1.2
                    font.bold: true
                    anchors.centerIn: parent
                }
            }
            
            contentItem: ScrollView {
                clip: true
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                
                ColumnLayout {
                    width: helpDialog.width - 40
                    spacing: App.Spacing.overallMargin
                    
                    Text {
                        text: "Using the Equalizer"
                        color: App.Style.primaryTextColor
                        font.pixelSize: App.Spacing.mediaPlayerTextSize * 1.1
                        font.bold: true
                        Layout.topMargin: App.Spacing.overallMargin
                    }
                    
                    Text {
                        text: "This equalizer allows you to adjust audio frequencies to customize your listening experience. It works with system-wide equalizer software for the best audio quality."
                        color: App.Style.secondaryTextColor
                        font.pixelSize: App.Spacing.mediaPlayerTextSize
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                    
                    Text {
                        text: "Presets"
                        color: App.Style.primaryTextColor
                        font.pixelSize: App.Spacing.mediaPlayerTextSize * 1.1
                        font.bold: true
                        Layout.topMargin: App.Spacing.overallMargin
                    }
                    
                    Text {
                        text: "Choose from built-in presets optimized for different music genres, or create and save your own custom presets."
                        color: App.Style.secondaryTextColor
                        font.pixelSize: App.Spacing.mediaPlayerTextSize
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                    
                    Text {
                        text: "Frequency Bands"
                        color: App.Style.primaryTextColor
                        font.pixelSize: App.Spacing.mediaPlayerTextSize * 1.1
                        font.bold: true
                        Layout.topMargin: App.Spacing.overallMargin
                    }
                    
                    Text {
                        text: "• Low Frequencies (32-125 Hz): Bass, deep sounds\n• Mid Frequencies (250-2000 Hz): Vocals, most instruments\n• High Frequencies (4000-16000 Hz): Cymbals, details"
                        color: App.Style.secondaryTextColor
                        font.pixelSize: App.Spacing.mediaPlayerTextSize
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                    
                    Text {
                        text: "Tips"
                        color: App.Style.primaryTextColor
                        font.pixelSize: App.Spacing.mediaPlayerTextSize * 1.1
                        font.bold: true
                        Layout.topMargin: App.Spacing.overallMargin
                    }
                    
                    Text {
                        text: "• Double-click any slider to reset it to 0 dB\n• Use subtle adjustments for best results\n• Enable the system equalizer toggle to apply changes"
                        color: App.Style.secondaryTextColor
                        font.pixelSize: App.Spacing.mediaPlayerTextSize
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                    
                    Text {
                        text: "System Requirements"
                        color: App.Style.primaryTextColor
                        font.pixelSize: App.Spacing.mediaPlayerTextSize * 1.1
                        font.bold: true
                        Layout.topMargin: App.Spacing.overallMargin
                    }

                    Text {
                        text: "For best results, please install a system equalizer:\n• Windows: Equalizer APO\n• macOS: eqMac\n• Linux: EasyEffects (with PipeWire audio server)"
                        color: App.Style.secondaryTextColor
                        font.pixelSize: App.Spacing.mediaPlayerTextSize
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                        Layout.bottomMargin: App.Spacing.overallMargin
                    }
                }
            }
            
            footer: DialogButtonBox {
                background: Rectangle { color: "transparent" }
                
                Button {
                    text: "CLOSE"
                    DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
                    
                    background: Rectangle {
                        color: App.Style.accent
                        radius: 5
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.pixelSize: App.Spacing.mediaPlayerTextSize
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                
                onAccepted: {
                    helpDialog.close()
                }
            }
        }
    }

    // Connect to equalizerManager signals
    Connections {
        target: equalizerManager
        
        function onEqualizerBandsChanged(newValues) {
            values = newValues
        }
        
        function onPresetChanged(newPreset) {
            currentPreset = newPreset
            presetComboBox.currentIndex = presets.indexOf(newPreset)
        }
        
        function onEqualizerStatusChanged(isActive) {
            equalizerActive = isActive
            eqActiveSwitch.checked = isActive
        }
    }

    // Initial setup
    Component.onCompleted: {
        // If needed, additional one-time setup code
        if (equalizerManager) {
            // Update UI based on current settings
            values = equalizerManager.get_equalizer_values()
            frequencies = equalizerManager.get_equalizer_frequencies()
            presets = equalizerManager.get_available_presets()
            currentPreset = equalizerManager.get_current_preset()
            
            // Check system equalizer status
            systemEqualizerAvailable = equalizerManager.is_system_equalizer_available()
            equalizerActive = equalizerManager.is_equalizer_active()
        }
    }
}