import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "." as App

ApplicationWindow {
    id: mainWindow
    visible: true
    title: deviceName

    // Minimum window constraints
    minimumWidth: 400
    minimumHeight: 300

    // Properties bound to settings manager
    property string deviceName: settingsManager ? settingsManager.deviceName : "Default Device"
    property string theme: settingsManager ? settingsManager.themeSetting : "Light"
    property real startUpVolume: settingsManager ? settingsManager.startUpVolume : 0.1
    property bool showClock: settingsManager ? settingsManager.showClock : true
    property bool clockFormat24Hour: settingsManager ? settingsManager.clockFormat24Hour : true
    property int clockSize: settingsManager ? settingsManager.clockSize : 18
    property string lastSettingsSection: "deviceSettings"

    // Screen dimension properties
    property int screenWidth: settingsManager ? settingsManager.screenWidth : 1280
    property int screenHeight: settingsManager ? settingsManager.screenHeight : 720

    // Set initial window size
    width: screenWidth
    height: screenHeight

    // Initialize settings and theme
    Component.onCompleted: {
        if (settingsManager) {
            // Load theme
            if (settingsManager.themeSetting) {
                App.Style.setTheme(settingsManager.themeSetting)
            }
            
            // Load dimensions
            width = settingsManager.screenWidth
            height = settingsManager.screenHeight
            
            // Initialize spacing
            App.Spacing.updateDimensions(width, height)
        }
    }

    // Window resize handlers
    onWidthChanged: {
        if (settingsManager && width > 0 && width >= minimumWidth) {
            settingsManager.save_screen_width(width)
            screenWidth = width
            App.Spacing.updateDimensions(width, height)
        }
    }

    onHeightChanged: {
        if (settingsManager && height > 0 && height >= minimumHeight) {
            settingsManager.save_screen_height(height)
            screenHeight = height
            App.Spacing.updateDimensions(width, height)
        }
    }

    // Settings manager connections
    Connections {
        target: settingsManager
        
        function onScreenWidthChanged() {
            if (settingsManager) {
                width = settingsManager.screenWidth
                App.Spacing.updateDimensions(width, height)
            }
        }
        
        function onScreenHeightChanged() {
            if (settingsManager) {
                height = settingsManager.screenHeight
                App.Spacing.updateDimensions(width, height)
            }
        }
        
        function onThemeSettingChanged() {
            if (settingsManager) {
                App.Style.setTheme(settingsManager.themeSetting)
                theme = settingsManager.themeSetting
            }
        }
    }

    // Main stack view
    StackView {
        id: stackView
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: bottomBar.top
        }
        
        initialItem: Qt.createComponent("MainMenu.qml").createObject(stackView, {
            stackView: stackView,
            mainWindow: mainWindow
        })
        
        // Disable transitions for better performance
        pushEnter: null
        pushExit: null
        popEnter: null
        popExit: null
        replaceEnter: null
        replaceExit: null
    }

    // Bottom bar
    BottomBar {
        id: bottomBar
        anchors.bottom: parent.bottom
        stackView: stackView
        mainWindow: mainWindow
    }

    // Settings update functions
    function updateDeviceName(newDeviceName) {
        if (settingsManager && newDeviceName.trim() !== "") {
            settingsManager.save_device_name(newDeviceName)
            deviceName = newDeviceName
        }
    }

    function updateTheme(newTheme) {
        if (settingsManager) {
            settingsManager.save_theme_setting(newTheme)
            App.Style.setTheme(newTheme)
            theme = newTheme
        }
    }

    function updateStartupVolume(newVolume) {
        if (settingsManager) {
            settingsManager.save_start_volume(newVolume)
            startUpVolume = newVolume
        }
    }

    function updateScreenDimensions(newWidth, newHeight) {
        if (settingsManager) {
            if (newWidth >= minimumWidth) {
                settingsManager.save_screen_width(newWidth)
                width = newWidth
            }
            if (newHeight >= minimumHeight) {
                settingsManager.save_screen_height(newHeight)
                height = newHeight
            }
            App.Spacing.updateDimensions(width, height)
        }
    }
}