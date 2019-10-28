#!/bin/sh

## SETTINGS
PRINTER_NAME="Open-Plan-Printer"
PRINTER_LOCATION="Open plan, JW403"
#DRIVER_PATH="Ricoh-IM_C4500-PDF-Ricoh.ppd"
DRIVER_PATH="C4500.ppd"

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

if ! pgrep -x cups-browsed > /dev/null 2>&1
then
  echo "cups needs to be running, if you\'re running systemd, do:"
  echo "  sudo systemctl start cups-browsed.service"
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

sudo lpadmin -P "$DRIVER_PATH" -v "$SMB_URI" -p "$PRINTER_NAME" -L "$PRINTER_LOCATION" -u allow:all

cupsenable "$PRINTER_NAME"
cupsaccept "$PRINTER_NAME"
lpstat -d "$PRINTER_NAME"
echo "Default printer set to \"$PRINTER_NAME\""

echo "Setting some good defaults:"
lpoptions -o ColorModel=CMYK
echo "  Color printing: ON"
lpoptions -o PageSize=a4
echo "  Page size: A4"
#lpoptions -o Booklet=off


echo "Printer has been installed."
echo ""
echo "You can print from the command line with 'lpr <filename>',"
echo "or from a graphical application as normal."
echo ""
echo "lpr has some generic printing options (see 'man lpr'),"
echo "'lpoptions -l' for printer specific options."
echo ""
echo "This is what I normally use for printing:"
echo "'lpr -P Open-Plan-Printer <file> -o fit-to-page -o sides=two-sided-long-edge'"
