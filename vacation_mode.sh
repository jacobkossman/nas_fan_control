#!/bin/bash

FILE="/root/nas_fan_control/.vacation_mode"

if [[ -f "$FILE" ]]; then
  echo "##### Vacation Mode already started!"
else
  mv "/root/nas_fan_control/PID_fan_control_config.ini" "/root/nas_fan_control/PID_fan_control_config.ini.bk"
  cp "/root/nas_fan_control/PID_fan_control_config_vacay.ini" "/root/nas_fan_control/PID_fan_control_config.ini"
  touch "/root/nas_fan_control/.vacation_mode"
  echo "##### STARTED VACATION MODE ####"
  # /root/nas_fan_control/reload_service.sh
fi
