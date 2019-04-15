# runescape
Dockerfile for running Runescape's NXT client (nvidia gpus only).

Modify the DRIVER flag to update to a new driver.
Driver file must be in the same directory.

Game data will be cached until container removal.
Containers will be automatically removed and rebuilt if the image changes.

You can have multiple clients at once, just pass a name as the first arg.


```sh
runescape.sh #runs the default client
runescape.sh myalt #creates a new client for myalt (if it does not exist)
```
asd