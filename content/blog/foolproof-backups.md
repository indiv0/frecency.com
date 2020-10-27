+++
title = "Foolproof Backups"
date = 2020-10-27
draft = true
+++

First, I need to get all my files together for a fresh backup. Currently
things are spread between a few services and devices. To start with, I copy
data from all my local disk & USB drives onto a single one. Then, I copy all
my previous disparate backups from my [rsync.net](https://rsync.net) (great
service, BTW) host to my local machine. To do so, I first copy my SSH key to
the remote host:
```sh
scp ~/.ssh/id_ed25519.pub 11111@ch-s111.rsync.net:.ssh/
```

I use lftp in parallel mirror mode as scp would copy each file sequentially,
and tar is not available on the remote host to create a single archive for
transfer. I had a lot of small files on the server, so I used `--parallel=20`
to download 20 files in parallel. If I had a lot of large files, I would've
wanted to download them with segmentation, so I would've used some combination
of `--parallel` and `--use-pget-n=10`. Note that the total number of
connections is proportional to both options, so if you use
`--parallel=10 --use-pget-n=10` you'll open 100 connections, which could
potentially get you in trouble or exhaust the number of available connections
on the server. The below command will mirror the remote directory
(for example, `/data1/home/11111` in my case) to your current local directory
(for example, `/home/indiv0/usr/2020-10-27_rsync_net_backup` in my case).
```sh
lftp -e "mirror --verbose --continue --parallel=20" sftp://11111@ch-s111.rsync.net
```

Next, I need to download my Tarsnap backups, so I install tarsnap and use it
to clone my remote backups to my local drive. I don't have the cache locally
so I need to fetch it as well. Clone only the latest archives.
```sh
sudo pacman -S tarsnap
tarsnap --fsck --keyfile ~/tmp/lifeboat/tarsnap.key --cachedir .cache
tarsnap --keyfile ~/tmp/lifeboat/tarsnap.key --cachedir .cache -x -f data-20160305-001733 "*"
tarsnap --keyfile ~/tmp/lifeboat/tarsnap.key --cachedir .cache -x -f doc-20160305-001601
tarsnap --keyfile ~/tmp/lifeboat/tarsnap.key --cachedir .cache -x -f mail-20160305-001711
...
```

First, install `borg`.
```sh
sudo pacman -S borg
```

# Remove

I want to configure a backup system that ensures I can be confident about never
losing data.

