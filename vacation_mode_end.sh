#!/bin/bash

FILE="/root/nas_fan_control/.vacation_mode"

if [[ -f "$FILE" ]]; then
  echo "##### ENDING VACATION MODE!"
  rm "/root/nas_fan_control/.vacation_mode"
  mv "/root/nas_fan_control/PID_fan_control_config.ini.bk" "/root/nas_fan_control/PID_fan_control_config.ini"
  /root/nas_fan_control/reload_service.sh
else
  echo "##### Vacation mode is not started!"
fi
