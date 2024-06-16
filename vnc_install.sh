#!/bin/bash
# 
# Script for installing x11vnc on Steam Deck.
#
# Install:
# 
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/sshuen30/Install_x11vnc_Steam/main/vnc_install.sh?$RANDOM)"
#
# This will modify root filesystem so it will probably get
# overwrite on system updates but is totally ok executing
# it several times, so if something stops working just
# launch it again.
#
# If you like seeing the terminal window, change
# "Terminal=false" to "Terminal=true" for the desktop entries below.
#
# Original script: àngel "mussol" bosch (muzzol@gmail.com)
#

echo -n "Checking root permissions: "
if [ "$(id -ru)" == "0" ]; then
    echo "OK"
else
    echo "user is $(whoami), trying again as root"
    exec sudo sh -c "$(curl -fsSL https://gist.githubusercontent.com/x43x61x69/9a5a231a25426e8a2cc0f7c24cfdaed9/raw/vnc_install.sh?$RANDOM)"
    exit 0
fi

## system related comands
echo "Disabling readonly filesystem"
steamos-readonly disable

if [ ! -e "/etc/pacman.d/gnupg/trustdb.gpg" ]; then
    echo "Initalizing pacman keys"
    sudo pacman-key --init
    sudo pacman-key --refresh-keys
    sudo pacman-key --populate holo
fi

echo "Installing package"
## pacman -Sy --noconfirm x11vnc
pacman -Sy --noconfirm --overwrite "*" x11vnc

echo "Re-enabling readonly filesystem"
steamos-readonly enable

## user related commands

DECK_USER=$(grep "^User=" /etc/sddm.conf.d/steamos.conf | cut -d"=" -f2)

echo "Creating desktop entries"

mkdir -p "/home/${DECK_USER}/Desktop/VNC/"

LAUNCHER_TEXT='[Desktop Entry]
Name=Start VNC
Exec=x11vnc -noxdamage -usepw -display :0 -no6 -forever -bg
Icon=/usr/share/app-info/icons/archlinux-arch-community/64x64/x11vnc_computer.png
Terminal=false
Type=Application
StartupNotify=false'
echo "$LAUNCHER_TEXT" > "/home/${DECK_USER}/Desktop/VNC/Start VNC.desktop"
chown "${DECK_USER}" "/home/${DECK_USER}/Desktop/VNC/Start VNC.desktop"
chmod +x "/home/${DECK_USER}/Desktop/VNC/Start VNC.desktop"

LAUNCHER_TEXT='[Desktop Entry]
Name=Stop VNC
Exec=killall x11vnc
Icon=/usr/share/app-info/icons/archlinux-arch-community/64x64/x11vnc_computer.png
Terminal=false
Type=Application
StartupNotify=false'
echo "$LAUNCHER_TEXT" > "/home/${DECK_USER}/Desktop/VNC/Stop VNC.desktop"
chown "${DECK_USER}" "/home/${DECK_USER}/Desktop/VNC/Stop VNC.desktop"
chmod +x "/home/${DECK_USER}/Desktop/VNC/Stop VNC.desktop"

LAUNCHER_TEXT='[Desktop Entry]
Name=Set VNC Password
Exec=sudo x11vnc -storepasswd; read -s -n 1 -p "Press any key to continue . . ."
Icon=/usr/share/app-info/icons/archlinux-arch-community/64x64/x11vnc_computer.png
Terminal=true
Type=Application
StartupNotify=false'
echo "$LAUNCHER_TEXT" > "/home/${DECK_USER}/Desktop/VNC/Set VNC Password.desktop"
chown "${DECK_USER}" "/home/${DECK_USER}/Desktop/VNC/Set VNC Password.desktop"
chmod +x "/home/${DECK_USER}/Desktop/VNC/Set VNC Password.desktop"

LAUNCHER_TEXT='[Desktop Entry]
Name=Reinstall VNC
Exec=sudo sh -c "$(curl -fsSL https://gist.githubusercontent.com/x43x61x69/9a5a231a25426e8a2cc0f7c24cfdaed9/raw/vnc_install.sh?$RANDOM)"
Icon=/usr/share/app-info/icons/archlinux-arch-community/64x64/x11vnc_computer.png
Terminal=true
Type=Application
StartupNotify=false'
echo "$LAUNCHER_TEXT" > "/home/${DECK_USER}/Desktop/VNC/Reinstall VNC.desktop"
chown "${DECK_USER}" "/home/${DECK_USER}/Desktop/VNC/Reinstall VNC.desktop"
chmod +x "/home/${DECK_USER}/Desktop/VNC/Reinstall VNC.desktop"

SCRIPT_TEXT='#!/bin/bash
x11vnc -noxdamage -usepw -display :0 -no6 -forever -bg'
echo "$SCRIPT_TEXT" > "/home/${DECK_USER}/Desktop/VNC/vnc_startup.sh"
chown "${DECK_USER}" "/home/${DECK_USER}/Desktop/VNC/vnc_startup.sh"
chmod +x "/home/${DECK_USER}/Desktop/VNC/vnc_startup.sh"

if [ ! -f "/home/${DECK_USER}/.vnc/passwd" ]; then
    echo "Creating VNC password"
    sudo -H -u "${DECK_USER}" bash -c "x11vnc -storepasswd"
fi

echo "Done!"

read -s -n 1 -p "Press any key to continue . . ."

echo ""
