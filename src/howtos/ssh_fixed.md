## How to fix `REMOTE HOST IDENTIFICATION HAS CHANGED` error

If error is something like this!

```
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
IT IS POSSIBLE THAT SOMEONE IS DOING SOMETHING NASTY!
Someone could be eavesdropping on you right now (man-in-the-middle attack)!
It is also possible that a host key has just been changed.
The fingerprint for the ED25519 key sent by the remote host is
SHA256:XM3xMy1ucD6LErF59aFRhOHW5IS57NTFvLWl/hE/oAU.
Please contact your system administrator.
Add correct host key in /Users/kanishkpachauri/.ssh/known_hosts to get rid of this message.
Offending ECDSA key in /Users/kanishkpachauri/.ssh/known_hosts:21
Host key for 192.168.0.162 has changed and you have requested strict checking.
Host key verification failed.
```

Solution :

```
ssh-keygen -R 192.168.0.162
```
