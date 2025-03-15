import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "." as App

Item {
    id: mediaPlayer
    objectName: "mediaPlayer"
    required property StackView stackView
    required property ApplicationWindow mainWindow

    property var mediaFiles: []
    property string lastPlayedSong: ""
    property real indexColumnWidth: 0.05
    property real titleColumnWidth: 0.60
    property real albumColumnWidth: 0.35
    property real listViewPosition: 0
    property bool isPaused: false

    property bool sortByTitleAscending: true
    property bool sortByAlbumAscending: true
    property string currentSortColumn: "title" // Can be "title", "album", or "none"

    property int currentFileIndex: 0
    property bool isCalculating: false


    property var statsCache: ({
        totalDuration: "",
        albumCount: 0,
        artistCount: 0
    })

    function sortMediaFiles() {
        let sortedFiles = [...mediaFiles]
        
        if (currentSortColumn === "title") {
            sortedFiles.sort((a, b) => {
                const titleA = a.replace('.mp3', '').toLowerCase()
                const titleB = b.replace('.mp3', '').toLowerCase()
                return sortByTitleAscending ? 
                    titleA.localeCompare(titleB) : 
                    titleB.localeCompare(titleA)
            })
        } else if (currentSortColumn === "album") {
            sortedFiles.sort((a, b) => {
                const albumA = (mediaManager ? mediaManager.get_album(a) : "").toLowerCase()
                const albumB = (mediaManager ? mediaManager.get_album(b) : "").toLowerCase()
                return sortByAlbumAscending ? 
                    albumA.localeCompare(albumB) : 
                    albumB.localeCompare(albumA)
            })
        }
        
        mediaFiles = sortedFiles
        updateTimer.restart()
    }
    // Stats calculation functions
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

    function updateStats() {
        totalDurationText.text = calculateTotalDuration()
        albumCountText.text = calculateUniqueAlbums()
        artistCountText.text = calculateUniqueArtists()
    }

    function clearStatsCache() {
        statsCache = {
            totalMs: 0,
            albums: new Set(),
            artists: new Set()
        }
        currentFileIndex = 0
    }

    function startStatsCalculation() {
        if (!isCalculating) {
            clearStatsCache()
            isCalculating = true
            currentFileIndex = 0
            statsCalculationTimer.start()
        }
    }

    function formatTotalDuration(ms) {
        let seconds = Math.floor(ms / 1000)
        let minutes = Math.floor(seconds / 60)
        let hours = Math.floor(minutes / 60)
        
        minutes = minutes % 60
        seconds = seconds % 60
        
        return `${hours}:${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`
    }


        

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

    Timer {
        id: statsCalculationTimer
        interval: 16  // Run every frame (~60fps)
        repeat: true  // Make it repeat
        property int batchSize: 50  // Process 50 files per batch

        onTriggered: {
            if (!isCalculating || !mediaManager || mediaFiles.length === 0) {
                stop()
                return
            }

            let endIndex = Math.min(currentFileIndex + batchSize, mediaFiles.length)
            
            // Process duration
            for (let i = currentFileIndex; i < endIndex; i++) {
                let duration = mediaManager.get_formatted_duration(mediaFiles[i])
                if (duration) {
                    let parts = duration.split(':')
                    let minutes = parseInt(parts[0])
                    let seconds = parseInt(parts[1])
                    statsCache.totalMs = (statsCache.totalMs || 0) + (minutes * 60 + seconds) * 1000
                }

                let album = mediaManager.get_album(mediaFiles[i])
                if (album && album !== "Unknown Album") {
                    statsCache.albums = statsCache.albums || new Set()
                    statsCache.albums.add(album)
                }

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

            // Check if we're done
            if (currentFileIndex >= mediaFiles.length) {
                isCalculating = false
                stop()
            }
        }
    }




    Rectangle {
        anchors.fill: parent
        color: App.Style.backgroundColor

        Rectangle {
            id: mainContent
            anchors {
                fill: parent
                margins: 5
                topMargin: statsBar.height + 5
            }
            color: App.Style.backgroundColor

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // Header Rectangle
                Rectangle {
                    Layout.fillWidth: true
                    height: 50
                    color: App.Style.headerBackgroundColor

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 0

                        // Index Header
                        Text {
                            text: "#"
                            color: App.Style.headerTextColor
                            font.pixelSize: 14
                            font.bold: true
                            Layout.preferredWidth: parent.width * indexColumnWidth
                        }

                        // Title Header
                        Item {
                            Layout.preferredWidth: parent.width * titleColumnWidth
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
                                font.pixelSize: 14
                                font.bold: true
                            }
                        }

                        // Album Header
                        Item {
                            Layout.preferredWidth: parent.width * albumColumnWidth
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
                                font.pixelSize: 14
                                font.bold: true
                            }
                        }
                    }
                }

                // Media List View
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

                    delegate: ItemDelegate {
                        id: delegate
                        width: ListView.view.width
                        height: 80
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
                                anchors.margins: 10
                                spacing: 0

                                // Index Column
                                Text {
                                    Layout.preferredWidth: parent.width * indexColumnWidth
                                    text: (index + 1).toString()
                                    color: App.Style.secondaryTextColor
                                    font.pixelSize: 13
                                    horizontalAlignment: Text.AlignLeft
                                }

                                // Album Art
                                LazyImage {
                                    Layout.preferredWidth: 60
                                    Layout.preferredHeight: 60
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

                                // Title and Artist Info
                                ColumnLayout {
                                    Layout.preferredWidth: parent.width * titleColumnWidth - 70
                                    Layout.leftMargin: 10
                                    spacing: 4

                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData.replace('.mp3', '')
                                        color: lastPlayedSong === modelData ? 
                                            App.Style.accent : 
                                            App.Style.primaryTextColor
                                        font.pixelSize: 14
                                        font.bold: true
                                        elide: Text.ElideRight
                                    }

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 10

                                        Text {
                                            text: mediaManager ? 
                                                mediaManager.get_band(modelData) : 
                                                "Unknown Artist"
                                            color: App.Style.secondaryTextColor
                                            font.pixelSize: 12
                                            elide: Text.ElideRight
                                        }

                                        Text {
                                            text: "•"
                                            color: App.Style.secondaryTextColor
                                            font.pixelSize: 12
                                        }

                                        Text {
                                            text: mediaManager ? 
                                                mediaManager.get_formatted_duration(modelData) : 
                                                "0:00"
                                            color: App.Style.secondaryTextColor
                                            font.pixelSize: 12
                                            elide: Text.ElideRight
                                        }
                                    }
                                }

                                // Album Column
                                Text {
                                    Layout.preferredWidth: parent.width * albumColumnWidth
                                    text: mediaManager ? 
                                        mediaManager.get_album(modelData) : 
                                        "Unknown Album"
                                    color: App.Style.secondaryTextColor
                                    font.pixelSize: 13
                                    Layout.leftMargin: 10
                                    horizontalAlignment: Text.AlignLeft
                                    elide: Text.ElideRight
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
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

                    ScrollBar.vertical: ScrollBar {
                        active: true
                    }
                }
            }

            // Empty State Message
            Text {
                anchors.centerIn: parent
                text: "No songs found in media folder"
                color: App.Style.primaryTextColor
                font.pixelSize: 16
                visible: mediaListView.count === 0
            }
        }
        // Stats Bar
        Rectangle {
            id: statsBar
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }
            height: 25
            color: App.Style.headerBackgroundColor
            z: 1

            RowLayout {
                anchors {
                    fill: parent
                    leftMargin: 20
                    rightMargin: 20
                }
                spacing: 20

                // Total Songs
                RowLayout {
                    spacing: 5
                    Text {
                        text: "Songs:"
                        color: App.Style.secondaryTextColor
                        font.pixelSize: 12
                    }
                    Text {
                        text: mediaFiles.length
                        color: App.Style.secondaryTextColor
                        font.pixelSize: 12
                        font.bold: true
                    }
                }

                // Number of Albums
                RowLayout {
                    spacing: 5
                    Text {
                        text: "Albums:"
                        color: App.Style.secondaryTextColor
                        font.pixelSize: 12
                    }
                    Text {
                        id: albumCountText
                        text: "-"
                        color: App.Style.secondaryTextColor
                        font.pixelSize: 12
                        font.bold: true
                    }
                }

                // Number of Artists
                RowLayout {
                    spacing: 5
                    Text {
                        text: "Artists:"
                        color: App.Style.secondaryTextColor
                        font.pixelSize: 12
                    }
                    Text {
                        id: artistCountText
                        text: "-"
                        color: App.Style.secondaryTextColor
                        font.pixelSize: 12
                        font.bold: true
                    }
                }
                // Total Duration
                RowLayout {
                    spacing: 5
                    Text {
                        text: "Total Duration:"
                        color: App.Style.secondaryTextColor
                        font.pixelSize: 12
                    }
                    Text {
                        id: totalDurationText
                        text: "--:--:--"
                        color: App.Style.secondaryTextColor
                        font.pixelSize: 12
                        font.bold: true
                    }
                }
                // Spacer
                Item {
                    Layout.fillWidth: true
                }
            }
        }
    }

    Connections {
        target: mediaManager
        function onMediaListChanged(files) {
            mediaFiles = files
            if (currentSortColumn !== "none") {
                sortMediaFiles()
            } else {
                updateTimer.restart()
            }
            startStatsCalculation()
        }
        
        function onDurationFormatChanged(duration) {    
        }
        
        function onCurrentMediaChanged(filename) {
            lastPlayedSong = filename
            updateTimer.restart()
        }
        
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