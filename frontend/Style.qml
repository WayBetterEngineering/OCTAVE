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
        "NightDrive": {
            "base": "#121212",
            "baseAlt": "#1E1E1E",
            "accent": "#3F88F2",
            "text": {
                "primary": "#FFFFFF",
                "secondary": "#AAAAAA"
            },
            "states": {
                "hover": "#2A2A2A",
                "paused": "#252525",
                "playing": "#303030"
            },
            "sliders": {
                "volume": "#3F88F2",
                "media": "#AAAAAA"
            },
            "bottombar": {
                "previous": "#3F88F2",
                "play": "#3F88F2",
                "pause": "#3F88F2",
                "next": "#3F88F2",
                "volume": "#3F88F2",
                "shuffle": "#3F88F2",
                "toggleShade": "#2A2A2A"
            },
            "mediaroom": {
                "previous": "#5E9CF3",
                "play": "#5E9CF3",
                "pause": "#5E9CF3",
                "next": "#5E9CF3",
                "left": "#5E9CF3",
                "right": "#5E9CF3",
                "shuffle": "#5E9CF3",
                "toggleShade": "#252525"
            },
            "mainmenu": {
                "mediaContainer": "#1A3F70"
            }
        },
        "DashboardRed": {
            "base": "#1A1A1A",
            "baseAlt": "#252525",
            "accent": "#E53935",
            "text": {
                "primary": "#FFFFFF",
                "secondary": "#B0B0B0"
            },
            "states": {
                "hover": "#2F2F2F",
                "paused": "#2A2A2A",
                "playing": "#353535"
            },
            "sliders": {
                "volume": "#E53935",
                "media": "#B0B0B0"
            },
            "bottombar": {
                "previous": "#E53935",
                "play": "#E53935",
                "pause": "#E53935",
                "next": "#E53935",
                "volume": "#E53935",
                "shuffle": "#E53935",
                "toggleShade": "#2F2F2F"
            },
            "mediaroom": {
                "previous": "#F05545",
                "play": "#F05545",
                "pause": "#F05545",
                "next": "#F05545",
                "left": "#F05545",
                "right": "#F05545",
                "shuffle": "#F05545",
                "toggleShade": "#2A2A2A"
            },
            "mainmenu": {
                "mediaContainer": "#7A1F1D"
            }
        },
        "EcoGreen": {
            "base": "#FAFAFA",
            "baseAlt": "#F0F0F0",
            "accent": "#43A047",
            "text": {
                "primary": "#212121",
                "secondary": "#757575"
            },
            "states": {
                "hover": "#E0E0E0",
                "paused": "#DBDBDB",
                "playing": "#D6D6D6"
            },
            "sliders": {
                "volume": "#43A047",
                "media": "#757575"
            },
            "bottombar": {
                "previous": "#43A047",
                "play": "#43A047",
                "pause": "#43A047",
                "next": "#43A047",
                "volume": "#43A047",
                "shuffle": "#43A047",
                "toggleShade": "#E0E0E0"
            },
            "mediaroom": {
                "previous": "#66BB6A",
                "play": "#66BB6A",
                "pause": "#66BB6A",
                "next": "#66BB6A",
                "left": "#66BB6A",
                "right": "#66BB6A",
                "shuffle": "#66BB6A",
                "toggleShade": "#DBDBDB"
            },
            "mainmenu": {
                "mediaContainer": "#2E7D32"
            }
        },
        "ElectricBlue": {
            "base": "#ECEFF1",
            "baseAlt": "#CFD8DC",
            "accent": "#0277BD",
            "text": {
                "primary": "#263238",
                "secondary": "#546E7A"
            },
            "states": {
                "hover": "#B0BEC5",
                "paused": "#A7B4BC",
                "playing": "#9EA7AC"
            },
            "sliders": {
                "volume": "#0277BD",
                "media": "#546E7A"
            },
            "bottombar": {
                "previous": "#0277BD",
                "play": "#0277BD",
                "pause": "#0277BD",
                "next": "#0277BD",
                "volume": "#0277BD",
                "shuffle": "#0277BD",
                "toggleShade": "#B0BEC5"
            },
            "mediaroom": {
                "previous": "#039BE5",
                "play": "#039BE5",
                "pause": "#039BE5",
                "next": "#039BE5",
                "left": "#039BE5",
                "right": "#039BE5",
                "shuffle": "#039BE5",
                "toggleShade": "#A7B4BC"
            },
            "mainmenu": {
                "mediaContainer": "#01579B"
            }
        }
    })

    // Rest of the file remains unchanged
    // ...

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