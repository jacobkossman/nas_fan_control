#!/bin/bash

hex=$(ipmitool raw 0x30 0x70 0x66 0x00 0x01)
upperhex=$(echo $hex | tr '[:lower:]' '[:upper:]')

echo "ibase=16; $upperhex"|bc
