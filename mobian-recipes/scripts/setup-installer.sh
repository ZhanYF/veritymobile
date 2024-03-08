#!/bin/sh

USERNAME=$1
MOBIAN_SUITE=$2
MOBIAN_GRAPHICAL_SHELL=$3
[ "$USERNAME" ] || exit 1
[ "$MOBIAN_SUITE" ] || exit 1
[ "$MOBIAN_GRAPHICAL_SHELL" ] || exit 1

# Disable power key handling to avoid accidental shutdown mid-install
mkdir -p /etc/systemd/logind.conf.d
cat > /etc/systemd/logind.conf.d/10-ignore-power-key.conf << EOF
[Login]
HandlePowerKey=ignore
EOF

# Disable eg25-manager (we don't need the modem during install)
systemctl disable eg25-manager.service

# Rename user so installer can change it's password
if [ -f /etc/calamares/modules/mobile.conf ] && [ "$USERNAME" != "mobian" ]; then
    sed -i "s/username: \"mobian\"/username: \"$USERNAME\"/" /etc/calamares/modules/mobile.conf
fi

# Set the Debian suite to be shown in the installer's splash screen
if [ -f /etc/calamares/modules/mobile.conf ] && [ "$MOBIAN_SUITE" != "trixie" ]; then
    sed -i "s/version: \"Trixie\"/version: \"$MOBIAN_SUITE\"/" /etc/calamares/modules/mobile.conf
fi

# Set the desktop environment to be shown in the installer's splash screen
if [ -f /etc/calamares/modules/mobile.conf ] && [ "$MOBIAN_GRAPHICAL_SHELL" != "phosh" ]; then
    sed -i "s/userInterface: \"Phosh\"/userInterface: \"$MOBIAN_GRAPHICAL_SHELL\"/" /etc/calamares/modules/mobile.conf
fi
