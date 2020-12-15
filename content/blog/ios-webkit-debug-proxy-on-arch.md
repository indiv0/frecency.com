+++
title = "ios-webkit-debug-proxy on Arch Linux"
date = 2020-12-15
+++

I needed to remotely debug my [colonize](https://colonize.rs) WASM bundle,
as it just showed a blank screen on my iPhone.

To do so, I wanted to use [ios-webkit-debug-proxy](https://github.com/google/ios-webkit-debug-proxy), which would let me connect to the iOS safari
instance from my desktop. I first tried to install the [libimobiledevice](https://www.archlinux.org/packages/extra/x86_64/libimobiledevice/) and [ios-webkit-debug-proxy](https://aur.archlinux.org/packages/ios-webkit-debug-proxy/) packages, but these didn't work.

I ran into issues like:
```
configure: error: Package requirements (libplist >= 1.12) were not met:              
                                            
Package 'libplist', required by 'virtual:world', not found

Consider adjusting the PKG_CONFIG_PATH environment variable if you
installed software in a non-standard prefix. 

Alternatively, you may set the environment variables libplist_CFLAGS
and libplist_LIBS to avoid the need to call pkg-config.
See the pkg-config man page for more details.
```
Despite having `libplist` or `libplist-git` installed.

Instead, I removed all the packages, and installed them all from source.
```
sudo pacman -Rssn libplist libplist-git libimobiledevice-git libimobiledevice usbmuxd
sudo pacman -S libusbmuxd libimobiledevice

git clone https://github.com/libimobiledevice/libimobiledevice
cd libimobiledevice
./autogen.sh
make
sudo make install
cd ..

git clone https://github.com/google/ios-webkit-debug-proxy
cd ios-webkit-debug-proxy
./autogen.sh
make
sudo ldconfig
sudo make install
```
The instructions above were found in [this](https://github.com/google/ios-webkit-debug-proxy/issues/331#issuecomment-626214607) helpful GitHub issue.

After installing the packages, I unplugged and replugged my iPhone to my desktop, and selected `Trust`
on the prompt on the device.
I then verified that my desktop could see the device by running:
```
$ idevice_id -l
********-****************
```

However, attempting to run ios-webkit-debug-proxy gave me a segfault:
```
$ ios_webkit_debug_proxy                           
Listing devices on :9221
Segmentation fault (core dumped)
```
Looks like I got the same error [described here](https://github.com/google/ios-webkit-debug-proxy/issues/331#issuecomment-731138821).
I could find a way around the segfault, so instead I used [remotedebug-ios-webkit-adapter-docker](https://git.netflux.io/rob/remotedebug-ios-webkit-adapter-docker) docker container to run the
service.

I launched the docker container, so that it would service remote targets on port 9000:
```
$ docker run --rm --privileged -p 9000:9000 -v /dev/bus/usb:/dev/bus/usb -v /var/run:/var/run netfluxio/remotedebug-ios-webkit-adapter-docker
```
Then, I opened up Chromium and went to [chrome://inspect](chrome://inspect), where I ensured that
"Discover network targets" was selected. I clicked "Configure..." and added `localhost:9000` as an IP/port pair to the list. My target adapter still didn't appear at this point.
Selecting "Enable port forwarding" did the trick through, and "Target (RemoteDebug iOS Webkit Adapter)" showed up in the "Remote Target" section.

However, selecting "trace" for that target didn't seem to do anything.
I assumed that the problem was due to the container being out of date, so I cloned the repo
of the dockerfile and rebuilt the container myself. Here's the [Dockerfile](https://web.archive.org/web/20201215233744/https://git.netflux.io/rob/remotedebug-ios-webkit-adapter-docker/src/commit/085aca0e0832ad8b9524ce8b2520ad5edc3a6d79/Dockerfile).

After running this container and opening Safari on my device, I was finally able to see
the pages I had open for remote debugging under the "Target" list.

![Remote Target List](/images/2020-12-15-183846_519x318_remote_target.png)