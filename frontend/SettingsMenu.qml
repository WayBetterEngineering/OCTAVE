import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
import "." as App

Item {
    id: settingsMenu
    required property var stackView
    required property var mainWindow
    required property string initialSection
    
    property string currentSection: initialSection
    
    component SettingLabel: Label {
        color: App.Style.primaryTextColor
        font.pixelSize: App.Spacing.overallText
        Layout.fillWidth: true
    }
    
    component SettingDescription: Text {
        color: App.Style.secondaryTextColor
        font.pixelSize: App.Spacing.overallText * 0.8
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
    }
    
    component SettingsDivider: Rectangle {
        Layout.fillWidth: true
        height: 1
        color: Qt.rgba(App.Style.primaryTextColor.r, App.Style.primaryTextColor.g, App.Style.primaryTextColor.b, 0.1)
        Layout.topMargin: App.Spacing.overallSpacing
        Layout.bottomMargin: App.Spacing.overallSpacing
    }
    
    component SettingsSlider: Slider {
        id: control
        Layout.fillWidth: true
        
        // Slightly increase the implicit height for more touch area without changing appearance
        implicitHeight: App.Spacing.overallSliderHeight * 2.5
        
        property color activeColor: App.Style.accent
        property double visualValue: value
        property string valueDisplay: ""
        
        handle: Rectangle {
            x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
            y: control.topPadding + control.availableHeight / 2 - height / 2
            width: App.Spacing.overallSliderWidth
            height: App.Spacing.overallSliderHeight
            radius: App.Spacing.overallSliderRadius
            color: control.pressed ? Qt.darker(control.activeColor, 1.1) : control.activeColor
            
            Behavior on color { ColorAnimation { duration: 150 } }
        }
        
        background: Rectangle {
            x: control.leftPadding
            y: control.topPadding + control.availableHeight / 2 - height / 2
            width: control.availableWidth
            height: App.Spacing.overallSliderHeight / 2
            radius: height / 2
            color: App.Style.secondaryTextColor
            
            Rectangle {
                width: control.visualPosition * parent.width
                height: parent.height
                color: control.activeColor
                radius: parent.radius
            }
        }
        
        // Make the whole track area clickable while preserving original appearance
        MouseArea {
            anchors.fill: parent
            onPressed: {
                // Calculate value based on mouse position
                var newPos = Math.max(0, Math.min(1, (mouseX - control.leftPadding) / control.availableWidth))
                control.value = control.from + newPos * (control.to - control.from)
                control.pressed = true
                mouse.accepted = false  // Allow the event to propagate to the Slider
            }
            onReleased: {
                control.pressed = false
                mouse.accepted = false
            }
        }
    }
    
    component SettingsSwitch: Switch {
        id: control
        
        indicator: Rectangle {
            implicitWidth: 48
            implicitHeight: 26
            x: control.leftPadding
            y: control.height / 2 - height / 2
            radius: 13
            color: control.checked ? App.Style.accent : App.Style.secondaryTextColor
            border.color: control.checked ? App.Style.accent : App.Style.secondaryTextColor
            
            Rectangle {
                x: control.checked ? parent.width - width - 3 : 3
                width: 20
                height: 20
                radius: 10
                anchors.verticalCenter: parent.verticalCenter
                color: "white"
                
                Behavior on x { NumberAnimation { duration: 150 } }
            }
        }
        
        contentItem: Text {
            text: control.text
            color: App.Style.primaryTextColor
            verticalAlignment: Text.AlignVCenter
            leftPadding: control.indicator.width + control.spacing
        }
    }
    
    component SettingsRadio: RadioButton {
        id: control
        
        indicator: Rectangle {
            implicitWidth: 20
            implicitHeight: 20
            x: control.leftPadding
            y: control.height / 2 - height / 2
            radius: 10
            border.color: control.checked ? App.Style.accent : App.Style.secondaryTextColor
            border.width: 2
            
            Rectangle {
                width: 10
                height: 10
                x: 5
                y: 5
                radius: 5
                color: control.checked ? App.Style.accent : "transparent"
                
                Behavior on color { ColorAnimation { duration: 150 } }
            }
        }
        
        contentItem: Text {
            text: control.text
            color: App.Style.primaryTextColor
            verticalAlignment: Text.AlignVCenter
            leftPadding: control.indicator.width + control.spacing
            elide: Text.ElideRight
            width: control.width - control.indicator.width - control.spacing - 10
        }
    }
    

    component SettingsTextField: TextField {
        id: control
        Layout.preferredHeight: App.Spacing.formElementHeight
        Layout.preferredWidth: 250
        Layout.maximumWidth: 400
        color: App.Style.primaryTextColor
        font.pixelSize: App.Spacing.overallText
        placeholderTextColor: App.Style.secondaryTextColor
        leftPadding: 20  // Increased from 15
        rightPadding: 20 // Increased from 15
        verticalAlignment: TextInput.AlignVCenter
        
        background: Rectangle {
            color: App.Style.hoverColor
            radius: 4
            border.color: control.activeFocus ? App.Style.accent : "transparent"
            border.width: 1
            
            // Highlight effect on hover
            Rectangle {
                anchors.fill: parent
                radius: 4
                color: control.hovered ? Qt.rgba(1, 1, 1, 0.05) : "transparent"
            }
            
            Behavior on border.color { ColorAnimation { duration: 200 } }
        }
    }
    

    component SettingsDropdown: Button {
        id: control
        Layout.preferredHeight: App.Spacing.formElementHeight
        Layout.preferredWidth: 300
        Layout.maximumWidth: 400
        Layout.minimumWidth: 250  // Ensure dropdown is never too small
        Layout.fillWidth: true
        property string displayText: ""
        property var options: []
        property var onSelected: function(value) {}
        
        contentItem: Item {
            anchors.fill: parent
            
            Text {
                id: labelText
                text: control.displayText
                color: App.Style.primaryTextColor
                font.pixelSize: App.Spacing.overallText
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
                
                anchors {
                    left: parent.left
                    leftMargin: 20  // Increased from 15
                    right: arrowText.left
                    rightMargin: 15
                    verticalCenter: parent.verticalCenter
                }
            }
            
            Text {
                id: arrowText
                text: "▼"
                color: App.Style.primaryTextColor
                font.pixelSize: App.Spacing.overallText * 0.8
                verticalAlignment: Text.AlignVCenter
                
                anchors {
                    right: parent.right
                    rightMargin: 20  // Increased from 15
                    verticalCenter: parent.verticalCenter
                }
            }
        }
        
        background: Rectangle {
            color: control.pressed ? Qt.darker(App.Style.hoverColor, 1.2) : 
                   control.hovered ? Qt.darker(App.Style.hoverColor, 1.1) : App.Style.hoverColor
            radius: 4
            
            // Highlight effect
            Rectangle {
                anchors.fill: parent
                radius: 4
                color: control.hovered ? Qt.rgba(1, 1, 1, 0.05) : "transparent"
            }
            
            Behavior on color { ColorAnimation { duration: 100 } }
        }
        
        property var dropdownPopup: Popup {
            id: popup
            width: control.width
            y: control.height
            height: Math.min(contentItem.implicitHeight, 300)
            
            background: Rectangle {
                color: App.Style.backgroundColor
                border.color: App.Style.accent
                border.width: 1
                radius: 6
            }
            
            contentItem: ListView {
                id: optionsList
                implicitHeight: contentHeight
                model: control.options
                clip: true
                
                delegate: ItemDelegate {
                    required property int index
                    required property var modelData
                    
                    width: parent.width
                    height: 45  // Increased from 40
                    
                    contentItem: Text {
                        text: modelData
                        color: App.Style.primaryTextColor
                        font.pixelSize: App.Spacing.overallText
                        leftPadding: 20  // Increased from 15
                        rightPadding: 20 // Increased from 15
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                    
                    background: Rectangle {
                        color: parent.hovered ? App.Style.hoverColor : "transparent"
                    }
                    
                    onClicked: {
                        control.onSelected(modelData)
                        popup.close()
                    }
                }
                
                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                    interactive: true
                    width: 8
                    anchors.right: parent.right
                }
            }
        }
        
        onClicked: {
            dropdownPopup.opened ? dropdownPopup.close() : dropdownPopup.open()
        }
    }


    component SettingsToggle: Item {
        id: control
        height: 60  // Increased from 40
        Layout.preferredHeight: 60  // Increased from 40
        Layout.fillWidth: true
        
        property bool checked: false
        property string text: ""
        property color activeColor: App.Style.accent
        property color inactiveColor: App.Style.hoverColor
        signal toggled(bool checked)
        
        RowLayout {
            anchors.fill: parent
            spacing: App.Spacing.overallSpacing * 2
            
            // Left-side label
            Text {
                text: control.text
                color: App.Style.primaryTextColor
                font.pixelSize: App.Spacing.overallText * 1.1  // Increased text size
                Layout.fillWidth: true
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        control.checked = !control.checked
                        control.toggled(control.checked)
                    }
                }
            }
            
            // Modern toggle with subtle animations
            Item {
                width: 80  // Increased from 64
                height: 40  // Increased from 32
                
                // Main track - flatter design
                Rectangle {
                    id: track
                    anchors.fill: parent
                    radius: height / 2
                    color: control.checked ? Qt.rgba(control.activeColor.r, control.activeColor.g, control.activeColor.b, 0.3) : 
                                        Qt.rgba(control.inactiveColor.r, control.inactiveColor.g, control.inactiveColor.b, 0.3)
                    
                    // Subtle gradient overlay
                    Rectangle {
                        anchors.fill: parent
                        radius: parent.radius
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "transparent" }
                            GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.05) }
                        }
                    }
                    
                    // Animated highlight that expands from the handle
                    Rectangle {
                        id: highlightTrack
                        width: control.checked ? parent.width : 0
                        height: parent.height
                        radius: parent.radius
                        anchors.right: control.checked ? parent.right : undefined
                        anchors.left: !control.checked ? parent.left : undefined
                        color: control.activeColor
                        opacity: control.checked ? 0.5 : 0
                        
                        Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutQuad } }
                        Behavior on opacity { NumberAnimation { duration: 300 } }
                    }
                    
                    // Status text inside track
                    Text {
                        anchors {
                            left: control.checked ? undefined : parent.left
                            right: control.checked ? parent.right : undefined
                            margins: 10  // Increased from 8
                            verticalCenter: parent.verticalCenter
                        }
                        text: control.checked ? "ON" : "OFF"
                        font.pixelSize: App.Spacing.overallText * 0.8  // Increased text size
                        font.bold: true
                        color: control.checked ? control.activeColor : Qt.rgba(control.inactiveColor.r, 
                                                                            control.inactiveColor.g, 
                                                                            control.inactiveColor.b, 0.7)
                        visible: width < (parent.width - handle.width - 10)
                        
                        Behavior on color { ColorAnimation { duration: 200 } }
                    }
                }
                
                // Handle with shadow and subtle effects
                Rectangle {
                    id: handle
                    width: 40  // Increased from 32
                    height: 40  // Increased from 32
                    radius: width / 2
                    x: control.checked ? parent.width - width : 0
                    y: 0
                    
                    // Create a subtle layer effect
                    color: "white"
                    
                    // Inner indicator for "on" state
                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width * 0.4
                        height: width
                        radius: width / 2
                        color: control.activeColor
                        opacity: control.checked ? 1 : 0
                        scale: control.checked ? 1 : 0.5
                        
                        Behavior on opacity { NumberAnimation { duration: 200 } }
                        Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
                    }
                    
                    // Handle shadow
                    layer.enabled: true
                    layer.effect: DropShadow {
                        verticalOffset: 2
                        radius: 6.0
                        samples: 17
                        color: Qt.rgba(0, 0, 0, 0.2)
                    }
                    
                    // Create subtle animation on click
                    scale: controlMouseArea.pressed ? 0.95 : 1.0
                    
                    Behavior on x { 
                        NumberAnimation { 
                            duration: 300
                            easing.type: Easing.OutBack
                            easing.overshoot: 0.6
                        }
                    }
                    Behavior on scale { NumberAnimation { duration: 100 } }
                }
                
                // Interactive area
                MouseArea {
                    id: controlMouseArea
                    anchors.fill: parent
                    onClicked: {
                        control.checked = !control.checked
                        control.toggled(control.checked)
                    }
                    
                    // Add subtle pulse animation on click
                    onPressed: {
                        pulseAnimation.start()
                    }
                    
                    SequentialAnimation {
                        id: pulseAnimation
                        PropertyAnimation {
                            target: handle
                            property: "scale"
                            to: 0.9
                            duration: 100
                        }
                        PropertyAnimation {
                            target: handle
                            property: "scale"
                            to: 1.0
                            duration: 100
                        }
                    }
                }
            }
        }
    }

    component SettingsSegmentedControl: RowLayout {
        id: control
        spacing: 1
        Layout.fillWidth: true
        
        property var options: []
        property string currentValue: ""
        property var onSelected: function(value) {}
        
        Repeater {
            model: control.options
            
            delegate: Rectangle {
                required property int index
                required property var modelData
                
                id: segmentRect
                Layout.fillWidth: true
                Layout.minimumWidth: 80
                height: App.Spacing.formElementHeight
                
                color: modelData === control.currentValue ? App.Style.accent : App.Style.hoverColor
                border.color: App.Style.hoverColor
                
                // Add a property to track hover state
                property bool isHovered: false
                
                Text {
                    anchors.centerIn: parent
                    text: modelData
                    color: modelData === control.currentValue ? "white" : App.Style.primaryTextColor
                    font.pixelSize: App.Spacing.overallText
                }
                
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: control.onSelected(modelData)
                    onEntered: segmentRect.isHovered = true
                    onExited: segmentRect.isHovered = false
                }
                
                // Highlight effect using the property
                Rectangle {
                    anchors.fill: parent
                    color: segmentRect.isHovered ? Qt.rgba(1, 1, 1, 0.05) : "transparent"
                    visible: modelData !== control.currentValue // Only show hover on non-selected segments
                }
            }
        }
    }

    component SettingsChips: Flow {
        id: control
        spacing: App.Spacing.overallSpacing
        Layout.fillWidth: true
        
        property var options: []
        property string currentValue: ""
        property var onSelected: function(value) {}
        
        Repeater {
            model: control.options
            
            delegate: Rectangle {
                required property int index
                required property var modelData
                
                id: chipRect
                width: chipText.width + App.Spacing.overallSpacing * 3
                height: App.Spacing.formElementHeight * 0.8
                radius: height / 2
                
                color: modelData === control.currentValue ? App.Style.accent : App.Style.hoverColor
                property bool isHovered: false
                
                // Add subtle border for non-selected chips
                border.width: modelData === control.currentValue ? 0 : 1
                border.color: Qt.rgba(App.Style.primaryTextColor.r, 
                                    App.Style.primaryTextColor.g, 
                                    App.Style.primaryTextColor.b, 0.1)
                
                Text {
                    id: chipText
                    anchors.centerIn: parent
                    text: modelData
                    color: modelData === control.currentValue ? "white" : App.Style.primaryTextColor
                    font.pixelSize: App.Spacing.overallText
                }
                
                MouseArea {
                    id: chipMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: control.onSelected(modelData)
                    onEntered: { 
                        chipRect.isHovered = true
                        chipRect.scale = 1.05
                    }
                    onExited: { 
                        chipRect.isHovered = false
                        chipRect.scale = 1.0
                    }
                }
                
                // Subtle shadow for selected chips
                layer.enabled: modelData === control.currentValue
                layer.effect: DropShadow {
                    horizontalOffset: 0
                    verticalOffset: 2
                    radius: 4.0
                    samples: 9
                    color: Qt.rgba(0, 0, 0, 0.2)
                }
                
                // Animation for scale changes
                Behavior on scale {
                    NumberAnimation { 
                        duration: 100
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
    }
    
    component ValueDisplay: Text {
        color: App.Style.secondaryTextColor
        font.pixelSize: App.Spacing.overallText
        Layout.topMargin: 2
    }
    
    // MAIN LAYOUT
    Rectangle {
        anchors.fill: parent
        color: App.Style.backgroundColor
        
        RowLayout {
            anchors.fill: parent
            spacing: 0
            
            
            Rectangle { // Left Navigation Panel
                Layout.preferredWidth: App.Spacing.settingsNavWidth
                Layout.fillHeight: true
                color: App.Style.sidebarColor
                
                ColumnLayout {
                    anchors {
                        fill: parent
                        margins: App.Spacing.settingsNavMargin
                    }
                    spacing: 0
                    
                    ListView {
                        id: navListView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        interactive: true
                        clip: true
                        
                        model: ListModel {
                            ListElement { name: "Device Settings"; section: "deviceSettings" }
                            ListElement { name: "Media Settings"; section: "mediaSettings" }
                            ListElement { name: "Display Settings"; section: "displaySettings" }
                            ListElement { name: "OBD Settings"; section: "obdSettings" }
                            ListElement { name: "Clock Settings"; section: "clockSettings" }
                            ListElement { name: "About"; section: "about" }
                        }
                        
                        delegate: Item {
                            required property string name
                            required property string section
                            
                            width: navListView.width
                            height: App.Spacing.settingsButtonHeight
                            
                            // Active indicator
                            Rectangle {
                                visible: currentSection === section
                                width: 4
                                height: parent.height
                                color: App.Style.accent
                                anchors.left: parent.left
                            }
                            
                            // Background
                            Rectangle {
                                anchors {
                                    left: parent.left
                                    leftMargin: 4 // Space for indicator
                                    right: parent.right
                                    top: parent.top
                                    bottom: parent.bottom
                                }
                                color: currentSection === section ? App.Style.hoverColor : "transparent"
                                
                                Behavior on color { ColorAnimation { duration: 150 } }
                            }
                            
                            // Text
                            Text {
                                anchors {
                                    left: parent.left
                                    leftMargin: App.Spacing.overallMargin
                                    right: parent.right
                                    rightMargin: 5
                                    verticalCenter: parent.verticalCenter
                                }
                                text: name
                                color: currentSection === section ? App.Style.primaryTextColor : App.Style.secondaryTextColor
                                font.pixelSize: App.Spacing.overallText
                                elide: Text.ElideRight
                            }
                            
                            // Entire area clickable
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    currentSection = section
                                    mainWindow.lastSettingsSection = section
                                }
                                hoverEnabled: true
                                
                                // Hover effect
                                onEntered: {
                                    if (currentSection !== section) {
                                        navHoverRectangle.visible = true
                                    }
                                }
                                onExited: {
                                    navHoverRectangle.visible = false
                                }
                            }
                            
                            // Hover effect
                            Rectangle {
                                id: navHoverRectangle
                                visible: false
                                anchors {
                                    left: parent.left
                                    leftMargin: 4
                                    right: parent.right
                                    top: parent.top
                                    bottom: parent.bottom
                                }
                                color: Qt.rgba(App.Style.hoverColor.r, App.Style.hoverColor.g, App.Style.hoverColor.b, 0.3)
                            }
                        }
                    }
                }
            }
            
            
            Rectangle { // Right Content Area
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: App.Style.contentColor
                
                StackLayout {
                    id: contentStack
                    anchors {
                        fill: parent
                        margins: App.Spacing.settingsContentMargin
                    }
                    currentIndex: {
                        switch(currentSection) {
                            case "deviceSettings": return 0;
                            case "mediaSettings": return 1;
                            case "displaySettings": return 2;
                            case "obdSettings": return 3;
                            case "clockSettings": return 4;
                            case "about": return 5;
                            default: return 0;
                        }
                    }
                    
                    
                    ScrollView { // Device Settings Page
                        contentWidth: parent.width
                        ScrollBar.vertical.policy: ScrollBar.AsNeeded
                        clip: true
                        
                        ColumnLayout {
                            width: parent.width

                            // Device Name Setting
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: App.Spacing.rowSpacing
                                
                                SettingLabel {
                                    text: "Device Name"
                                }
                                
                                SettingsTextField {
                                    id: deviceName
                                    Layout.fillWidth: true
                                    text: settingsManager ? settingsManager.deviceName : ""
                                    
                                    onEditingFinished: {
                                        if (text.trim() !== "" && settingsManager) {
                                            mainWindow.updateDeviceName(text)
                                        }
                                    }
                                }
                            }
                            
                            // Future device settings can be added here
                            
                            Item { Layout.fillHeight: true } // Spacer
                        }
                    }
                    
                    ScrollView { // Media Settings Page
                        contentWidth: parent.width
                        ScrollBar.vertical.policy: ScrollBar.AsNeeded
                        clip: true
                        
                        ColumnLayout {
                            width: parent.width

                            // Media Folder
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: App.Spacing.rowSpacing
                                
                                SettingLabel {
                                    text: "Media Source Folder"
                                }
                                
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: App.Spacing.itemSpacing
                                    
                                    SettingsTextField {
                                        id: mediaFolderField
                                        Layout.fillWidth: true
                                        text: settingsManager ? settingsManager.mediaFolder : ""
                                        
                                        // Update when setting changes externally
                                        Connections {
                                            target: settingsManager
                                            function onMediaFolderChanged() {
                                                mediaFolderField.text = settingsManager.mediaFolder
                                            }
                                        }
                                        
                                        onEditingFinished: {
                                            if (text.trim() !== "" && settingsManager) {
                                                settingsManager.save_media_folder(text)
                                            }
                                        }
                                    }
                                    
                                    // Save directory button
                                    Button {
                                        id: saveDirectoryButton
                                        text: "Save"
                                        Layout.preferredWidth: 80
                                        implicitHeight: mediaFolderField.height
                                        
                                        background: Rectangle {
                                            color: parent.pressed ? Qt.darker(App.Style.accent, 1.4) : 
                                                parent.hovered ? Qt.darker(App.Style.accent, 1.2) : App.Style.accent
                                            radius: 6
                                            border.width: 1
                                            border.color: Qt.darker(App.Style.accent, 1.3)
                                        }
                                        
                                        contentItem: Text {
                                            text: parent.text
                                            color: "white"
                                            font.pixelSize: App.Spacing.overallText * 0.9
                                            font.bold: true
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                        
                                        ToolTip.visible: hovered
                                        ToolTip.text: "Save current directory to quick access list"
                                        ToolTip.delay: 300
                                        
                                        onClicked: {
                                            if (settingsManager && mediaFolderField.text.trim() !== "") {
                                                settingsManager.save_to_directory_history(mediaFolderField.text)
                                            }
                                        }
                                    }
                                    
                                    // Delete current folder button - Always visible if text field has content
                                    Button {
                                        id: deleteCurrentButton
                                        text: "Delete"
                                        Layout.preferredWidth: 80
                                        implicitHeight: mediaFolderField.height
                                        visible: mediaFolderField.text.trim() !== ""
                                        
                                        background: Rectangle {
                                            color: parent.pressed ? Qt.darker("#ff6666", 1.2) : 
                                                parent.hovered ? Qt.darker("#ff6666", 1.1) : "#ff6666"
                                            radius: 6
                                            border.width: 1
                                            border.color: Qt.darker("#ff6666", 1.3)
                                        }
                                        
                                        contentItem: Text {
                                            text: parent.text
                                            color: "white"
                                            font.pixelSize: App.Spacing.overallText * 0.9
                                            font.bold: true
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                        
                                        ToolTip.visible: hovered
                                        ToolTip.text: "Remove current directory from saved list"
                                        ToolTip.delay: 300
                                        
                                        onClicked: {
                                            if (settingsManager && mediaFolderField.text.trim() !== "") {
                                                settingsManager.remove_from_directory_history(mediaFolderField.text)
                                            }
                                        }
                                    }
                                }
                                
                                // Saved Directories Section - Simplified Chips
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: App.Spacing.rowSpacing
                                    Layout.topMargin: App.Spacing.rowSpacing
                                    
                                    SettingLabel {
                                        text: "Saved Media Directories"
                                        font.pixelSize: App.Spacing.overallText * 0.9
                                    }
                                    
                                    // Flow layout for directory chips
                                    Flow {
                                        id: directoriesFlow
                                        Layout.fillWidth: true
                                        spacing: App.Spacing.overallSpacing
                                        Layout.preferredHeight: childrenRect.height
                                        Layout.maximumHeight: 180
                                        
                                        // Empty state message when no directories
                                        Text {
                                            visible: !settingsManager || !settingsManager.directoryHistory || settingsManager.directoryHistory.length === 0
                                            text: "No saved directories yet"
                                            color: App.Style.secondaryTextColor
                                            font.pixelSize: App.Spacing.overallText * 0.9
                                            font.italic: true
                                            width: parent.width
                                            height: 40
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                        
                                        // Directory chips
                                        Repeater {
                                            model: settingsManager ? settingsManager.directoryHistory : []
                                            
                                            delegate: Rectangle {
                                                id: directoryChip
                                                property bool isActive: settingsManager && settingsManager.mediaFolder === modelData
                                                property bool isHovered: false
                                                
                                                // Calculate width based on text width
                                                width: directoryText.contentWidth + App.Spacing.overallSpacing * 3
                                                height: App.Spacing.formElementHeight * 0.8
                                                radius: height / 2
                                                
                                                // Use accent color for active directory
                                                color: isActive ? App.Style.accent : isHovered ? Qt.darker(App.Style.hoverColor, 1.1) : App.Style.hoverColor
                                                
                                                // Add subtle border
                                                border.width: 1
                                                border.color: isActive ? Qt.darker(App.Style.accent, 1.2) :
                                                            Qt.rgba(App.Style.primaryTextColor.r, 
                                                                    App.Style.primaryTextColor.g, 
                                                                    App.Style.primaryTextColor.b, 0.1)
                                                                    
                                                // Animation for scale changes
                                                scale: isHovered ? 1.05 : 1.0
                                                
                                                Behavior on scale {
                                                    NumberAnimation { 
                                                        duration: 100
                                                        easing.type: Easing.OutCubic
                                                    }
                                                }
                                                
                                                // Transition for color changes
                                                Behavior on color {
                                                    ColorAnimation { duration: 150 }
                                                }
                                                
                                                // Directory name with elide
                                                Text {
                                                    id: directoryText
                                                    anchors.centerIn: parent
                                                    text: {
                                                        // Extract just the folder name for display
                                                        const parts = modelData.split(/[/\\]/)
                                                        const folderName = parts[parts.length - 1]
                                                        return folderName || modelData
                                                    }
                                                    color: directoryChip.isActive ? "white" : App.Style.primaryTextColor
                                                    font.pixelSize: App.Spacing.overallText * 0.8
                                                    font.bold: directoryChip.isActive
                                                    elide: Text.ElideRight
                                                    
                                                    // Show the full path on hover
                                                    ToolTip.visible: directoryChip.isHovered
                                                    ToolTip.text: modelData
                                                    ToolTip.delay: 500
                                                    
                                                    // Transition for text color
                                                    Behavior on color {
                                                        ColorAnimation { duration: 150 }
                                                    }
                                                }
                                                
                                                // Click to use this directory
                                                MouseArea {
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    onEntered: directoryChip.isHovered = true
                                                    onExited: directoryChip.isHovered = false
                                                    onClicked: {
                                                        if (settingsManager) {
                                                            settingsManager.save_media_folder(modelData)
                                                        }
                                                    }
                                                }
                                                
                                                // Update active state when media folder changes
                                                Connections {
                                                    target: settingsManager
                                                    function onMediaFolderChanged() {
                                                        directoryChip.isActive = settingsManager && settingsManager.mediaFolder === modelData
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                SettingDescription {
                                    text: "Type or paste the full path to the folder containing your music files. Save frequently used directories for quick access."
                                }
                            }
                            
                            SettingsDivider {}

                            // Startup Volume
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: App.Spacing.rowSpacing
                                
                                SettingLabel {
                                    text: "Startup Volume"
                                }
                                
                                SettingsSlider {
                                    id: volumeSlider
                                    from: 0
                                    to: 1
                                    stepSize: 0.01
                                    value: settingsManager ? settingsManager.startUpVolume : 0.5
                                    visualValue: Math.round(Math.sqrt(value) * 100)
                                    valueDisplay: visualValue + "%"
                                    activeColor: App.Style.volumeSliderColor
                                    
                                    // Debounce updates
                                    Timer {
                                        id: volumeUpdateTimer
                                        interval: 100
                                        running: false
                                        repeat: false
                                        onTriggered: {
                                            if (settingsManager) {
                                                settingsManager.save_start_volume(volumeSlider.value)
                                            }
                                        }
                                    }
                                    
                                    onMoved: volumeUpdateTimer.restart()
                                }
                                
                                ValueDisplay {
                                    text: volumeSlider.valueDisplay
                                }
                            }

                            SettingsDivider {}
                            
                            // Media Room Background Blur Effect
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: App.Spacing.rowSpacing
                                
                                SettingLabel {
                                    text: "Media Room Background Blur Effect"
                                }
                                
                                SettingsSlider {
                                    id: blurRadiusSlider
                                    from: 0
                                    to: 100
                                    stepSize: 1
                                    value: settingsManager ? settingsManager.backgroundBlurRadius : 40
                                    activeColor: App.Style.accent
                                    
                                    // Debounce updates
                                    Timer {
                                        id: blurUpdateTimer
                                        interval: 100
                                        running: false
                                        repeat: false
                                        onTriggered: {
                                            if (settingsManager) {
                                                settingsManager.save_background_blur_radius(blurRadiusSlider.value)
                                            }
                                        }
                                    }
                                    
                                    onMoved: blurUpdateTimer.restart()
                                }
                                
                                ValueDisplay {
                                    text: blurRadiusSlider.value.toFixed(0)
                                }
                            }
                            
                            SettingsDivider {}
                            
                            // Media Room Background
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: App.Spacing.rowSpacing
                                
                                SettingLabel {
                                    text: "Media Room Background"
                                }
                                
                                SettingsSegmentedControl {
                                    id: backgroundGridButton
                                    Layout.fillWidth: true
                                    currentValue: settingsManager ? settingsManager.backgroundGrid : "4x4"
                                    options: ["Normal", "2x2", "4x4"]
                                    
                                    onSelected: function(value) {
                                        if (settingsManager) {
                                            settingsManager.save_background_grid(value)
                                        }
                                    }
                                }
                            }

                            SettingsDivider {}

                            // Background Overlay Toggle
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: App.Spacing.rowSpacing
                                
                                SettingLabel {
                                    text: "Show Background Overlay"
                                }
                                
                                SettingsToggle {
                                    id: backgroundOverlayToggle
                                    Layout.fillWidth: true
                                    text: "Enable dark overlay on album art"
                                    checked: settingsManager ? settingsManager.showBackgroundOverlay : true
                                    activeColor: App.Style.accent
                                    inactiveColor: App.Style.hoverColor
                                    
                                    onToggled: {
                                        if (settingsManager) {
                                            settingsManager.save_show_background_overlay(checked)
                                        }
                                    }
                                    
                                    // Update when setting changes externally
                                    Connections {
                                        target: settingsManager
                                        function onShowBackgroundOverlayChanged() {
                                            backgroundOverlayToggle.checked = settingsManager.showBackgroundOverlay
                                        }
                                    }
                                }
                            }
                            
                            Item { Layout.fillHeight: true } // Spacer
                        }
                    }
                    
                    ScrollView { // Display Settings Page
                        contentWidth: parent.width
                        ScrollBar.vertical.policy: ScrollBar.AsNeeded
                        clip: true
                        
                        ColumnLayout {
                            width: parent.width

                             // UI Scaling slider
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: App.Spacing.rowSpacing
                                
                                SettingLabel {
                                    text: "UI Scaling"
                                }
                                
                                SettingsSlider {
                                    id: uiScaleSlider
                                    from: 0.7
                                    to: 1.5
                                    stepSize: 0.05
                                    value: App.Spacing.globalScale
                                    
                                    Timer {
                                        id: scaleUpdateTimer
                                        interval: 100
                                        running: false
                                        repeat: false
                                        onTriggered: {
                                            if (settingsManager) {
                                                settingsManager.save_ui_scale(uiScaleSlider.value)
                                                App.Spacing.globalScale = uiScaleSlider.value
                                            }
                                        }
                                    }
                                    
                                    onMoved: scaleUpdateTimer.restart()
                                }
                                
                                ValueDisplay {
                                    text: (uiScaleSlider.value * 100).toFixed(0) + "%"
                                }
                                
                                SettingDescription {
                                    text: "Adjusts the size of all UI elements. Changes apply immediately."
                                }
                            }

                            SettingsDivider {}

                            // Screen Dimensions
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: App.Spacing.rowSpacing
                                
                                SettingLabel {
                                    text: "Screen Dimensions"
                                }
                                
                                RowLayout {
                                    spacing: App.Spacing.overallSpacing
                                    Layout.fillWidth: true
                                    
                                    Text {
                                        text: "Width:"
                                        color: App.Style.primaryTextColor
                                        font.pixelSize: App.Spacing.overallText
                                        Layout.preferredWidth: 70  // Increased from 60
                                    }
                                    
                                    SettingsTextField {
                                        id: screenWidth
                                        Layout.preferredWidth: 120  // Increased from 100
                                        text: mainWindow.width
                                        horizontalAlignment: TextInput.AlignHCenter
                                        validator: IntValidator {
                                            bottom: 400
                                            top: 3840
                                        }
                                        
                                        onEditingFinished: {
                                            if (text && settingsManager) {
                                                const width = parseInt(text)
                                                settingsManager.save_screen_width(width)
                                                mainWindow.width = width
                                                App.Spacing.updateDimensions(width, mainWindow.height)
                                            }
                                        }
                                        
                                        Connections {
                                            target: mainWindow
                                            function onWidthChanged() {
                                                if (!screenWidth.activeFocus) {
                                                    screenWidth.text = mainWindow.width
                                                    if (settingsManager) {
                                                        settingsManager.save_screen_width(mainWindow.width)
                                                    }
                                                    App.Spacing.updateDimensions(mainWindow.width, mainWindow.height)
                                                }
                                            }
                                        }
                                    }
                                    
                                    Text {
                                        text: "Height:"
                                        color: App.Style.primaryTextColor
                                        font.pixelSize: App.Spacing.overallText
                                        Layout.preferredWidth: 70  // Increased from 60
                                    }
                                    
                                    SettingsTextField {
                                        id: screenHeight
                                        Layout.preferredWidth: 120  // Increased from 100
                                        text: mainWindow.height
                                        horizontalAlignment: TextInput.AlignHCenter
                                        validator: IntValidator {
                                            bottom: 300
                                            top: 2160
                                        }
                                        
                                        onEditingFinished: {
                                            if (text && settingsManager) {
                                                const height = parseInt(text)
                                                settingsManager.save_screen_height(height)
                                                mainWindow.height = height
                                                App.Spacing.updateDimensions(mainWindow.width, height)
                                            }
                                        }
                                        
                                        Connections {
                                            target: mainWindow
                                            function onHeightChanged() {
                                                if (!screenHeight.activeFocus) {
                                                    screenHeight.text = mainWindow.height
                                                    if (settingsManager) {
                                                        settingsManager.save_screen_height(mainWindow.height)
                                                    }
                                                    App.Spacing.updateDimensions(mainWindow.width, mainWindow.height)
                                                }
                                            }
                                        }
                                    }
                                    
                                    Item { Layout.fillWidth: true } // Spacer
                                }
                            }
                            
                            SettingsDivider {}
                            
                            // Theme Selection
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: App.Spacing.rowSpacing
                                
                                SettingLabel {
                                    text: "Theme"
                                }
                                
                                // In the Theme Selection section, update the control to:
                                SettingsChips {
                                    id: themeButton
                                    Layout.fillWidth: true
                                    currentValue: settingsManager ? settingsManager.themeSetting : "Light" // Changed from displayText
                                    options: Object.keys(App.Style.themes)
                                    
                                    onSelected: function(value) {
                                        if (settingsManager) {
                                            mainWindow.updateTheme(value)
                                        }
                                    }
                                }
                            }
                            

                            
                            
                            Item { Layout.fillHeight: true } // Spacer
                        }
                    }
                    
                    ScrollView { // OBD Settings Page
                        contentWidth: parent.width
                        ScrollBar.vertical.policy: ScrollBar.AsNeeded
                        clip: true
                        
                        ColumnLayout {
                            width: parent.width
                            
                            // OBD Connection
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: App.Spacing.rowSpacing
                                
                                SettingLabel {
                                    text: "OBD Connection Status"
                                }
                                
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 40
                                    color: obdManager ? (obdManager.is_connected ? App.Style.accent : "#F44336") : "#F44336"
                                    radius: 4

                                    Text {
                                        anchors.centerIn: parent
                                        text: obdManager ? obdManager.get_connection_status() : "Not Connected"
                                        color: "white"
                                        font.pixelSize: App.Spacing.overallText
                                        font.bold: true
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            if (obdManager) {
                                                obdManager.reconnect()
                                            }
                                        }
                                    }
                                }
                                
                                SettingDescription {
                                    text: "Click the status bar above to attempt reconnection"
                                }   
                            }
                            
                            SettingsDivider {}
                            
                            // Bluetooth Device Path
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: App.Spacing.rowSpacing
                                
                                SettingLabel {
                                    text: "Bluetooth OBD Device"
                                }
                                
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: App.Spacing.overallSpacing
                                    
                                    SettingsTextField {
                                        id: bluetoothPortField
                                        Layout.fillWidth: true
                                        text: settingsManager ? settingsManager.obdBluetoothPort : "/dev/rfcomm0"
                                        
                                        onEditingFinished: {
                                            if (settingsManager && text.trim() !== "") {
                                                settingsManager.save_obd_bluetooth_port(text)
                                            }
                                        }
                                    }
                                    
                                    Text {
                                        text: "e.g. /dev/rfcomm0"
                                        color: App.Style.secondaryTextColor
                                        font.pixelSize: App.Spacing.overallText * 0.8
                                    }
                                }
                                
                                SettingDescription {
                                    text: "Enter the Bluetooth device port for your OBD adapter"
                                }
                            }
                            
                            SettingsDivider {}
                            
                            // Fast Mode Toggle
                            SettingsToggle {
                                text: "Fast Mode"
                                Layout.fillWidth: true
                                checked: settingsManager ? settingsManager.obdFastMode : true
                                
                                onToggled: {
                                    if (settingsManager) {
                                        settingsManager.save_obd_fast_mode(checked)
                                    }
                                }
                            }
                            
                            SettingDescription {
                                text: "Fast mode optimizes for quicker updates but may not work with all vehicles"
                            }
                            
                            SettingsDivider {}
                            
                            // Parameter selection with actual settings values
                            ColumnLayout {
                                id: parameterSelectionLayout
                                Layout.fillWidth: true
                                spacing: App.Spacing.rowSpacing / 2
                                
                                // Add a row for the Select All button
                                RowLayout {
                                    Layout.fillWidth: true
                                    Layout.bottomMargin: 10
                                    
                                    // Select All button
                                    Button {
                                        id: selectAllButton
                                        text: "Select All"
                                        implicitHeight: 35
                                        
                                        // Variable to track if all items are currently selected
                                        property bool allSelected: false
                                        
                                        background: Rectangle {
                                            color: selectAllButton.pressed ? Qt.darker(App.Style.accent, 1.4) : 
                                                selectAllButton.hovered ? Qt.darker(App.Style.accent, 1.2) : 
                                                App.Style.accent
                                            radius: 4
                                        }
                                        
                                        contentItem: Text {
                                            text: selectAllButton.text
                                            color: "#ffffff"
                                            font.pixelSize: App.Spacing.overallText * 0.9
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                        
                                        onClicked: {
                                            // Toggle between select all and deselect all
                                            allSelected = !allSelected;
                                            text = allSelected ? "Deselect All" : "Select All";
                                            
                                            // Apply the selection to all parameters
                                            if (settingsManager) {
                                                const parameterList = [
                                                    "COOLANT_TEMP", "CONTROL_MODULE_VOLTAGE", "ENGINE_LOAD", 
                                                    "THROTTLE_POS", "INTAKE_TEMP", "TIMING_ADVANCE",
                                                    "MAF", "SPEED", "RPM", "COMMANDED_EQUIV_RATIO",
                                                    "FUEL_LEVEL", "INTAKE_PRESSURE", "SHORT_FUEL_TRIM_1",
                                                    "LONG_FUEL_TRIM_1", "O2_B1S1", "FUEL_PRESSURE",
                                                    "OIL_TEMP", "IGNITION_TIMING"
                                                ];
                                                
                                                // Update each parameter
                                                parameterList.forEach(function(param) {
                                                    settingsManager.save_obd_parameter_enabled(param, allSelected);
                                                });
                                            }
                                        }
                                    }
                                    
                                    // Spacer
                                    Item { Layout.fillWidth: true }
                                    
                                    // Count of enabled parameters
                                    Text {
                                        id: enabledCount
                                        text: "0 of 0 enabled"
                                        color: App.Style.secondaryTextColor
                                        font.pixelSize: App.Spacing.overallText * 0.9
                                        
                                        // Function to count enabled parameters
                                        function updateEnabledCount() {
                                            if (!settingsManager) return;
                                            
                                            const parameterList = [
                                                "COOLANT_TEMP", "CONTROL_MODULE_VOLTAGE", "ENGINE_LOAD", 
                                                "THROTTLE_POS", "INTAKE_TEMP", "TIMING_ADVANCE",
                                                "MAF", "SPEED", "RPM", "COMMANDED_EQUIV_RATIO",
                                                "FUEL_LEVEL", "INTAKE_PRESSURE", "SHORT_FUEL_TRIM_1",
                                                "LONG_FUEL_TRIM_1", "O2_B1S1", "FUEL_PRESSURE",
                                                "OIL_TEMP", "IGNITION_TIMING"
                                            ];
                                            
                                            let count = 0;
                                            parameterList.forEach(function(param) {
                                                if (settingsManager.get_obd_parameter_enabled(param, true)) {
                                                    count++;
                                                }
                                            });
                                            
                                            enabledCount.text = count + " of " + parameterList.length + " enabled";
                                            
                                            // Update the select all button state
                                            selectAllButton.allSelected = (count === parameterList.length);
                                            selectAllButton.text = selectAllButton.allSelected ? "Deselect All" : "Select All";
                                        }
                                        
                                        // Initialize the count
                                        Component.onCompleted: {
                                            updateEnabledCount();
                                        }
                                    }
                                }
                                
                                // Timer for updating the enabled count
                                Timer {
                                    id: updateCountTimer
                                    interval: 250  // 250ms delay to avoid too frequent updates
                                    running: false
                                    repeat: false
                                    onTriggered: {
                                        enabledCount.updateEnabledCount();
                                    }
                                }
                                
                                // Connection to update from settings changes
                                Connections {
                                    target: settingsManager
                                    function onObdParametersChanged() {
                                        // Use the timer to prevent multiple rapid updates
                                        updateCountTimer.restart();
                                    }
                                }
                                
                                // Repeater with parameters in a ColumnLayout
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2
                                    
                                    Repeater {
                                        model: [
                                            // Original parameters
                                            { name: "Coolant Temperature", command: "COOLANT_TEMP" },
                                            { name: "System Voltage", command: "CONTROL_MODULE_VOLTAGE" },
                                            { name: "Engine Load", command: "ENGINE_LOAD" },
                                            { name: "Throttle Position", command: "THROTTLE_POS" },
                                            { name: "Intake Temperature", command: "INTAKE_TEMP" },
                                            { name: "Timing Advance", command: "TIMING_ADVANCE" },
                                            { name: "Mass Air Flow", command: "MAF" },
                                            { name: "Vehicle Speed", command: "SPEED" },
                                            { name: "Engine RPM", command: "RPM" },
                                            { name: "Air-Fuel Ratio", command: "COMMANDED_EQUIV_RATIO" },
                                            
                                            // New parameters (removed fuel economy related)
                                            { name: "Fuel Level", command: "FUEL_LEVEL" },
                                            { name: "Intake Manifold Pressure", command: "INTAKE_PRESSURE" },
                                            { name: "Short Term Fuel Trim", command: "SHORT_FUEL_TRIM_1" },
                                            { name: "Long Term Fuel Trim", command: "LONG_FUEL_TRIM_1" },
                                            { name: "O2 Sensor Voltage", command: "O2_B1S1" },
                                            { name: "Fuel Pressure", command: "FUEL_PRESSURE" },
                                            { name: "Oil Temperature", command: "OIL_TEMP" },
                                            { name: "Ignition Timing", command: "IGNITION_TIMING" }
                                        ]
                                        
                                        delegate: RowLayout {
                                            required property var modelData
                                            Layout.fillWidth: true
                                            spacing: 5
                                            
                                            // Use a CheckBox with an explicit ID so we can reference it
                                            CheckBox {
                                                id: paramCheck
                                                text: modelData.name
                                                Layout.fillWidth: true
                                                
                                                // Add a property binding so it updates when settings change
                                                property bool paramEnabled: settingsManager ? 
                                                    settingsManager.get_obd_parameter_enabled(modelData.command, true) : true
                                                
                                                // Update checked state immediately when the paramEnabled property changes
                                                onParamEnabledChanged: {
                                                    checked = paramEnabled;
                                                    // Schedule an update of the counter
                                                    updateCountTimer.restart();
                                                }
                                                
                                                // Initialize with the current value
                                                Component.onCompleted: {
                                                    checked = paramEnabled;
                                                }
                                                
                                                contentItem: Text {
                                                    text: paramCheck.text
                                                    color: App.Style.primaryTextColor
                                                    font.pixelSize: App.Spacing.overallText
                                                    verticalAlignment: Text.AlignVCenter
                                                    leftPadding: paramCheck.indicator.width + paramCheck.spacing
                                                    elide: Text.ElideRight
                                                }
                                                
                                                onToggled: {
                                                    if (settingsManager) {
                                                        console.log(modelData.command + " monitoring " + (checked ? "enabled" : "disabled"))
                                                        settingsManager.save_obd_parameter_enabled(modelData.command, checked)
                                                        // Schedule an update of the counter with a small delay
                                                        updateCountTimer.restart();
                                                    }
                                                }
                                                
                                                // Add a connection to update from settings changes
                                                Connections {
                                                    target: settingsManager
                                                    function onObdParametersChanged() {
                                                        paramCheck.checked = settingsManager.get_obd_parameter_enabled(modelData.command, true);
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                // Call updateEnabledCount once when component is completed
                                Component.onCompleted: {
                                    // Give a slight delay to allow the UI to initialize
                                    Qt.callLater(function() {
                                        if (enabledCount) {
                                            enabledCount.updateEnabledCount();
                                        }
                                    });
                                }
                            }

                            Item { Layout.fillHeight: true } // Spacer
                        }
                    }
                    
                    ScrollView { // Clock Settings Page
                        contentWidth: parent.width
                        ScrollBar.vertical.policy: ScrollBar.AsNeeded
                        clip: true
                        
                        ColumnLayout {
                            width: parent.width
                            
                            // Show Clock Toggle - Using the new toggle
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: App.Spacing.rowSpacing
                                
                                SettingsToggle {
                                    text: "Show Clock"
                                    Layout.fillWidth: true
                                    checked: settingsManager ? settingsManager.showClock : true
                                    
                                    onToggled: {
                                        if (settingsManager) {
                                            settingsManager.save_show_clock(checked)
                                        }
                                    }
                                }
                            }
                            
                            SettingsDivider {}
                            
                            // Clock Format Options - Using segmented control
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: App.Spacing.rowSpacing
                                
                                SettingLabel {
                                    text: "Time Format"
                                }
                                
                                SettingsSegmentedControl {
                                    id: timeFormatControl
                                    Layout.fillWidth: true
                                    options: ["24-hour", "12-hour (AM/PM)"]
                                    currentValue: settingsManager ? 
                                                (settingsManager.clockFormat24Hour ? "24-hour" : "12-hour (AM/PM)") : 
                                                "24-hour"
                                    
                                    onSelected: function(value) {
                                        if (settingsManager) {
                                            settingsManager.save_clock_format(value === "24-hour")
                                        }
                                    }
                                }
                            }
                            
                            SettingsDivider {}
                            
                            // Clock Size Slider - Keep this as is
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: App.Spacing.rowSpacing
                                
                                SettingLabel {
                                    text: "Clock Size"
                                }
                                
                                SettingsSlider {
                                    id: clockSizeSlider
                                    from: 10
                                    to: 85
                                    stepSize: 1
                                    value: settingsManager ? settingsManager.clockSize : 18
                                    
                                    onMoved: {
                                        if (settingsManager) {
                                            settingsManager.save_clock_size(value)
                                        }
                                    }
                                }
                                
                                RowLayout {
                                    Layout.fillWidth: true
                                    
                                    ValueDisplay {
                                        text: clockSizeSlider.value.toFixed(0) + " pixels"
                                    }
                                    
                                    Item { Layout.fillWidth: true }
                                    
                                }
                            }
                            
                            Item { Layout.fillHeight: true } // Spacer
                        }
                    }

                    ScrollView { // About Page
                        contentWidth: parent.width
                        ScrollBar.vertical.policy: ScrollBar.AsNeeded
                        clip: true
                        
                        ColumnLayout {
                            width: parent.width
                            spacing: 0
                            
                            // Use a GridLayout for better control over positioning
                            GridLayout {
                                Layout.fillWidth: true
                                Layout.margins: App.Spacing.overallMargin * 2
                                columns: 1
                                rowSpacing: App.Spacing.overallSpacing * 2
                                
                                // Title with adequate spacing from content
                                Text {
                                    id: titleText
                                    text: "OCTAVE"
                                    color: App.Style.primaryTextColor
                                    font.pixelSize: App.Spacing.overallText * 2
                                    font.bold: true
                                    Layout.fillWidth: true
                                }
                                
                                // Version with proper spacing
                                Text {
                                    id: versionText
                                    text: "Version 1.0.0"
                                    color: App.Style.secondaryTextColor
                                    font.pixelSize: App.Spacing.overallText * 1.2
                                    Layout.fillWidth: true
                                }
                                
                                // Description text
                                Text {
                                    id: descriptionText
                                    text: "Welcome to OCTAVE, an open-source, cross-platform telematics system for an augmented vehicle experience. Developed by WayBetterEngineering, our mission is simple: we make things better.\n\nThis software is designed to provide a seamless interface for vehicle systems, media playback, navigation, and more."
                                    wrapMode: Text.WordWrap
                                    color: App.Style.primaryTextColor
                                    font.pixelSize: App.Spacing.overallText
                                    Layout.fillWidth: true
                                    Layout.topMargin: App.Spacing.overallSpacing
                                }
                                
                                // Separator
                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 1
                                    color: App.Style.hoverColor
                                    Layout.topMargin: App.Spacing.overallSpacing
                                    Layout.bottomMargin: App.Spacing.overallSpacing
                                }
                                
                                // GitHub Link section
                                Text {
                                    text: "GitHub Repository"
                                    color: App.Style.primaryTextColor
                                    font.pixelSize: App.Spacing.overallText * 1.2
                                    font.bold: true
                                    Layout.fillWidth: true
                                }
                                
                                // GitHub link
                                Text {
                                    text: "<a href='https://github.com/waybetterengineering/octave'>github.com/waybetterengineering/octave</a>"
                                    color: App.Style.accent
                                    linkColor: App.Style.accent
                                    font.pixelSize: App.Spacing.overallText
                                    Layout.fillWidth: true
                                    onLinkActivated: Qt.openUrlExternally(link)
                                }
                                
                                Text {
                                    text: "Copyright © 2024 WayBetterEngineering"
                                    color: App.Style.primaryTextColor
                                    font.pixelSize: App.Spacing.overallText
                                    Layout.fillWidth: true
                                    Layout.topMargin: App.Spacing.overallSpacing
                                }
                                
                                // Bottom spacer
                                Item { 
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    Layout.minimumHeight: App.Spacing.overallSpacing * 4
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}