# Machine-specific settings for PID_fan_control.pl
#
# Copy this file to /root/nas_fan_control/local_settings.pl (the path is
# $local_settings_file in the script) and edit it there. That copy is in
# .gitignore, so your addresses and tuning never end up on GitHub.
#
# Anything set here overrides the default of the same name in the script, so
# only list what you actually change. Each setting is described next to its
# default in PID_fan_control.pl.

## TrueNAS ssh login, used to list the drives and read their temperatures.
## Keep the trailing double quote inside the single quotes.
$ssh_command_prefix = 'ssh user@truenas.example.lan "';

## smartctl command. Leave this out: the script works out whether it's
## TrueNAS CORE or SCALE and picks the right one. Only set it if yours lives
## somewhere unusual.
# $smartctl = 'sudo -n /usr/sbin/smartctl';

## Debug level, 0 = off
# $debug = 0;

## Fan zones and the headers used to check them
# $cpu_fan_zone   = 0;
# $hd_fan_zone    = 1;
# $cpu_fan_header = "FAN1";
# $hd_fan_header  = "FANA";
# @hd_fan_list    = ("FANA");

## Fastest speed (rpm) of the fans on each header
# $cpu_max_fan_speed = 2000;
# $hd_max_fan_speed  = 3300;

## CPU temperature thresholds (C)
# $high_cpu_temp = 55;
# $med_cpu_temp  = 45;
# $low_cpu_temp  = 35;

## Fan duty levels (%)
# $fan_duty_med         = 60;
# $fan_duty_low         = 30;
# $hd_fan_duty_med_high = 80;
# $hd_fan_duty_low      = 16;

# $cpu_fans_cool_hd = 1;

1;  # must stay as the last line
