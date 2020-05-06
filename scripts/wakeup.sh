#!/bin/sh -e

# run "chrontab -e" and add the line "@reboot /home/ac/dotfiles/scripts/wakeup.sh
echo LID0 > /proc/acpi/wakeup
echo XHC1 > /proc/acpi/wakeup
echo `whoami` > /tmp/testcron
exit 0
