#!/bin/bash

FILE_PATH="/root/nas_fan_control/.vacation_mode"

if [ -f "$FILE_PATH" ]; then
    echo "ON"
else
    echo "OFF"
fi
