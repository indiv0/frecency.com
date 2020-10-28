+++
title = "Configuring HSPA+ on the Samsung Galaxy S5 SG-G900H"
date = 2014-06-19
+++
I recently replaced my Samsung GS4 with the Samsung Galaxy S5, because my GS4's microphone started to sound horrible and because the darn thing refused to charge (the port was broken).

So I decided to replace it. Being a die-hard Android user, I got the Galaxy S5.
It worked great for me on the Rogers network, but when I switched over to Fido after my contract expired, I noticed that I had no mobile data connection.
I looked all around the internet on how to connect to Fido's LTE network, but it turns out my (international) **GS5 SG-G900H does not support LTE**.
The Exynos chip does not have the necessary hardware to connect.

Fido's LTE SIM automatically provides an LTE APN setting, but as I needed HSPA+, this wouldn't work.

To fix it, I performed the following steps:

* Open **Settings**
* Under the **Network Connections** settings group, open **More networks**
* Open **Mobile Networks**
* Ensure **Network Mode** is set to **WCDMA/GSM**
* Open **Access Point Names**
* Add a new APN with the following settings:
    * Name: **Fido HSPA+** (this setting is optional)
    * APN: **fido-core-appl1.apn**
    * MMSC: **http://mms.fido.ca**
    * Multimedia message proxy: **205.151.11.13**
    * Multimedia message port: **80**
    * MCC: **302**
    * MNC: **370**
    * APN type: **default,supl,mms**
    * Leave the remaining settings either unset or with their default value
* **Reboot** your phone

After this, I managed to connect to HSPA+ on Fido with a paltry 1.95/0.78 Mbps connection.
Time to wait for this phone to break so I can upgrade to LTE :)

Hope that helps!
