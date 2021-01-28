# IPFS WEB APP UPLOAD

A tool to easily "upload" files to IPFS


## Setup

In order to function correctly, IPFS needs to be installed and the daemon needs to be running.
Node should be installed and used to serve the data as well.

```
ipfs daemon
```


## Starting the server

Make sure, that the IPFS API-Address is the right one.

Navigate to the "IPFS-APP" folder and than start the server:
```
node ipfs.app
```


## Upload

Now open your browser and go to [http://127.0.0.1:3000/](http://127.0.0.1:3000/)
There you can choose a file and than make it available in IPFS.


## View uploaded file

After a successful upload you will be directed to ahttps://ipfs.io/ipfs/ site, where you can click at a link, where you can find your file at https://ipfs.io/ipfs/<hash>
