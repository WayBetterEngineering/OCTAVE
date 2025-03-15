#!/bin/bash
sudo rfcomm bind 0 00:0C:BF:3D:FB:D0
source /home/pi/venv/bin/activate
python /home/pi/Documents/_OCTAVE/octave/main.py
exit 0