The system I envision:
- provides local snapshots (for quick recovery)
- copies to an offsite location automatically
- encrypts data locally, preventing remote snooping
- allows me to easily copy to an external device for
  [3-2-1 backups](https://www.backblaze.com/blog/the-3-2-1-backup-strategy/)

I frequently use 5 devices:
- my desktop
- my laptop
- my phone
- my NAS
- cloud VMs (primarily AWS & Digitalocean)

I want all 5 of these devices to be continuously backed up, so that if any of
them dies I don't lose any data and I can just get a new device to replace it.

I'm a fan of privacy, so I want my backups to be unreadable to prying eyes.
This means relying on encryption at rest and in transit. I'm also a practical
person, which means I don't want to pay through the nose for data transfer
charges. This means that the backups must be deduplicated and compressed
allowing for transfers of only deltas.

[BorgBackup](https://borgbackup.readthedocs.io/en/stable/) covers the encrypted,
compressed, deduplicated, and snapshot points.

Borg does require that the target of your backup be running Borg, which means
that unless I keep a local copy of my Borg repo and _then_ rsync that over, I
need an offsite provider that lets me run Borg. Syncing my backup to an external
HDD also provides a challenge, because unless I keep a local copy of my Borg
repo I need to backup to the cloud, then sync that back to my external HDD. Not
unworkable, but not great either.

Previous attempts at backups led me to [https://rsync.net](https://rsync.net).
Their service is rock solid and they also provide a special discount for Borg
users, although it does cost your the ability to make ZFS snapshots.
Services like Backblaze B2 might be cheaper for bulk storage, but unless I'm
willing to give up Borg (or concede to keeping a local Borg repo), I can't use
those.
I'm more than happy to stick with rsync.net.

Configuring Borg to backup my NAS files periodically to rsync.net is easy (just
a cron job), but the greater difficulty lies with my other devices.
My NAS is not always online, but it _usually_ is. I also travel on occasion,
which means I can't rely on connectivity to it.
I could still use the NAS as the target of the backups and from there copy
everything over to rsync.net, but I'm more confident that rsync.net will remain
available than my NAS will, so I'm going to target that.
This means that each device will need to backup to rsync.net independently.

The problematic devices are my Windows 10 partition on my desktop (I dual boot)
and my phone (Android).

There's experimental support for Borg on WSL, which I'll
try, but I think I'm primarily just going to either save my Windows documents to
my NAS or setup and automatic sync from my Windows PC to the NAS.
It's unlikely I'll ever be in a situation where I'm using my Windows PC but I
don't have access to my NAS, for an extended period of time.

As for my phone, Borg can be run via Termux, which also seems iffy, but I'll
give that a shot as well. If it requires root permissions I might need to think
of something else.

In summary, my requirements are:
- backups are encrypted at rest (at least on the external HDD and offsite
  storage)
- backups are encrypted in transit
- backups are snapshottable
- backups are deduplicated
- backups are accessible if my NAS is down
- backups are accessible if the cloud is down
- backups are accessible if external HDD is down
- backups are never more than two weeks old
- backups occur automatically
- backups occur periodically (at least once a day)
- one-line command to sync my NAS and/or cloud backup to my external HDD
- desktop, laptop, phone, NAS, and cloud VM files are backed up
- offsite storage is relatively cheap

To avoid each device interfering with each other, and to allow for parallel
backups, I'm going to have each device backup to a separate repo. That'll result
in some excess use of space if I ever move files from one device to another but
it's a price I'm willing to pay.

# Process

First, I created an iocage jail called `borg02` on my FreeNAS server.
I brought the jail up, and it got the IP address `172.16.1.63` via DHCP.

I SSHed in to my FreeNAS server (`172.16.1.89`) and installed Borg:

```
indiv0@sputnik~ ssh root@172.16.1.89 -p 21598
root@freenas# iocage console borg02
root@borg02# pkg update
root@borg02# pkg search borg
py37-borgbackup-1.1.10         Deduplicating backup program
py37-borgmatic-1.3.26_1        Wrapper script for Borg backup software
```

I installed the Borg package:

```
root@borg02# pkg install py37-borgbackup-1.1.10
```

In the FreeNAS UI:
1. Stop the jail in the UI so that we can edit the mount points.
2. Use "Add storage" to add two mount points.

The first mount point is to make our files accessible in the jail.

Set source to `/mnt/tank/storage`.

Set destination to `/mnt/storage`.

Set as read-only.

We want Borg to read from this mount, but we don't want it potentially
destroying data.

The second mount point is a destination for our backup data.
I used a dataset called `/mnt/tank/backups` for this purpose.

Set source to `/mnt/tank/backups`.

Set destination to `/mnt/backups`.

Do not set as read-only.
Borg needs to be able to write to this directory to store your backups.

# Allow SSH into FreeNAS Jail

In the FreeNAS UI, start the `borg02` jail.

In the FreeNAS CLI, enter the `borg02` jail:

```
iocage console borg02
```

In the `borg02` jail, edit `rc.conf`:

```
# vi /etc/rc.conf
sshd_enable="YES"
```

**NOTE**: If `vi` doesn't display the file correctly, run `set term=xterm`
first.
This is a known bug in FreeNAS 11.2.

In the `borg02` jail, edit `sshd_config`:

```
# vi /etc/ssh/sshd_config
PermitRootLogin yes
```

Start the SSHD service:

```
# service sshd start
```

Set a password for the `root` jail user, as it does not have one by default.

```
# passwd
```

# Setup Passwordless SSH to Rsync.net

In your `borg02` jail, create an SSH key pair:

```
ssh-keygen -t ed25519
```

**NOTE**: I did not use a passphrase for the key pair so that backup scripts
could run automatically.

Copy your `authorized_keys` file from rsync.net:

```
# scp 17803@ch-s011.rsync.net:.ssh/authorized_keys .
```

Add your public key to the `authorized_keys` file and upload it to rsync.net:

```
# cat ~/.ssh/id_ed25519.pub >> authorized_keys
# scp authorized_keys 17803@ch-s011.rsync.net:.ssh/
```

Verify that you can log in without a password or passphrase:
```
# ssh 17803@ch-s011.rsync.net
```

# Create a Borg Repository

In the `borg02` jail, create a local Borg repository:

```
# borg init --encryption=repokey /mnt/backups/borg-repo-atlas
```

Initialize the remote Borg repository:

```
# borg --remote-path=borg1 init --encryption=repokey 17803@ch-s011.rsync.net:borg-repo-atlas
```

**NOTE**: Do not use the same passphrase for both repos. This [makes the crypto
unsecure](https://github.com/borgbackup/borg/issues/1767#issuecomment-256623279).

**NOTE**: Use `--remote-path=borg1` to use Borg v1 on rsync.net instead of Borg
v0, which is the default.

Borg supports multiple clients backing up to the same repo, but it results in
performance problems (because client caches become out-dated) and it means
having to deal with potential locks on the archive.

For simpler backups, we use one repo per client.
For now, I just want to backup my NAS, so I just made one repo.

# Write Backup Script

Write a script to perform the backup.
For example:

```sh
#!/bin/sh
```

Make the script executable:

```
chmod +x backup.sh
```

Verify that the script works by running it:

```
./backup.sh
```

# Set the Borg Passphrase In Shell

If you want to run Borg manually, and you don't want to be prompted for the the
passphrase, you should set the `BORG_PASSPHRASE` environment variable.

Modify `.cshrc`:

```
# vi .cshrc
setenv BORG_PASSPHRASE yourborgpassphrase
```

# Use Cron to Backup Daily

Use cron to schedule the script to run daily.
Open crontab for editing:

```
crontab -e
```

We want to schedule the backup to run at 5 minutes past midnight, every day.
We want to use `-x` to get `sh` to log debug info (e.g. for each executed
command), and use `>> /root/backup.log` to keep a log of the backups in case you
want to debug them or verify they are working.

```
0 5 * * * sh -x /root/backup.sh >> /root/backup.log
```

# Deduplicate Files Between NAS & Other Machines

Find the name of the exported FreeNAS NFS mount, on your desktop:

```
showmount -e freenas
```

Mount the NFS directory, omitting the server's NFS export root:

```
# pacman -S nfs-utils
# mkdir /mnt/storage
# mount -t nfs freenas:/mnt/tank/storage /mnt/storage
```

# TODO:

Export the local and remote Borg repo keys and make them available in multiple formats:

```
borg key export /mnt/backups/borg-repo-atlas borg-repo-atlas-local.key
borg key export 17803@ch-s011.rsync.net:borg-repo-atlas borg-repo-atlas-remote.key
```

Export the remote Borg repo key and make it available in multiple formats:
```
???
```

Write down and memorize the Borg repo key passphrases:

```
pass borg/repo-atlas-passphrase-local
pass borg/repo-atlas-passphrase-remote
```
