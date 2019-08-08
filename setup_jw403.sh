#!/bin/sh

## SETTINGS
PRINTER_NAME="Open-Plan-Printer"
PRINTER_LOCATION="Open plan, JW403"
DRIVER_PATH="Ricoh-IM_C4500-PDF-Ricoh.ppd"

try_install_cups() {
  echo "\"cups\" not installed, trying to install..."
  if command -v apt > /dev/null 2>&1
  then
    apt update
    sudo apt install cups || exit 1
  elif command -v pacman > /dev/null 2>&1
  then
    sudo pacman -S cups || exit 1
  elif command -v yum > /dev/null 2>&1
  then
    sudo yum install cups || exit 1
  else
    echo "Could not install cups."
    echo "You need to install the package \"cups\" before continuing."
    exit 1
  fi
}

if ! command -v lpadmin > /dev/null 2>&1
then
  try_install_cups
fi

USERNAME=
PASSWORD=
PASSWORD2=
printf "Enter your DS username (e.g. abc12156): "
read -r USERNAME

stty -echo
printf "Enter password: "
read -r PASSWORD
printf "\nRe-enter password: "
read -r PASSWORD2
stty echo
echo

if [ "$PASSWORD" != "$PASSWORD2" ]
then
  echo "Passwords do not match"
  exit 1
fi

#SMB_URI="smb://DS/$USERNAME:$PASSWORD@ce-pcut-srv.chemeng.strath.ac.uk/ce-secure"
SMB_URI="smb://DS/$USERNAME:$PASSWORD@eng-pcut-ss01.eng.strath.ac.uk/ENG_MonoSimplex"

lpadmin -P "$DRIVER_PATH" -v "$SMB_URI" -p "$PRINTER_NAME" -L "$PRINTER_LOCATION" -u allow:all

cupsenable "$PRINTER_NAME"
cupsaccept "$PRINTER_NAME"
lpstat -d "$PRINTER_NAME"

echo "Default printer set to \"$PRINTER_NAME\""
