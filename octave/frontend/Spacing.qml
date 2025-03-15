// Spacing.qml
pragma Singleton
import QtQuick 2.15

QtObject {
    // Base screen dimensions
    property int applicationWidth: width
    property int applicationHeight: height
    
    // Global scaling factors
    property real globalScale: 1.0
    property real textScale: 1.0
    property real controlScale: 1.0
    
    // Remove responsive breakpoints
    // readonly property bool isSmallScreen: applicationWidth < 600
    // readonly property bool isMediumScreen: applicationWidth >= 600 && applicationWidth < 1024
    // readonly property bool isLargeScreen: applicationWidth >= 1024
    
    property real normalButtonSize: 0.05

    property double settingsMinPreviewWidth: 250
    
    // =======================================
    // ===== KEEP ALL ORIGINAL PROPERTIES ====
    // =======================================
    
    // overall % - use single values instead of conditionals
    property real overallMarginPercent: 0.01
    property real overallTextPercent: 0.035
    property real overallSpacingPercent: .05

    property real overallSliderWidthPercent: 0.06
    property real overallSliderHeightPercent: 0.06
    property real overallSliderRadiusPercent: 0.03 //use 0.01 for more square slider

    // Bottom Bar %
    property real bottomBarBetweenButtonMarginPercent: 0.01

    property real bottomBarHeightPercent: 0.125

    property real bottomBarPreviousButtonWidthPercent: normalButtonSize
    property real bottomBarPreviousButtonHeightPercent: normalButtonSize

    property real bottomBarPlayButtonWidthPercent: normalButtonSize + (normalButtonSize*.5)
    property real bottomBarPlayButtonHeightPercent: normalButtonSize + (normalButtonSize*.5)

    property real bottomBarNextButtonWidthPercent: normalButtonSize
    property real bottomBarNextButtonHeightPercent: normalButtonSize

    property real bottomBarMuteButtonWidthPercent: normalButtonSize
    property real bottomBarMuteButtonHeightPercent: normalButtonSize

    property real bottomBarShuffleButtonWidthPercent: normalButtonSize *1.125
    property real bottomBarShuffleButtonHeightPercent: normalButtonSize *1.125

    property real bottomBarVolumeSliderWidthPercent: 0.05
    property real bottomBarVolumeSliderHeightPercent: 0.05
    property real bottomBarVolumeTextPercent: 0.05

    property real bottomBarVolumePopupTextBoxHeightPercent: 0.1
    property real bottomBarVolumePopupTextBoxWidthPercent: 0.1

    property real bottomBarVolumePopupTextPercent: 0.3
    property real bottomBarVolumePopupTextMarginPercent: 0.5

    property real bottomBarVolumePopupWidthPercent: 0.05
    property real bottomBarVolumePopupHeightPercent: 0.5


    //Media Room %
    property real mediaRoomMediaPlayerButtonWidthPercent: .1
    property real mediaRoomMediaPlayerButtonHeightPercent: .1

    property real mediaRoomEqualizerButtonWidthPercent: .1
    property real mediaRoomEqualizerButtonHeightPercent: .1

    property real mediaRoomControlsContainerWidth: .9
    property real mediaRoomControlsContainerHeight: .6

    property real mediaRoomMarginPercent: .01

    property real mediaRoomSpacingPercent: .05

    property real mediaRoomBetweenButtonPercent: .04

    property real mediaRoomPreviousButtonHeightPercent: .1
    property real mediaRoomPreviousButtonWidthPercent: .1

    property real mediaRoomPlayButtonHeightPercent: .3
    property real mediaRoomPlayButtonWidthPercent: .3

    property real mediaRoomNextButtonHeightPercent: .1
    property real mediaRoomNextButtonWidthPercent: .1

    property real mediaRoomShuffleButtonHeightPercent: .1
    property real mediaRoomShuffleButtonWidthPercent: .1

    property real mediaRoomMetaSpacingPercent: .01

    property real mediaRoomMetaDataSongTextPercent: .04

    property real mediaRoomMetaDataBandTextPercent: .06

    property real mediaRoomMetaDataAlbumTextPercent: .06

    property real mediaRoomAlbumArtHeightPercent: .5
    property real mediaRoomAlbumArtWidthPercent: .5

    property real mediaRoomDurationBarHeightPercent: .1

    property real mediaRoomProgressSliderHeightPercent: .025
    property real mediaRoomSliderButtonHeightPercent: .05
    property real mediaRoomSliderButtonWidthPercent: .05
    property real mediaRoomSliderButtonRadiusPercent: .025
    property real mediaRoomSliderDurationTextPercent: .05

    // Settings %
    property real settingsNavMarginPercent: .05
    property real settingsContentMarginPercent: .05

    property real settingsDeviceNameWidthPercent: .25
    property real settingsDeviceNameHeightPercent: .05

    property real settingsNavWidthPercent: 0.25
    property real settingsButtonHeightPercent: 0.1
    property real settingsPreviewWidthPercent: 0.5
    property real formElementHeightPercent: 0.1
    property real formLabelWidthPercent: 0.2
    property real formInputWidthPercent: 0.4
    
    // ===== Calculated sizes =====
    // Apply scaling to all calculated values
    function scaledSize(baseSize) {
        return Math.round(baseSize * globalScale)
    }

    // Original calculated sizes with scaling applied
    property int overallMargin: scaledSize(Math.min(applicationWidth, applicationHeight) * overallMarginPercent)
    property int overallText: scaledSize(Math.min(applicationWidth, applicationHeight) * overallTextPercent * textScale)
    property int overallSpacing: scaledSize(Math.min(applicationWidth, applicationHeight) * overallSpacingPercent)

    property int overallSliderWidth: scaledSize(Math.min(applicationWidth, applicationHeight) * overallSliderWidthPercent)
    property int overallSliderHeight: scaledSize(Math.min(applicationWidth, applicationHeight) * overallSliderHeightPercent)
    property int overallSliderRadius: scaledSize(Math.min(applicationWidth, applicationHeight) * overallSliderRadiusPercent)

    // Bottom Bar
    property int bottomBarHeight: scaledSize(applicationHeight * bottomBarHeightPercent)
    property int bottomBarBetweenButtonMargin: scaledSize(Math.min(applicationWidth, applicationHeight) * bottomBarBetweenButtonMarginPercent)

    property int bottomBarPreviousButtonWidth: scaledSize(applicationWidth * bottomBarPreviousButtonWidthPercent)
    property int bottomBarPreviousButtonHeight: scaledSize(applicationHeight * bottomBarPreviousButtonHeightPercent)

    property int bottomBarPlayButtonWidth: scaledSize(applicationWidth * bottomBarPlayButtonWidthPercent)
    property int bottomBarPlayButtonHeight: scaledSize(applicationHeight * bottomBarPlayButtonHeightPercent)

    property int bottomBarNextButtonWidth: scaledSize(applicationWidth * bottomBarNextButtonWidthPercent)
    property int bottomBarNextButtonHeight: scaledSize(applicationHeight * bottomBarNextButtonHeightPercent)

    property int bottomBarMuteButtonWidth: scaledSize(applicationWidth * bottomBarMuteButtonWidthPercent)
    property int bottomBarMuteButtonHeight: scaledSize(applicationHeight * bottomBarMuteButtonHeightPercent)

    property int bottomBarShuffleButtonWidth: scaledSize(applicationWidth * bottomBarShuffleButtonWidthPercent)
    property int bottomBarShuffleButtonHeight: scaledSize(applicationHeight * bottomBarShuffleButtonHeightPercent)

    property int bottomBarVolumeSliderWidth: scaledSize(applicationWidth * bottomBarVolumeSliderWidthPercent)
    property int bottomBarVolumeSliderHeight: scaledSize(applicationHeight * bottomBarVolumeSliderHeightPercent)
    property int bottomBarVolumeText: scaledSize(Math.min(applicationWidth, applicationHeight) * bottomBarVolumeTextPercent)

    property int bottomBarVolumePopupTextBoxHeight: scaledSize(Math.min(applicationWidth, applicationHeight) * bottomBarVolumePopupTextBoxHeightPercent)
    property int bottomBarVolumePopupTextBoxWidth: scaledSize(Math.min(applicationWidth, applicationHeight) * bottomBarVolumePopupTextBoxWidthPercent)
    property int bottomBarVolumePopupText: scaledSize(Math.min(applicationWidth, applicationHeight) * bottomBarVolumePopupTextPercent)
    property int bottomBarVolumePopupTextMargin: scaledSize(Math.min(applicationWidth, applicationHeight) * bottomBarVolumePopupTextMarginPercent)
    property int bottomBarVolumePopupWidth: scaledSize(applicationWidth * bottomBarVolumePopupWidthPercent)
    property int bottomBarVolumePopupHeight: scaledSize(applicationHeight * bottomBarVolumePopupHeightPercent)


    //MediaRoom
    property int mediaRoomMediaPlayerButtonWidth: scaledSize(applicationWidth * mediaRoomMediaPlayerButtonWidthPercent)
    property int mediaRoomMediaPlayerButtonHeight: scaledSize(applicationHeight * mediaRoomMediaPlayerButtonHeightPercent)

    property int mediaRoomEqualizerButtonWidth: scaledSize(applicationWidth * mediaRoomEqualizerButtonWidthPercent)
    property int mediaRoomEqualizerButtonHeight: scaledSize(applicationHeight * mediaRoomEqualizerButtonHeightPercent)

    property int mediaRoomMargin: scaledSize(Math.min(applicationWidth, applicationHeight) * mediaRoomMarginPercent)

    property int mediaRoomSpacing: scaledSize(Math.min(applicationWidth, applicationHeight) * mediaRoomSpacingPercent)

    property int mediaRoomBetweenButton: scaledSize(Math.min(applicationWidth, applicationHeight) * mediaRoomBetweenButtonPercent)

    property int mediaRoomPreviousButtonHeight: scaledSize(applicationHeight * mediaRoomPreviousButtonHeightPercent)
    property int mediaRoomPreviousButtonWidth: scaledSize(applicationWidth * mediaRoomPreviousButtonWidthPercent)

    property int mediaRoomPlayButtonHeight: scaledSize(applicationHeight * mediaRoomPlayButtonHeightPercent)
    property int mediaRoomPlayButtonWidth: scaledSize(applicationWidth * mediaRoomPlayButtonWidthPercent)

    property int mediaRoomNextButtonHeight: scaledSize(applicationHeight * mediaRoomNextButtonHeightPercent)
    property int mediaRoomNextButtonWidth: scaledSize(applicationWidth * mediaRoomNextButtonWidthPercent)

    property int mediaRoomShuffleButtonHeight: scaledSize(applicationHeight * mediaRoomShuffleButtonHeightPercent)
    property int mediaRoomShuffleButtonWidth: scaledSize(applicationWidth * mediaRoomShuffleButtonWidthPercent)

    property int mediaRoomMetaSpacing: scaledSize(Math.min(applicationWidth, applicationHeight) * mediaRoomMetaSpacingPercent)

    property int mediaRoomMetaDataSongText: scaledSize(Math.min(applicationWidth, applicationHeight) * mediaRoomMetaDataSongTextPercent)

    property int mediaRoomMetaDataBandText: scaledSize(Math.min(applicationWidth, applicationHeight) * mediaRoomMetaDataBandTextPercent)

    property int mediaRoomMetaDataAlbumText: scaledSize(Math.min(applicationWidth, applicationHeight) * mediaRoomMetaDataAlbumTextPercent)

    property int mediaRoomAlbumArtHeight: scaledSize(applicationHeight * mediaRoomAlbumArtHeightPercent)
    property int mediaRoomAlbumArtWidth: scaledSize(applicationWidth * mediaRoomAlbumArtWidthPercent)

    property int mediaRoomDurationBarHeight: scaledSize(applicationHeight * mediaRoomDurationBarHeightPercent)

    property int mediaRoomProgressSliderHeight: scaledSize(applicationHeight * mediaRoomProgressSliderHeightPercent)

    property int mediaRoomSliderButtonWidth: scaledSize(Math.min(applicationWidth, applicationHeight) * mediaRoomSliderButtonWidthPercent)
    property int mediaRoomSliderButtonHeight: scaledSize(Math.min(applicationWidth, applicationHeight) * mediaRoomSliderButtonHeightPercent)
    property int mediaRoomSliderButtonRadius: scaledSize(Math.min(applicationWidth, applicationHeight) * mediaRoomSliderButtonRadiusPercent)
    property int mediaRoomSliderDurationText: scaledSize(Math.min(applicationWidth, applicationHeight) * mediaRoomSliderDurationTextPercent)

    // Settings
    property int settingsNavMargin: scaledSize(Math.min(applicationWidth, applicationHeight) * settingsNavMarginPercent)
    property int settingsContentMargin: scaledSize(Math.min(applicationWidth, applicationHeight) * settingsContentMarginPercent)

    property int settingsDeviceNameHeight: scaledSize(applicationHeight * settingsDeviceNameHeightPercent)
    property int settingsDeviceNameWidth: scaledSize(applicationWidth * settingsDeviceNameWidthPercent)
    
    // New calculated values for Settings
    property int settingsNavWidth: scaledSize(applicationWidth * settingsNavWidthPercent)
    property int settingsButtonHeight: scaledSize(applicationHeight * settingsButtonHeightPercent)
    property int settingsPreviewWidth: scaledSize(applicationWidth * settingsPreviewWidthPercent)
    property int formElementHeight: scaledSize(applicationHeight * formElementHeightPercent)
    property int formLabelWidth: scaledSize(applicationWidth * formLabelWidthPercent)
    property int formInputWidth: scaledSize(applicationWidth * formInputWidthPercent)
    
    // Section spacing values for better organization - removed conditional values
    property int sectionSpacing: scaledSize(Math.min(applicationWidth, applicationHeight) * 0.05)
    property int rowSpacing: scaledSize(Math.min(applicationWidth, applicationHeight) * 0.015)
    property int columnSpacing: scaledSize(Math.min(applicationWidth, applicationHeight) * 0.02)
    
    // Enhanced updateDimensions function
    function updateDimensions(width, height) {
        applicationWidth = width
        applicationHeight = height
        // Signal that dimensions have been updated
        dimensionsChanged()
    }
    
    // Signal handler property for notifying dimension changes
    property var dimensionsChanged: function() {}
    
    // Utility function to scale any value based on screen size
    function scalePx(size) {
        return Math.round(size * globalScale * (Math.min(applicationWidth, applicationHeight) / 1000))
    }
}