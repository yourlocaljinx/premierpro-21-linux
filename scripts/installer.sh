#!/bin/bash

source "./shared.sh"

export WINEPREFIX="$PWD/Pr-prefix"

echo ""
echo "Starting Adobe Premier Pro CC 2021 installer..."
echo ""
sleep 1

if [ -d "Pr-prefix" ]; then
  choice="0"
  read -p "A Premier Pro installation seems to be present, would you like to override that installation? (y/n): " choice
  if ! [ $choice = "y" ]; then
    echo ""
    echo "Aborting installation!"
    echo ""
    exit 1
  fi
  sleep 1
fi


echo "Checking for dependencies..."
sleep 0.5

if ! command -v curl &> /dev/null; then
  echo -e "- '${red}curl${reset}' is MISSING!"
  MISSING=1
  sleep 0.5
fi

if ! command -v wine &> /dev/null; then
  echo -e "- '${red}wine${reset}' is MISSING!"
  MISSING=1
  sleep 0.5
fi

if ! command -v tar &> /dev/null; then
  echo -e "- '${red}tar${reset}' is MISSING!"
  MISSING=1
  sleep 0.5
fi

if ! command -v wget &> /dev/null; then
  echo -e "- '${red}wget${reset}' is MISSING!"
  MISSING=1
  sleep 0.5
fi

if ! command -v gdown &> /dev/null; then
  echo -e "- '${red}gdown${reset}' is MISSING! (To install: \"${yellow}pip3 install gdown${reset}\")"
  MISSING=1
  sleep 0.5
fi

if [[ $MISSING == "1" ]]; then
  echo -e "\n${red}- ERROR:${reset} Please install the missing dependencies and then reattempt the isntallation"
  exit 1
fi

vdk3d="0"
echo ""
read -p "- Would you like to install vdk3d proton? (y/n): " vdk3d
sleep 1

echo "Making PS prefix..."
sleep 1
rm -rf $PWD/Pr-prefix
mkdir $PWD/Pr-prefix
sleep 1

mkdir -p scripts

echo "Downloading winetricks and making executable if not already downloaded..."
sleep 1
wget -nc --directory-prefix=scripts/ https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
chmod +x scripts/winetricks

sleep 1

echo "Downloading Premier Pro files and components if not already downloaded..."
sleep 1
mkdir -p installation_files

if ! [ -f installation_files/pr_components.tar.xz ]; then
  gdown "1esUAZkejzJARub9cessbVeUCDlzzzcQG" -O installation_files/pr_components.tar.xz
else
  if md5sum --status -c .pr_components.md5; then
    echo -e "The file pr_components.tar.xz is available"
  else  
    echo ""
    choice="0"
    read -p "The \"pr_components.tar.xz\" file is corrupted, would you like to remove and re-download it? (y/n): " choice
    if [ $choice = "y" ]; then
      rm installation_files/pr_components.tar.xz
      echo ""
      echo "Removed corrupted file and downloading again..."
      echo ""
      gdown "1esUAZkejzJARub9cessbVeUCDlzzzcQG" -O installation_files/pr_components.tar.xz
    else
      echo ""
      echo "Aborting installation!"
      echo ""
      exit 1
    fi
  fi
fi

sleep 1

echo "Extracting files..."
sleep 1
rm -fr installation_files/Adobe\ Premier\ Pro\ 2021 installation_files/redist installation_files/x64 installation_files/x86
tar -xvf installation_files/pr_components.tar.xz.tar.xz -C installation_files/
sleep 1


echo "Booting & creating new prefix"
sleep 1
wineboot
sleep 1

echo "Setting win version to win10"
sleep 1
./scripts/winetricks win10
sleep 1

echo "Installing & configuring winetricks components..."
./scripts/winetricks fontsmooth=rgb gdiplus msxml3 msxml6 atmlib corefonts dxvk
sleep 1

echo "Installing redist components..."
sleep 1

wine installation_files/redist/2010/vcredist_x64.exe /q /norestart
wine installation_files/redist/2010/vcredist_x86.exe /q /norestart
wine installation_files/redist/2012/vcredist_x86.exe /install /quiet /norestart
wine installation_files/redist/2012/vcredist_x64.exe /install /quiet /norestart
wine installation_files/redist/2013/vcredist_x86.exe /install /quiet /norestart
wine installation_files/redist/2013/vcredist_x64.exe /install /quiet /norestart
wine installation_files/redist/2019/VC_redist.x64.exe /install /quiet /norestart
wine installation_files/redist/2019/VC_redist.x86.exe /install /quiet /norestart

sleep 1


if [ $vdk3d = "y" ]; then
    echo "Installing vdk3d proton..."
    sleep 1
  ./scripts/winetricks vdk3d
  sleep 1
fi

echo "Making Premier Pro directory and copying files..."

sleep 1

mkdir $PWD/Pr-prefix/drive_c/Program\ Files/Adobe
mv installation_files/Adobe\ Premier\ Pro\ 2021 $PWD/Pr-prefix/drive_c/Program\ Files/Adobe/Adobe\ Premier\ Pro\ 2021

sleep 1

echo "Copying launcher files..."

sleep 1
rm -f scripts/launcher.sh
rm -f scripts/premierpro.desktop

echo "#\!/bin/bash
cd \"$PWD/Pr-prefix/drive_c/Program Files/Adobe/Adobe\ Premier\ Pro\ 2021/"
WINEPREFIX=\"$PWD/Pr-prefix\" wine premierpro.exe $1" > scripts/launcher.sh


echo "[Desktop Entry]
Name=Premier Pro CC
Exec=bash -c '$PWD/scripts/launcher.sh'
Type=Application
Comment=Premier Pro CC 2021
Categories=Graphics;2DGraphics;VideoEditing;Production;
Icon=$PWD/images/premierpro.svg
StartupWMClass=premierpro.exe
MimeType=image/png;image/psd;" > scripts/premierpro.desktop

chmod u+x scripts/launcher.sh
chmod u+x scripts/premierpro.desktop

rm -f ~/.local/share/applications/premierpro.desktop
mv scripts/premierpro.desktop ~/.local/share/applications/premierpro.desktop

sleep 1

if [ $cameraraw = "y" ]; then
    echo "Installing Adobe Camera Raw, please follow the instructions on the installer window..."
    sleep 1
  wine installation_files/CameraRaw_12_2_1.exe
  sleep 1
fi

echo "Adobe Premier Pro CC 2021 Installation has been completed!"
echo -e "Use this command to run Premier Pro from the terminal:\n\n${yellow}bash -c '$PWD/scripts/launcher.sh'${reset}"