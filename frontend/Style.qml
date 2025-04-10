// Style.qml
pragma Singleton
import QtQuick 2.15

QtObject {
    property string currentTheme: "Nightfall"

    // Define theme palettes
    readonly property var themes: ({
        "Nightfall": {
            "base": "#12151A",
            "baseAlt": "#1C2026",
            "accent": "#5CCFE6",
            "text": {
                "primary": "#FFFFFF",
                "secondary": "#B3C0D1"
            },
            "states": {
                "hover": "#2A3140",
                "paused": "#232933",
                "playing": "#2D3747"
            },
            "sliders": {
                "volume": "#5CCFE6",
                "media": "#B3C0D1"
            },
            "bottombar": {
                "previous": "#5CCFE6",
                "play": "#5CCFE6",
                "pause": "#5CCFE6",
                "next": "#5CCFE6",
                "volume": "#5CCFE6",
                "shuffle": "#5CCFE6",
                "toggleShade": "#2A3140"
            },
            "mediaroom": {
                "previous": "#80DEEA",
                "play": "#80DEEA",
                "pause": "#80DEEA",
                "next": "#80DEEA",
                "left": "#80DEEA",
                "right": "#80DEEA",
                "shuffle": "#80DEEA",
                "toggleShade": "#232933"
            }
        },

        "Daylight": {
            "base": "#F2F5F8",
            "baseAlt": "#E5EAF0",
            "accent": "#0066CC",
            "text": {
                "primary": "#14273D",
                "secondary": "#4A6583"
            },
            "states": {
                "hover": "#DBE3ED",
                "paused": "#D1DBE7",
                "playing": "#C7D3E1"
            },
            "sliders": {
                "volume": "#0066CC",
                "media": "#4A6583"
            },
            "bottombar": {
                "previous": "#0066CC",
                "play": "#0066CC",
                "pause": "#0066CC",
                "next": "#0066CC",
                "volume": "#0066CC",
                "shuffle": "#0066CC",
                "toggleShade": "#DBE3ED"
            },
            "mediaroom": {
                "previous": "#2276D2",
                "play": "#2276D2",
                "pause": "#2276D2",
                "next": "#2276D2",
                "left": "#2276D2",
                "right": "#2276D2",
                "shuffle": "#2276D2",
                "toggleShade": "#D1DBE7"
            }
        },
        
        "SolarizedDark": {
            "base": "#002B36",
            "baseAlt": "#073642",
            "accent": "#2AA198",
            "text": {
                "primary": "#FDF6E3",
                "secondary": "#93A1A1"
            },
            "states": {
                "hover": "#0E4B59",
                "paused": "#084150",
                "playing": "#145766"
            },
            "sliders": {
                "volume": "#2AA198",
                "media": "#93A1A1"
            },
            "bottombar": {
                "previous": "#2AA198",
                "play": "#2AA198",
                "pause": "#2AA198",
                "next": "#2AA198",
                "volume": "#2AA198",
                "shuffle": "#2AA198",
                "toggleShade": "#0E4B59"
            },
            "mediaroom": {
                "previous": "#268BD2",
                "play": "#268BD2",
                "pause": "#268BD2",
                "next": "#268BD2",
                "left": "#268BD2",
                "right": "#268BD2",
                "shuffle": "#268BD2",
                "toggleShade": "#084150"
            }
        },
        
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
            }
        },
        
        "HighContrast": {
            "base": "#000000",
            "baseAlt": "#171717",
            "accent": "#FFFF00",
            "text": {
                "primary": "#FFFFFF",
                "secondary": "#DDDDDD"
            },
            "states": {
                "hover": "#2A2A2A",
                "paused": "#222222",
                "playing": "#333333"
            },
            "sliders": {
                "volume": "#FFFF00",
                "media": "#DDDDDD"
            },
            "bottombar": {
                "previous": "#FFFF00",
                "play": "#FFFF00",
                "pause": "#FFFF00",
                "next": "#FFFF00",
                "volume": "#FFFF00",
                "shuffle": "#FFFF00",
                "toggleShade": "#2A2A2A"
            },
            "mediaroom": {
                "previous": "#FFFFFF",
                "play": "#FFFFFF",
                "pause": "#FFFFFF",
                "next": "#FFFFFF",
                "left": "#FFFFFF",
                "right": "#FFFFFF",
                "shuffle": "#FFFFFF",
                "toggleShade": "#222222"
            }
        },
        
        "ArcticBlue": {
            "base": "#F0F7FD",
            "baseAlt": "#DFE9F5",
            "accent": "#006EE6",
            "text": {
                "primary": "#0A2742",
                "secondary": "#4D6B8A"
            },
            "states": {
                "hover": "#CFDBED",
                "paused": "#C0CDE2",
                "playing": "#B1BFD8"
            },
            "sliders": {
                "volume": "#006EE6",
                "media": "#4D6B8A"
            },
            "bottombar": {
                "previous": "#006EE6",
                "play": "#006EE6",
                "pause": "#006EE6",
                "next": "#006EE6",
                "volume": "#006EE6",
                "shuffle": "#006EE6",
                "toggleShade": "#CFDBED"
            },
            "mediaroom": {
                "previous": "#1A85FF",
                "play": "#1A85FF",
                "pause": "#1A85FF",
                "next": "#1A85FF",
                "left": "#1A85FF",
                "right": "#1A85FF",
                "shuffle": "#1A85FF",
                "toggleShade": "#C0CDE2"
            }
        },
        
        "DesertSand": {
            "base": "#FDF8F1",
            "baseAlt": "#F2EAE0",
            "accent": "#D35400",
            "text": {
                "primary": "#301D15",
                "secondary": "#785A46"
            },
            "states": {
                "hover": "#E6DCD0",
                "paused": "#D9CFC3",
                "playing": "#CCC2B6"
            },
            "sliders": {
                "volume": "#D35400",
                "media": "#785A46"
            },
            "bottombar": {
                "previous": "#D35400",
                "play": "#D35400",
                "pause": "#D35400",
                "next": "#D35400",
                "volume": "#D35400",
                "shuffle": "#D35400",
                "toggleShade": "#E6DCD0"
            },
            "mediaroom": {
                "previous": "#E67E22",
                "play": "#E67E22",
                "pause": "#E67E22",
                "next": "#E67E22",
                "left": "#E67E22",
                "right": "#E67E22",
                "shuffle": "#E67E22",
                "toggleShade": "#D9CFC3"
            }
        },
        
        "MidnightOasis": {
            "base": "#101820",
            "baseAlt": "#1A222C",
            "accent": "#00E676",
            "text": {
                "primary": "#FFFFFF",
                "secondary": "#A2B5CD"
            },
            "states": {
                "hover": "#2A3441",
                "paused": "#232D39",
                "playing": "#313C4A"
            },
            "sliders": {
                "volume": "#00E676",
                "media": "#A2B5CD"
            },
            "bottombar": {
                "previous": "#00E676",
                "play": "#00E676",
                "pause": "#00E676",
                "next": "#00E676",
                "volume": "#00E676",
                "shuffle": "#00E676",
                "toggleShade": "#2A3441"
            },
            "mediaroom": {
                "previous": "#26A69A",
                "play": "#26A69A",
                "pause": "#26A69A",
                "next": "#26A69A",
                "left": "#26A69A",
                "right": "#26A69A",
                "shuffle": "#26A69A",
                "toggleShade": "#232D39"
            }
        },
        
        "GrayscaleDark": {
            "base": "#1A1A1A",
            "baseAlt": "#262626",
            "accent": "#FFFFFF",
            "text": {
                "primary": "#F5F5F5",
                "secondary": "#B0B0B0"
            },
            "states": {
                "hover": "#333333",
                "paused": "#2C2C2C",
                "playing": "#3A3A3A"
            },
            "sliders": {
                "volume": "#FFFFFF",
                "media": "#B0B0B0"
            },
            "bottombar": {
                "previous": "#FFFFFF",
                "play": "#FFFFFF",
                "pause": "#FFFFFF",
                "next": "#FFFFFF",
                "volume": "#FFFFFF",
                "shuffle": "#FFFFFF",
                "toggleShade": "#333333"
            },
            "mediaroom": {
                "previous": "#DEDEDE",
                "play": "#DEDEDE",
                "pause": "#DEDEDE",
                "next": "#DEDEDE",
                "left": "#DEDEDE",
                "right": "#DEDEDE",
                "shuffle": "#DEDEDE",
                "toggleShade": "#2C2C2C"
            }
        },
        
        "GrayscaleLight": {
            "base": "#F5F5F5",
            "baseAlt": "#E8E8E8",
            "accent": "#000000",
            "text": {
                "primary": "#1A1A1A",
                "secondary": "#5E5E5E"
            },
            "states": {
                "hover": "#DBDBDB",
                "paused": "#D1D1D1",
                "playing": "#C7C7C7"
            },
            "sliders": {
                "volume": "#000000",
                "media": "#5E5E5E"
            },
            "bottombar": {
                "previous": "#000000",
                "play": "#000000",
                "pause": "#000000",
                "next": "#000000",
                "volume": "#000000",
                "shuffle": "#000000",
                "toggleShade": "#DBDBDB"
            },
            "mediaroom": {
                "previous": "#333333",
                "play": "#333333",
                "pause": "#333333",
                "next": "#333333",
                "left": "#333333",
                "right": "#333333",
                "shuffle": "#333333",
                "toggleShade": "#D1D1D1"
            }
        },
        
        "DeepOcean": {
            "base": "#0A192F",
            "baseAlt": "#142640",
            "accent": "#64FFDA",
            "text": {
                "primary": "#E6F1FF",
                "secondary": "#8892B0"
            },
            "states": {
                "hover": "#1E3555",
                "paused": "#1A2E4A",
                "playing": "#233C5F"
            },
            "sliders": {
                "volume": "#64FFDA",
                "media": "#8892B0"
            },
            "bottombar": {
                "previous": "#64FFDA",
                "play": "#64FFDA",
                "pause": "#64FFDA",
                "next": "#64FFDA",
                "volume": "#64FFDA",
                "shuffle": "#64FFDA",
                "toggleShade": "#1E3555"
            },
            "mediaroom": {
                "previous": "#5CCFEE",
                "play": "#5CCFEE",
                "pause": "#5CCFEE",
                "next": "#5CCFEE",
                "left": "#5CCFEE",
                "right": "#5CCFEE",
                "shuffle": "#5CCFEE",
                "toggleShade": "#1A2E4A"
            }
        },
        
        "ForestGreen": {
            "base": "#EEFAE9",
            "baseAlt": "#DFF0D8",
            "accent": "#2E7D32",
            "text": {
                "primary": "#1B341C",
                "secondary": "#5C775E"
            },
            "states": {
                "hover": "#D1E7C9",
                "paused": "#C3DDBA",
                "playing": "#B5D3AA"
            },
            "sliders": {
                "volume": "#2E7D32",
                "media": "#5C775E"
            },
            "bottombar": {
                "previous": "#2E7D32",
                "play": "#2E7D32",
                "pause": "#2E7D32",
                "next": "#2E7D32",
                "volume": "#2E7D32",
                "shuffle": "#2E7D32",
                "toggleShade": "#D1E7C9"
            },
            "mediaroom": {
                "previous": "#43A047",
                "play": "#43A047",
                "pause": "#43A047",
                "next": "#43A047",
                "left": "#43A047",
                "right": "#43A047",
                "shuffle": "#43A047",
                "toggleShade": "#C3DDBA"
            }
        },
        
        "AmberNight": {
            "base": "#121212",
            "baseAlt": "#1D1D1D",
            "accent": "#FFC107",
            "text": {
                "primary": "#FFFFFF",
                "secondary": "#B3B3B3"
            },
            "states": {
                "hover": "#2C2C2C",
                "paused": "#242424",
                "playing": "#333333"
            },
            "sliders": {
                "volume": "#FFC107",
                "media": "#B3B3B3"
            },
            "bottombar": {
                "previous": "#FFC107",
                "play": "#FFC107",
                "pause": "#FFC107",
                "next": "#FFC107",
                "volume": "#FFC107",
                "shuffle": "#FFC107",
                "toggleShade": "#2C2C2C"
            },
            "mediaroom": {
                "previous": "#FFD54F",
                "play": "#FFD54F",
                "pause": "#FFD54F",
                "next": "#FFD54F",
                "left": "#FFD54F",
                "right": "#FFD54F",
                "shuffle": "#FFD54F",
                "toggleShade": "#242424"
            }
        }
    })

    // Helper function to get current theme
    function getCurrentTheme() {
        return themes[currentTheme] || themes["Nightfall"]
    }

    // Color properties that reference the theme
    // Bottom Bar
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

    // Settings
    property color sidebarColor: getCurrentTheme().base
    property color contentColor: getCurrentTheme().baseAlt

    // Function to update theme
    function setTheme(theme) {
        if (themes[theme]) {
            currentTheme = theme
            svgManager.update_svg_color(themes[theme].buttons)
        }
    }
}