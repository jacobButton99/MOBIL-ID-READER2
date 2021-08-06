# MOBIL-ID Reader2


## What is MOBIL-ID?
#### A Python web service & embedded reader for Apple PassKit

The MOBIL-ID project is an engineering systems capstone project for Oklahoma Christian University. The team’s mission statement is to create a mobile platform front-end to Oklahoma Christian University’s user management system. Students and Faculty will use their mobile ID to gain chapel attendance, enter the university cafeteria, and pay using Eagle Bucks.

### MOBIL-ID Reader2
The MOBIL-ID Reader2 is a slave device responsible for scanning MOBIL-ID passes. It captures and encrypted QR data from a scanned pass, decrypts it and sends it along to OC's transactional system

### The MOBIL-ID2 Team
* Jacob Button - Electrical/Software Engineer
* Kyla Tarpey - Electrical Engineer


### Acknowledgments
- Steve Maher - Mentor
- Luke Hartman - Customer
- Peyton Chenault - System Integrator

---

## Hardware Setup
Just unlock the camera connectors on the camera and pi ends, stick the ribbon. You will then need to assemble the case around it, but not untill software setup is complete because there is no hole for the sd card.

## Software Setup
### Prerequisites
* [Install Raspberry Pi OS LITE using Raspberry Pi Imager](https://www.raspberrypi.org/software/)
* [Headless Raspberry Pi Setup](https://pimylifeup.com/headless-raspberry-pi-setup/)

### Raspberry Pi First Boot
Before we start, check that you have:

* A clean installation of Raspberry Pi OS LITE on a microSD card
* Added the `ssh` file to the `/boot` directory
* Added the `wpa_supplicant.conf` file to the `/boot` directory

**You will not be able to continue without completing these steps. Use the links above to properly allow headless setup.**

If you are confident you have completed the steps above, put the microSD card into the Raspberry Pi and plug the USB power cable in.
You should hear a startup beep and the LED on the MOBIL-ID Reader Board should be magenta. If one of theses did not happen, you will need to troubleshoot your hardware setup.

### Login to Raspberry Pi Remotely
In macOS/Linux, open Terminal and enter:
```sh
ssh pi@raspberrypi.local
```
The default password is `raspberry`.

### Run the MOBIL-ID Reader Installer
Once you are logged into as user `pi` run:
``` sh
curl https://raw.githubusercontent.com/jacobButton99/MOBIL-ID-Reader2/main/install.sh > install.sh && sudo bash install.sh
```
This script installs software for the MOBIL-ID Reader on the Raspberry Pi.

This includes:

* Creating a new hostname & password (hostname actually doesnt change, a bug due to time constraints)
* Updating the package index files (apt-get update)
* Installing prerequisite software
* Installing MOBIL-ID software and examples
* Configuring boot options

**Run time > 20 minutes. Reboot recommended after install. EXISTING INSTALLATION, IF ANY, WILL BE OVERWRITTEN.**

> The MOBIL-ID Reader will not work correctly until the system has been rebooted.

You will need to put a reference to opening the virtual environment /MOBIL-ID-Reader2/ and MOBIL-ID-Reader2/main.py in the rc.local file for main.py to run on start. This could be put in the installer, idk how.


### Subsystem testing
There are 3 subsytem test on the pi. You will need to be sshed in to manually run these. They are all located in /MOBIL-ID-Reader2/

* qr_decode.py - tests the qrcode/pyzbar side of things - on success prints "12345678"
* encryption.py - tests the cryptography side of things - on success prints "12345678"
* Configuring boot options - tests the keyboard side of things - on success provides a keyboard input of "12345678"

### Notes on effectiveness

* The first limitation is that it does not recognize a qr code as fast as the mobil-id Reader v1. This is a limitation of the camera. I think there are probably some creative solutions to speed this up though
* Secondly in its current state you can use the same qr code unlimited times. The only way to keep the reader offline and prevent this would be to somehow manipulate the key to not reconize the same encrypted code twice. There may be a way to do this but I dont know how and am limited by time.

* Onto the Pros, it is half the price of Mobil-ID-Reader v1
* Not relying on the network connection also makes it more durable and less prone to errors in my view

### Recommended Upgrades

On the slower detection of an qr, the main issue is that the camera is slow to focus. Since the opencv library is already utilized a possible improvement might be to look for movement, wait a second to focus and then take the picture. Also a reader, holder configuration that would have the student set the phone underneath the reader at an appropriate distance would let the camera focus easier and would improve things

On the issue of being able to use the same qr code multiple times, manipulating the key to not reconize the same id twice is a potential fix. Also having the server generating a new key and sending it out to the readers every morning is also a potential fix, since the key would change all previous qr codes would be unreadable. This would obviously require the reader being connected to the network though.