#!/bin/bash

source "./scritps/shared.sh"

export WINEPREFIX="$PWD/Ps-prefix"

! [ -d logs ] && mkdir logs

clear
echo "${bold}-------------- Adobe Premier Pro CC 2021  installer main menu on Linux --------------${reset}"
echo ""
PS3="
[Choose options 1-6 or 7 to exit]: "
options=("Install Premier Pro CC 2021" "Uninstall Premier Pro CC 2021" "Install/Uninstall vdk3d proton" "Configure Premier Pro wine prefix (winecfg)"  "Update desktop integration" "Exit")
select opt in "${options[@]}"
do
    case $opt in
        "Install Premier Pro CC 2021")
			echo ""
            bash scripts/installer.sh | tee logs/installer.log
            ;;
        "Uninstall Premier Pro CC 2021")
            echo ""
			bash scripts/uninstaller.sh | tee logs/uninstaller.log
            ;;
        "Install/Uninstall vdk3d proton")
            choice="u"
            echo ""
            read -p "Would you like to install or uninstall vkd3d proton [i=install u=uninstall]: " choice
            if [[ $choice = "i" ]]
            then
                ./scripts/setup_vkd3d_proton.sh install
                echo ""
                echo "Vdk3d proton installed!"
                echo ""
            elif [[ $choice = "u" ]]
            then
                ./scripts/setup_vkd3d_proton.sh uninstall
                echo ""
                echo "Vdk3d proton uninstalled!"
                echo ""
            else
                echo "Invalid choice: $choice"
            fi
            ;;
		"Configure Premier Pro wine prefix (winecfg)")
			echo ""
            echo "Starting winecfg..."
            echo ""
            winecfg | tee logs/winecfg.log
			sleep 1
			;;
		"Update desktop integration")
            echo "[Desktop Entry]
echo "[Desktop Entry]
Name=Premier Pro CC
Exec=bash -c '$PWD/scripts/launcher.sh'
Type=Application
Comment=Premier Pro CC 2021
Categories=Graphics;2DGraphics;VideoEditing;Production;
Icon=$PWD/images/premierpro.svg
StartupWMClass=premierpro.exe
MimeType=image/png;image/psd;" > scripts/premierpro.desktop

            echo "#\!/bin/bash
cd \"$PWD/Ps-prefix/drive_c/Program Files/Adobe/Adobe\ Premier\ Pro\ 2021/"
WINEPREFIX=\"$PWD/Ps-prefix\" wine premierpro.exe $1" > scripts/launcher.sh

            chmod u+x scripts/launcher.sh
            chmod u+x ~/.local/share/applications/premierpro.desktop
			echo ""
            echo "Desktop entry updated!"
            echo ""
			;;
		"Exit")
			echo ""
            echo "Exiting Premier Pro Main Menu."
            break
            ;;
        *) echo "Invalid option: $REPLY";;
    esac
done
