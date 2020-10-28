+++
title = "Being My Own VPN"
date = 2015-01-21
draft = true
+++
Login to your server

```
ssh root@server
```

Add yourself to the `wheel` group if you are not already a member

```
```

Ensure the wheel group is enabled in sudoers:

```
visudo
```

On your local computer, copy your SSH key to the remote PC:

```
ssh-copy-id USER@HOST
```

[Follow along](http://networkfilter.blogspot.ca/2015/01/be-your-own-vpn-provider-with-openbsd.html)
