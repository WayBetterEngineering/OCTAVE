import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Basic 2.15
import Qt5Compat.GraphicalEffects
import "." as App

Rectangle {
    id: bottomBar
    width: parent.width
    height: parent.height * App.Spacing.bottomBarHeightPercent
    gradient: Gradient {
        GradientStop { position: 1.5; color: App.Style.bottomBarGradientStart }
        GradientStop { position: 0.0; color: App.Style.bottomBarGradientEnd }
    }

    signal clicked()
    
    MouseArea {
        anchors.fill: parent
        onClicked: function(mouse) {
            bottomBar.clicked()
            mouse.accepted = false // Allow clicks to pass through
        }
        z: -1 // Put behind other controls
    }

    layer.enabled: true
    layer.effect: DropShadow {
        color: "#40000000"
        radius: 8
        samples: 16
        verticalOffset: -4
    }

    required property StackView stackView
    required property Window mainWindow

    // Main layout that divides the bar into three sections with equal spacing
    RowLayout {
        anchors.fill: parent
        spacing: 0 // We'll handle spacing within each section
        
        // SECTION 1: Left section - Media Controls
        Item {
            Layout.preferredWidth: parent.width * 0.4 // Allocate 40% of space 
            Layout.fillHeight: true
            
            RowLayout { 
                id: mediaControls
                anchors {
                    left: parent.left
                    leftMargin: App.Spacing.overallMargin
                    right: parent.right
                    rightMargin: App.Spacing.overallMargin
                    verticalCenter: parent.verticalCenter
                }
                spacing: App.Spacing.bottomBarBetweenButtonMargin

                // Previous button
                Control {
                    id: previousButtonControl
                    implicitWidth: App.Spacing.bottomBarPreviousButtonWidth
                    implicitHeight: App.Spacing.bottomBarPreviousButtonHeight
                    Layout.alignment: Qt.AlignVCenter
                    
                    scale: mouseAreaPrev.pressed ? 0.8 : 1.0
                    opacity: mouseAreaPrev.pressed ? 0.7 : 1.0
                    
                    Behavior on scale {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutBack  
                            easing.overshoot: 1.1
                        }
                    }
                    
                    Behavior on opacity {
                        NumberAnimation { duration: 150 }
                    }

                    background: Rectangle { color: "transparent" }
                    
                    contentItem: Item {
                        Image {
                            id: previousButtonImage
                            anchors.centerIn: parent
                            width: parent.width
                            height: parent.height
                            source: "./assets/previous_button.svg"
                            sourceSize: Qt.size(width * 2, height * 2)
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            antialiasing: true
                            mipmap: true
                            visible: false
                        }
                        
                        ColorOverlay {
                            id: colorOverlay
                            anchors.fill: previousButtonImage
                            source: previousButtonImage
                            color: App.Style.bottomBarPreviousButton
                        }
                    }

                    MouseArea {
                        id: mouseAreaPrev
                        anchors.fill: parent
                        onClicked: mediaManager.previous_track()
                    }
                }

                // Play/Pause button
                Control {
                    id: playButtonControl
                    implicitWidth: App.Spacing.bottomBarPlayButtonWidth
                    implicitHeight: App.Spacing.bottomBarPlayButtonHeight
                    Layout.alignment: Qt.AlignVCenter

                    scale: mouseAreaPlay.pressed ? 0.8 : 1.0
                    opacity: mouseAreaPlay.pressed ? 0.7 : 1.0
                    
                    Behavior on scale {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutBack  
                            easing.overshoot: 1.1
                        }
                    }
                    
                    Behavior on opacity {
                        NumberAnimation { duration: 150 }
                    }

                    background: Rectangle { color: "transparent" }
                    
                    contentItem: Item {
                        Image {
                            id: playButtonImage
                            anchors.centerIn: parent
                            width: parent.height
                            height: parent.height
                            source: mediaManager && mediaManager.is_playing() ? 
                                    "./assets/pause_button.svg" : "./assets/play_button.svg"
                            sourceSize: Qt.size(width * 2, height * 2)
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            antialiasing: true
                            mipmap: true
                            visible: false
                        }
                        
                        ColorOverlay {
                            anchors.fill: playButtonImage
                            source: playButtonImage
                            color: App.Style.bottomBarPlayButton
                        }
                    }
                    
                    MouseArea {
                        id: mouseAreaPlay
                        anchors.fill: parent
                        onClicked: mediaManager.toggle_play()
                    }
                }

                // Next button
                Control {
                    id: nextButtonControl
                    implicitWidth: App.Spacing.bottomBarNextButtonWidth
                    implicitHeight: App.Spacing.bottomBarNextButtonHeight
                    Layout.alignment: Qt.AlignVCenter

                    scale: mouseAreaNext.pressed ? 0.8 : 1.0
                    opacity: mouseAreaNext.pressed ? 0.7 : 1.0
                    
                    Behavior on scale {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutBack  
                            easing.overshoot: 1.1
                        }
                    }
                    
                    Behavior on opacity {
                        NumberAnimation { duration: 150 }
                    }
                    
                    background: Rectangle { color: "transparent" }
                    
                    contentItem: Item {
                        Image {
                            id: nextButtonImage
                            anchors.centerIn: parent
                            width: parent.width
                            height: parent.height
                            source: "./assets/next_button.svg"
                            sourceSize: Qt.size(width * 2, height * 2)
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            antialiasing: true
                            mipmap: true
                            visible: false
                        }
                        
                        ColorOverlay {
                            anchors.fill: nextButtonImage
                            source: nextButtonImage
                            color: App.Style.bottomBarNextButton
                        }
                    }
                    
                    MouseArea {
                        id: mouseAreaNext
                        anchors.fill: parent
                        onClicked: mediaManager.next_track()
                    }
                }

                // Shuffle button
                Control {
                    id: shuffleButton
                    property bool isShuffleEnabled: mediaManager ? mediaManager.is_shuffled() : false
                    implicitWidth: App.Spacing.bottomBarShuffleButtonWidth
                    implicitHeight: App.Spacing.bottomBarShuffleButtonHeight
                    Layout.alignment: Qt.AlignVCenter

                    scale: mouseAreaShuffle.pressed ? 0.8 : 1.0
                    opacity: mouseAreaShuffle.pressed ? 0.7 : 1.0
                    
                    Behavior on scale {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutBack  
                            easing.overshoot: 1.1
                        }
                    }
                    
                    Behavior on opacity {
                        NumberAnimation { duration: 150 }
                    }

                    background: Rectangle {
                        color: shuffleButton.isShuffleEnabled ? App.Style.bottomBarToggleShade : "transparent"
                        radius: width / 2
                    }
                    
                    contentItem: Item {
                        Image {
                            id: shuffleButtonImage
                            anchors.centerIn: parent
                            width: parent.width
                            height: parent.height
                            source: "./assets/shuffle_button.svg"
                            sourceSize: Qt.size(width * 2, height * 2)
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            antialiasing: true
                            mipmap: true
                            visible: false
                        }
                        
                        ColorOverlay {
                            anchors.fill: shuffleButtonImage
                            source: shuffleButtonImage
                            color: shuffleButton.isShuffleEnabled ? 
                                App.Style.bottomBarActiveToggleButton : 
                                App.Style.bottomBarVolumeButton
                        }
                    }

                    MouseArea {
                        id: mouseAreaShuffle
                        anchors.fill: parent
                        onClicked: mediaManager.toggle_shuffle()
                    }
                }

                // Mute button
                Control {
                    id: muteButton
                    property bool isMuted: false
                    implicitWidth: App.Spacing.bottomBarMuteButtonWidth
                    implicitHeight: App.Spacing.bottomBarMuteButtonHeight
                    Layout.alignment: Qt.AlignVCenter

                    scale: mouseAreaMute.pressed ? 0.8 : 1.0
                    opacity: mouseAreaMute.pressed ? 0.7 : 1.0
                    
                    Behavior on scale {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutBack  
                            easing.overshoot: 1.1
                        }
                    }
                    
                    Behavior on opacity {
                        NumberAnimation { duration: 150 }
                    }

                    background: Rectangle { color: "transparent" }
                    
                    contentItem: Item {
                        Image {
                            id: muteButtonImage
                            anchors.centerIn: parent
                            width: parent.width
                            height: parent.height
                            source: getUpdatedMuteSource()
                            sourceSize: Qt.size(width * 2, height * 2)
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            antialiasing: true
                            mipmap: true
                            visible: false
                        }
                        
                        ColorOverlay {
                            anchors.fill: muteButtonImage
                            source: muteButtonImage
                            color: App.Style.bottomBarVolumeButton
                        }
                    }
                    
                    MouseArea {
                        id: mouseAreaMute
                        anchors.fill: parent
                        onClicked: {
                            muteButton.isMuted = !muteButton.isMuted
                            mediaManager.toggle_mute()
                        }
                    }
                }

                // Volume Control
                Control {
                    id: volumeControl
                    implicitWidth: App.Spacing.bottomBarVolumeSliderWidth
                    implicitHeight: App.Spacing.bottomBarVolumeSliderHeight
                    Layout.alignment: Qt.AlignVCenter
                    
                    // Create a container for the volume text
                    Item {
                        id: volumeTextContainer
                        anchors {
                            left: parent.left
                            leftMargin: App.Spacing.overallMargin
                            verticalCenter: parent.verticalCenter
                        }
                        // Make the clickable area wider than just the text
                        width: parent.width
                        height: parent.parent.height  // Full height of parent
                        
                        Text {
                            id: volumeText
                            anchors {
                                left: parent.left
                                verticalCenter: parent.verticalCenter
                            }
                            text: volumeControl.currentValue + "%"
                            color: App.Style.primaryTextColor
                            font.pixelSize: App.Spacing.bottomBarVolumeText
                            font.bold: true
                        }
                        
                        // Add a MouseArea that covers just the text and some padding around it
                        MouseArea {
                            anchors.fill: parent
                            onClicked: popupSlider.open()
                        }
                    }
                    
                    property int currentValue: 0
                    
                    Component.onCompleted: {
                        if (settingsManager) {
                            var volumeValue = settingsManager.startUpVolume
                            currentValue = Math.round(Math.sqrt(volumeValue) * 100)
                            mediaManager.setVolume(volumeValue)
                        } else {
                            currentValue = 10
                            mediaManager.setVolume(0.1)
                        }
                        
                        updateMuteButtonImage()

                        if (mediaManager) {
                            shuffleButton.isShuffleEnabled = mediaManager.is_shuffled()
                        }
                    }

                    Popup {
                        id: popupSlider
                        width: parent.Window.width
                        height: 140
                        anchors.centerIn: Overlay.overlay
                        modal: true
                        focus: true
                        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
                        
                        // Simple background
                        background: Rectangle {
                            color: App.Style.backgroundColor
                            radius: 8
                            border.color: App.Style.accent
                            border.width: 1
                        }
                        
                        // Content with centered slider
                        contentItem: Item {
                            anchors.fill: parent
                            
                            // Larger percentage display
                            Label {
                                id: percentLabel
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.top: parent.top
                                anchors.topMargin: 15
                                text: Math.round(volumeSlider.value) + "%"
                                color: App.Style.accent
                                font.pixelSize: 32
                                font.bold: true
                            }
                            
                            // Container for the slider - centered in the popup
                            Item {
                                id: sliderContainer
                                anchors.top: percentLabel.bottom
                                anchors.topMargin: 15
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: 15
                                
                                // Simplified slider
                                Slider {
                                    id: volumeSlider
                                    anchors.centerIn: parent
                                    width: parent.width * 0.95
                                    height: 50
                                    from: 0
                                    to: 100
                                    stepSize: 1
                                    value: volumeControl.currentValue
                                    
                                    // Simple slider background
                                    background: Rectangle {
                                        x: volumeSlider.leftPadding
                                        y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                                        width: volumeSlider.availableWidth
                                        height: 16
                                        radius: 8
                                        color: App.Style.hoverColor
                                        
                                        // Filled portion
                                        Rectangle {
                                            width: volumeSlider.visualPosition * parent.width
                                            height: parent.height
                                            color: App.Style.volumeSliderColor
                                            radius: 8
                                        }
                                    }
                                    
                                    // Larger handle for better touch
                                    handle: Rectangle {
                                        x: volumeSlider.leftPadding + volumeSlider.visualPosition * (volumeSlider.availableWidth - width)
                                        y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                                        width: 40
                                        height: 40
                                        radius: 20  // Circular handle
                                        color: App.Style.accent
                                    }
                                    
                                    // The core functionality
                                    onValueChanged: {
                                        volumeControl.currentValue = value
                                        var normalizedValue = value / 100
                                        var logVolume = Math.pow(normalizedValue, 2.0)
                                        mediaManager.setVolume(logVolume)
                                        
                                        if (value > 0 && muteButton.isMuted) {
                                            muteButton.isMuted = false
                                            mediaManager.toggle_mute()
                                        }
                                        updateMuteButtonImage()
                                    }
                                }
                                
                                // Circular touch area
                                Item {
                                    id: touchAreaContainer
                                    anchors.centerIn: sliderContainer
                                    width: sliderContainer.width
                                    height: sliderContainer.height
                                    
                                    // Create multiple circular touch areas along the slider track
                                    Repeater {
                                        model: 9  // Create 9 touch areas along the slider
                                        
                                        // Each touch area is a circular MouseArea
                                        MouseArea {
                                            id: circularTouchArea
                                            // Position touch areas evenly along the slider
                                            x: (index * (volumeSlider.width / 8)) - width/2 + volumeSlider.x
                                            y: volumeSlider.y + volumeSlider.height/2 - height/2
                                            width: 80  // Large circular area
                                            height: 80
                                            
                                            // Make the touch area visually circular (only for debugging)
                                            // Rectangle {
                                            //     anchors.fill: parent
                                            //     radius: width/2
                                            //     color: "transparent"
                                            //     border.width: 1
                                            //     border.color: "red"
                                            //     opacity: 0.3
                                            // }
                                            
                                            // Handle touch interactions
                                            onMouseXChanged: {
                                                if (pressed) {
                                                    // Calculate global position relative to the slider
                                                    var globalX = mapToItem(volumeSlider, mouseX, mouseY).x
                                                    var newPosition = Math.max(0, Math.min(1, 
                                                        (globalX - volumeSlider.leftPadding) / volumeSlider.availableWidth))
                                                    volumeSlider.value = newPosition * 100
                                                }
                                            }
                                            
                                            // Allow slider to receive events too
                                            preventStealing: false
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // SECTION 2: Center section - Navigation Buttons
        Item {
            Layout.preferredWidth: parent.width * 0.4 // Allocate 40% of space
            Layout.fillHeight: true
            
            RowLayout {
                id: navigationBar
                anchors.centerIn: parent
                spacing: App.Spacing.bottomBarBetweenButtonMargin * 8
                
                // Home Button (Main Menu)
                Control {
                    id: homeButton
                    implicitWidth: App.Spacing.bottomBarNavButtonWidth
                    implicitHeight: App.Spacing.bottomBarNavButtonHeight
                    
                    // Add scale and opacity animations
                    scale: mouseAreaHome.pressed ? 0.8 : 1.0
                    opacity: mouseAreaHome.pressed ? 0.7 : 1.0
                    
                    Behavior on scale {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutBack  
                            easing.overshoot: 1.1
                        }
                    }
                    
                    Behavior on opacity {
                        NumberAnimation { duration: 150 }
                    }
                    
                    background: Rectangle {
                        color: "transparent"
                        radius: 8
                        border.color: App.Style.accent
                        border.width: 1
                    }
                    
                    contentItem: Item {
                        Image {
                            id: homeButtonImage
                            anchors.centerIn: parent
                            width: parent.width * 0.7
                            height: parent.height * 0.7
                            source: "./assets/home_button.svg"
                            sourceSize: Qt.size(width * 2, height * 2)
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            antialiasing: true
                            mipmap: true
                            visible: false
                        }
                        
                        ColorOverlay {
                            anchors.fill: homeButtonImage
                            source: homeButtonImage
                            color: App.Style.bottomBarHomeButton
                        }
                    }
                    
                    MouseArea {
                        id: mouseAreaHome
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            // Pop to root/main menu
                            while (stackView.depth > 1) {
                                stackView.pop();
                            }
                        }
                    }
                }
                
                // OBD Button
                Control {
                    id: obdButton
                    implicitWidth: App.Spacing.bottomBarNavButtonWidth
                    implicitHeight: App.Spacing.bottomBarNavButtonHeight
                    
                    // Add scale and opacity animations
                    scale: mouseAreaOBD.pressed ? 0.8 : 1.0
                    opacity: mouseAreaOBD.pressed ? 0.7 : 1.0
                    
                    Behavior on scale {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutBack  
                            easing.overshoot: 1.1
                        }
                    }
                    
                    Behavior on opacity {
                        NumberAnimation { duration: 150 }
                    }
                    
                    background: Rectangle {
                        color: "transparent"
                        radius: 8
                        border.color: App.Style.accent
                        border.width: 1
                    }
                    
                    contentItem: Item {
                        Image {
                            id: obdButtonImage
                            anchors.centerIn: parent
                            width: parent.width * 0.7
                            height: parent.height * 0.7
                            source: "./assets/obd_button.svg"
                            sourceSize: Qt.size(width * 2, height * 2)
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            antialiasing: true
                            mipmap: true
                            visible: false
                        }
                        
                        ColorOverlay {
                            anchors.fill: obdButtonImage
                            source: obdButtonImage
                            color: App.Style.bottomBarOBDButton
                        }
                    }
                    
                    MouseArea {
                        id: mouseAreaOBD
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            var component = Qt.createComponent("OBDMenu.qml")
                            if (component.status === Component.Ready) {
                                var page = component.createObject(stackView, {
                                    stackView: bottomBar.stackView,
                                    mainWindow: stackView.parent.Window.window
                                })
                                if (page) {
                                    stackView.push(page)
                                }
                            }
                        }
                    }
                }

                // Media Button
                Control {
                    id: mediaButton
                    implicitWidth: App.Spacing.bottomBarNavButtonWidth
                    implicitHeight: App.Spacing.bottomBarNavButtonHeight
                    
                    // Add scale and opacity animations
                    scale: mouseAreaMedia.pressed ? 0.8 : 1.0
                    opacity: mouseAreaMedia.pressed ? 0.7 : 1.0
                    
                    Behavior on scale {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutBack  
                            easing.overshoot: 1.1
                        }
                    }
                    
                    Behavior on opacity {
                        NumberAnimation { duration: 150 }
                    }
                    
                    background: Rectangle {
                        color: "transparent"
                        radius: 8
                        border.color: App.Style.accent
                        border.width: 1
                    }
                    
                    contentItem: Item {
                        Image {
                            id: mediaButtonImage
                            anchors.centerIn: parent
                            width: parent.width * 0.7
                            height: parent.height * 0.7
                            source: "./assets/media_button.svg"
                            sourceSize: Qt.size(width * 2, height * 2)
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            antialiasing: true
                            mipmap: true
                            visible: false
                        }
                        
                        ColorOverlay {
                            anchors.fill: mediaButtonImage
                            source: mediaButtonImage
                            color: App.Style.bottomBarMediaButton
                        }
                    }
                    
                    MouseArea {
                        id: mouseAreaMedia
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            var page = Qt.createComponent("MediaRoom.qml").createObject(stackView, {
                                stackView: bottomBar.stackView
                            })
                            stackView.push(page)
                        }
                    }
                }

                // Settings Button
                Control {
                    id: settingsButton
                    implicitWidth: App.Spacing.bottomBarNavButtonWidth
                    implicitHeight: App.Spacing.bottomBarNavButtonHeight
                    
                    // Add scale and opacity animations
                    scale: mouseAreaSettings.pressed ? 0.8 : 1.0
                    opacity: mouseAreaSettings.pressed ? 0.7 : 1.0
                    
                    Behavior on scale {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutBack  
                            easing.overshoot: 1.1
                        }
                    }
                    
                    Behavior on opacity {
                        NumberAnimation { duration: 150 }
                    }
                    
                    background: Rectangle {
                        color: "transparent"
                        radius: 8
                        border.color: App.Style.accent
                        border.width: 1
                    }
                    
                    contentItem: Item {
                        Image {
                            id: settingsButtonImage
                            anchors.centerIn: parent
                            width: parent.width * 0.7
                            height: parent.height * 0.7
                            source: "./assets/settings_button.svg"
                            sourceSize: Qt.size(width * 2, height * 2)
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            antialiasing: true
                            mipmap: true
                            visible: false
                        }
                        
                        ColorOverlay {
                            anchors.fill: settingsButtonImage
                            source: settingsButtonImage
                            color: App.Style.bottomBarSettingsButton
                        }
                    }
                    
                    MouseArea {
                        id: mouseAreaSettings
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            var page = Qt.createComponent("SettingsMenu.qml").createObject(stackView, {
                                stackView: bottomBar.stackView,
                                mainWindow: stackView.parent.Window.window,
                                initialSection: lastSettingsSection
                            })
                            stackView.push(page)
                        }
                    }
                }
            }
        }
        
        // SECTION 3: Right section - Clock and other controls
        Item {
            Layout.preferredWidth: parent.width * 0.2 // Allocate 20% of space
            Layout.fillHeight: true
            
            RowLayout {
                id: rightControls
                anchors {
                    right: parent.right
                    rightMargin: App.Spacing.overallMargin
                    verticalCenter: parent.verticalCenter
                }
                spacing: App.Spacing.bottomBarBetweenButtonMargin
                
                Text {
                    id: clockText
                    visible: settingsManager ? settingsManager.showClock : true
                    font.pixelSize: settingsManager ? settingsManager.clockSize : 18
                    color: App.Style.clockTextColor
                }
            }
        }
    }

    // Connections and Signal handlers
    Connections {
        target: clock
        function onTimeChanged(time) {
            clockText.text = time
        }
    }

    Connections {
        target: mediaManager
        function onPlayStateChanged(playing) {
            playButtonImage.source = playing ? 
                "./assets/pause_button.svg" : "./assets/play_button.svg"
        }
        function onMuteChanged(muted) {
            updateMuteButtonImage()
        }
        function onVolumeChanged() {
            updateMuteButtonImage()
        }
        function onShuffleStateChanged(enabled) {
            shuffleButton.isShuffleEnabled = enabled
        }
    }

    Connections {
        target: svgManager
        function onSvgUpdated() {
            var timestamp = new Date().getTime()
            previousButtonImage.source = ""
            playButtonImage.source = ""
            nextButtonImage.source = ""
            muteButtonImage.source = ""
            shuffleButtonImage.source = ""
            
            previousButtonImage.source = `./assets/previous_button.svg?t=${timestamp}`
            playButtonImage.source = mediaManager && mediaManager.is_playing() ? 
                `./assets/pause_button.svg?t=${timestamp}` : 
                `./assets/play_button.svg?t=${timestamp}`
            nextButtonImage.source = `./assets/next_button.svg?t=${timestamp}`
            muteButtonImage.source = getUpdatedMuteSource() + `?t=${timestamp}`
            shuffleButtonImage.source = `./assets/shuffle_button.svg?t=${timestamp}`
        }
    }

    // Helper functions
    function getUpdatedMuteSource() {
        if (mediaManager.is_muted() || muteButton.isMuted || volumeSlider.value === 0) {
            return "./assets/mute_on.svg"
        }
        const volume = volumeSlider.value
        if (volume < 0.2) return "./assets/mute_off_med.svg"
        if (volume > 0.9) return "./assets/mute_off_low.svg"
        return "./assets/mute_off_low.svg"
    }

    function updateMuteButtonImage() {
        muteButtonImage.source = 
            (mediaManager.is_muted() || muteButton.isMuted || volumeSlider.value === 0) ? "./assets/mute_on.svg" :
            volumeSlider.value < 0.2 ? "./assets/mute_off_med.svg" :
            volumeSlider.value > 0.9 ? "./assets/mute_off_low.svg" : 
            "./assets/mute_off_low.svg"
    }
}