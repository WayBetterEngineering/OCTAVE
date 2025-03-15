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

    // Media Controls Section
    RowLayout { // Media Controls
        id: mediaControls
        anchors {
            left: parent.left
            leftMargin: App.Spacing.overallMargin
            verticalCenter: parent.verticalCenter
        }
        spacing: App.Spacing.bottomBarBetweenButtonMargin

        Control { // previous button
            id: previousButtonControl
            implicitWidth: App.Spacing.bottomBarPreviousButtonWidth
            implicitHeight: App.Spacing.bottomBarPreviousButtonHeight
            
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

            background: Rectangle {
                color: "transparent"
            }
            
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
        Control { // play pause button
            id: playButtonControl
            implicitWidth: App.Spacing.bottomBarPlayButtonWidth
            implicitHeight: App.Spacing.bottomBarPlayButtonHeight

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

            background: Rectangle {
                color: "transparent"
            }
            contentItem: Image {
                Image {
                    id: playButtonImage
                    anchors.centerIn: parent
                    width: parent.height
                    height: parent.height
                    source: mediaManager && mediaManager.is_playing() ? "./assets/pause_button.svg" : "./assets/play_button.svg"
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
        Control { // next button
            id: nextButtonControl
            implicitWidth: App.Spacing.bottomBarNextButtonWidth
            implicitHeight: App.Spacing.bottomBarNextButtonHeight

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
            background: Rectangle {
                color: "transparent"
            }
            contentItem: Image {
                Image{
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
                ColorOverlay{
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
        Control { // shuffle button
                id: shuffleButton
                property bool isShuffleEnabled: mediaManager ? mediaManager.is_shuffled() : false
                implicitWidth: App.Spacing.bottomBarShuffleButtonWidth
                implicitHeight: App.Spacing.bottomBarShuffleButtonHeight

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
                    onClicked: {
                        mediaManager.toggle_shuffle()
                    }
                }
        }
        Control { // mute button
            id: muteButton
            property bool isMuted: false
            implicitWidth: App.Spacing.bottomBarMuteButtonWidth
            implicitHeight: App.Spacing.bottomBarMuteButtonHeight

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

            background: Rectangle {
                color: "transparent"
            }
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
                    visible: false  // Make invisible since we use ColorOverlay
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
        Control { // Volume Slider Control
            id: volumeControl
            implicitWidth: App.Spacing.bottomBarVolumeSliderWidth
            implicitHeight: App.Spacing.bottomBarVolumeSliderHeight
            
            // Display volume percentage in bottom bar
            Text {
                id: volumeText
                anchors {
                    left: parent.left
                    leftMargin: App.Spacing.overallMargin
                    verticalCenter: parent.verticalCenter
                }
                text: volumeControl.currentValue + "%"
                color: App.Style.primaryTextColor
                font.pixelSize: App.Spacing.bottomBarVolumeText
                font.bold: true
            }
            
            // Store current volume value as a percentage (0-100)
            property int currentValue: 0  // Start at 0 until properly initialized
            
            // Initial setup
            Component.onCompleted: {
                if (settingsManager) {
                    // Calculate percentage from 0-1 range
                    var volumeValue = settingsManager.startUpVolume
                    
                    // Convert to percentage (0-100)
                    currentValue = Math.round(Math.sqrt(volumeValue) * 100)
                    
                    // Apply the volume to the media manager
                    mediaManager.setVolume(volumeValue)
                    
                    console.log("Startup volume set to: " + volumeValue + " (" + currentValue + "%)")
                } else {
                    currentValue = 10
                    mediaManager.setVolume(0.1)
                    console.log("No settings manager, default volume set to 10%")
                }
                
                // Update the mute button image based on current volume
                updateMuteButtonImage()

                if (mediaManager) {
                    shuffleButton.isShuffleEnabled = mediaManager.is_shuffled()
                }
            }
            
            // Make clickable
            MouseArea {
                anchors.fill: parent
                onClicked: function() {
                    popupSlider.open()
                }
            }

            // Popup vertical slider with integrated volume display
            Popup {
                id: popupSlider
                width: App.Spacing.bottomBarVolumePopupWidth
                height: App.Spacing.bottomBarVolumePopupHeight
                x: parent.width / 2 - width / 2
                y: -height
                modal: true
                focus: true
                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
                
                // Prevent clipping so we can position elements outside the popup boundaries
                clip: false
                
                background: Rectangle {
                    color: App.Style.backgroundColor
                    radius: 12
                    border.color: App.Style.accent
                    border.width: 1
                }
                
                contentItem: Item {
                    anchors.fill: parent
                    
                    Slider {
                        id: volumeSlider
                        anchors {
                            fill: parent
                            margins: 15
                        }
                        orientation: Qt.Vertical
                        from: 0
                        to: 100
                        stepSize: 1
                        value: volumeControl.currentValue
                        
                        handle: Rectangle {
                            x: volumeSlider.leftPadding + volumeSlider.availableWidth / 2 - width / 2
                            y: volumeSlider.topPadding + volumeSlider.visualPosition * (volumeSlider.availableHeight - height)
                            width: App.Spacing.overallSliderWidth
                            height: App.Spacing.overallSliderHeight
                            radius: App.Spacing.overallSliderRadius
                            color: App.Style.accent
                        }
                        
                        background: Rectangle {
                            x: volumeSlider.leftPadding + volumeSlider.availableWidth / 2 - width / 2
                            y: volumeSlider.topPadding
                            width: 12
                            height: volumeSlider.availableHeight
                            radius: 6
                            color: App.Style.hoverColor
                            
                            Rectangle {
                                x: 0
                                y: volumeSlider.visualPosition * parent.height
                                width: parent.width
                                height: parent.height - y
                                color: App.Style.volumeSliderColor
                                radius: 6
                            }
                        }
                        
                        onValueChanged: {
                            // Update the display text
                            volumeControl.currentValue = value
                            
                            // Convert percentage (0-100) to volume (0-1)
                            var normalizedValue = value / 100
                            
                            // Apply logarithmic scaling
                            var logVolume = Math.pow(normalizedValue, 2.)
                            mediaManager.setVolume(logVolume)
                            
                            // Handle mute toggling
                            if (value > 0 && muteButton.isMuted) {
                                muteButton.isMuted = false
                                mediaManager.toggle_mute()
                            }
                            updateMuteButtonImage()
                        }
                    }
                    
                    // Volume percentage display - attached to the popup but positioned outside
                    Rectangle {
                        id: volumePercentageDisplay
                        width: App.Spacing.bottomBarVolumePopupTextBoxWidth
                        height: App.Spacing.bottomBarVolumePopupTextBoxHeight
                        
                        // Position to the right of the popup
                        x: App.Spacing.bottomBarVolumePopupTextMargin
                        y: parent.height / 2 - height / 2
                        
                        color: "transparent"
                        
                        // This display is part of the popup, so it won't be affected by the modal overlay
                        Text {
                            anchors.centerIn: parent
                            text: volumeSlider.value + "%"
                            color: App.Style.primaryTextColor
                            font.pixelSize: App.Spacing.bottomBarVolumePopupText
                            font.bold: true
                        }
                    }
                }
            }
        }
    }


    GridLayout {     // Navigation Bar
        columns: 5
        columnSpacing: 10
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }

        Control {
            implicitWidth: 50
            implicitHeight: 50
            contentItem: Text {
                text: "Home"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: App.Style.primaryTextColor
            }
            MouseArea {
                anchors.fill: parent
                onClicked: stackView.pop(null)
            }
        }

        Control {
            implicitWidth: 50
            implicitHeight: 50
            contentItem: Text {
                text: "OBD"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: App.Style.primaryTextColor
            }
            MouseArea {
                anchors.fill: parent
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

        Control {
            implicitWidth: 50
            implicitHeight: 50
            contentItem: Text {
                text: "Settings"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: App.Style.primaryTextColor
            }
            MouseArea {
                anchors.fill: parent
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

        Control {
            implicitWidth: 50
            implicitHeight: 50
            contentItem: Text {
                text: "Media"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: App.Style.primaryTextColor
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    var page = Qt.createComponent("MediaRoom.qml").createObject(stackView, {
                        stackView: bottomBar.stackView
                    })
                    stackView.push(page)
                }
            }
        }
    }


    RowLayout {     // Right Controls
        id: rightControls
        anchors {
            right: parent.right
            rightMargin: 20
            verticalCenter: parent.verticalCenter
        }
        spacing: 10

        Text {
            id: clockText
            visible: settingsManager ? settingsManager.showClock : true
            font.pixelSize: settingsManager ? settingsManager.clockSize : 18
            color: App.Style.clockTextColor
        }
    }


    Connections {     // Connections
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
        if (volume > 0.9) return "./assets/mute_off_high.svg"
        return "./assets/mute_off_low.svg"
    }

    function updateMuteButtonImage() {
        muteButtonImage.source = 
            (mediaManager.is_muted() || muteButton.isMuted || volumeSlider.value === 0) ? "./assets/mute_on.svg" :
            volumeSlider.value < 0.2 ? "./assets/mute_off_med.svg" :
            volumeSlider.value > 0.9 ? "./assets/mute_off_high.svg" : 
            "./assets/mute_off_low.svg"
    }
}