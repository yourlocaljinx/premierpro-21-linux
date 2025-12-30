#!/bin/bash

choice="0"
echo ""
read -p "Are you sure you want to uninstall Adobe Premier Pro? (y/n): " choice

if [ "$choice" = "y" ]
then
    rm -rf Pr-prefix
    rm -rf  ~/.local/share/applications/premierpro.desktop
    echo ""
    echo "Premier Pro uninstalled!"
    echo ""
elif [ "$choice" = "n" ]
then
    echo ""
    echo "Uninstallation canceled!"
    echo ""
else
    echo ""
    echo "Invalid input, exiting Adobe Premier Pro uninstaller!"
    echo ""
fi

