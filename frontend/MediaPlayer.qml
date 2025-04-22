import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "." as App

Item {
    id: mediaPlayer
    objectName: "mediaPlayer"
    required property StackView stackView
    required property ApplicationWindow mainWindow

    // Core properties
    property var mediaFiles: []
    property string lastPlayedSong: ""
    property real listViewPosition: 0
    property bool isPaused: false
    property int currentFileIndex: 0
    property bool isCalculating: false

    // Sorting properties
    property bool sortByTitleAscending: true
    property bool sortByAlbumAscending: true
    property string currentSortColumn: "title" // Can be "title", "album", or "none"

    // Statistics cache
    property var statsCache: ({
        totalDuration: "",
        albumCount: 0,
        artistCount: 0
    })

    // Sort media files based on current sort column and direction
    function sortMediaFiles() {
        let sortedFiles = [...mediaFiles]
        
        if (currentSortColumn === "title") {
            sortedFiles.sort((a, b) => {
                // Remove special characters and file extension for comparison
                const titleA = a.replace('.mp3', '')
                    .toLowerCase()
                    .replace(/[^\w\s]|_/g, '')
                    .trim()
                const titleB = b.replace('.mp3', '')
                    .toLowerCase()
                    .replace(/[^\w\s]|_/g, '')
                    .trim()
                return sortByTitleAscending ? 
                    titleA.localeCompare(titleB) : 
                    titleB.localeCompare(titleA)
            })
        } else if (currentSortColumn === "album") {
            sortedFiles.sort((a, b) => {
                // Remove special characters from album names for comparison
                const albumA = (mediaManager ? mediaManager.get_album(a) : "")
                    .toLowerCase()
                    .replace(/[^\w\s]|_/g, '')
                    .trim()
                const albumB = (mediaManager ? mediaManager.get_album(b) : "")
                    .toLowerCase()
                    .replace(/[^\w\s]|_/g, '')
                    .trim()
                return sortByAlbumAscending ? 
                    albumA.localeCompare(albumB) : 
                    albumB.localeCompare(albumA)
            })
        }
        
        mediaFiles = sortedFiles
        updateTimer.restart()
    }

    // Calculate total duration of all media files
    function calculateTotalDuration() {
        if (statsCache.totalDuration) return statsCache.totalDuration
        if (!mediaManager || mediaFiles.length === 0) return "0:00:00"
        
        let totalMs = 0
        for (let i = 0; i < mediaFiles.length; i++) {
            let duration = mediaManager.get_formatted_duration(mediaFiles[i])
            if (duration) {
                let parts = duration.split(':')
                let minutes = parseInt(parts[0])
                let seconds = parseInt(parts[1])
                totalMs += (minutes * 60 + seconds) * 1000
            }
        }
        statsCache.totalDuration = formatTotalDuration(totalMs)
        return statsCache.totalDuration
    }

    // Calculate unique albums count
    function calculateUniqueAlbums() {
        if (statsCache.albumCount) return statsCache.albumCount
        if (!mediaManager || mediaFiles.length === 0) return 0
        
        let albums = new Set()
        for (let i = 0; i < mediaFiles.length; i++) {
            let album = mediaManager.get_album(mediaFiles[i])
            if (album && album !== "Unknown Album") albums.add(album)
        }
        statsCache.albumCount = albums.size
        return statsCache.albumCount
    }

    // Calculate unique artists count
    function calculateUniqueArtists() {
        if (statsCache.artistCount) return statsCache.artistCount
        if (!mediaManager || mediaFiles.length === 0) return 0
        
        let artists = new Set()
        for (let i = 0; i < mediaFiles.length; i++) {
            let artist = mediaManager.get_band(mediaFiles[i])
            if (artist && artist !== "Unknown Artist") artists.add(artist)
        }
        statsCache.artistCount = artists.size
        return statsCache.artistCount
    }

    // Update statistics display
    function updateStats() {
        totalDurationText.text = calculateTotalDuration()
        albumCountText.text = calculateUniqueAlbums()
        artistCountText.text = calculateUniqueArtists()
    }

    // Clear statistics cache
    function clearStatsCache() {
        statsCache = {
            totalDuration: "",
            albumCount: 0,
            artistCount: 0
        }
        currentFileIndex = 0
    }

    // Start statistics calculation
    function startStatsCalculation() {
        if (!isCalculating) {
            clearStatsCache()
            isCalculating = true
            currentFileIndex = 0
            statsCalculationTimer.start()
        }
    }

    // Format milliseconds to hours:minutes:seconds
    function formatTotalDuration(ms) {
        let seconds = Math.floor(ms / 1000)
        let minutes = Math.floor(seconds / 60)
        let hours = Math.floor(minutes / 60)
        
        minutes = minutes % 60
        seconds = seconds % 60
        
        return `${hours}:${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`
    }

    // Initialize component
    Component.onCompleted: {
        if (mediaManager) {
            mediaManager.get_media_files()
            var currentFile = mediaManager.get_current_file()
            if (currentFile) {
                lastPlayedSong = currentFile
                isPaused = !mediaManager.is_playing()
            }
            startStatsCalculation()
            updateTimer.restart()
        }
    }

    // Update timer for model changes
    Timer {
        id: updateTimer
        interval: 50
        repeat: false
        onTriggered: {
            listViewPosition = mediaListView.contentY
            mediaListView.model = []
            mediaListView.model = mediaFiles
            mediaListView.contentY = listViewPosition
        }
    }

    // Statistics calculation timer (incremental)
    Timer {
        id: statsCalculationTimer
        interval: 16  // Run every frame (~60fps)
        repeat: true
        property int batchSize: 50  // Process 50 files per batch

        onTriggered: {
            if (!isCalculating || !mediaManager || mediaFiles.length === 0) {
                stop()
                return
            }

            let endIndex = Math.min(currentFileIndex + batchSize, mediaFiles.length)
            
            // Process batch of files
            for (let i = currentFileIndex; i < endIndex; i++) {
                // Calculate duration
                let duration = mediaManager.get_formatted_duration(mediaFiles[i])
                if (duration) {
                    let parts = duration.split(':')
                    let minutes = parseInt(parts[0])
                    let seconds = parseInt(parts[1])
                    statsCache.totalMs = (statsCache.totalMs || 0) + (minutes * 60 + seconds) * 1000
                }

                // Collect unique albums
                let album = mediaManager.get_album(mediaFiles[i])
                if (album && album !== "Unknown Album") {
                    statsCache.albums = statsCache.albums || new Set()
                    statsCache.albums.add(album)
                }

                // Collect unique artists
                let artist = mediaManager.get_band(mediaFiles[i])
                if (artist && artist !== "Unknown Artist") {
                    statsCache.artists = statsCache.artists || new Set()
                    statsCache.artists.add(artist)
                }
            }

            // Update progress
            currentFileIndex = endIndex
            
            // Update UI with current progress
            if (statsCache.totalMs) {
                totalDurationText.text = formatTotalDuration(statsCache.totalMs)
            }
            if (statsCache.albums) {
                albumCountText.text = statsCache.albums.size
            }
            if (statsCache.artists) {
                artistCountText.text = statsCache.artists.size
            }

            // Check if calculation is complete
            if (currentFileIndex >= mediaFiles.length) {
                isCalculating = false
                stop()
            }
        }
    }

    // Main content
    Rectangle {
        anchors.fill: parent
        color: App.Style.backgroundColor

        // Stats bar at the top
        Rectangle {
            id: statsBar
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }
            height: App.Spacing.mediaPlayerStatsBarHeight
            color: App.Style.headerBackgroundColor
            z: 1

            RowLayout {
                anchors {
                    fill: parent
                    leftMargin: App.Spacing.overallMargin * 4
                    rightMargin: App.Spacing.overallMargin * 4
                }
                spacing: App.Spacing.overallMargin * 4

                // Total Songs
                RowLayout {
                    spacing: App.Spacing.overallMargin
                    Text {
                        text: "Songs:"
                        color: App.Style.secondaryTextColor
                        font.pixelSize: App.Spacing.mediaPlayerStatsTextSize
                    }
                    Text {
                        text: mediaFiles.length
                        color: App.Style.secondaryTextColor
                        font.pixelSize: App.Spacing.mediaPlayerStatsTextSize
                        font.bold: true
                    }
                }

                // Number of Albums
                RowLayout {
                    spacing: App.Spacing.overallMargin
                    Text {
                        text: "Albums:"
                        color: App.Style.secondaryTextColor
                        font.pixelSize: App.Spacing.mediaPlayerStatsTextSize
                    }
                    Text {
                        id: albumCountText
                        text: "-"
                        color: App.Style.secondaryTextColor
                        font.pixelSize: App.Spacing.mediaPlayerStatsTextSize
                        font.bold: true
                    }
                }

                // Number of Artists
                RowLayout {
                    spacing: App.Spacing.overallMargin
                    Text {
                        text: "Artists:"
                        color: App.Style.secondaryTextColor
                        font.pixelSize: App.Spacing.mediaPlayerStatsTextSize
                    }
                    Text {
                        id: artistCountText
                        text: "-"
                        color: App.Style.secondaryTextColor
                        font.pixelSize: App.Spacing.mediaPlayerStatsTextSize
                        font.bold: true
                    }
                }

                // Total Duration
                RowLayout {
                    spacing: App.Spacing.overallMargin
                    Text {
                        text: "Total Duration:"
                        color: App.Style.secondaryTextColor
                        font.pixelSize: App.Spacing.mediaPlayerStatsTextSize
                    }
                    Text {
                        id: totalDurationText
                        text: "--:--:--"
                        color: App.Style.secondaryTextColor
                        font.pixelSize: App.Spacing.mediaPlayerStatsTextSize
                        font.bold: true
                    }
                }

                // Spacer
                Item {
                    Layout.fillWidth: true
                }
            }
        }

        // Main content area
        Rectangle {
            id: mainContent
            anchors {
                fill: parent
                margins: App.Spacing.overallMargin
                topMargin: statsBar.height + App.Spacing.overallMargin
            }
            color: App.Style.backgroundColor

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // Table header
                Rectangle {
                    Layout.fillWidth: true
                    height: App.Spacing.mediaPlayerHeaderHeight
                    color: App.Style.headerBackgroundColor

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: App.Spacing.overallMargin * 2
                        anchors.rightMargin: App.Spacing.overallMargin * 2
                        spacing: 0

                        // Index header
                        Text {
                            text: "#"
                            color: App.Style.headerTextColor
                            font.pixelSize: App.Spacing.mediaPlayerTextSize
                            font.bold: true
                            Layout.preferredWidth: parent.width * App.Spacing.mediaPlayerIndexColumnWidthPercent
                        }

                        // Title header with sort functionality
                        Item {
                            Layout.preferredWidth: parent.width * App.Spacing.mediaPlayerTitleColumnWidthPercent
                            Layout.fillHeight: true

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    if (currentSortColumn === "title") {
                                        sortByTitleAscending = !sortByTitleAscending
                                    } else {
                                        currentSortColumn = "title"
                                        sortByTitleAscending = true
                                    }
                                    sortMediaFiles()
                                }
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: "Title " + (currentSortColumn === "title" ? 
                                    (sortByTitleAscending ? "↑" : "↓") : "")
                                color: App.Style.headerTextColor
                                font.pixelSize: App.Spacing.mediaPlayerTextSize
                                font.bold: true
                            }
                        }

                        // Album header with sort functionality
                        Item {
                            Layout.preferredWidth: parent.width * App.Spacing.mediaPlayerAlbumColumnWidthPercent
                            Layout.fillHeight: true

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    if (currentSortColumn === "album") {
                                        sortByAlbumAscending = !sortByAlbumAscending
                                    } else {
                                        currentSortColumn = "album"
                                        sortByAlbumAscending = true
                                    }
                                    sortMediaFiles()
                                }
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: "Album " + (currentSortColumn === "album" ? 
                                    (sortByAlbumAscending ? "↑" : "↓") : "")
                                color: App.Style.headerTextColor
                                font.pixelSize: App.Spacing.mediaPlayerTextSize
                                font.bold: true
                            }
                        }
                    }
                }

                // Media list
                ListView {
                    id: mediaListView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: mediaFiles
                    cacheBuffer: height * 0.5
                    displayMarginBeginning: 40
                    displayMarginEnd: 40
                    reuseItems: true

                    // List item delegate
                    delegate: ItemDelegate {
                        id: delegate
                        width: ListView.view.width
                        height: App.Spacing.mediaPlayerRowHeight
                        visible: y >= mediaListView.contentY - height && 
                                y <= mediaListView.contentY + mediaListView.height

                        Rectangle {
                            anchors.fill: parent
                            color: {
                                if (lastPlayedSong === modelData && mediaManager) {
                                    return mediaManager.get_current_file() === modelData ?
                                        (mediaManager.is_playing() ? 
                                            App.Style.playingHighlightColor : 
                                            App.Style.pausedHighlightColor) :
                                        App.Style.rowBackgroundColor
                                }
                                return App.Style.rowBackgroundColor
                            }
                            Behavior on color { ColorAnimation { duration: 150 } }

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: App.Spacing.overallMargin * 2
                                spacing: 0

                                // Index column
                                Text {
                                    Layout.preferredWidth: parent.width * App.Spacing.mediaPlayerIndexColumnWidthPercent
                                    text: (index + 1).toString()
                                    color: App.Style.secondaryTextColor
                                    font.pixelSize: App.Spacing.mediaPlayerSecondaryTextSize
                                    horizontalAlignment: Text.AlignLeft
                                }

                                // Album art
                                LazyImage {
                                    Layout.preferredWidth: App.Spacing.mediaPlayerAlbumArtSize
                                    Layout.preferredHeight: App.Spacing.mediaPlayerAlbumArtSize
                                    fidelity: 120
                                    smoothing: true
                                    mipmap: true
                                    antialiasing: true
                                    quality: 0.7
                                    source: visible ? 
                                        (mediaManager ? 
                                            mediaManager.get_album_art(modelData) || 
                                            "./assets/missing_art.jpg" : 
                                            "./assets/missing_art.jpg") : 
                                        ""
                                }

                                // Title and artist info
                                ColumnLayout {
                                    Layout.preferredWidth: parent.width * 
                                        App.Spacing.mediaPlayerTitleColumnWidthPercent - 
                                        (App.Spacing.mediaPlayerAlbumArtSize + App.Spacing.overallMargin * 2)
                                    Layout.leftMargin: App.Spacing.overallMargin * 2
                                    spacing: App.Spacing.overallMargin

                                    // Song title
                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData.replace('.mp3', '')
                                        color: lastPlayedSong === modelData ? 
                                            App.Style.accent : 
                                            App.Style.primaryTextColor
                                        font.pixelSize: App.Spacing.mediaPlayerTextSize
                                        font.bold: true
                                        elide: Text.ElideRight
                                    }

                                    // Artist and duration
                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: App.Spacing.overallMargin * 2

                                        // Artist name
                                        Text {
                                            text: mediaManager ? 
                                                mediaManager.get_band(modelData) : 
                                                "Unknown Artist"
                                            color: App.Style.secondaryTextColor
                                            font.pixelSize: App.Spacing.mediaPlayerSecondaryTextSize
                                            elide: Text.ElideRight
                                        }

                                        // Separator
                                        Text {
                                            text: "•"
                                            color: App.Style.secondaryTextColor
                                            font.pixelSize: App.Spacing.mediaPlayerSecondaryTextSize
                                        }

                                        // Duration
                                        Text {
                                            text: mediaManager ? 
                                                mediaManager.get_formatted_duration(modelData) : 
                                                "0:00"
                                            color: App.Style.secondaryTextColor
                                            font.pixelSize: App.Spacing.mediaPlayerSecondaryTextSize
                                            elide: Text.ElideRight
                                        }
                                    }
                                }

                                // Album column
                                Text {
                                    Layout.preferredWidth: parent.width * App.Spacing.mediaPlayerAlbumColumnWidthPercent
                                    text: mediaManager ? 
                                        mediaManager.get_album(modelData) : 
                                        "Unknown Album"
                                    color: App.Style.secondaryTextColor
                                    font.pixelSize: App.Spacing.mediaPlayerSecondaryTextSize
                                    Layout.leftMargin: App.Spacing.overallMargin * 2
                                    horizontalAlignment: Text.AlignLeft
                                    elide: Text.ElideRight
                                }
                            }

                            // Click behavior for list items
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: false
                                onClicked: {
                                    if (mediaManager) {
                                        mediaManager.play_file(modelData)
                                        lastPlayedSong = modelData
                                        stackView.push("MediaRoom.qml", {
                                            stackView: mediaPlayer.stackView
                                        })
                                    }
                                }
                                onEntered: parent.color = lastPlayedSong === modelData && 
                                    mediaManager ? 
                                    (mediaManager.is_playing() ? 
                                        App.Style.hoverPlayingColor : 
                                        App.Style.hoverPausedColor) : 
                                    App.Style.hoverColor
                                onExited: parent.color = lastPlayedSong === modelData && 
                                    mediaManager ? 
                                    (mediaManager.is_playing() ? 
                                        App.Style.playingHighlightColor : 
                                        App.Style.pausedHighlightColor) : 
                                    App.Style.rowBackgroundColor
                            }
                        }
                    }

                    // Scrollbar
                    ScrollBar.vertical: ScrollBar {
                        active: true
                    }
                }
            }

            // Empty state message
            Text {
                anchors.centerIn: parent
                text: "No songs found in media folder"
                color: App.Style.primaryTextColor
                font.pixelSize: App.Spacing.mediaPlayerTextSize
                visible: mediaListView.count === 0
            }
        }
    }

    // Connect to mediaManager signals
    Connections {
        target: mediaManager
        
        // Media list updated
        function onMediaListChanged(files) {
            mediaFiles = files
            if (currentSortColumn !== "none") {
                sortMediaFiles()
            } else {
                updateTimer.restart()
            }
            startStatsCalculation()
        }
        
        // Duration format updated
        function onDurationFormatChanged(duration) {
            // Placeholder for any future functionality
        }
        
        // Current media changed
        function onCurrentMediaChanged(filename) {
            lastPlayedSong = filename
            updateTimer.restart()
        }
        
        // Play state changed
        function onPlayStateChanged(isPlaying) {
            isPaused = !isPlaying
            if (mediaManager) {
                var currentFile = mediaManager.get_current_file()
                if (currentFile) {
                    lastPlayedSong = currentFile
                }
            }
            updateTimer.restart()
        }
    }
}