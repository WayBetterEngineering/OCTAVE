// Style.qml
pragma Singleton
import QtQuick 2.15

QtObject {
    property string currentTheme: "SolarizedLight"
    
    // This will store our custom themes that are loaded from settings
    property var customThemes: ({})

    // Define theme palettes (built-in themes)
    readonly property var themes: ({
        "SolarizedLight": {
            "base": "#FDF6E3",
            "baseAlt": "#EEE8D5",
            "accent": "#268BD2",
            "text": {
                "primary": "#073642",
                "secondary": "#586E75"
            },
            "states": {
                "hover": "#E0DAC3",
                "paused": "#D6D0B9",
                "playing": "#CCC6AF"
            },
            "sliders": {
                "volume": "#268BD2",
                "media": "#586E75"
            },
            "bottombar": {
                "previous": "#268BD2",
                "play": "#268BD2",
                "pause": "#268BD2",
                "next": "#268BD2",
                "volume": "#268BD2",
                "shuffle": "#268BD2",
                "toggleShade": "#E0DAC3"
            },
            "mediaroom": {
                "previous": "#2AA198",
                "play": "#2AA198",
                "pause": "#2AA198",
                "next": "#2AA198",
                "left": "#2AA198",
                "right": "#2AA198",
                "shuffle": "#2AA198",
                "toggleShade": "#D6D0B9"
            },
            "mainmenu": {
                "mediaContainer": "#9d2aa1"
            }
        },
        // ... other built-in themes
    })

    // Helper function to get current theme
    function getCurrentTheme() {
        // Check if theme is a custom theme first
        if (customThemes[currentTheme]) {
            return customThemes[currentTheme]
        }
        // Fall back to built-in themes
        return themes[currentTheme] || themes["Nightfall"]
    }
    
    // Function to add a custom theme
    function addCustomTheme(name, themeObject) {
        customThemes[name] = themeObject
        // Emit a signal that themes have changed
        customThemesUpdated()
    }
    
    // Function to get all theme names (built-in + custom)
    function getAllThemeNames() {
        let allNames = Object.keys(themes)
        allNames = allNames.concat(Object.keys(customThemes))
        return allNames
    }

    // Color properties that reference the theme
    // ... your existing color properties
    property color volumeSliderColor: getCurrentTheme().sliders.volume
    property color bottomBarGradientStart: getCurrentTheme().base
    property color bottomBarGradientEnd: getCurrentTheme().baseAlt
    property color clockTextColor: getCurrentTheme().accent
    property color bottomBarPreviousButton: getCurrentTheme().bottombar.previous
    property color bottomBarPlayButton: getCurrentTheme().bottombar.play
    property color bottomBarPauseButton: getCurrentTheme().bottombar.pause
    property color bottomBarNextButton: getCurrentTheme().bottombar.next
    property color bottomBarVolumeButton: getCurrentTheme().bottombar.volume
    property color bottomBarShuffleButton: getCurrentTheme().bottombar.shuffle
    property color bottomBarToggleShade: getCurrentTheme().bottombar.toggleShade
    property color bottomBarActiveToggleButton: getCurrentTheme().accent

    // MediaRoom
    property color metadataColor: getCurrentTheme().accent
    property color mediaRoomSlider: getCurrentTheme().sliders.media
    property color mediaRoomSeekColor: getCurrentTheme().sliders.volume
    property color mediaRoomPreviousButton: getCurrentTheme().mediaroom.previous
    property color mediaRoomPlayButton: getCurrentTheme().mediaroom.play
    property color mediaRoomPauseButton: getCurrentTheme().mediaroom.pause
    property color mediaRoomNextButton: getCurrentTheme().mediaroom.next
    property color mediaRoomLeftButton: getCurrentTheme().mediaroom.left
    property color mediaRoomRightButton: getCurrentTheme().mediaroom.right
    property color mediaRoomToggleButton: getCurrentTheme().mediaroom.shuffle
    property color mediaRoomToggleShade: getCurrentTheme().mediaroom.toggleShade

    // MediaPlayer
    property color accent: getCurrentTheme().accent
    property color primaryTextColor: getCurrentTheme().text.primary
    property color secondaryTextColor: getCurrentTheme().text.secondary
    property color hoverColor: getCurrentTheme().states.hover
    property color hoverPausedColor: getCurrentTheme().states.paused
    property color hoverPlayingColor: getCurrentTheme().states.paused
    property color pausedHighlightColor: getCurrentTheme().states.paused
    property color playingHighlightColor: getCurrentTheme().states.playing
    property color rowBackgroundColor: getCurrentTheme().base
    property color backgroundColor: getCurrentTheme().base
    property color headerBackgroundColor: getCurrentTheme().baseAlt
    property color headerTextColor: getCurrentTheme().text.primary

    //MainMenu
    property color mediaContentArea: getCurrentTheme().mainmenu.mediaContainer

    // Settings
    property color sidebarColor: getCurrentTheme().base
    property color contentColor: getCurrentTheme().baseAlt
    
    // Function to update theme
    function setTheme(theme) {
        if (themes[theme] || customThemes[theme]) {
            currentTheme = theme
            // Determine the correct theme object to get button colors
            let themeObj = themes[theme] || customThemes[theme]
            svgManager.update_svg_color(themeObj.bottombar.play)
        }
    }
    
    // Changed signal name to avoid conflict
    signal customThemesUpdated()
}