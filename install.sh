#!/bin/bash

SERVER = 'https://mobileid.oc.edu'

# INSTALLER SCRIPT FOR MOBIL-ID Reader2

if [ $(id -u) -ne 0 ]; then
	echo "Installer must be run as root."
	echo "Try 'sudo bash $0'"
	exit 1
fi

clear

echo "This script installs software for the"
echo "MOBIL-ID Reader on the Raspberry Pi."
echo "This includes:"
echo "- Creating a new hostname & password"
echo "- Updating the package index files (apt-get update)"
echo "- Installing prerequisite software"
echo "- Installing MOBIL-ID software and examples"
echo "- Configuring boot options"
echo "Run time ~20 minutes. Reboot recommended after install."
echo "EXISTING INSTALLATION, IF ANY, WILL BE OVERWRITTEN."
echo
echo -n "CONTINUE? [Y/n] "
read
if [[ ! "$REPLY" =~ ^(yes|y|Y)$ ]]; then
	echo "Canceled."
	exit 0
fi

clear

# FEATURE PROMPTS ----------------------------------------------------------

echo "To setup a new MOBIL-ID Reader we will need to"
echo "first reset the default hostname and password."
echo
echo "We want to set the hostname to MOBIL-ID-Reader2-XXX"
echo "where XXX is a unique identifier for the device."
echo
echo -n "Enter a unique identifier for this device: "
read ID
echo
echo "Hostname will be changed to MOBIL-ID-Reader2-"$ID

echo
echo "Now lets change the default password (raspberry)."
sudo passwd pi

echo
echo "Done."
echo
read -n 1 -s -r -p "Press any key to continue."

clear

# START INSTALL ------------------------------------------------------------

echo "Starting installation..."
echo "Updating package index files..."
sudo apt-get update -y

echo "Downloading prerequisites..."
sudo apt install git-all -y
sudo apt-get install python3-pip -y
sudo apt-get install python3-venv -y

echo "Downloading MOBIL-ID Reader software..."
if [ ! -d "/home/pi/MOBIL-ID-Reader2" ] 
then
    sudo rm -r /home/pi/MOBIL-ID-Reader2
fi

cd /home/pi
git clone https://github.com/jacobButton99/MOBIL-ID-Reader2

echo "Setting up virtual environment..."
python3 -m venv /home/pi/MOBIL-ID-Reader2
cd /home/pi/MOBIL-ID-Reader2
source bin/activate

echo "Downloading dependencies..."


sudo apt-get install python3-opencv
sudo apt-get install libqt4-test python3-sip python3-pyqt5 libqtgui4 libjasper-dev libatlas-base-dev -y
pip3 install opencv-contrib-python
sudo modprobe bcm2835-v4l2
pip3 install pyzbar

# CONFIG -------------------------------------------------------------------

echo "Configuring MOBIL-ID software..."
touch /home/pi/MOBIL-ID-Reader2/config.py
sudo sed -i '/SERIAL_NUMBER/d' /home/pi/MOBIL-ID-Reader2/config.py
echo "SERIAL_NUMBER = '"$ID"'" | sudo tee -a /home/pi/MOBIL-ID-Reader2/config.py

echo "Configuring system..."
sudo sed -i 's+ init=/bin/systemd++' /boot/cmdline.txt
sudo sed -i 's+$+ init=/bin/systemd+' /boot/cmdline.txt

echo "Setting up USB Gadget..."
sudo sed -i '/dtoverlay=dwc2/d' /boot/config.txt
sudo sed -i '/dwc2/d' /etc/modules
sudo sed -i '/libcomposite/d' /etc/modules
echo "dtoverlay=dwc2" | sudo tee -a /boot/config.txt
echo "dwc2" | sudo tee -a /etc/modules
sudo echo "libcomposite" | sudo tee -a /etc/modules

echo "Creating USB Keyboard Service..."
sudo touch /usr/bin/mobil_id_usb
sudo chmod +x /usr/bin/mobil_id_usb

sudo sed -i '/mobil_id_usb/d' /etc/rc.local
sudo sed -i '19 a /usr/bin/mobil_id_usb # libcomposite configuration' /etc/rc.local

sudo tee -a /usr/bin/mobil_id_usb > /dev/null << EOT
#!/bin/bash
cd /sys/kernel/config/usb_gadget/
mkdir -p mobil_id
cd mobil_id
echo 0x1d6b > idVendor # Linux Foundation
echo 0x0104 > idProduct # Multifunction Composite Gadget
echo 0x0100 > bcdDevice # v1.0.0
echo 0x0200 > bcdUSB # USB2
mkdir -p strings/0x409
echo "$ID" > strings/0x409/serialnumber
echo "Oklahoma Christian University" > strings/0x409/manufacturer
echo "MOBIL-ID Reader" > strings/0x409/product
mkdir -p configs/c.1/strings/0x409
echo "Config 1: ECM network" > configs/c.1/strings/0x409/configuration
echo 250 > configs/c.1/MaxPower
# Add functions here
mkdir -p functions/hid.usb0
echo 1 > functions/hid.usb0/protocol
echo 1 > functions/hid.usb0/subclass
echo 8 > functions/hid.usb0/report_length
echo -ne \\\x05\\\x01\\\x09\\\x06\\\xa1\\\x01\\\x05\\\x07\\\x19\\\xe0\\\x29\\\xe7\\\x15\\\x00\\\x25\\\x01\\\x75\\\x01\\\x95\\\x08\\\x81\\\x02\\\x95\\\x01\\\x75\\\x08\\\x81\\\x03\\\x95\\\x05\\\x75\\\x01\\\x05\\\x08\\\x19\\\x01\\\x29\\\x05\\\x91\\\x02\\\x95\\\x01\\\x75\\\x03\\\x91\\\x03\\\x95\\\x06\\\x75\\\x08\\\x15\\\x00\\\x25\\\x65\\\x05\\\x07\\\x19\\\x00\\\x29\\\x65\\\x81\\\x00\\\xc0 > functions/hid.usb0/report_desc
ln -s functions/hid.usb0 configs/c.1/
# End functions
ls /sys/class/udc > UDC
EOT


# PROMPT FOR REBOOT --------------------------------------------------------
echo
echo "Done."
echo
echo "Install will take effect on next boot."
echo
echo "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
echo "Upon reboot, ssh into the Raspberry Pi using:"
echo
echo "ssh pi@MOBIL-ID-Reader2-"$ID".local"
echo
echo "...and your new password."
echo "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
echo
echo -n "REBOOT NOW? [Y/n] "
read
if [[ ! "$REPLY" =~ ^(yes|y|Y)$ ]]; then
	echo "Exiting without reboot."
	exit 0
fi
echo "Reboot started..."

reboot
sleep infinity