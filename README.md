# OCTAVE

## Overview
OCTAVE (Open-source Cross-platform Telematics for Augmented Vehicle Experience) is an open-source infotainment system designed to provide a seamless interface for vehicle systems, media playback, navigation, and OBD-II diagnostics.

## Features
- **Media Player**: Album art display, playlist management, and music library organization
- **Integrated Equalizer**: Visual equalizer with customizable presets and system equalizer support
- **OBD-II Integration**: Real-time vehicle diagnostics with customizable dashboard
- **Customizable UI**: Multiple built-in themes and ability to create custom themes
- **Cross-Platform**: Compatible with Windows, Linux, and macOS

## Screenshots
*OCTAVE Media Player with album art and equalizer*  
*Customizable OBD-II diagnostics dashboard*

## System Requirements
- **Minimum Screen Resolution**: 800x480 (recommended: 1280x720 or higher)
- **Memory**: 2GB RAM minimum
- **OBD Functionality**: Bluetooth-enabled OBD-II adapter
- **Equalizer Performance**: System-level equalizer software
- **Operating Systems**: Windows 10+, Ubuntu 20.04+, macOS 11+

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

For equalizer support, install Equalizer APO for system-wide equalizer support.
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


Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

Fork the repository
Create your feature branch (git checkout -b feature/amazing-feature)
Commit your changes (git commit -m 'Add some amazing feature')
Push to the branch (git push origin feature/amazing-feature)
Open a Pull Request

License
Copyright © 2025 WayBetterEngineering
This software is released under the MIT License.

You can copy this directly into your README.md file. The formatting uses proper Markdown syntax with appropriate headers, bullet points, code blocks with language specifications, and text formatting.