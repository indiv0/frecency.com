+++
title = "Development VM on QEMU Arch Linux Host"
date = 2020-11-03
+++

To isolate my development dependencies from my host system, I want to run a VM
locally.
I'd like to use QEMU for virtualization as it's simple and performant.

I install `qemu-headless` so that I have QEMU present without the GUI. I
installed `edk2-ovmf` to [enable UEFI support for virtual machines](https://wiki.archlinux.org/index.php/Unified_Extensible_Firmware_Interface#OVMF_for_virtual_machines).
```sh
sudo pacman -S qemu-headless edk2-ovmf
```

I create an image to use as the backing storage for the VM. I use raw
as the format for performance and because I don't care about snapshot
functionality right now. I preallocate the image to ensure I don't
run out of space on my host machine unexpectedly in the future. Preallocating
should also give better performance, but I haven't tested this.
```sh
qemu-img create -f raw -o preallocation=full ~/var/qemu/work-development.img 40G
```

To install the OS (Arch Linux) I
[download the ISO](https://www.archlinux.org/download/). Then, I make a copy of
the non-volatile variable store for the virtual machine. Then, I launch QEMU
with the ISO and backing storage attached.
```sh
cp /usr/share/edk2-ovmf/x64/OVMF_VARS.fd ~/var/qemu/work-development-uefi-vars.fd
qemu-system-x86_64 -cdrom ~/Downloads/archlinux-2020.11.01-x86_64.iso -boot order=d\
    -drive if=virtio,file=$HOME/var/qemu/work-development.img,format=raw\
    -drive if=pflash,format=raw,readonly,file=/usr/share/edk2-ovmf/x64/OVMF_CODE.fd\
    -drive if=pflash,format=raw,file=$HOME/var/qemu/work-development-uefi-vars.fd
```
Note that we use `if=virtio` for the backing image because we want to use the
paravirtualized virtio drivers, which provide [better performance and overhead](https://wiki.archlinux.org/index.php/QEMU#Installing_virtio_drivers).
Note the `$HOME` in place of `~` above. This is because for some reason QEMU
gives the following error when using `~` with a `-drive` specified with an
`-if=...` directive:
```
Could not open '~/var/qemu/work-development-uefi-vars.fd': No such file or directory
```
QEMU helpfully starts a local VNC server for us to connect to.
```
VNC server running on ::1:5900
```

I installed `tigervnc` and connected to the VNC server.
```sh
sudo pacman -S tigervnc
vncviewer :5900
```

It turned out that the system had too little memory to boot, so I needed to re-launch it with more memory.
![Kernel Panic: System is deadlocked on memory](/images/2020-11-03-152643_720x402_kernel_panic.png)
```sh
qemu-system-x86_64 -cdrom ~/Downloads/archlinux-2020.11.01-x86_64.iso -boot order=d\
    -drive if=virtio,file=$HOME/var/qemu/work-development.img,format=raw\
    -drive if=pflash,format=raw,readonly,file=/usr/share/edk2-ovmf/x64/OVMF_CODE.fd\
    -drive if=pflash,format=raw,file=$HOME/var/qemu/work-development-uefi-vars.fd\
    -m 2G
vncviewer :5900
```

If you enter fullscreen mode in VNC and have trouble exiting, press `F8` to
open the context menu. You should be able to disable fullscreen from there.

Once the machine booted, I verified that my network interface was listed and enabled.
```sh
ip link
```
I tested that I had a working internet connection.
```sh
ping archlinux.org
```
I ensured that the EFI vars were available:
```sh
efivar -l
```
I updated the system clock.
```sh
timedatectl set-ntp true
```
I partitioned the disk after identifying it with `lsblk`.
I didn't want to get fancy, so I chose `gpt` as the label type and created two
partitions: boot and root. The boot partition was `512M` in size with
partition type code `ef00` (EFI system partition) and label `boot` and the root
partition took up the remainder of the free space (~39.5G) with partition
type code `8600` (Linux filesystem) and label `root`.
I didn't create a swap partition.
```sh
cgdisk /dev/vda
```
I formatted the newly created partitions.
```sh
mkfs.fat -F32 /dev/vda1
mkfs.ext4 /dev/vda2
```
I mounted the root volume to `/mnt` and the boot volume to `/mnt/boot`.
```sh
mount /dev/vda2 /mnt
mkdir /mnt/boot
mount /dev/vda1 /mnt/boot
```
I used reflector to select the fastest, most recently updated mirrors.
```sh
pacman -Sy reflector
reflector --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
```
I used pacstrap to install the base system.
```sh
pacstrap /mnt base base-devel linux linux-firmware vim intel-ucode
```
I generated an fstab file.
```sh
genfstab -U /mnt >> /mnt/etc/fstab
```
I changed root into the new system.
```sh
arch-chroot /mnt
```
Within the chroot, I selected my time zone and ran hwclock to generate `/etc/adjtime`.
```sh
ln -sf /usr/share/zoneinfo/Canada/Eastern /etc/localtime
hwclock --systohc
```
I edited my `/etc/locale.gen` and uncommented `en_CA.UTF-8 UTF-8` to enable my
locale. I then generated the locales.
```sh
vim /etc/locale.gen
locale-gen
```
I created the locale.conf file and set the `LANG` variable.
```sh
echo "LANG=en_CA.UTF-8" > /etc/locale.conf
```
I created a hostname file and added matching entries to hosts.
```sh
echo hephaestus > /etc/hostname
echo "127.0.1.1       hephaestus.olympus.hax.rs hephaestus" > /etc/hosts
```
I set the root password:
```sh
passwd
```
I installed systemd-boot as my bootloader:
```sh
bootctl install
```
I configured systemd-boot by creating a `/boot/loader/entries/arch.conf` file
with the contents:
```
title   Arch Linux
linux   /vmlinuz-linux
initrd  /intel-ucode.img
initrd  /initramfs-linux.img
options root="UUID=..." rw
```
I also created a `/boot/loader/loader.conf` file with the contents:
```
default      arch.conf
console-mode max
```
I left the chroot, unmounted the partitions, and rebooted the machine.
```sh
exit
umount -R /mnt
reboot
```
I confirmed that I successfully booted into my new Arch Linux install, then I shutdown the VM.
I wanted to add some performance improvements. First, I had to switch from using DHCP on my interface
to a DHCP created on a bridge. I removed my `/etc/systemd/network/20-wired.network` file and replaced it with
the files `/etc/systemd/network/10-br0-interface.netdev`:
```ini
[NetDev]
Name=br0
Kind=bridge
```
`/etc/systemd/network/20-br0-bind.network`:
```ini
[Match]
Name=enp0s31f6

[Network]
Bridge=br0
```
and `/etc/systemd/network/30-br0-bridge.network`:
```ini
[Match]
Name=br0

[Network]
DHCP=ipv4

[DHCP]
UseDomains=true
```
I restarted `systemd-networkd` and made sure I still had internet access:
```sh
sudo systemctl restart systemd-networkd
ping archlinux.org
```
I wanted to use the [qemu-bridge-helper](https://wiki.archlinux.org/index.php/QEMU#Bridged_networking_using_qemu-bridge-helper)
to create a tap device for me, so that my guest could talk to the external network directly.
To do so, I added an ACL file telling QEMU that the `br0` interface should be whitelisted:
```sh
sudo mkdir /etc/qemu
echo "allow br0" | sudo tee -a /etc/qemu/bridge.conf
sudo chown root:kvm /etc/qemu/bridge.conf
sudo chmod 0640 /etc/qemu/bridge.conf
```
Then, I added my user to the `kvm` group:
```sh
sudo usermod -a -G kvm indiv0
```
Now, QEMU would automatically configure the bridge for me if I launched it
with the arguments `-net nic -net bridge,br=br0` but the guest would not be
able to connect to the network, because the firewall was still blocking all
traffic. To solve this, I configured iptables to allow all traffic to be
forwarded across the bridge:
```sh
sudo iptables -I FORWARD -m physdev --physdev-is-bridged -j ACCEPT
```
Next, I started my VM with [extra options](https://wiki.archlinux.org/index.php/QEMU#Improve_virtual_machine_performance) for [improved performance](https://heiko-sieger.info/tuning-vm-disk-performance/).
- enabled KVM for hardware acceleration
- used `-cpu host` to make QEMU emulate the host's exact CPU
- used `-smp $(nproc)` to provide the VM access to all available cores
- assigned the VM half my RAM with `-m 16G`
- enabled virtio drivers for the network device with `-net nic,model=virtio`
- disabled the cache for the raw disk image
- used native Linux AIO instead of userspace threads
- using tap devices for networking
- enabling the `virtio-balloon` device for potential memory reclamation
```sh
qemu-system-x86_64\
    -enable-kvm\
    -cpu host\
    -smp $(nproc)\
    -device virtio-balloon\
    -net nic,model=virtio -net bridge,br=br0\
    -drive if=virtio,file=$HOME/var/qemu/work-development.img,format=raw,aio=native,cache=none\
    -drive if=pflash,format=raw,readonly,file=/usr/share/edk2-ovmf/x64/OVMF_CODE.fd\
    -drive if=pflash,format=raw,file=$HOME/var/qemu/work-development-uefi-vars.fd\
    -m 16G
```
Inside the VM I added a `/etc/systemd/network/20-wired.network` to
connect the VM to my external network:
```ini
[Match]
Name=ens*

[Network]
DHCP=yes

[DHCP]
UseDomains=true
```
Then I enabled and started the `systemd-networkd` and `systemd-resolved`
services:
```sh
systemctl start systemd-networkd
systemctl enable systemd-networkd
systemctl start systemd-resolved
systemctl enable systemd-resolved
```
I also needed to replace the default `resolv.conf` with the systemd one.
```sh
rm /etc/resolv.conf
ln -s /usr/lib/systemd/resolv.conf /etc/resolv.conf
```
I added my user to the machine:
```sh
useradd -m npekin
passwd npekin
```
Add the new user to the sudoers:
```sh
EDITOR=vim visudo
```
I installed openssh and enabled the sshd service so that I could connect to the
VM over SSH instead of over VNC:
```sh
pacman -S openssh
systemctl start sshd
systemctl enable sshd
```
From the host I connected to the VM via SSH and copied over my key:
```sh
ssh-copy-id npekin@hephaestus
ssh npekin@hephaestus
```
I generated a new SSH key on the VM and uploaded it to my GitHub account.
I then installed git and cloned my dotfiles repo.
Using my dotfiles bootstrap script, I installed the necessary packages onto
the machine.
```sh
ssh-keygen -t ed25519
sudo pacman -S git
git clone git@github.com:indiv0/dotfiles etc
cd etc
make
./bootstrap.sh
```
I modified the `/etc/ssh/sshd_config` to allow X11 forwarding by setting
`X11Forwarding` to yes:
```sh
sudo vim /etc/ssh/sshd_config
sudo systemctl restart sshd
```
This allows to me SSH into the VM with X11 forwarding enabled and launch
graphical applications:
```sh
ssh -X hephaestus
firefox
```
