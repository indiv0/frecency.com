+++
title = "Mac OS X as a Guest in VMWare on Arch Linux"
date = 2014-01-31
+++
I needed to package my [launchcraft](https://github.com/indiv0/launchcraft/) script for OS X.

Initially, Znork volunteered to help, but I needed a solution wherein I could do it without reliance on others, allowing me to stick to my non-existant release cycle.

o I decided to virtualize OS X on Linux so that I could build it inside the VM.

After some unsuccessful attempts with Virtualbox, I decided to go ahead and try VMware.

I went to the VMware website, and got the latest Linux bundle from their [releases](https://my.vmware.com/web/vmware/details?productId=362&amp;downloadGroup=WKST-1001-LX) page.

I made the bundle executable with `chmod +x VMware-Workstation-Full-10.0.1-1379776.x86_64.bundle`, then ran it with `./VMware-Workstation-Full-10.0.1-1379776.x86_64.bundle`.

After finishing the setup, I installed the necessary VMware patch from the Arch Linux AUR: `yaourt -S vmware-patch`.

I then had to modify the vmware initialization script `/etc/init.d/vmware` as per the [instructions](https://wiki.archlinux.org/index.php/VMware#vmci.2Fvsock_modules_not_loading_automatically) on the Arch Wiki as the `vcpi` module was not being loaded automatically.

This is done by changing `vmwareLoadModule "$mod"` to `vmwareLoadModule "$vmci"` in `vmwareStartVmci()` and `vmwareStopVmci()`. You must also change `vmwareLoadModule "$mod"` to `vmwareLoadModule "$vsock"` in `vmwareStartVsock()` and `vmwareStopVsock()`.

I then obtained the official VMware pre-built OS X Mavericks image, with the necessary VMware unlocker for Linux.

I `chmod`ed the unlocker, and ran it with administrator
privileges.

I then ran VMware, imported the downloaded VM image, and ran
it.

Yay OSX!
