+++
title = "My FreeNAS Build"
date = 2014-08-21
draft = true
+++
This is my post documenting my FreeNAS build.

## Hardware

TBD

## OS

## Memtest86+

* Test RAM with Memtest86+ following [these](http://forum.canardpc.com/threads/28875-Linux-HOWTO-Boot-Memtest-on-USB-Drive) instructions.

## FreeNAS
### Installation

* [Download](http://www.freenas.org/download-freenas-release.html) the latest FreeNAS release USB image.
* Extract the downloaded file with `xzcat FreeNAS-9.2.1.7-RELEASE-x64.img.xz | sudo dd of=/dev/sdd bs=64k`
* Plug the USB into the NAS and boot with it.
* Let FreeNAS set itself up. The first boot takes a LONG
    time.
* Use the IP address provided at the end of the installation to connect to the FreeNAS web interface.

### Users

* Create a user via "Account > User > Add User", with the primary group as `wheel`.

### Volumes

* Create a ZFS volume.

### CIFS

* Under "Services", enable `CIFS`.
* On the UNIX client, TBD

### Plex

* Click "Plugins" at the top of the menu.
* Click "plexmediaserver"
* Click "Install"

### TODO

* Set up static DNS
* Set up plexmediaserver
* Set up UPnP
* Set up UPS
* Set up regular ZFS scrubs
* Set up S.M.A.R.T.

