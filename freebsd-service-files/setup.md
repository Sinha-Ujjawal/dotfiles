# Steps to install Wayvnc and Sway on FreeBSD

1. Installing Wayland and Sway
```console
# pkg install wayland sway wmenu foot xorg-fonts wayvnc
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

6. Create a new file `/usr/local/etc/rc.d/sway` with following content
```bash
#!/bin/sh

# PROVIDE: sway
# REQUIRE: dbus
# KEYWORD: shutdown

. /etc/rc.subr

name="sway"
rcvar="sway_enable"

start_cmd="sway_start"
stop_cmd="sway_stop"
status_cmd="sway_status"

load_rc_config $name

: ${sway_enable="NO"}
: ${sway_command="/usr/local/bin/sway"}
: ${sway_daemon_pidfile="/var/run/sway_daemon.pid"}
: ${sway_program_pidfile="/var/run/sway_program.pid"}
: ${WLR_BACKENDS="${sway_backends:-headless}"}

sway_start() {
    set -x
    echo "Starting $name"
    export WLR_BACKENDS="$WLR_BACKENDS"
    export WLR_LIBINPUT_NO_DEVICES=1
    export XDG_RUNTIME_DIR="/var/run/xdg/root"
    export XDG_CONFIG_HOME="/usr/local/etc/sway"
    export PATH="/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin"

    rm -rf "$XDG_RUNTIME_DIR"
    mkdir -p "$XDG_RUNTIME_DIR"
    chmod 0700 "$XDG_RUNTIME_DIR"

    /usr/sbin/daemon -r -P "$sway_daemon_pidfile" -p "$sway_program_pidfile" -- $sway_command >/dev/null 2>&1 &
    set +x
}

sway_stop() {
    set -x
    echo "Stopping $name"

    local daemon_pid=""
    if [ -f "$sway_daemon_pidfile" ]; then
        daemon_pid=$(cat "$sway_daemon_pidfile")
    fi

    local program_pid=""
    if [ -f "$sway_program_pidfile" ]; then
        program_pid=$(cat "$sway_program_pidfile")
    fi

    kill -9 $daemon_pid $program_pid >/dev/null 2>&1

    rm -f "$sway_daemon_pidfile"
    rm -f "$sway_program_pidfile"

    set +x
}

sway_status() {
    set -x

    if [ -f "$sway_daemon_pidfile" ]; then
        echo "$name is running"
    else
        echo "$name is not running"
    fi

    set +x
}

run_rc_command $1
```

7. Create a new file `/usr/local/etc/rc.d/wayvnc` with following content
```bash
#!/bin/sh

# PROVIDE: wayvnc
# REQUIRE: sway
# KEYWORD: shutdown

. /etc/rc.subr

name="wayvnc"
rcvar="wayvnc_enable"

start_cmd="wayvnc_start"
stop_cmd="wayvnc_stop"
status_cmd="wayvnc_status"

load_rc_config $name

: ${wayvnc_enable="NO"}
: ${wayvnc_command="/usr/local/bin/wayvnc"}
: ${wayvnc_daemon_pidfile="/var/run/wayvnc_daemon.pid"}
: ${wayvnc_program_pidfile="/var/run/wayvnc_program.pid"}
: ${config="${wayvnc_config:-/usr/local/etc/wayvnc/config}"}
: ${WAYLAND_DISPLAY="${wayvnc_wayland_display:-wayland-1}"}

wayvnc_start() {
    set -x
    echo "Starting $name"
    export WAYLAND_DISPLAY="$WAYLAND_DISPLAY"
    export XDG_RUNTIME_DIR="/var/run/xdg/root"

    rm -f "$XDG_RUNTIME_DIR/wayvncctl"

    /usr/sbin/daemon -r -P "$wayvnc_daemon_pidfile" -p "$wayvnc_program_pidfile" -- $wayvnc_command -C "$config" >/dev/null 2>&1 &

    set +x
}

wayvnc_stop() {
    set -x
    echo "Stopping $name"

    local daemon_pid=""
    if [ -f "$wayvnc_daemon_pidfile" ]; then
        daemon_pid=$(cat "$wayvnc_daemon_pidfile")
    fi

    local program_pid=""
    if [ -f "$wayvnc_program_pidfile" ]; then
        program_pid=$(cat "$wayvnc_program_pidfile")
    fi

    kill -9 $daemon_pid $program_pid >/dev/null 2>&1

    rm -f "$wayvnc_daemon_pidfile"
    rm -f "$wayvnc_program_pidfile"

    set +x
}

wayvnc_status() {
    set -x

    if [ -f "$wayvnc_daemon_pidfile" ]; then
        echo "$name is running"
    else
        echo "$name is not running"
    fi

    set +x
}

run_rc_command $1
```

8. Make both the files executable.
```console
# chmod +x /usr/local/etc/rc.d/sway /usr/local/etc/rc.d/wayvnc
```

9. Enable and start the services.
```console
# sysrc sway_enable=YES
sway_enable:  -> YES

# sysrc wayvnc_enable=YES
wayvnc_enable:  -> YES

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

10. Connect with VNC Viewer to the host machine, and then open the terminal (Ctrl + Enter). It will open the foot terminal. Then inside the terminal hold Ctrl+Shift and two fingers on the trackpad to increase the font size. Then execute below commands to set the resolution
```console
# swaymsg output HEADLESS-1 mode 1640x1000
```

11. Execute below command to make audio work. If `cat /dev/sndstat` does not show you devices. After running below command run `cat /dev/sndstat` again to see if any device is getting recognized.
```console
# sudo kldload snd_hda
```
