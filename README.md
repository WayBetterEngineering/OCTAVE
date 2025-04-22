# OCTAVE

OCTAVE (Open-source Cross-platform Telematics for Augmented Vehicle Experience) is an open-source infotainment system designed to provide a seamless interface for vehicle systems, media playback, navigation, and OBD-II diagnostics.

## Features

- **Media Player**: Album art display, playlist management, and music library organization
- **Integrated Equalizer**: Visual equalizer with customizable presets and system equalizer support
- **OBD-II Integration**: Real-time vehicle diagnostics with customizable dashboard
- **Customizable UI**: Multiple built-in themes and ability to create custom themes
- **Cross-Platform**: Compatible with Windows, Linux, and macOS

## Screenshots

[Consider adding screenshots of your application here]

## Installation

### Prerequisites

- Python 3.8 or newer
- PySide6 (Qt for Python)
- Python-OBD library
- Mutagen (for media metadata)
- Additional dependencies listed in requirements.txt

### Windows Installation

1. Open Command Prompt as administrator or PowerShell with elevated privileges:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

Navigate to your desired installation location:

cmdcd C:\Users\YourUserName\Documents

Clone the repository and enter the directory:

cmdgit clone https://github.com/waybetterengineering/octave.git
cd octave

Create and activate a virtual environment:

cmdpython -m venv venv
venv\Scripts\activate

Install dependencies:

cmdpip install -r requirements.txt
pip install --upgrade numpy pint

For OBD support, install Equalizer APO for system-wide equalizer support.
Launch the application:

cmdpython main.py
Linux Installation

Open a terminal window
Navigate to your desired installation location:

bashcd ~/Documents

Clone the repository and enter the directory:

bashgit clone https://github.com/waybetterengineering/octave.git
cd octave

Create and activate a virtual environment:

bashpython -m venv venv
source venv/bin/activate

Install dependencies:

bashpip install -r requirements.txt
pip install --upgrade numpy pint

For OBD support, ensure you have permissions to access the Bluetooth device:

bashsudo usermod -a -G dialout $USER
(You may need to log out and back in for this to take effect)

For equalizer functionality, install EasyEffects:

bashflatpak install flathub com.github.wwmm.easyeffects

Launch the application:

bashpython main.py
macOS Installation

Open Terminal
Navigate to your desired installation location:

bashcd ~/Documents

Clone the repository and enter the directory:

bashgit clone https://github.com/waybetterengineering/octave.git
cd octave

Create and activate a virtual environment:

bashpython -m venv venv
source venv/bin/activate

Install dependencies:

bashpip install -r requirements.txt
pip install --upgrade numpy pint

For equalizer support, consider installing eqMac.
Launch the application:

bashpython main.py
OBD-II Configuration
To use OBD-II features:

Pair your Bluetooth OBD-II adapter with your computer
In OCTAVE, go to Settings > OBD Settings
Enter the Bluetooth device path:

Windows: Usually "COM3" (check Device Manager)
Linux: Usually "/dev/rfcomm0"
macOS: Usually "/dev/tty.OBDLinkMX-STN-SPP-1"


Enable or disable Fast Mode depending on your vehicle's compatibility
Customize which OBD parameters to display on the home screen

Media Player

Add your music files to the default media folder or configure a custom music folder in Settings > Media Settings
The player supports MP3 files with album art and metadata
Create and save equalizer presets for different audio preferences
Toggle shuffle mode to randomize playback

Customizing the Interface

Go to Settings > Display Settings
Choose from built-in themes or create your own custom theme
Adjust UI scaling to fit your screen
Modify clock format and visibility

System Requirements

Minimum screen resolution: 800x480 (recommended: 1280x720 or higher)
2GB RAM minimum
For OBD functionality: Bluetooth-enabled OBD-II adapter
For optimal equalizer performance: System-level equalizer software

Troubleshooting

OBD Connection Issues: Check Bluetooth pairing and device path
Media Not Playing: Verify file formats (MP3) and folder permissions
Missing Album Art: Ensure MP3 files have embedded album art
Performance Issues: Adjust UI scaling and background blur settings

License
Copyright © 2025 WayBetterEngineering
This software is released under the MIT License.
Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

Fork the repository
Create your feature branch (git checkout -b feature/amazing-feature)
Commit your changes (git commit -m 'Add some amazing feature')
Push to the branch (git push origin feature/amazing-feature)
Open a Pull Request

Acknowledgments

Python-OBD library for OBD-II communication
Mutagen for audio metadata extraction
PySide6 for the UI framework
Contributors and testers who have provided valuable feedback

Roadmap

Navigation integration
Voice control features
Android Auto/Apple CarPlay compatibility
Enhanced data logging and analytics
Raspberry Pi optimized version


Feel free to customize any part of this README to better fit your project's specific features and requirements. The structure provides a comprehensive overview of your OCTAVE application based on the code files you've shared.