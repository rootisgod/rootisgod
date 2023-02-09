---
categories: linux tls certificates
date: "2023-02-09T08:00:00Z"
title: Checking the Certificate on a Non-Standard Port
draft: false
---

Ever need to check the certificate used on a non-HTTPS port and verify it is correct? No? It doesn't happen all that often, but it can be a little bit of a stumper as to how you would do it when you can't use a web browser. But, you can use this command on a linux machine and give it a test.

This example is to test a web page (this site!), but its something simple we can use that exists already.

```bash
openssl s_client -connect www.rootisgod.com:443
```

But simply change the port to whatever service you are hosting, for example 5671 for a rabbitmq instance woth a cert ofr example. It will reply with the same type of result. We can now verify the service is listening with the certificate we expect

```bash
openssl s_client -connect rabbitmq.myinstance.com:5671
```

### Example Output for www.rootisgod.com
```
CONNECTED(00000003)
depth=2 C = US, O = DigiCert Inc, OU = www.digicert.com, CN = DigiCert Global Root CA
verify return:1
depth=1 C = US, O = DigiCert Inc, CN = DigiCert TLS RSA SHA256 2020 CA1
verify return:1
depth=0 C = US, ST = California, L = Los Angeles, O = Edgecast Inc., CN = sni2107cgl.wpc.edgecastcdn.net
verify return:1
---
Certificate chain
 0 s:C = US, ST = California, L = Los Angeles, O = Edgecast Inc., CN = sni2107cgl.wpc.edgecastcdn.net
   i:C = US, O = DigiCert Inc, CN = DigiCert TLS RSA SHA256 2020 CA1
   a:PKEY: rsaEncryption, 2048 (bit); sigalg: RSA-SHA256
   v:NotBefore: May 17 00:00:00 2022 GMT; NotAfter: Jun 17 23:59:59 2023 GMT
 1 s:C = US, O = DigiCert Inc, CN = DigiCert TLS RSA SHA256 2020 CA1
   i:C = US, O = DigiCert Inc, OU = www.digicert.com, CN = DigiCert Global Root CA
   a:PKEY: rsaEncryption, 2048 (bit); sigalg: RSA-SHA256
   v:NotBefore: Apr 14 00:00:00 2021 GMT; NotAfter: Apr 13 23:59:59 2031 GMT
---
Server certificate
-----BEGIN CERTIFICATE-----
MIIG5TCCBc2gAwIBAgIQBJBrsk+Wo3zLaTRVX5d3/zANBgkqhkiG9w0BAQsFADBP
... remove for brevity ...
lkls4c18OqGObpGVM92BPb9dZMZTbYkuv3bPzwhHwc5AK6netXB1RZI=
-----END CERTIFICATE-----
subject=C = US, ST = California, L = Los Angeles, O = Edgecast Inc., CN = sni2107cgl.wpc.edgecastcdn.net
issuer=C = US, O = DigiCert Inc, CN = DigiCert TLS RSA SHA256 2020 CA1
---
No client certificate CA names sent
Peer signing digest: SHA256
Peer signature type: RSA-PSS
Server Temp Key: ECDH, prime256v1, 256 bits
---
SSL handshake has read 3674 bytes and written 751 bytes
Verification: OK
---
New, TLSv1.3, Cipher is TLS_AES_256_GCM_SHA384
Server public key is 2048 bit
Secure Renegotiation IS NOT supported
Compression: NONE
Expansion: NONE
No ALPN negotiated
Early data was not sent
Verify return code: 0 (ok)
---
---
Post-Handshake New Session Ticket arrived:
SSL-Session:
    Protocol  : TLSv1.3
    Cipher    : TLS_AES_256_GCM_SHA384
    Session-ID: B2C7B36166DE83CD27F3D6A916B170AC478652434971E831E739620FC2352CAF
    Session-ID-ctx: 
    Resumption PSK: E82C8350FF9E94857573142CB17FB76C4DFA4A4D462FFEB1018BF1671BC76C5A9094DA4FA081FA04056D1F8F8DE5724A
    PSK identity: None
    PSK identity hint: None
    SRP username: None
    TLS session ticket lifetime hint: 7200 (seconds)
    TLS session ticket:
    0000 - f4 b5 b7 d1 29 be 7c 62-e5 75 13 68 4f 08 1c d1   ....).|b.u.hO...
    0010 - 96 20 21 98 17 3d af e4-25 91 9b 6a b3 3c 50 ec   . !..=..%..j.<P.
    0020 - 3f f3 7c 2c 45 44 90 6f-91 b7 b6 54 96 d9 be 8d   ?.|,ED.o...T....
    0030 - f5 79 2f f6 1d 86 d9 12-4d 42 b3 2d 1a b5 1d 42   .y/.....MB.-...B
    0040 - f9 9b 48 93 61 f5 86 b3-b1 92 d0 a8 1a a3 bd 86   ..H.a...........
    0050 - 4c 94 84 41 58 a3 ac ec-b0 b7 eb e3 08 04 9a 6f   L..AX..........o
    0060 - 5d cc 0c 8b 1f 83 66 d2-b1 9a 2e 2c f8 27 3a cc   ].....f....,.':.
    0070 - 71 a0 2d 73 b5 50 ef f5-37 8d c5 82 47 30 95 03   q.-s.P..7...G0..
    0080 - 9b 24 b5 e0 e6 0e 98 40-16 48 e0 68 5a 3b 0c da   .$.....@.H.hZ;..
    0090 - d2 8a be 3f 0f 7d 94 5b-0f 33 22 0b fa 7d c9 86   ...?.}.[.3"..}..
    00a0 - c9 4b 91 ed 56 ad 0c 19-fd 83 96 c2 80 13 58 85   .K..V.........X.
    00b0 - e3 89 eb 08 55 31 41 28-5a 7b 5c a7 c6 43 0a dd   ....U1A(Z{\..C..
    00c0 - ee 7d 96 b6 df 39 cf 55-70 5f 5a de 0c 98 d4 a2   .}...9.Up_Z.....

    Start Time: 1675935338
    Timeout   : 7200 (sec)
    Verify return code: 0 (ok)
    Extended master secret: no
    Max Early Data: 0
---
read R BLOCK
---
Post-Handshake New Session Ticket arrived:
SSL-Session:
    Protocol  : TLSv1.3
    Cipher    : TLS_AES_256_GCM_SHA384
    Session-ID: 902304B51A92111CFAFF9E919E0BECD9B28EF948A27520B95F435F83328BC270
    Session-ID-ctx: 
    Resumption PSK: 5E6CBD13C7780A2F1D3F29B52A7227172E7E44B40B2DE7D6946C5814AB7608D4D934F657D6EE3DB52B19281887A94E23
    PSK identity: None
    PSK identity hint: None
    SRP username: None
    TLS session ticket lifetime hint: 7200 (seconds)
    TLS session ticket:
    0000 - f4 b5 b7 d1 29 be 7c 62-e5 75 13 68 4f 08 1c d1   ....).|b.u.hO...
    0010 - 0f 18 44 af c7 1c 91 02-45 b0 0b c0 46 5d 96 8d   ..D.....E...F]..
    0020 - d4 d5 62 1d 4b 4a e9 2e-fa 2c 37 7a be 6e e0 5c   ..b.KJ...,7z.n.\
    0030 - 47 c1 d8 80 07 17 48 21-c4 9f 9a ec 5c 2b 8d 8b   G.....H!....\+..
    0040 - 8c dc 73 40 ca d1 5a e0-8d 38 15 a2 8b 3b 94 e3   ..s@..Z..8...;..
    0050 - 19 90 57 0e 9d 7b f0 83-f0 c2 56 b4 30 b4 5a 1a   ..W..{....V.0.Z.
    0060 - 5e 56 76 7a 79 3c 54 0c-de 3d 66 33 e8 4e 67 4e   ^Vvzy<T..=f3.NgN
    0070 - fd 1a 97 af 3b 09 45 bd-d6 f1 80 05 1a 6a da 9f   ....;.E......j..
    0080 - 80 18 b8 45 fc 95 0a 85-15 b7 08 8d d3 0d ba 1d   ...E............
    0090 - fc 67 1e 55 16 e3 3f fd-9c 66 0b 3e e8 04 9d ff   .g.U..?..f.>....
    00a0 - 1b 86 c7 ed 79 22 1d 5a-57 32 03 7b e3 8d 65 ec   ....y".ZW2.{..e.
    00b0 - 0f 62 e8 53 55 4a a9 95-94 b2 76 ad 39 a5 ad 4b   .b.SUJ....v.9..K

    Start Time: 1675935338
    Timeout   : 7200 (sec)
    Verify return code: 0 (ok)
    Extended master secret: no
    Max Early Data: 0
---
read R BLOCK
```
