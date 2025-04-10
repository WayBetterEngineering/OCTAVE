from PySide6.QtCore import QObject, Signal, Slot, Property, QTimer
from PySide6.QtMultimedia import QMediaPlayer, QAudioOutput
from PySide6.QtCore import QUrl
from mutagen.mp3 import MP3
from mutagen.id3 import ID3, TIT2, TPE1, TALB
import os
import random

# Check if audio processing libraries are available
try:
    import numpy as np
    import sounddevice as sd
    import scipy.signal as signal
    AUDIO_PROCESSING_AVAILABLE = True
except ImportError:
    AUDIO_PROCESSING_AVAILABLE = False
    print("Warning: numpy, scipy, or sounddevice not available. Equalizer will be visual-only.")


class MediaManager(QObject):
    playbackStateChanged = Signal(int)
    playStateChanged = Signal(bool)
    currentMediaChanged = Signal(str)
    mediaListChanged = Signal(list)
    muteChanged = Signal(bool)
    durationChanged = Signal(int)
    positionChanged = Signal(int)
    metadataChanged = Signal(str, str, str)
    durationFormatChanged = Signal(str)
    volumeChanged = Signal(float)
    shuffleStateChanged = Signal(bool)
    
    def __init__(self):
        super().__init__()
        self._player = QMediaPlayer()
        self._audio_output = QAudioOutput()
        self._player.setAudioOutput(self._audio_output)
        
        # Set default volume
        self._audio_output.setVolume(0.5)
        
        # Set up media directory
        self.backend_dir = os.path.dirname(os.path.abspath(__file__))
        self.default_media_dir = os.path.join(self.backend_dir, 'media')
        self.media_dir = self.default_media_dir
        self.temp_dir = os.path.join(self.backend_dir, 'temp')
        
        # Media player configuration
        self._player.setProperty("probe-size", 10000000)  # 10MB
        self._player.setProperty("analyzeduration", 5000000)  # 5 seconds
        
        # Playback state
        self._current_index = 0
        self._is_muted = False
        self._previous_volume = 0.5
        self._is_playing = False
        self._is_paused = True
        self._shuffle = False
        self._auto_play = False  # Set to False to prevent auto-play
        
        # Playlist management
        self._original_files = []
        self._current_playlist = []
        
        # Caching
        self._album_art_cache = {}  # Album ID to filename mapping
        self._metadata_cache = {}  # Filename to metadata mapping
        self._max_cache_files = 500  # Maximum number of cached files
        self._metadata_cache_max = 1000  # Maximum metadata cache entries
        self._access_count = {}  # Track album art access for LRU caching
        
        # Connect signals
        self._player.durationChanged.connect(self.durationChanged.emit)
        self._player.positionChanged.connect(self.positionChanged.emit)
        self._player.mediaStatusChanged.connect(self._handle_media_status)
        
        # Initialize position timer
        self._position_timer = QTimer()
        self._position_timer.setInterval(100)  # Update every 100ms
        self._position_timer.timeout.connect(self._update_position)
        self._position_timer.start()
        
        # Set up equalizer support
        self._setup_equalizer_support()
        
        # Create media and temp directories if they don't exist
        self._ensure_directories()
        
        # Clear temp files on startup
        self._clear_temp_files()
        
        self._settings_manager = None

    def __del__(self):
        """Clean up resources on destruction"""
        try:
            self._clear_temp_files()
            if self._player:
                self._player.stop()
            if self._position_timer:
                self._position_timer.stop()
            
            # Clean up audio processor if active
            if hasattr(self, '_audio_processor') and self._audio_processor:
                self._audio_processor.stop()
        except:
            pass  # Avoid errors during shutdown
    
    def _setup_equalizer_support(self):
        """Set up support for equalizer integration"""
        try:
            # Add a placeholder for equalizer manager
            self._equalizer_manager = None
            
            # Flag to indicate if equalizer is active
            self._equalizer_active = False
            
            # Audio processor for real-time processing
            self._audio_processor = None
            
            print("Equalizer support prepared in MediaManager")
        except Exception as e:
            print(f"Error setting up equalizer support: {e}")
    
    def connect_equalizer(self, equalizer_manager):
        """Connect an equalizer manager to this media manager"""
        try:
            self._equalizer_manager = equalizer_manager
            self._equalizer_active = True
            
            # If audio processing is available, initialize the audio processor
            if AUDIO_PROCESSING_AVAILABLE and hasattr(equalizer_manager, '_audio_processor'):
                self._audio_processor = equalizer_manager._audio_processor
                
                # Connect to playback state changes to control audio processor
                self.playStateChanged.connect(self._handle_playback_state_for_equalizer)
                
                print("Connected equalizer with audio processing capabilities")
            else:
                print("Connected equalizer (visual only)")
        except Exception as e:
            print(f"Error connecting equalizer: {e}")
    
    def _handle_playback_state_for_equalizer(self, is_playing):
        """Handle playback state changes for equalizer"""
        if not hasattr(self, '_audio_processor') or not self._audio_processor:
            return
            
        try:
            if is_playing:
                # Start audio processor when playback starts
                self._audio_processor.start()
            else:
                # Stop audio processor when playback stops
                self._audio_processor.stop()
        except Exception as e:
            print(f"Error handling playback state for equalizer: {e}")
    
    def _ensure_directories(self):
        """Ensure required directories exist"""
        try:
            if not os.path.exists(self.media_dir):
                os.makedirs(self.media_dir)
                print(f"Created media directory at: {self.media_dir}")
            
            if not os.path.exists(self.temp_dir):
                os.makedirs(self.temp_dir)
                print(f"Created temp directory at: {self.temp_dir}")
        except Exception as e:
            print(f"Error creating directories: {e}")
            
    def _update_position(self):
        """Update position for UI slider"""
        if self._player.playbackState() == QMediaPlayer.PlayingState:
            self.positionChanged.emit(self._player.position())
            
    def _handle_media_status(self, status):
        """Handle media status changes"""
        try:
            if status == QMediaPlayer.MediaStatus.EndOfMedia:
                print("Song ended, playing next track")
                self.next_track()
        except Exception as e:
            print(f"Media status handling error: {e}")

    def _cache_metadata(self, filename):
        """Cache metadata for a file to reduce disk operations"""
        if filename in self._metadata_cache:
            return
            
        try:
            file_path = os.path.join(self.media_dir, filename)
            
            # Manage cache size
            if len(self._metadata_cache) >= self._metadata_cache_max:
                # Remove oldest entry
                self._metadata_cache.pop(next(iter(self._metadata_cache)))
                
            # Read metadata once
            audio = ID3(file_path)
            mp3 = MP3(file_path)
            
            # Store all required metadata at once
            self._metadata_cache[filename] = {
                "artist": self._extract_id3_text(audio.get('TPE1'), "Unknown Artist"),
                "album": self._extract_id3_text(audio.get('TALB'), "Unknown Album"),
                "title": self._extract_id3_text(audio.get('TIT2'), filename.replace('.mp3', '')),
                "duration": int(mp3.info.length)
            }
        except Exception as e:
            print(f"Metadata caching error for {filename}: {e}")
            # Set fallback values
            self._metadata_cache[filename] = {
                "artist": "Unknown Artist",
                "album": "Unknown Album",
                "title": filename.replace('.mp3', ''),
                "duration": 0
            }
    
    def _extract_id3_text(self, tag, default=""):
        """Helper to safely extract text from ID3 tags"""
        if tag is None:
            return default
        if isinstance(tag, str):
            return tag
        if hasattr(tag, 'text') and tag.text:
            return tag.text[0]
        return str(tag) if tag else default

    def _emit_metadata(self, filename):
        """Emit metadata change signals"""
        if filename not in self._metadata_cache:
            self._cache_metadata(filename)
            
        meta = self._metadata_cache[filename]
        self.metadataChanged.emit(
            meta.get("title", filename.replace('.mp3', '')),
            meta.get("artist", "Unknown Artist"),
            meta.get("album", "Unknown Album")
        )
        
    def _get_album_id(self, filename):
        """Create a unique ID for album art caching"""
        try:
            if filename not in self._metadata_cache:
                self._cache_metadata(filename)
                
            meta = self._metadata_cache[filename]
            # Create unique ID from album and artist
            return f"{meta['album']}_{meta['artist']}"
        except Exception as e:
            print(f"Error getting album ID: {e}")
            return str(hash(filename))
        
    def _manage_cache(self, new_album_id):
        """More efficient cache management using LRU approach"""
        try:
            if len(self._album_art_cache) >= self._max_cache_files:
                # Find least recently accessed item, excluding the new one
                items = [(k, v) for k, v in self._access_count.items() if k != new_album_id]
                if not items:
                    return
                    
                # Find least used album art
                least_used = min(items, key=lambda x: x[1])[0]
                
                # Remove it from cache
                if least_used in self._album_art_cache:
                    file_path = self._album_art_cache[least_used].replace('file:///', '')
                    try:
                        if os.path.exists(file_path):
                            os.remove(file_path)
                    except Exception as e:
                        print(f"Warning: Could not remove file {file_path}: {e}")
                    finally:
                        del self._album_art_cache[least_used]
                        del self._access_count[least_used]
                        
                print(f"Cache managed. New size: {len(self._album_art_cache)}")
        except Exception as e:
            print(f"Cache management error: {e}")
            
    @Slot()
    def _clear_temp_files(self):
        """Improved temp file management with error handling"""
        if os.path.exists(self.temp_dir):
            for file in os.listdir(self.temp_dir):
                try:
                    file_path = os.path.join(self.temp_dir, file)
                    if os.path.isfile(file_path):
                        os.remove(file_path)
                except Exception as e:
                    print(f"Error removing temp file {file}: {e}")
                    
        # Make sure directory exists
        try:
            if not os.path.exists(self.temp_dir):
                os.makedirs(self.temp_dir)
        except Exception as e:
            print(f"Error creating temp directory: {e}")
                
    def _shuffle_playlist(self):
        """Helper method to create shuffled playlist"""
        files = self.get_media_files()
        if not files:
            return []
            
        shuffled = files.copy()
        random.shuffle(shuffled)
        return shuffled
                
    @Slot()
    def get_media_files(self):
        """Get list of available MP3 files"""
        mp3_files = []
        try:
            if os.path.exists(self.media_dir):
                for file in os.listdir(self.media_dir):
                    if file.lower().endswith('.mp3'):
                        mp3_files.append(file)
                        
                self.mediaListChanged.emit(mp3_files)
        except Exception as e:
            print(f"Error getting media files: {e}")
            
        return mp3_files
    
    @Slot(str, result=str)
    def get_formatted_duration(self, filename):
        """Get formatted duration string (MM:SS)"""
        try:
            if filename not in self._metadata_cache:
                self._cache_metadata(filename)
                
            duration_seconds = self._metadata_cache[filename]["duration"]
            minutes = duration_seconds // 60
            seconds = duration_seconds % 60
            formatted = f"{minutes}:{seconds:02d}"
            self.durationFormatChanged.emit(formatted)
            return formatted
        except Exception as e:
            print(f"Error getting duration: {e}")
            return "0:00"
    

    @Slot(str, result=str)
    def get_band(self, filename):
        """Get artist name from metadata"""
        if filename not in self._metadata_cache:
            self._cache_metadata(filename)
        return self._metadata_cache[filename]["artist"]

    @Slot(str, result=str)
    def get_album(self, filename):
        """Get album name from metadata"""
        if filename not in self._metadata_cache:
            self._cache_metadata(filename)
        return self._metadata_cache[filename]["album"]

    @Slot(str, result=str)
    def get_album_art(self, filename):
        """Extract and cache album art"""
        try:
            album_id = self._get_album_id(filename)
            
            # Update access count for LRU cache
            self._access_count[album_id] = self._access_count.get(album_id, 0) + 1

            # Return if already cached
            if album_id in self._album_art_cache:
                return self._album_art_cache[album_id]
            
            # Manage cache BEFORE adding new entry
            self._manage_cache(album_id)

            # Extract and cache new album art
            file_path = os.path.join(self.media_dir, filename)
            audio = ID3(file_path)
            
            for tag in audio.values():
                if tag.FrameID == 'APIC':
                    # Create a unique name for this album art
                    temp_path = os.path.join(self.temp_dir, f'cover_{hash(album_id)}.jpg')
                    
                    # Write the image data
                    with open(temp_path, 'wb') as img_file:
                        img_file.write(tag.data)
                    
                    # Convert to URL and cache
                    url = QUrl.fromLocalFile(temp_path).toString()
                    self._album_art_cache[album_id] = url
                    return url

            return ""
        except Exception as e:
            print(f"Error getting album art: {e}")
            return ""
            
    @Slot(result=str)
    def get_current_file(self):
        """Get currently playing file without auto-playing"""
        # Initialize playlist if empty
        if not self._current_playlist:
            files = self.get_media_files()
            if files:
                self._current_playlist = sorted(files)
                self._current_index = 0
                # Return the first file but don't play it
                return files[0]
                
        # Return current file if index is valid
        if 0 <= self._current_index < len(self._current_playlist):
            return self._current_playlist[self._current_index]
        
        # Fallback to first file if index is invalid
        files = sorted(self.get_media_files())
        if files:
            self._current_playlist = files
            self._current_index = 0
            return files[0]
            
        return ""
            
    @Slot(str)
    def play_file(self, filename):
        """Play specified file"""
        # Initialize current_playlist if needed
        if not self._current_playlist:
            try:
                self._current_playlist = self._shuffle_playlist() if self._shuffle else sorted(self.get_media_files())
            except Exception as e:
                print(f"Error initializing playlist: {e}")
                self._current_playlist = []
                
        # Only proceed if we have files
        if not self._current_playlist:
            print("No media files available to play")
            return

        # Try to find the file in the playlist
        try:
            if filename in self._current_playlist:
                self._current_index = self._current_playlist.index(filename)
            elif not self._shuffle:
                # If not found and not shuffled, rebuild alphabetical playlist
                self._current_playlist = sorted(self.get_media_files())
                if filename in self._current_playlist:
                    self._current_index = self._current_playlist.index(filename)
                else:
                    # File not found in any playlist, use the first file
                    filename = self._current_playlist[0] if self._current_playlist else ""
                    self._current_index = 0
        except Exception as e:
            print(f"Error finding file in playlist: {e}")
            # Fallback to first file
            self._current_index = 0
            if self._current_playlist:
                filename = self._current_playlist[0]
            else:
                return
        
        # Play the file
        file_path = os.path.join(self.media_dir, filename)
        if os.path.exists(file_path):
            try:
                url = QUrl.fromLocalFile(file_path)
                self._player.setSource(url)
                self._player.play()
                self._is_playing = True
                self._is_paused = False
                self.playStateChanged.emit(True)
                self.currentMediaChanged.emit(filename)  
                self._emit_metadata(filename)
                self.get_formatted_duration(filename)
                print(f"Now playing: {filename} from {'shuffled' if self._shuffle else 'alphabetical'} playlist at position {self._current_index}")
                
                # Start audio processor if available and connected
                if self._equalizer_active and hasattr(self, '_audio_processor') and self._audio_processor:
                    self._audio_processor.start()
                    
            except Exception as e:
                print(f"Playback error: {e}")
        else:
            print(f"File not found: {file_path}")
        

    @Slot()
    def next_track(self):
        """Play next track in playlist"""
        try:
            if not self._current_playlist:
                self._current_playlist = self.get_media_files()
                
            if not self._current_playlist:
                print("No media files available")
                return
                
            self._current_index = (self._current_index + 1) % len(self._current_playlist)
            next_song = self._current_playlist[self._current_index]
            self.play_file(next_song)
        except Exception as e:
            print(f"Error in next_track: {e}")

    @Slot()
    def previous_track(self):
        """Play previous track in playlist"""
        try:
            if not self._current_playlist:
                self._current_playlist = self.get_media_files()
                
            if not self._current_playlist:
                print("No media files available")
                return
                
            self._current_index = (self._current_index - 1) % len(self._current_playlist)
            prev_song = self._current_playlist[self._current_index]
            self.play_file(prev_song)
        except Exception as e:
            print(f"Error in previous_track: {e}")
        
    @Slot()
    def pause(self):
        """Pause playback"""
        self._player.pause()
        self._is_paused = True
        self._is_playing = False
        self.playStateChanged.emit(False)
        
        # Stop audio processor if available
        if self._equalizer_active and hasattr(self, '_audio_processor') and self._audio_processor:
            self._audio_processor.stop()
        
    @Slot()
    def toggle_play(self):
        """Toggle between play and pause"""
        # Handle case when no source is set
        if not self._player.source().isValid():
            files = self.get_media_files()
            if files:
                self._current_index = 0
                self.play_file(files[0])
                return
                
        # Toggle play/pause state
        if self._is_playing:
            self._player.pause()
            self._is_paused = True
            self._is_playing = False
            
            # Stop audio processor if available
            if self._equalizer_active and hasattr(self, '_audio_processor') and self._audio_processor:
                self._audio_processor.stop()
        else:
            self._player.play()
            self._is_paused = False
            self._is_playing = True
            
            # Start audio processor if available
            if self._equalizer_active and hasattr(self, '_audio_processor') and self._audio_processor:
                self._audio_processor.start()
            
        self.playStateChanged.emit(self._is_playing)
            
    @Slot(result=bool)
    def is_playing(self):
        """Return current playing state"""
        return self._is_playing
    
    @Slot(result=bool)
    def is_paused(self):
        """Return current paused state"""
        return self._is_paused
    
    @Slot(result=float)
    def get_duration(self):
        """Get current media duration in ms"""
        return self._player.duration()

    @Slot(result=float)
    def get_position(self):
        """Get current playback position in ms"""
        return self._player.position()

    @Slot(int)
    def set_position(self, position):
        """Set playback position in ms"""
        self._player.setPosition(position)

    @Slot()
    def toggle_mute(self):
        """Toggle mute state"""
        if self._is_muted:
            self._audio_output.setVolume(self._previous_volume)
        else:
            self._previous_volume = self._audio_output.volume()
            self._audio_output.setVolume(0.0)
            
        self._is_muted = not self._is_muted
        self.muteChanged.emit(self._is_muted)
        print(f"Mute toggled: {self._is_muted}")
    
    @Slot(result=bool)
    def is_muted(self):
        """Return current mute state"""
        return self._is_muted
            
    @Slot(float)
    def setVolume(self, volume):
        """Set output volume (0.0-1.0)"""
        try:
            volume = float(volume)
            # Clamp volume to valid range
            volume = max(0.0, min(1.0, volume))
            
            #print(f"Volume set to: {volume}")
            self._audio_output.setVolume(volume)
            self.volumeChanged.emit(volume)
            
            # If volume is being set and we were muted, unmute
            if self._is_muted and volume > 0:
                self._is_muted = False
                self.muteChanged.emit(False)
        except Exception as e:
            print(f"Error setting volume: {e}")
            
    @Slot(result=float)
    def getVolume(self):
        """Get current volume level (0.0-1.0)"""
        return self._audio_output.volume()
    
    @Slot()
    def toggle_shuffle(self):
        """Toggle shuffle mode"""
        self._shuffle = not self._shuffle
        self.shuffleStateChanged.emit(self._shuffle)
        
        # Get current song before changing playlists
        current_song = self.get_current_file()
        files = self.get_media_files()
        
        if self._shuffle:
            # Store original order if needed
            if not self._original_files:
                self._original_files = files.copy()
            
            # Create shuffled playlist
            shuffled = files.copy()
            random.shuffle(shuffled)
            
            # Move current song to start of shuffled list if it exists
            if current_song in shuffled:
                idx = shuffled.index(current_song)
                if idx > 0:  # Only swap if not already at position 0
                    shuffled[0], shuffled[idx] = shuffled[idx], shuffled[0]
                
            self._current_playlist = shuffled
            self._current_index = 0
            print(f"Shuffle enabled, starting from: {current_song}")
        else:
            # Get alphabetical list
            alphabetical = sorted(files)
            
            # Find current song in alphabetical order
            if current_song and current_song in alphabetical:
                self._current_index = alphabetical.index(current_song)
                self._current_playlist = alphabetical
                print(f"Shuffle disabled. Continuing alphabetically from: {current_song}")
            else:
                self._current_playlist = alphabetical
                self._current_index = 0
        
        # Update UI
        self.mediaListChanged.emit(self._current_playlist)
        
    @Slot(result=bool)
    def is_shuffled(self):
        """Return current shuffle state"""
        return self._shuffle

    @Slot(QObject)
    def connect_settings_manager(self, settings_manager):
        self._settings_manager = settings_manager
        # Update media directory from settings
        if self._settings_manager:
            self.update_media_directory(self._settings_manager.mediaFolder)
            # Connect to future changes
            self._settings_manager.mediaFolderChanged.connect(self.update_media_directory)
            
    @Slot(str)
    def update_media_directory(self, directory):
        if os.path.exists(directory) and os.path.isdir(directory):
            old_dir = self.media_dir
            self.media_dir = directory
            print(f"Media directory changed from {old_dir} to {self.media_dir}")
            
            # Clear caches that depend on the previous directory
            self._metadata_cache = {}
            self._album_art_cache = {}
            self._access_count = {}
            
            # Refresh media files
            self.get_media_files()
            
            # If currently playing, try to continue with same file or reset
            current_file = self.get_current_file()
            if self._is_playing and current_file and os.path.exists(os.path.join(self.media_dir, current_file)):
                self.play_file(current_file)
            elif self._is_playing:
                # Was playing but file not in new directory - play first available file
                files = self.get_media_files()
                if files:
                    self.play_file(files[0])
                else:
                    self._player.stop()
                    self._is_playing = False
                    self._is_paused = True
                    self.playStateChanged.emit(False)
                    
                    # Stop audio processor if needed
                    if self._equalizer_active and hasattr(self, '_audio_processor') and self._audio_processor:
                        self._audio_processor.stop()
        else:
            print(f"Warning: Directory {directory} does not exist or is not a directory")
            
    @Slot(result=str)
    def get_default_media_dir(self):
        """Return the default media directory path"""
        return self.default_media_dir