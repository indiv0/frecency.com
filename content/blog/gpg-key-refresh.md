+++
title = "GPG Key Refresh"
date = 2020-10-26
+++

GPG is a safe, reliable way to encrypt data. zx2c4's
[pass](https://www.passwordstore.org/) password manager uses GPG to encrypt
password files.

I use pass a lot, which means that I use GPG keys a lot (or at least that's
what happens in the background). When old keys expire, they need to be
replaced with new ones. My pass repo also needs to have the keys rotated out.
This is the process I use to do so.

First, we need to ensure we're using OpenPGP best practices. My
[dotfiles](https://github.com/indiv0/dotfiles) contain the most up-to-date
configurations I use. As of the time of writing, here is my
[`~/.gnupg/gpg.conf`](https://github.com/indiv0/dotfiles/blob/c92d5502aa5d317793e025911bbeb155ab2e514c/.gnupg/gpg.conf).
The configuration is primarily drawn from the riseup.net
[OpenPGP Best Practices](https://riseup.net/en/security/message-security/openpgp/best-practices#use-a-strong-primary-key).

Import the sks-keyservers CA certificate, otherwise the keyserver won't work:
```sh
curl --location https://sks-keyservers.net/sks-keyservers.netCA.pem > /tmp/sks-keyservers.netCA.pem
sudo trust anchor --store /tmp/sks-keyservers.netCA.pem
rm /tmp/sks-keyservers.netCA.pem
```

First, generate the master key. We'll be storing the master key offline and
only using subkeys during normal operation. Thus, the master key only needs to
be able to certify new keys:

```
[indiv0@apollo 2020-10-26_gpg_key_refresh]$ gpg --expert --full-gen-key
gpg (GnuPG) 2.2.23; Copyright (C) 2020 Free Software Foundation, Inc.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Please select what kind of key you want:
   (1) RSA and RSA (default)
   (2) DSA and Elgamal
   (3) DSA (sign only)
   (4) RSA (sign only)
   (7) DSA (set your own capabilities)
   (8) RSA (set your own capabilities)
   (9) ECC and ECC
  (10) ECC (sign only)
  (11) ECC (set your own capabilities)
  (13) Existing key
  (14) Existing key from card
Your selection? 11

Possible actions for a ECDSA/EdDSA key: Sign Certify Authenticate 
Current allowed actions: Sign Certify  

   (S) Toggle the sign capability
   (A) Toggle the authenticate capability
   (Q) Finished
                                     
Your selection? s                                                         
                                                                          
Possible actions for a ECDSA/EdDSA key: Sign Certify Authenticate    
Current allowed actions: Certify                                          
                                                                          
   (S) Toggle the sign capability    
   (A) Toggle the authenticate capability
   (Q) Finished             
                                     
Your selection? q     
Please select which elliptic curve you want:                              
   (1) Curve 25519                                                        
   (3) NIST P-256                                                         
   (4) NIST P-384 
   (5) NIST P-521     
   (6) Brainpool P-256                                                    
   (7) Brainpool P-384
   (8) Brainpool P-512       
   (9) secp256k1  
Your selection? 1                    
Please specify how long the key should be valid.                  
         0 = key does not expire                                          
      <n>  = key expires in n days   
      <n>w = key expires in n weeks
      <n>m = key expires in n months                                      
      <n>y = key expires in n years
Key is valid for? (0) 1y
Key expires at Tue 26 Oct 2021 09:32:31 PM EDT
Is this correct? (y/N) y

GnuPG needs to construct a user ID to identify your key.

Real name: Nikita Pekin
Email address: personal@example.com
Comment: 
You selected this USER-ID:
    "Nikita Pekin <personal@example.com>"

Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit? O
We need to generate a lot of random bytes. It is a good idea to perform
some other action (type on the keyboard, move the mouse, utilize the
disks) during the prime generation; this gives the random number
generator a better chance to gain enough entropy.
gpg: key 0x4264C0ABC8A52CC1 marked as ultimately trusted
gpg: revocation certificate stored as '/home/indiv0/.gnupg/openpgp-revocs.d/37363F2B2EF6132D4DA2AECE4264C0ABC8A52CC1.rev'
public and secret key created and signed.

pub   ed25519/0x4264C0ABC8A52CC1 2020-10-27 [C] [expires: 2021-10-27]
      Key fingerprint = 3736 3F2B 2EF6 132D 4DA2  AECE 4264 C0AB C8A5 2CC1
uid                              Nikita Pekin <personal@example.com>
```

We've created a master key with the fingerprint `4264C0ABC8A52CC1`.
Now we create the subkeys. First, list the available keys:
```
[indiv0@apollo 2020-10-26_gpg_key_refresh]$ gpg --list-keys
gpg: checking the trustdb
gpg: marginals needed: 3  completes needed: 1  trust model: pgp
gpg: depth: 0  valid:   1  signed:   0  trust: 0-, 0q, 0n, 0m, 0f, 1u
gpg: next trustdb check due at 2021-10-27
/home/indiv0/.gnupg/pubring.kbx
-------------------------------
pub   ed25519/0x4264C0ABC8A52CC1 2020-10-27 [C] [expires: 2021-10-27]
      Key fingerprint = 3736 3F2B 2EF6 132D 4DA2  AECE 4264 C0AB C8A5 2CC1
uid                   [ultimate] Nikita Pekin <personal@example.com>
```

Add the encryption key with the `addkey` command:
```
[indiv0@apollo 2020-10-26_gpg_key_refresh]$ gpg --expert --edit-key 4264C0ABC8A52CC1
gpg (GnuPG) 2.2.23; Copyright (C) 2020 Free Software Foundation, Inc.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Secret key is available.

sec  ed25519/0x4264C0ABC8A52CC1
     created: 2020-10-27  expires: 2021-10-27  usage: C   
     trust: ultimate      validity: ultimate
[ultimate] (1). Nikita Pekin <personal@example.com>

gpg> addkey
Please select what kind of key you want:
   (3) DSA (sign only)
   (4) RSA (sign only)
   (5) Elgamal (encrypt only)
   (6) RSA (encrypt only)
   (7) DSA (set your own capabilities)
   (8) RSA (set your own capabilities)
  (10) ECC (sign only)
  (11) ECC (set your own capabilities)
  (12) ECC (encrypt only)
  (13) Existing key
  (14) Existing key from card
Your selection? 8

Possible actions for a RSA key: Sign Encrypt Authenticate 
Current allowed actions: Sign Encrypt 

   (S) Toggle the sign capability
   (E) Toggle the encrypt capability
   (A) Toggle the authenticate capability
   (Q) Finished

Your selection? s

Possible actions for a RSA key: Sign Encrypt Authenticate 
Current allowed actions: Encrypt 

   (S) Toggle the sign capability
   (E) Toggle the encrypt capability
   (A) Toggle the authenticate capability
   (Q) Finished

Your selection? q
RSA keys may be between 1024 and 4096 bits long.
What keysize do you want? (3072) 4096
Requested keysize is 4096 bits
Please specify how long the key should be valid.
         0 = key does not expire
      <n>  = key expires in n days
      <n>w = key expires in n weeks
      <n>m = key expires in n months
      <n>y = key expires in n years
Key is valid for? (0) 1y
Key expires at Tue 26 Oct 2021 09:36:57 PM EDT
Is this correct? (y/N) y
Really create? (y/N) y
We need to generate a lot of random bytes. It is a good idea to perform
some other action (type on the keyboard, move the mouse, utilize the
disks) during the prime generation; this gives the random number
generator a better chance to gain enough entropy.

sec  ed25519/0x4264C0ABC8A52CC1
     created: 2020-10-27  expires: 2021-10-27  usage: C   
     trust: ultimate      validity: ultimate
ssb  rsa4096/0x4B1922292563DA2D
     created: 2020-10-27  expires: 2021-10-27  usage: E   
[ultimate] (1). Nikita Pekin <personal@example.com>
```

We've created an encryption key with the fingerprint `4B1922292563DA2D`.
Now we repeat this process for the signing and authentication keys:
```
gpg> addkey
Please select what kind of key you want:
   (3) DSA (sign only)
   (4) RSA (sign only)
   (5) Elgamal (encrypt only)
   (6) RSA (encrypt only)
   (7) DSA (set your own capabilities)
   (8) RSA (set your own capabilities)
  (10) ECC (sign only)
  (11) ECC (set your own capabilities)
  (12) ECC (encrypt only)
  (13) Existing key
  (14) Existing key from card
Your selection? 11

Possible actions for a ECDSA/EdDSA key: Sign Authenticate 
Current allowed actions: Sign 

   (S) Toggle the sign capability
   (A) Toggle the authenticate capability
   (Q) Finished

Your selection? q
Please select which elliptic curve you want:
   (1) Curve 25519
   (3) NIST P-256
   (4) NIST P-384
   (5) NIST P-521
   (6) Brainpool P-256
   (7) Brainpool P-384
   (8) Brainpool P-512
   (9) secp256k1
Your selection? 1
Please specify how long the key should be valid.
         0 = key does not expire
      <n>  = key expires in n days
      <n>w = key expires in n weeks
      <n>m = key expires in n months
      <n>y = key expires in n years
Key is valid for? (0) 1y
Key expires at Tue 26 Oct 2021 09:40:34 PM EDT
Is this correct? (y/N) y
Really create? (y/N) y
We need to generate a lot of random bytes. It is a good idea to perform
some other action (type on the keyboard, move the mouse, utilize the
disks) during the prime generation; this gives the random number
generator a better chance to gain enough entropy.

sec  ed25519/0x4264C0ABC8A52CC1
     created: 2020-10-27  expires: 2021-10-27  usage: C   
     trust: ultimate      validity: ultimate
ssb  rsa4096/0x4B1922292563DA2D
     created: 2020-10-27  expires: 2021-10-27  usage: E   
ssb  ed25519/0xF7AD7C72CECB97FB
     created: 2020-10-27  expires: 2021-10-27  usage: S   
[ultimate] (1). Nikita Pekin <personal@example.com>

gpg> addkey
Please select what kind of key you want:
   (3) DSA (sign only)
   (4) RSA (sign only)
   (5) Elgamal (encrypt only)
   (6) RSA (encrypt only)
   (7) DSA (set your own capabilities)
   (8) RSA (set your own capabilities)
  (10) ECC (sign only)
  (11) ECC (set your own capabilities)
  (12) ECC (encrypt only)
  (13) Existing key
  (14) Existing key from card
Your selection? 11

Possible actions for a ECDSA/EdDSA key: Sign Authenticate 
Current allowed actions: Sign 

   (S) Toggle the sign capability
   (A) Toggle the authenticate capability
   (Q) Finished

Your selection? s

Possible actions for a ECDSA/EdDSA key: Sign Authenticate 
Current allowed actions: 

   (S) Toggle the sign capability
   (A) Toggle the authenticate capability
   (Q) Finished

Your selection? a

Possible actions for a ECDSA/EdDSA key: Sign Authenticate 
Current allowed actions: Authenticate 

   (S) Toggle the sign capability
   (A) Toggle the authenticate capability
   (Q) Finished

Your selection? q
Please select which elliptic curve you want:
   (1) Curve 25519
   (3) NIST P-256
   (4) NIST P-384
   (5) NIST P-521
   (6) Brainpool P-256
   (7) Brainpool P-384
   (8) Brainpool P-512
   (9) secp256k1
Your selection? 1
Please specify how long the key should be valid.
         0 = key does not expire
      <n>  = key expires in n days
      <n>w = key expires in n weeks
      <n>m = key expires in n months
      <n>y = key expires in n years
Key is valid for? (0) 1y
Key expires at Tue 26 Oct 2021 09:41:27 PM EDT
Is this correct? (y/N) y
Really create? (y/N) y
We need to generate a lot of random bytes. It is a good idea to perform
some other action (type on the keyboard, move the mouse, utilize the
disks) during the prime generation; this gives the random number
generator a better chance to gain enough entropy.

sec  ed25519/0x4264C0ABC8A52CC1
     created: 2020-10-27  expires: 2021-10-27  usage: C   
     trust: ultimate      validity: ultimate
ssb  rsa4096/0x4B1922292563DA2D
     created: 2020-10-27  expires: 2021-10-27  usage: E   
ssb  ed25519/0xF7AD7C72CECB97FB
     created: 2020-10-27  expires: 2021-10-27  usage: S   
ssb  ed25519/0x7BAD5F7DD968CD98
     created: 2020-10-27  expires: 2021-10-27  usage: A   
[ultimate] (1). Nikita Pekin <personal@example.com>
```

Thus, the signing and authentication key fingerprints are `F7AD7C72CECB97FB`
and `7BAD5F7DD968CD98` respectively.
Enter `save` to complete the process:
```
gpg> save
```

Generate a revocation certificate for the event of theft of the master key.
```
[indiv0@apollo 2020-10-26_gpg_key_refresh]$ gpg --output 4264C0ABC8A52CC1.rev --gen-revoke 4264C0ABC8A52CC1

sec  ed25519/0x4264C0ABC8A52CC1 2020-10-27 Nikita Pekin <personal@example.com>

Create a revocation certificate for this key? (y/N) y
Please select the reason for the revocation:
  0 = No reason specified
  1 = Key has been compromised
  2 = Key is superseded
  3 = Key is no longer used
  Q = Cancel
(Probably you want to select 1 here)
Your decision? 1
Enter an optional description; end it with an empty line:
> 
Reason for revocation: Key has been compromised
(No description given)
Is this okay? (y/N) y
ASCII armored output forced.
Revocation certificate created.

Please move it to a medium which you can hide away; if Mallory gets
access to this certificate he can use it to make your key unusable.
It is smart to print this certificate and store it away, just in case
your media become unreadable.  But have some caution:  The print system of
your machine might store the data and make it available to others!
```

Save all the keys.
```sh
[indiv0@apollo 2020-10-26_gpg_key_refresh]$ gpg --export --armor 4264C0ABC8A52CC1 > 4264C0ABC8A52CC1.pub.asc
[indiv0@apollo 2020-10-26_gpg_key_refresh]$ gpg --export-secret-keys --armor 4264C0ABC8A52CC1 > 4264C0ABC8A52CC1.priv.asc
[indiv0@apollo 2020-10-26_gpg_key_refresh]$ gpg --export-secret-subkeys --armor 4264C0ABC8A52CC1 > 4264C0ABC8A52CC1.sub_priv.asc
```

`4264C0ABC8A52CC1.pub.asc` will contain all public keys,
`4264C0ABC8A52CC1.priv.asc` will contain the private keys of the master key,
and `4264C0ABC8A52CC1.sub_priv.asc` will contain only the private keys of the
subkeys.

Next, we need to remove the private keys of the master key. First, delete all
private keys:
```
[indiv0@apollo 2020-10-26_gpg_key_refresh]$ gpg --delete-secret-key 4264C0ABC8A52CC1
gpg (GnuPG) 2.2.23; Copyright (C) 2020 Free Software Foundation, Inc.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.


sec  ed25519/0x4264C0ABC8A52CC1 2020-10-27 Nikita Pekin <personal@example.com>

Delete this key from the keyring? (y/N) y
This is a secret key! - really delete? (y/N) y
```

Then, import only the private keys of the subkeys:
```
[indiv0@apollo 2020-10-26_gpg_key_refresh]$ gpg --import 4264C0ABC8A52CC1.sub_priv.asc 
gpg: key 0x4264C0ABC8A52CC1: "Nikita Pekin <personal@example.com>" not changed
gpg: To migrate 'secring.gpg', with each smartcard, run: gpg --card-status
gpg: key 0x4264C0ABC8A52CC1: secret key imported
gpg: Total number processed: 1
gpg:              unchanged: 1
gpg:       secret keys read: 1
gpg:   secret keys imported: 1
```

Verify that only the private keys of the subkeys are present.
```
[indiv0@apollo 2020-10-26_gpg_key_refresh]$ gpg --list-secret-keys
/home/indiv0/.gnupg/pubring.kbx
-------------------------------
sec#  ed25519/0x4264C0ABC8A52CC1 2020-10-27 [C] [expires: 2021-10-27]
      Key fingerprint = 3736 3F2B 2EF6 132D 4DA2  AECE 4264 C0AB C8A5 2CC1
uid                   [ultimate] Nikita Pekin <personal@example.com>
ssb   rsa4096/0x4B1922292563DA2D 2020-10-27 [E] [expires: 2021-10-27]
ssb   ed25519/0xF7AD7C72CECB97FB 2020-10-27 [S] [expires: 2021-10-27]
ssb   ed25519/0x7BAD5F7DD968CD98 2020-10-27 [A] [expires: 2021-10-27]
```

The `#` symbol before `sec` indicates that the secret key of the master key no
longer exists.

Personally, I also wanted to generate a separate GPG key for work, so I
repreated all of the steps above again. The one major difference is that I
have two work emails so I added the second one as another user ID under my
work key.
```
gpg> adduid
Real name: Nikita Pekin
Email address: work2@example.com
Comment: 
You selected this USER-ID:
    "Nikita Pekin <work2@example.com>"

Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit? O

sec  ed25519/0x8D9358ECD4A65A32
     created: 2020-10-27  expires: 2021-10-27  usage: C   
     trust: ultimate      validity: ultimate
[ultimate] (1)  Nikita Pekin <work1@example.com>
[ unknown] (2). Nikita Pekin <work2@example.com>

gpg> uid 2

sec  ed25519/0x8D9358ECD4A65A32
     created: 2020-10-27  expires: 2021-10-27  usage: C   
     trust: ultimate      validity: ultimate
[ultimate] (1)  Nikita Pekin <work1@example.com>
[ unknown] (2)* Nikita Pekin <work2@example.com>

gpg> trust
sec  ed25519/0x8D9358ECD4A65A32
     created: 2020-10-27  expires: 2021-10-27  usage: C   
     trust: ultimate      validity: ultimate
[ultimate] (1)  Nikita Pekin <work1@example.com>
[ unknown] (2)* Nikita Pekin <work2@example.com>

Please decide how far you trust this user to correctly verify other users' keys
(by looking at passports, checking fingerprints from different sources, etc.)

  1 = I don't know or won't say
  2 = I do NOT trust
  3 = I trust marginally
  4 = I trust fully
  5 = I trust ultimately
  m = back to the main menu

Your decision? 5
Do you really want to set this key to ultimate trust? (y/N) y

sec  ed25519/0x8D9358ECD4A65A32
     created: 2020-10-27  expires: 2021-10-27  usage: C   
     trust: ultimate      validity: ultimate
[ultimate] (1)  Nikita Pekin <work1@example.com>
[ unknown] (2)* Nikita Pekin <work2@example.com>

gpg> save
```

I ended up with the following key list in the end:
```
[indiv0@apollo 2020-10-26_gpg_key_refresh]$ gpg --list-secret-keys
/home/indiv0/.gnupg/pubring.kbx
-------------------------------
sec#  ed25519/0x4264C0ABC8A52CC1 2020-10-27 [C] [expires: 2021-10-27]
      Key fingerprint = 3736 3F2B 2EF6 132D 4DA2  AECE 4264 C0AB C8A5 2CC1
uid                   [ultimate] Nikita Pekin <personal@example.com>
ssb   rsa4096/0x4B1922292563DA2D 2020-10-27 [E] [expires: 2021-10-27]
ssb   ed25519/0xF7AD7C72CECB97FB 2020-10-27 [S] [expires: 2021-10-27]
ssb   ed25519/0x7BAD5F7DD968CD98 2020-10-27 [A] [expires: 2021-10-27]

sec#  ed25519/0x8D9358ECD4A65A32 2020-10-27 [C] [expires: 2021-10-27]
      Key fingerprint = 846F 4458 2952 EEC3 B275  6F1F 8D93 58EC D4A6 5A32
uid                   [ultimate] Nikita Pekin <work2@example.com>
uid                   [ultimate] Nikita Pekin <work1@example.com>
ssb   rsa4096/0x9F4B2DDF8049967B 2020-10-27 [E] [expires: 2021-10-27]
ssb   ed25519/0x05259179BC027533 2020-10-27 [S] [expires: 2021-10-27]
ssb   ed25519/0xB3A681B5B1CA424A 2020-10-27 [A] [expires: 2021-10-27]
```

Set the new key as the default key in your `.gnupg/gpg.conf`:
```
default-key 37363F2B2EF6132D4DA2AECE4264C0ABC8A52CC1

Publish the new keys to the keyservers:
```sh
[indiv0@apollo 2020-10-26_gpg_key_refresh]$ gpg --send-key 4264C0ABC8A52CC1
gpg: sending key 0x4264C0ABC8A52CC1 to hkps://hkps.pool.sks-keyservers.net
[indiv0@apollo 2020-10-26_gpg_key_refresh]$ gpg --send-key 8D9358ECD4A65A32
gpg: sending key 0x8D9358ECD4A65A32 to hkps://hkps.pool.sks-keyservers.net
```

Since I generated a work key, I wanted to ensure that anyone who trusts my
primary key could trust that one as well, so I signed my work key with my
primary key.
```
[indiv0@apollo 2020-10-26_gpg_key_refresh]$ gpg --sign-key 8D9358ECD4A65A32
[indiv0@apollo 2020-10-26_gpg_key_refresh]$ gpg --send-keys 8D9358ECD4A65A32
```

Next, I wanted to revoke all my existing keys to ensure that they wouldn't be
used for any correspondence. Luckily I still had all my previous master keys
available, so I imported them into my keyring an issued the revocation certificates:
```
[indiv0@apollo 2020-10-26_gpg_key_refresh]$ gpg --import 8558129A36D54E73.priv.asc
[indiv0@apollo 2020-10-26_gpg_key_refresh]$ gpg --import 99FA8C40093C34AC.priv.asc
[indiv0@apollo 2020-10-26_gpg_key_refresh]$ gpg --import A63C40C35614D8D6.priv.asc
[indiv0@apollo 2020-10-26_gpg_key_refresh]$ gpg --import 5CA3587585FEBB49.priv.asc
[indiv0@apollo 2020-10-26_gpg_key_refresh]$ gpg --import privkeys.asc
[indiv0@apollo 2020-10-26_gpg_key_refresh]$ gpg --edit-key 99FA8C40093C34AC
gpg (GnuPG) 2.2.23; Copyright (C) 2020 Free Software Foundation, Inc.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Secret key is available.

sec  rsa4096/0x99FA8C40093C34AC
     created: 2016-12-14  expired: 2018-12-14  usage: SC  
     trust: unknown       validity: expired
ssb  rsa4096/0x82DC1CF7FDE3DF1F
     created: 2016-12-14  expired: 2018-12-14  usage: E   
[ expired] (1). Nikita Pekin <foo@example.com>

gpg> revkey
Do you really want to revoke the entire key? (y/N) y
Please select the reason for the revocation:
  0 = No reason specified
  1 = Key has been compromised
  2 = Key is superseded
  3 = Key is no longer used
  Q = Cancel
Your decision? 2
Enter an optional description; end it with an empty line:
> Key has been superseded by new keys 3736 3F2B 2EF6 132D 4DA2  AECE 4264 C0AB C8A5 2CC1 (personal) and 846F 4458 2952 EEC3 B275  6F1F 8D93 58EC D4A6 5A32 (work).
> 
Reason for revocation: Key is superseded
Key has been superseded by new keys 3736 3F2B 2EF6 132D 4DA2  AECE 4264 C0AB C8A5 2CC1 (personal) and 846F 4458 2952 EEC3 B275  6F1F 8D93 58EC D4A6 5A32 (work).
Is this okay? (y/N) y

The following key was revoked on 2020-10-27 by RSA key 0x99FA8C40093C34AC Nikita Pekin <foo@example.com>
sec  rsa4096/0x99FA8C40093C34AC
     created: 2016-12-14  revoked: 2020-10-27  usage: SC  
     trust: unknown       validity: revoked
The following key was revoked on 2020-10-27 by RSA key 0x99FA8C40093C34AC Nikita Pekin <foo@example.com>
ssb  rsa4096/0x82DC1CF7FDE3DF1F
     created: 2016-12-14  revoked: 2020-10-27  usage: E   
[ revoked] (1). Nikita Pekin <foo@example.com>

gpg> save
[indiv0@apollo 2020-10-26_gpg_key_refresh]$ gpg --edit-key 8558129A36D54E73
gpg (GnuPG) 2.2.23; Copyright (C) 2020 Free Software Foundation, Inc.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Secret key is available.

sec  rsa4096/0x8558129A36D54E73
     created: 2015-01-13  expires: never       usage: SC  
     trust: unknown       validity: unknown
ssb  rsa4096/0xE96501EEE6721CA4
     created: 2015-01-13  expires: never       usage: E   
[ unknown] (1). Nikita Pekin <foo@example.com>

gpg> revkey
Do you really want to revoke the entire key? (y/N) y
Please select the reason for the revocation:
  0 = No reason specified
  1 = Key has been compromised
  2 = Key is superseded
  3 = Key is no longer used
  Q = Cancel
Your decision? 2
Enter an optional description; end it with an empty line:
> Key has been superseded by new keys 3736 3F2B 2EF6 132D 4DA2  AECE 4264 C0AB C8A5 2CC1 (personal) and 846F 4458 2952 EEC3 B275  6F1F 8D93 58EC D4A6 5A32 (work).
> 
Reason for revocation: Key is superseded
Key has been superseded by new keys 3736 3F2B 2EF6 132D 4DA2  AECE 4264 C0AB C8A5 2CC1 (personal) and 846F 4458 2952 EEC3 B275  6F1F 8D93 58EC D4A6 5A32 (work).
Is this okay? (y/N) y

The following key was revoked on 2020-10-27 by RSA key 0x8558129A36D54E73 Nikita Pekin <foo@example.com>
sec  rsa4096/0x8558129A36D54E73
     created: 2015-01-13  revoked: 2020-10-27  usage: SC  
     trust: unknown       validity: revoked
The following key was revoked on 2020-10-27 by RSA key 0x8558129A36D54E73 Nikita Pekin <foo@example.com>
ssb  rsa4096/0xE96501EEE6721CA4
     created: 2015-01-13  revoked: 2020-10-27  usage: E   
[ revoked] (1). Nikita Pekin <foo@example.com>

gpg> save
[indiv0@apollo 2020-10-26_gpg_key_refresh]$ gpg --edit-key A63C40C35614D8D6
gpg (GnuPG) 2.2.23; Copyright (C) 2020 Free Software Foundation, Inc.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Secret key is available.

gpg: checking the trustdb
gpg: marginals needed: 3  completes needed: 1  trust model: pgp
gpg: depth: 0  valid:   2  signed:   0  trust: 0-, 0q, 0n, 0m, 0f, 2u
gpg: next trustdb check due at 2021-10-27
sec  ed25519/0xA63C40C35614D8D6
     created: 2018-12-16  expires: 2020-12-15  usage: C   
     trust: unknown       validity: unknown
ssb  cv25519/0xA37CBCCC793F7304
     created: 2018-12-16  expires: 2020-12-15  usage: E   
ssb  ed25519/0x29E24F74E09A5E6B
     created: 2018-12-16  expires: 2020-12-15  usage: S   
ssb  ed25519/0x293943476C14D67D
     created: 2018-12-16  expires: 2020-12-15  usage: A   
[ unknown] (1). Nikita Pekin <bar@example.com>

gpg> revkey
Do you really want to revoke the entire key? (y/N) y
Please select the reason for the revocation:
  0 = No reason specified
  1 = Key has been compromised
  2 = Key is superseded
  3 = Key is no longer used
  Q = Cancel
Your decision? 2
Enter an optional description; end it with an empty line:
> Key has been superseded by new keys 3736 3F2B 2EF6 132D 4DA2  AECE 4264 C0AB C8A5 2CC1 (personal) and 846F 4458 2952 EEC3 B275  6F1F 8D93 58EC D4A6 5A32 (work).
> 
Reason for revocation: Key is superseded
Key has been superseded by new keys 3736 3F2B 2EF6 132D 4DA2  AECE 4264 C0AB C8A5 2CC1 (personal) and 846F 4458 2952 EEC3 B275  6F1F 8D93 58EC D4A6 5A32 (work).
Is this okay? (y/N) y

The following key was revoked on 2020-10-27 by ? key 0xA63C40C35614D8D6 Nikita Pekin <bar@example.com>
sec  ed25519/0xA63C40C35614D8D6
     created: 2018-12-16  revoked: 2020-10-27  usage: C   
     trust: unknown       validity: revoked
The following key was revoked on 2020-10-27 by ? key 0xA63C40C35614D8D6 Nikita Pekin <bar@example.com>
ssb  cv25519/0xA37CBCCC793F7304
     created: 2018-12-16  revoked: 2020-10-27  usage: E   
The following key was revoked on 2020-10-27 by ? key 0xA63C40C35614D8D6 Nikita Pekin <bar@example.com>
ssb  ed25519/0x29E24F74E09A5E6B
     created: 2018-12-16  revoked: 2020-10-27  usage: S   
The following key was revoked on 2020-10-27 by ? key 0xA63C40C35614D8D6 Nikita Pekin <bar@example.com>
ssb  ed25519/0x293943476C14D67D
     created: 2018-12-16  revoked: 2020-10-27  usage: A   
[ revoked] (1). Nikita Pekin <bar@example.com>

gpg> save
[indiv0@apollo 2020-10-26_gpg_key_refresh]$ gpg --edit-key 5CA3587585FEBB49
gpg (GnuPG) 2.2.23; Copyright (C) 2020 Free Software Foundation, Inc.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Secret key is available.

gpg: checking the trustdb
gpg: marginals needed: 3  completes needed: 1  trust model: pgp
gpg: depth: 0  valid:   2  signed:   0  trust: 0-, 0q, 0n, 0m, 0f, 2u
gpg: next trustdb check due at 2021-10-27
sec  ed25519/0x5CA3587585FEBB49
     created: 2018-12-18  expires: 2020-12-17  usage: C   
     trust: unknown       validity: unknown
ssb  cv25519/0xBF05CC4D5C9DE040
     created: 2018-12-18  expires: 2020-12-17  usage: E   
ssb  ed25519/0x2BDD3761AD436884
     created: 2018-12-18  expires: 2020-12-17  usage: S   
ssb  ed25519/0x2AD6EDFB2D211DD4
     created: 2018-12-18  expires: 2020-12-17  usage: A   
[ unknown] (1). Nikita Pekin <baz@example.com>

gpg> revkey
Do you really want to revoke the entire key? (y/N) y
Please select the reason for the revocation:
  0 = No reason specified
  1 = Key has been compromised
  2 = Key is superseded
  3 = Key is no longer used
  Q = Cancel
Your decision? 2
Enter an optional description; end it with an empty line:
> Key has been superseded by new keys 3736 3F2B 2EF6 132D 4DA2  AECE 4264 C0AB C8A5 2CC1 (personal) and 846F 4458 2952 EEC3 B275  6F1F 8D93 58EC D4A6 5A32 (work).
> 
Reason for revocation: Key is superseded
Key has been superseded by new keys 3736 3F2B 2EF6 132D 4DA2  AECE 4264 C0AB C8A5 2CC1 (personal) and 846F 4458 2952 EEC3 B275  6F1F 8D93 58EC D4A6 5A32 (work).
Is this okay? (y/N) y

The following key was revoked on 2020-10-27 by ? key 0x5CA3587585FEBB49 Nikita Pekin <baz@example.com>
sec  ed25519/0x5CA3587585FEBB49
     created: 2018-12-18  revoked: 2020-10-27  usage: C   
     trust: unknown       validity: revoked
The following key was revoked on 2020-10-27 by ? key 0x5CA3587585FEBB49 Nikita Pekin <baz@example.com>
ssb  cv25519/0xBF05CC4D5C9DE040
     created: 2018-12-18  revoked: 2020-10-27  usage: E   
The following key was revoked on 2020-10-27 by ? key 0x5CA3587585FEBB49 Nikita Pekin <baz@example.com>
ssb  ed25519/0x2BDD3761AD436884
     created: 2018-12-18  revoked: 2020-10-27  usage: S   
The following key was revoked on 2020-10-27 by ? key 0x5CA3587585FEBB49 Nikita Pekin <baz@example.com>
ssb  ed25519/0x2AD6EDFB2D211DD4
     created: 2018-12-18  revoked: 2020-10-27  usage: A   
[ revoked] (1). Nikita Pekin <baz@example.com>

gpg> save
```

Then, I sent the now revoked keys to the keyservers.
```
[indiv0@apollo 2020-10-26_gpg_key_refresh]$ gpg --send-key 8558129A36D54E73
gpg: sending key 0x8558129A36D54E73 to hkps://hkps.pool.sks-keyservers.net
[indiv0@apollo 2020-10-26_gpg_key_refresh]$ gpg --send-key A63C40C35614D8D6
gpg: sending key 0xA63C40C35614D8D6 to hkps://hkps.pool.sks-keyservers.net
[indiv0@apollo 2020-10-26_gpg_key_refresh]$ gpg --send-key 5CA3587585FEBB49
gpg: sending key 0x5CA3587585FEBB49 to hkps://hkps.pool.sks-keyservers.net
[indiv0@apollo 2020-10-26_gpg_key_refresh]$ gpg --send-key 99FA8C40093C34AC
gpg: sending key 0x99FA8C40093C34AC to hkps://hkps.pool.sks-keyservers.net
```

I then re-encrypted my pass directory against my new personal key, and
selectively re-encrypted my work password directory against both keys.
```sh
pass init 4264C0ABC8A52CC1
echo 4264C0ABC8A52CC1 > $PASSWORD_STORE_DIR/work/.gpg-id
echo 8D9358ECD4A65A32 >> $PASSWORD_STORE_DIR/work/.gpg-id
pass init -p $(cat $PASSWORD_STORE_DIR/work/.gpg-id)
```

After pushing my updated pass directory to GitHub & pulling it to my phone
(along with my new keys) I needed to create a "lifeboat" to ensure that I
could always have a way to re-gain access to my passwords. To do so, I created
a lifeboat with my personal GPG key and a copy of my pass directory at this
point in time.
```sh
[indiv0@apollo usr]$ mkdir 2020-10-27_lifeboat
[indiv0@apollo usr]$ cd 2020-10-27_lifeboat/
[indiv0@apollo 2020-10-27_lifeboat]$ cp ../2020-10-26_gpg_key_refresh/4264C0ABC8A52CC1.* .
[indiv0@apollo 2020-10-27_lifeboat]$ ls
4264C0ABC8A52CC1.priv.asc  4264C0ABC8A52CC1.rev
4264C0ABC8A52CC1.pub.asc   4264C0ABC8A52CC1.sub_priv.asc
[indiv0@apollo 2020-10-27_lifeboat]$ rsync --archive --partial --progress $PASSWORD_STORE_DIR .
[indiv0@apollo 2020-10-27_lifeboat]$ find . -type d -exec chmod 700 {} \;
[indiv0@apollo 2020-10-27_lifeboat]$ find . -type f -exec chmod 600 {} \;
[indiv0@apollo 2020-10-27_lifeboat]$ cd ..
[indiv0@apollo usr]$ tar czvf 2020-10-27_lifeboat2.tar.gz 2020-10-27_lifeboat
[indiv0@apollo usr]$ gpg --symmetric --output 2020-10-27_lifeboat.tar.gz.gpg 2020-10-27_lifeboat.tar.gz
```

Then, I copied this lifeboat to a separate machine to test that it worked.
Since I re-use the same passphrase for symmetric encryption of the lifeboat
and for the GPG keys themselves, I only need to remember one password to
restore access.
```
[npekin@apollo ~]$ gpg --decrypt 2020-10-27_lifeboat.tar.gz.gpg | tar xz
[npekin@apollo ~]$ cd 2020-10-27_lifeboat
[npekin@apollo 2020-10-27_lifeboat]$ gpg --import 4264C0ABC8A52CC1.sub_priv.asc
[npekin@apollo 2020-10-27_lifeboat]$ PASSWORD_STORE_DIR=pass pass gpg_passphrase
```

To clean up my keyring a bit, I removed the keys I just revoked.
```
gpg --delete-secret-keys 8558129A36D54E73 A63C40C35614D8D6 5CA3587585FEBB49 99FA8C40093C34AC
gpg --delete-keys 8558129A36D54E73 A63C40C35614D8D6 5CA3587585FEBB49 99FA8C40093C34AC
```

To finish, I distributed my lifeboat to a variety of locations.
Offline harddrives, cloud storage, email to trusted family.
