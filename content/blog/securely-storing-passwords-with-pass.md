+++
title = "Securely Storing Passwords with Pass"
date = 2014-02-25
draft = true
+++
So with the recent NSA/PRISM revelations, I decided to store my passwords securely.

This meant removing any passwords I had from "the cloud" - LastPass/Firefox Sync/etc.
Now, just because I removed the passwords from these locations does not mean they are insecure.
In fact, LastPass appears to be [doing everything correctly](https://news.ycombinator.com/item?id=2526868) from a security standpoint.
However, with the possibility of anything being backdoored, this is merely a "don't trust anyone" scenario.

I'm also doing this because I have **very many** passwords, and it's gotten to the point where I simply can't remember all of them.
I've tried having KeePass and other software remember it for me, but I just couldn't get used to using it on a daily basis.

I recently found out about [`pass`](http://www.zx2c4.com/projects/password-store/), software that labels itself "the standard unix password manager".
`pass` stores passwords in a directory called `~/.password-store` in an encrypted format.
This means that my passwords would be stored locally, be encrypted, and be easily moveable.

Before I began using it, however, I had to generate a GnuPG key with which to encrypt the password-store that `pass` creates.

First, I installed gnupg:

```
pacman -S gnupg
```

Then, I had to configure `~/.gnupg/gpg.conf`.

After it was configured, I generated a key using:

```
gpg --gen-key
```

I chose RSA (sign-only) and RSA (encrypt only) as the key types that I wanted.
At first glance, this seems opposed to my goal as the RSA has been part of the NSA scandal with a revealed $10M USD deal between the NSA and RSA, *allegedly* for the implementation of [Dual\_EC\_DRBG](https://en.wikipedia.org/wiki/Dual_EC_DRBG) as the default PRNG for RSA's BSAFE, etc.
However, GnuPG does not use BSAFE (as BSAFE is commerical software and GnuPG is GPL).
Instead, GnuPG relies on `/dev/random`, which is based on [RFC 1750](http://www.ietf.org/rfc/rfc1750.txt).

Next, I chose a 4096 bit keysize, for greater security.

For an intial test period, I decided to not let my key expire.

The rest of the options were fairly straightforward.

Once the configuration was completed and I'd entered my passphrase, I began writing this and setting up my DigitalOcean Dokku droplet to provide the necessary entropy to generate the key.

After the key was completed, I decided to follow the [instructions](https://alexcabal.com/creating-the-perfect-gpg-keypair/) provided by Alex Cabal help reduce the potential damage of losing my GnuPG keypair is my laptop were to be stolen.

Begin by strengthening the hashing preferences:

```
gpg --edit-key my@email.org
setpref SHA512 SHA384 SHA256 SHA224 AES256 AES192 AES CAST5 ZLIB BZIP2 ZIP Uncompressed
save
```

Then add a new signing key, of type RSA (sign only), with keysize 4096:

```
gpg --edit-key my@email.org
addkey
save
```

Then I created the actual revocation certificate, selecting 1 as the reason for the revocation:

```
gpg --output <my@email.org>.gpg-revocation-certificate --gen-revoke my@email.org
```

Export the keypair so that it can be backed up:

```
gpg --export-secret-keys --armor my@email.org > <my@email.org>.private.gpg-key
gpg --export --armor my@email.org > <my@email.org>.public.gpg-key
```

These three files were then backed up in a safe, long-term storage location (e.g. on a usb in a safety deposit box).

After the key creation was completed, I had to setup `pass`.
