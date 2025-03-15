// Style.qml
pragma Singleton
import QtQuick 2.15

QtObject {
    property string currentTheme: "Midnight"

    // Define theme palettes
    readonly property var themes: ({
        "Midnight": {
            "base": "#0F1924",
            "baseAlt": "#1A2738",
            "accent": "#64FFDA",
            "text": {
                "primary": "#E0F7FA",
                "secondary": "#90A4AE"
            },
            "states": {
                "hover": "#273A52",
                "paused": "#1F2D3D",
                "playing": "#324A6C"
            },
            "sliders": {
                "volume": "#64FFDA",
                "media": "#90A4AE"
            },
            "bottombar": {
                "previous": "#64FFDA",
                "play": "#64FFDA",
                "pause": "#64FFDA",
                "next": "#64FFDA",
                "volume": "#64FFDA",
                "shuffle": "#64FFDA",
                "toggleShade": "#37474F"
            },
            "mediaroom": {
                "previous": "#B2DFDB",
                "play": "#B2DFDB",
                "pause": "#B2DFDB",
                "next": "#B2DFDB",
                "left": "#B2DFDB",
                "right": "#B2DFDB",
                "shuffle": "#B2DFDB",
                "toggleShade": "#263238"
            }
        },

        "Sakura": {
            "base": "#FFF5F7",
            "baseAlt": "#FFEEF2",
            "accent": "#FF6B95",
            "text": {
                "primary": "#4A2932",
                "secondary": "#9E7C85"
            },
            "states": {
                "hover": "#FFE6EC",
                "paused": "#FFDBDF",
                "playing": "#FFD1D8"
            },
            "sliders": {
                "volume": "#FF6B95",
                "media": "#9E7C85"
            },
            "bottombar": {
                "previous": "#FF6B95",
                "play": "#FF6B95",
                "pause": "#FF6B95",
                "next": "#FF6B95",
                "volume": "#FF6B95",
                "shuffle": "#FF6B95",
                "toggleShade": "#FFD1D8"
            },
            "mediaroom": {
                "previous": "#E8718D",
                "play": "#E8718D",
                "pause": "#E8718D",
                "next": "#E8718D",
                "left": "#E8718D",
                "right": "#E8718D",
                "shuffle": "#E8718D",
                "toggleShade": "#FFDBDF"
            }
        },
        
        "Aurora": {
            "base": "#0E2439",
            "baseAlt": "#183450",
            "accent": "#5BEDC9",
            "text": {
                "primary": "#ECF8FF",
                "secondary": "#A4C2DB"
            },
            "states": {
                "hover": "#234468",
                "paused": "#1D3C5C",
                "playing": "#2A4E7A"
            },
            "sliders": {
                "volume": "#5BEDC9",
                "media": "#A4C2DB"
            },
            "bottombar": {
                "previous": "#5BEDC9",
                "play": "#5BEDC9",
                "pause": "#5BEDC9",
                "next": "#5BEDC9",
                "volume": "#5BEDC9",
                "shuffle": "#5BEDC9",
                "toggleShade": "#234468"
            },
            "mediaroom": {
                "previous": "#D974FF",
                "play": "#D974FF",
                "pause": "#D974FF",
                "next": "#D974FF",
                "left": "#D974FF",
                "right": "#D974FF",
                "shuffle": "#D974FF",
                "toggleShade": "#1D3C5C"
            }
        },
        
        "Sunset": {
            "base": "#2A1B2D",
            "baseAlt": "#3A2840",
            "accent": "#FF7B5F",
            "text": {
                "primary": "#FFF4ED",
                "secondary": "#BFA1C5"
            },
            "states": {
                "hover": "#4A3452",
                "paused": "#412E48",
                "playing": "#563B5F"
            },
            "sliders": {
                "volume": "#FF7B5F",
                "media": "#BFA1C5"
            },
            "bottombar": {
                "previous": "#FF7B5F",
                "play": "#FF9459",
                "pause": "#FF9459",
                "next": "#FF7B5F",
                "volume": "#FFBD4F",
                "shuffle": "#DEAAFF",
                "toggleShade": "#4A3452"
            },
            "mediaroom": {
                "previous": "#FF5A8C",
                "play": "#FF9459",
                "pause": "#FF9459",
                "next": "#FF5A8C",
                "left": "#FFBD4F",
                "right": "#FFBD4F",
                "shuffle": "#DEAAFF",
                "toggleShade": "#412E48"
            }
        },
        
        "Glacier": {
            "base": "#F2FBFF",
            "baseAlt": "#E4F5FD",
            "accent": "#3894D7",
            "text": {
                "primary": "#193147",
                "secondary": "#6C8EAA"
            },
            "states": {
                "hover": "#D6EDF9",
                "paused": "#C8E5F5",
                "playing": "#B9DDF1"
            },
            "sliders": {
                "volume": "#3894D7",
                "media": "#6C8EAA"
            },
            "bottombar": {
                "previous": "#3894D7",
                "play": "#3894D7",
                "pause": "#3894D7",
                "next": "#3894D7",
                "volume": "#3894D7",
                "shuffle": "#3894D7",
                "toggleShade": "#C8E5F5"
            },
            "mediaroom": {
                "previous": "#1F5A82",
                "play": "#1F5A82",
                "pause": "#1F5A82",
                "next": "#1F5A82",
                "left": "#1F5A82",
                "right": "#1F5A82",
                "shuffle": "#1F5A82",
                "toggleShade": "#D6EDF9"
            }
        },
        
        "Bamboo": {
            "base": "#F4F9ED",
            "baseAlt": "#EAF3DE",
            "accent": "#7CB342",
            "text": {
                "primary": "#2C3E19",
                "secondary": "#7D8D71"
            },
            "states": {
                "hover": "#E1EDD0",
                "paused": "#D7E7C1",
                "playing": "#CDE1B2"
            },
            "sliders": {
                "volume": "#7CB342",
                "media": "#7D8D71"
            },
            "bottombar": {
                "previous": "#7CB342",
                "play": "#8BC34A",
                "pause": "#8BC34A",
                "next": "#7CB342",
                "volume": "#689F38",
                "shuffle": "#9CCC65",
                "toggleShade": "#D7E7C1"
            },
            "mediaroom": {
                "previous": "#558B2F",
                "play": "#7CB342",
                "pause": "#7CB342",
                "next": "#558B2F",
                "left": "#689F38",
                "right": "#689F38",
                "shuffle": "#9CCC65",
                "toggleShade": "#E1EDD0"
            }
        },
        
        "Obsidian": {
            "base": "#161616",
            "baseAlt": "#242424",
            "accent": "#BB86FC",
            "text": {
                "primary": "#F6F6F6",
                "secondary": "#B0B0B0"
            },
            "states": {
                "hover": "#323232",
                "paused": "#2A2A2A",
                "playing": "#3A3A3A"
            },
            "sliders": {
                "volume": "#BB86FC",
                "media": "#B0B0B0"
            },
            "bottombar": {
                "previous": "#BB86FC",
                "play": "#BB86FC",
                "pause": "#BB86FC",
                "next": "#BB86FC",
                "volume": "#BB86FC",
                "shuffle": "#BB86FC",
                "toggleShade": "#323232"
            },
            "mediaroom": {
                "previous": "#03DAC5",
                "play": "#03DAC5",
                "pause": "#03DAC5",
                "next": "#03DAC5",
                "left": "#03DAC5",
                "right": "#03DAC5",
                "shuffle": "#03DAC5",
                "toggleShade": "#2A2A2A"
            }
        },
        
        "Neo": {
            "base": "#0C0C14",
            "baseAlt": "#14141F",
            "accent": "#01FFC3",
            "text": {
                "primary": "#F7FBFF",
                "secondary": "#8A8D9C"
            },
            "states": {
                "hover": "#1C1C2A",
                "paused": "#161621",
                "playing": "#222234"
            },
            "sliders": {
                "volume": "#01FFC3",
                "media": "#8A8D9C"
            },
            "bottombar": {
                "previous": "#01FFC3",
                "play": "#01FFC3",
                "pause": "#01FFC3",
                "next": "#01FFC3",
                "volume": "#01FFC3",
                "shuffle": "#01FFC3",
                "toggleShade": "#1C1C2A"
            },
            "mediaroom": {
                "previous": "#F62E8E",
                "play": "#01FFC3",
                "pause": "#01FFC3",
                "next": "#F62E8E",
                "left": "#2196F3",
                "right": "#2196F3",
                "shuffle": "#F62E8E",
                "toggleShade": "#161621"
            }
        },
        
        "Terracotta": {
            "base": "#FFFAF5",
            "baseAlt": "#FFF0E6",
            "accent": "#E76F51",
            "text": {
                "primary": "#33272A",
                "secondary": "#8A6552"
            },
            "states": {
                "hover": "#FFE6D7",
                "paused": "#FFDCC9",
                "playing": "#FFD2BA"
            },
            "sliders": {
                "volume": "#E76F51",
                "media": "#8A6552"
            },
            "bottombar": {
                "previous": "#E76F51",
                "play": "#E76F51",
                "pause": "#E76F51",
                "next": "#E76F51",
                "volume": "#E76F51",
                "shuffle": "#E76F51",
                "toggleShade": "#FFDCC9"
            },
            "mediaroom": {
                "previous": "#F4A261",
                "play": "#F4A261",
                "pause": "#F4A261",
                "next": "#F4A261",
                "left": "#F4A261",
                "right": "#F4A261",
                "shuffle": "#F4A261",
                "toggleShade": "#FFE6D7"
            }
        },
        
        "Azure": {
            "base": "#F8FBFF",
            "baseAlt": "#EFF6FF",
            "accent": "#0066FF",
            "text": {
                "primary": "#0A2F5E",
                "secondary": "#5B7BA5"
            },
            "states": {
                "hover": "#E1EFFF",
                "paused": "#D3E6FF",
                "playing": "#C6DDFF"
            },
            "sliders": {
                "volume": "#0066FF",
                "media": "#5B7BA5"
            },
            "bottombar": {
                "previous": "#0066FF",
                "play": "#0066FF",
                "pause": "#0066FF",
                "next": "#0066FF",
                "volume": "#0066FF",
                "shuffle": "#0066FF",
                "toggleShade": "#D3E6FF"
            },
            "mediaroom": {
                "previous": "#1E88E5",
                "play": "#1E88E5",
                "pause": "#1E88E5",
                "next": "#1E88E5",
                "left": "#1E88E5",
                "right": "#1E88E5",
                "shuffle": "#1E88E5",
                "toggleShade": "#E1EFFF"
            }
        },
        
        "Emerald": {
            "base": "#0D1F1A",
            "baseAlt": "#142E26",
            "accent": "#00E676",
            "text": {
                "primary": "#E8FFF3",
                "secondary": "#82A39A"
            },
            "states": {
                "hover": "#193D32",
                "paused": "#16352B",
                "playing": "#1C463A"
            },
            "sliders": {
                "volume": "#00E676",
                "media": "#82A39A"
            },
            "bottombar": {
                "previous": "#00E676",
                "play": "#00E676",
                "pause": "#00E676",
                "next": "#00E676",
                "volume": "#00E676",
                "shuffle": "#00E676",
                "toggleShade": "#193D32"
            },
            "mediaroom": {
                "previous": "#4DB6AC",
                "play": "#4DB6AC",
                "pause": "#4DB6AC",
                "next": "#4DB6AC",
                "left": "#4DB6AC",
                "right": "#4DB6AC",
                "shuffle": "#4DB6AC",
                "toggleShade": "#16352B"
            }
        },
        
        "Serenity": {
            "base": "#EAEFF7",
            "baseAlt": "#DDE6F3",
            "accent": "#7E9AE5",
            "text": {
                "primary": "#293658",
                "secondary": "#7486AD"
            },
            "states": {
                "hover": "#D0DDEE",
                "paused": "#C3D4E9",
                "playing": "#B6CBE4"
            },
            "sliders": {
                "volume": "#7E9AE5",
                "media": "#7486AD"
            },
            "bottombar": {
                "previous": "#7E9AE5",
                "play": "#7E9AE5",
                "pause": "#7E9AE5",
                "next": "#7E9AE5",
                "volume": "#7E9AE5",
                "shuffle": "#7E9AE5",
                "toggleShade": "#C3D4E9"
            },
            "mediaroom": {
                "previous": "#90A4D7",
                "play": "#90A4D7",
                "pause": "#90A4D7",
                "next": "#90A4D7",
                "left": "#90A4D7",
                "right": "#90A4D7",
                "shuffle": "#90A4D7",
                "toggleShade": "#D0DDEE"
            }
        }
    })

    // Helper function to get current theme
    function getCurrentTheme() {
        return themes[currentTheme] || themes["Midnight"]
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