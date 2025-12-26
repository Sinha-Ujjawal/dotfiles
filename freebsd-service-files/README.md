# Steps to install Wayvnc and Sway on FreeBSD

1. Installing Wayland, Sway, Wayvnc and Pulseaudio
```console
# pkg install wayland sway wmenu foot xorg-fonts wayvnc pulseaudio
```

2. Edit Sway Config. Change `set $mod Mod4` to `set $mod Ctrl`
```console
vim /usr/local/etc/sway/config
```

3. Create a new file `/usr/local/etc/wayvnc/config` with content
```plain
address=0.0.0.0
enable_auth=true
username=root
password=root
```

4. Enable DBUS and Starting Bus
```console
# sysrc dbus_enable=YES
dbus_enable:  -> YES
# service dbus start
```

5. At this point we are ready to use Sway and Wayvnc, but Let's create a nice service to make it easier.

6. Create a new file `/usr/local/etc/rc.d/pulseaudio` with following [content](./pulseaudio)

7. Create a new file `/usr/local/etc/rc.d/wayvnc` with following [content](./wayvnc)

8. Create a new file `/usr/local/etc/rc.d/wayvnc` with following [content](./wayvnc)

9. Make the files executable.
```console
# chmod +x /usr/local/etc/rc.d/pulseaudio /usr/local/etc/rc.d/sway /usr/local/etc/rc.d/wayvnc
```

10. Enable and start the services.
```console
# sysrc pulseaudio_enable=YES
pulseaudio_enable:  -> YES

# sysrc sway_enable=YES
sway_enable:  -> YES

# sysrc wayvnc_enable=YES
wayvnc_enable:  -> YES

# service pulseaudio start
+ echo 'Starting pulseaudio'
Starting pulseaudio
+ set +x
+ /usr/sbin/daemon -r -P /var/run/pulseaudio_daemon.pid -p /var/run/pulseaudio_program.pid -- /usr/local/bin/pulseaudio --start

# service sway start
+ echo 'Starting sway'
Starting sway
+ export 'WLR_BACKENDS={:-headless}'
+ export 'WLR_LIBINPUT_NO_DEVICES=1'
+ export 'XDG_RUNTIME_DIR=/var/run/xdg/root'
+ export 'XDG_CONFIG_HOME=/usr/local/etc/sway'
+ export 'PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin'
+ rm -rf /var/run/xdg/root
+ mkdir -p /var/run/xdg/root
+ chmod 0700 /var/run/xdg/root
+ set +x
+ /usr/sbin/daemon -r -P /var/run/sway_daemon.pid -p /var/run/sway_program.pid -- /usr/local/bin/sway

# service wayvnc start
+ echo 'Starting wayvnc'
Starting wayvnc
+ export 'WAYLAND_DISPLAY=wayland-1'
+ export 'XDG_RUNTIME_DIR=/var/run/xdg/root'
+ rm -f /var/run/xdg/root/wayvncctl
+ set +x
+ /usr/sbin/daemon -r -P /var/run/wayvnc_daemon.pid -p /var/run/wayvnc_program.pid -- /usr/local/bin/wayvnc -C /usr/local/etc/wayvnc/config
```

11. Connect with VNC Viewer to the host machine, and then open the terminal (Ctrl + Enter). It will open the foot terminal. Then inside the terminal hold Ctrl+Shift and two fingers on the trackpad to increase the font size. Then execute below commands to set the resolution
```console
# swaymsg output HEADLESS-1 mode 1640x1000
```

12. Execute below command to make audio work. If `cat /dev/sndstat` does not show you devices. After running below command run `cat /dev/sndstat` again to see if any device is getting recognized.
```console
# sudo kldload snd_hda
```

13. Add below line to `/boot/loader.conf` to detect the sound hardware automatically after every restart.
```bash
snd_hda_load="YES"
```
