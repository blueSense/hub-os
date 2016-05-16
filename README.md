# The BlueSenseNetworks operating system image

TODO: provide a vagrant file to circumvent manual settings, described below

## How to use
* build image as specified below (or download artifact from teamcity)
* flash image to SD card
* power on RPI, connect to network, and wait for the application to be downloaded and started (might take a while for the first time as it is downloading base image as well)
* the device should be working

## Overview
TODO: describe how it works
The image is archlinux with some customizations.

## Must do on the host OS prior to building:

* https://hblok.net/blog/posts/2014/02/06/chroot-to-arm/

## How to build
In order to build the image execute:
```
sudo make USER_NAME=username USER_PASSWORD=password USER_SSH_KEY=key rpi2
```
and the image will be created in the "/build" folder.
Note: the USER_NAME and USER_SSH_KEY are mandatory, while the password can be ommited. The password is only used when connecting directly to the RPI (i.e. not over SSH)

## Connect to wifi
In order to have the device connect to wifi, connect to the device and execute:
```
wpa_passphrase SSID pass > /etc/wpa_supplicant/wpa_supplicant-wlan0.conf
```
and reboot the device.
