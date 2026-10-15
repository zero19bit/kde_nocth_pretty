#!/bin/sh
set -eu
notch_package_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
if ! command -v kpackagetool6 >/dev/null 2>&1; then
    printf '%s\n' 'kpackagetool6 is required. Install this widget in KDE Plasma 6.' >&2
    exit 1
fi
if kpackagetool6 --type Plasma/Applet --show org.oziro.notch >/dev/null 2>&1; then
    kpackagetool6 --type Plasma/Applet --upgrade "$notch_package_dir"
else
    kpackagetool6 --type Plasma/Applet --install "$notch_package_dir"
fi

printf '\n%s\n' 'Notch 0.8.1 installed. Close the widget settings window.'
printf '%s\n' 'Reload Plasma before opening the new calendar settings:'
printf '%s\n' '  systemctl --user restart plasma-plasmashell.service'
printf '%s\n' 'Or log out and log in again. Your saved settings will be preserved.'
