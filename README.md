# nas_fan_control
collection of scripts to control fan speed on NAS boxes

PID_fan_control.pl - Perl fan control script based on the hybrid fan control script created by @Stux, and posted at:
https://forums.freenas.org/index.php?threads/script-hybrid-cpu-hd-fan-zone-controller.46159/ .  @Stux's script was modified by replacing his fan control loop with a PID controller.  This version of the script was settings and gains used by the author on a Norco RPC-4224, with the following fans:

*  3 x Noctua NF-F12 PWM 120mm fans: hard drive wall fans replaced with .  
*  2 x Noctua NF-A8 PWM 80mm fans: chassis exit fans.  
*  1 x Noctua NH-U9DX I4: CPU cooler.

The hard drive fans are connected to fan headers assigned to the hard drive temperature control portion of the script.  The chassis exit fans and the CPU cooler are connected to fan headers assigned to the CPU temperature control portion of the script.

See the scripts for more info and commentary.

Discussion on the FreeNAS forums: https://forums.freenas.org/index.php?threads/pid-fan-controller-perl-script.50908/

## Running it on a Proxmox host with a TrueNAS VM

This version runs on the hypervisor (Proxmox), which owns the BMC, while the drives sit behind an HBA passed through to a TrueNAS VM. Drive temperatures are read over ssh from TrueNAS; fans are set with `ipmitool` locally. It works with both **TrueNAS CORE** and **TrueNAS SCALE**: on startup it runs `uname` over ssh and picks the matching drive-list command (`camcontrol` on CORE, `lsblk` on SCALE) and smartctl path. On SCALE only spinning disks are counted, so SSDs (SLOG, L2ARC, boot) are ignored.

### 1. TrueNAS: an ssh login Proxmox can use

The script needs a key-based (passwordless) ssh login from Proxmox's root user into TrueNAS.

1. On Proxmox, if root has no key yet: `ssh-keygen -t ed25519` (press Enter through the prompts). Show it with `cat /root/.ssh/id_ed25519.pub`.
2. In TrueNAS, open **Credentials > Users**, pick (or add) the user to log in as, paste that key into **Authorized Keys**, and save. Make sure the SSH service is running (**System > Services**).
3. **SCALE with a non-root user:** reading drive temperatures needs root, so the script runs smartctl through sudo. On the same user page set **Allowed sudo commands with no password** to `/usr/sbin/smartctl`. Nothing else is granted. (If saving the form does nothing, a password manager's autofill may be filling hidden fields; turn it off for that page.)
4. From Proxmox, test it. The first run asks you to accept the host key, which the service can't do, so this step matters:

   ```bash
   ssh user@truenas.lan "uname -s"
   ssh user@truenas.lan "sudo -n /usr/sbin/smartctl -A /dev/sda | grep Temperature_Celsius"
   ```

   The first should print `Linux` (SCALE) or `FreeBSD` (CORE). The second, on SCALE, should print a temperature line without asking for a password. On CORE, test `/usr/local/sbin/smartctl -A /dev/da0` instead.

### 2. Proxmox: get the script

```bash
apt install ipmitool git
git clone https://github.com/jacobkossman/nas_fan_control.git /root/nas_fan_control
cd /root/nas_fan_control
ln -s 2d_config.ini PID_fan_control_config.ini
```

`PID_fan_control_config.ini` holds the PID tuning (target drive temperature, gains). The `switch_*.sh` scripts swap between the provided ones; you can edit them while the script runs.

### 3. Your settings: `local_settings.pl`

Everything specific to your machine goes in its own file, so you never edit the script itself and your addresses and logins never end up on GitHub (`local_settings.pl` is in `.gitignore`).

```bash
cp local_settings.example.pl local_settings.pl
nano local_settings.pl
```

- Set `$ssh_command_prefix` to your TrueNAS login, e.g. `'ssh user@truenas.lan "'`. Keep the double quote before the closing single quote. Add `-p 2222` after `ssh` if TrueNAS listens on another port.
- Uncomment and change only the settings you need: fan zones and headers (check yours with `ipmitool sdr type fan`), max fan rpm, CPU temperature thresholds, fan duty levels. Each one is explained next to its default in `PID_fan_control.pl`.
- Leave `$smartctl` alone unless smartctl is somewhere unusual; it's picked automatically.
- Keep `1;` as the last line.

The script reads it from `/root/nas_fan_control/local_settings.pl` after its own defaults, so anything set there wins. Without the file it runs on the defaults and says so on startup.

### 4. Install and start the service

```bash
cp /root/nas_fan_control/PID_fan_control.pl /usr/local/bin/
cp /root/nas_fan_control/IPMIFanControl.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable --now IPMIFanControl
```

Check it's working:

```bash
systemctl status IPMIFanControl
tail -n 30 /root/PID_fan_control.log
```

The log should list every drive with a temperature. If the drive list is empty, rerun the ssh tests from step 1 as root on Proxmox. For more detail set `$debug = 3;` in `local_settings.pl`, restart, and read `/root/Debug_PID_fan_control.log`.

### Updating

```bash
git -C /root/nas_fan_control pull
cp /root/nas_fan_control/PID_fan_control.pl /usr/local/bin/
systemctl restart IPMIFanControl
```

`local_settings.pl` isn't touched by `git pull`, so your settings carry over.
