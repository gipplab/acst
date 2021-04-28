#  Blockchain 1: Academic Storage Cluster
Seminar Selected Topics in Data & Knowledge Engineering WS 2020/2021 

***
## Table of contents

- [Academic Storage Cluster](#academic-storage-cluster)
- [Motivation](#motivation)
- [Features](#features)
- [Installation and Start](#installation-and-start)
    - [Setup](#0-setup)
        - [Clone repository](#1-clone-repository)
        - [Build images](#2-build-images)
    - [Start](#1-start)
- [Docker](#docker)
    - [Intro](#intro)
    - [Setup](#setup)
    - [Container](#container)
    - [Dockerfile](#dockerfile)
- [Inter Planetary File System](#inter-planetary-file-system)
    - [Overview](#overview--how-it-works)
    - [Installation & Setup](#installation--setup)
    - [Interacting with Clients](#interacting-with-clients)
    - [Bootstrap node](#bootstrap-node)
- [Cluster](#cluster)
    - [Private Cluster](#private-cluster)
- [WebApp](#webapp)
- [Network restrictions](#network-restrictions)
- [Measurement and Manipulation of Cluster](#measurement-and-manipulation-of-cluster)
- [Evaluation](#evaluation)
    - [Methodology](#methodology)
    - [Wireshark](#wireshark)
    - [Results](#results)
    - [Conclusion](#conclusion)
- [Appendix](#appendix)
    - [Table with measurement data](#table-with-measurement-data)
- [Sources and references](#sources-and-references)
    - [General resources](#general-resources)
    - [API and library references](#api-and-library-references)
- [License](#license)
***
## Academic Storage Cluster
This project is about finding out the benefits and shortcomings of recent decentralized content addressable storage in the form of `IPFS` and if we can use it to store, retrieve and manage academic documents. For this purpose, data made available inside a private cluster. Then other peers tried to read the data previously added.
Instead of downloading the data from a specific server to my client, my peer asks other (nearby) peers for the information. In the same way, new data should not only be hosted by my peer, but also by others in the network, so the information should still be retrieved when my own peer is deactivated or lost the data.

![Overview](https://github.com/ag-gipp/acst/blob/main/graphics/ov.png?raw=true)

## Motivation
IPFS brings high availability while only requiring one comparatively lightweight peer on my side. With IPFS the data transport can be faster and therefore more energy-efficient than via the conventional server-client way, assuming the information requested is available on a geographically closer peer and replication is cheaper than routing.

## Features
This project was mainly about the creation of a Dockerfile and a script, with which it is possible to start a test environment. 
In this environment, some parameters of the Docker containers can be changed so that network properties and hardware changes can be simulated. With a single command, the environment can be started (as superuser):

    ./startEnv.sh

A bootstap-node is generated, on which data can be uploaded at port 3000, and further IPFS nodes are created.
***

## Installation and Start
### 0. Setup
To start the test environment, Docker ([Get Docker](https://docs.docker.com/get-docker/ "Get Docker")) needs to be installed first.
#### 1. Clone repository

    git clone "https://github.com/ag-gipp/acst.git"

#### 2. Build images
        
  In order for the script to launch all containers later, they must first be downloaded and installed. To do this, run the following Dockerfiles:
   1. Build bootstrapnode / server with dockerfile:
   
    cd acst/ascEnv/webAppServer
    sudo docker build --tag s0p3 .

   2. Build clientnode with dockerfile:
   
    cd acst/ascEnv/neueDock
    sudo docker build --tag c0p3 .

 *This can take several minutes, because docker needs to download software at the first time.*

   *If you want to use a different image, be sure to change the image in `startEnvnew.sh` in the `docker run` lines (line 63 and 114).*

### 1. Start
#### 1. Navigate to `startEnvnew.sh`:

    cd acst/ascEnv

#### 2. Start the environment:
   
    sudo ./startEnvnew.sh

All required data should be contained in the subfolders, and should have been loaded by the Dockerfiles.

#### 3. Now the number of peers (without bootstrap node) and the parameters of the peers are queried:

        NUM OF NODES (min 1 max 100): 
        2
        NUM OF CPUS for NODE 1 (min 0.1 max 16): 
        1
        RAM for NODE 1 [MB, min=4]: 
        200
        DOWNSTREAM for NODE 1 [kbps]: 
        10000              
        DELAY for NODE 1 [ms]: 
        1
        NUM OF CPUS for NODE 2 (min 0.1 max 16): 
        1
        RAM for NODE 2 [MB, min=4]: 
        200
        DOWNSTREAM for NODE 2 [kbps]: 
        100
        DELAY for NODE 2 [ms]: 
        10
        Node #1:
        CPUS: 1 RAM: 200
        DS: 
        10000
        DELAY: 
        1
        Node #2:
        CPUS: 1 RAM: 200
        DS: 
        100
        DELAY: 
        10

If everything is finished, you get a table with information like this:

    BSN: 3d941c1d45fb ID: 12D3KooWSzkpmdEsaTJjAjZs4u1wMMpNF8RUrx9L4DzdBYgRnSi8 BSNIP: 172.17.0.2
    N1: ff1b61312a1b
    N2: dd5ba61f2c11

#### 4. Interact with containers

    docker exec -it <container_id> bash

***

## Docker
### Intro
One approach can be to use many computers with their own hardware, which are connected in a network. Unfortunately, this is **very expensive** and additionally very time counsuing to use, as each computer has to be set up and initialized individually. Therefore, it is a better idea to use some software that **runs on one real computer** and launches multiple IPFS instances at ones, like a virtual machine. This is where Docker comes into play.

With Docker the host can run many instances of a lightweight OS with applications installed on the image. It is designed to be resource-efficient and installs only one instance of the required data for all containers.

### Setup
Docker is offered for many operating systems, including MacOs, Windows and many Linux distributions at Docker Hub [5]. 
After a few attempts, however, Windows should be avoided, since the Windows subsystem for Linux (WSL) offered by Microsoft [6] still has some bugs and most docker images require this, because they are based on Linux to keep them easy to run in multiple instances. 
One big problem was very high memory usage, which was not detected by docker itself, restricting the memory was also not fruitful. There are also general difficulties in compiling and running programs due to the non-existence of some data or programs in the WSL. Since than Ubuntu 20.04.1 [7] was used as the base operating system. 

### Container 
An image for running IPFS is already provided in the Docker Hub [8]. This is very small (in terms of memory requirements), but is very cumbersome to use, as there is no package manager or similar in the busybox by default. Therefore, a separate Dockerfile was created, which is based on alpine and thus supports the apk packet manager to get programs installed.

### Dockerfile
As described earlier, Alpine is used as the base:

    FROM alpine:latest
Now the programs needed to compile IPFS can be downloaded and installed:

	RUN apk update
    RUN apk add gcc bash git binutils musl musl-dev libc6-compat make go
    RUN export PATH=$PATH:/usr/local/go/bin
    RUN export PATH=$PATH:$GOPATH/bin

Now IPFS is copied from the Dockerfile folder to the container (or downloaded from the Internet):

    COPY go-ipfs /go-ipfs	

Finally IPFS can be compiled and installed with make and go:

    WORKDIR /go-ipfs
    RUN make -j 16 install
    WORKDIR /go-ipfs/cmd/ipfs
    RUN go build

Now IPFS is installed and can be used.


## Inter Planetary File System

### Overview / how it works
To understand, what makes IPFS special, we first need to know the “conventional” way of file systems in the web. **HTTP** at this time is the most successful “distributed system of files” and will be used by all of us many times per day, for example for reading news, streaming video or learning at home. If your client wants any data, it needs to know where it is located. Then we get the information from a domain like “www.mywebsite.tld/important/somedata.html”. So, the data should be stored at this location, but since we just specify the data by its location, it is not guaranteed to be the exact data we want. The server could serve a different file with the same name at the location or provide a different version. If just one server is deactivated, the data is not available for the downtime.

The Inter Planetary File System on the other hand works different. 
Let us look at the following scenario: 

>> Alice is a student downloading a paper for her bachelor thesis. Since many are homeschooling and the university server is busy, she can only download the data very slowly.
>    
> > Bob, on the other hand, has the file on his computer and is an active IPFS peer.
> >
> > Alice remembers a lecture in which IPFS was introduced and activates her client out of boredom because the download from the university is still not finished. She simply asks the network for the file and gets the required paper directly from Bob.
> 
> So the data is not only hosted by one server, but by others in the network, so the information should still be retrieved when a peer is not available or lost the data, but this only works, if the data is relevant enough or if it is been pinned by an active peer.


As we saw in the scenario, *IPFS does not address the data according to the location of the data, but according to the content of the data itself (content-addressing)* [1]. For this, however, a unique fingerprint, also called a **cryptographic hash**, must be created for each file. This allows the data to be uniquely described and verified. So, another benefit is that there is **no need to trust** other peers. 
Furthermore, **duplicates can be avoided** by cleverly dividing the files into chunks and using intelligent data structures like the **Merkle DAG** [2] used by IPFS, thus saving on storage space. Each node can store only the data it considers important and additionally a table (**distributes hash table**), in which the peers that hold other data are stored [1]. 

### Installation & Setup
To provide or view data inside the IPFS network, the IPFS-client is needed on the computer. Installers for MacOs, Windows and some Linux distributions as well as binaries in repositories like GitHub [3] are available. They are also accessible through package managers like brew and choco.
After the installation IPFS must be *initialized* to function and the computer gets a **peer ID**:

    ipfs init

### Interacting with Clients
Data can be *displayed, made available on the network* and on the user's own computer or can be *managed* with the following commands:
|Command|Action|
|:-----:|:----:|
|ipfs id|show info like peer id|
|ipfs refs local|show all data on my peer (local)|
|ipfs add <path>|adds data on path to the network|
|ipfs cat <hash>|shows the data |
|ipfs get <hash>|downloads the data|
|ipfs ls <hash>|lists links from an object|
|ipfs pin ls --type recursive \| cut -d' ' -f1 \| xargs -n1 ipfs pin rm|unpins all local data|
|ipfs repo gc|garbage collection (delets unpinned items)|

### Bootstrap node
The bootstrap node is an IPFS node that other nodes can connect to, in order to **find other peers**. 
For a private network, you cannot use the bootstrap nodes from the public IPFS network but use our private address instead. 
*PA* is the bootstrap node, *PB* every other node, that wants to be in the network.
To use our IPFS peers in private mode, we need to change the bootstrap addresses and tell the configuration, that we want to use a private network:

Initialize IPFS and remove standard BSN on PA & PB:

    ipfs init
    ipfs bootstrap rm --all
    ipfs config show

Copy the ID from PA:

    ipfs config show | grep "PeerID"

Add bootstrap IP and ID to PB:

    ipfs bootstrap add /ip4/<ip address of bootnode>/tcp/4001/ipfs/<peer identity hash of bootnode>

Enable the private network on PA & PB:

    export LIBP2P_FORCE_PNET=1
    ipfs daemon &

Testing:
PA:

    mkdir ipfstest
    cd ipfstest
    echo "Test" > file1
    ipfs add file1

PB:

    ipfs cat <hash>

## Cluster
When we use IPFS as a single node, we have to store all the data we need or want to make available. 
We also share just one network connection, power grid etc. 
On the other hand, if we use multiple IPFS nodes as a storage cluster, we have many advantages: 
* When our cluster is busy, we do not have to upgrade the peers, we just add more peers to our cluster, so the load is distributed in the system *(scalability)*.
* The *availability* is better, because the probability that the information is available is higher with a large number of peers than with just one. 
* Additionally, the amount of stored data can be *distributed* across the peers.


![Image of Cluster](https://github.com/ag-gipp/acst/blob/main/graphics/cluster.png?raw=true)

### Private Cluster
As default IPFS runs in a *public* mode, in which every peer can request data, and the first ones to serve it sends the data. Also, everyone can make data available from the own peer.
Sometimes the data should *not be distributed* all over the world. 

In this scenario we want the data to be distributed only on some of our peers, so the test environment is consistent so we can **change only one parameter and measure the impact of the change**. But a private cluster cannot be used by other peers than the ones we initialize. This means that the storage capacity and network connectivity of external peers cannot be used. 

***

## WebApp

The service of this prototype uses the ipfs-http-client API/library, which was developed by Alan Shaw et. al.
### IPFS WEB APP UPLOAD

A tool to easily "upload" files to IPFS.
If you use the webapp form the bootstrapnode, you can go directly to Upload. This node already runs the node server.

#### Setup

In order to function correctly, IPFS needs to be installed and the daemon needs to be running.
Node should be installed and used to serve the data as well.

```
ipfs daemon
```


#### Starting the server

Make sure, that the IPFS API-Address is the right one.

Navigate to the "IPFS-APP" folder and than start the server:
```
node ipfs.app
```


#### Upload

Now open your browser and go to [http://127.0.0.1:3000/](http://127.0.0.1:3000/).
There you can choose a file and than make it available in IPFS.


#### View uploaded file

After a successful upload you can read the file with
    
    ipfs cat <hash>


### Backend
Since no real server is used here, node and npm must be installed on the container responsible for the backend of the WebApp.	
The actual app uses the ipfs-http-client [9] and the API interface of the IPFS client, which must run in the background. In addition, express [10] and express-fileupload [11] are used as the web framework and for uploading data.

#### Functions
First, the IPFS-client is given the API address, which must be known beforehand. 

    ipfs daemon

The client returns much information including the IPFS API address (typically localhost on port 5001). This needs to be the same as in app.js:

    const ipfs = new ipfsHttpClient({ host: 'localhost', port: '5001', protocol: 'http'});

To deploy a file to IPFS, the file must first be uploaded to the server:

    app.post('/upload', (req, res) => {
        file.mv(filePath, async (err) =>{
            const fileHash = await addFile(fileName, filePath);
            …
In the addFile function the file is then added to IPFS:

    const addFile = async (fileName, filePath) => {
        const file = fs.readFileSync(filePath);
        const fileAdded = await ipfs.add({path: fileName, content: file});
        var cid = fileAdded.cid.toString();
        fileHash = cid;
        return fileHash;
    };
If everything works a hash is returned which can be used to find the file on the IPFS network.
The actual server listens on port 3000:

    app.listen(3000, () => {
       console.log('Server list. on 3000');
    });


### User Interface
In the user interface we can choose a file and than add upload it to the server by pressing “Submit”.
The server downloads the file (in our case in the corresponding docker container and makes it available to the IPFS network by using the IPFS-client API.

***
## Network restrictions
A good program for our case was **tc**.
### Traffic Control
Other than trickle restricts tc **the whole system (container)**. This works better for our situation and is also more realistic, in case we ant to simulate a internet connection with less bandwidth or delays.

#### Installation: 

    apt-get install iproute

#### Setup:
Delay:

	tc qdisc add dev <eth dev> root netem delay <delay>[ms]ms

Show:

	tc qdisc show dev <eth dev>

Delete:

	tc qdisc del dev <eth dev> root

Packet loss:

	tc qdisc add dev <eth dev> root netem loss <loss[%]>%

Bandwidth:

	tc qdisc add dev <eth dev> root tbf rate <bw>mbit burst <bwb>kbit latency <lat>ms
	
Example:

	tc qdisc add dev eth0 root tbf rate 100kbit burst 32kbit latency 1ms


Tests show that this also works with IPFS: 
    
    tc qdisc add dev eth0 root netem delay 100ms 

... also resulted in a 100ms later arrival of the packages. So this tool is suitable for our case.


### Measurement and Manipulation of Cluster
#### Manipulation

In addition to the network restrictions, other tools are used to manipulate and measure the performance of the cluster. On one hand, CPU performance and memory can be changed or limited using docker itself. The following commands are useful for this:

    docker run …
    • -m : set maximum memory
    • --cpus=“<val>” 
In the cluster itself, the number of peers and the replication value can be changed.

#### Measurement

**Replication**
The replication (i.e. how many peers the data is actually available on) can be measured by using the command:

    ipfs-cluster-ctl

**Resources**

Additionally, the size of the Docker containers, the CPU usage and the memory usage can be determined in Docker.

**Network**
The network is examined extensively. Above all, it is interesting to observe from which peer to which other peer the packets are sent, and what the size of these packets is. This is all done with the help of `wireshark`. 
All docker containers can be examined in wireshark by filtering the IP address. Thus, the number and size of packets from one peer to another can be measured. 

***

## Evaluation
### Methodology
In order to find out whether IPFS and cluster are usable for the purposes of the academic storage cluster, effects on the system are measured using the previously mentioned tools. As is common for a storage system for academic data, a PDF file is taken as a reference for academic files. The size of our test file is 6.93 MB. 

This file is first made available by a peer in IPFS (`ipfs add test.pdf`). Then, this file is pinned throughout the cluster (`ipfs-cluster-ctl pin add <hash>`). The pinning status is then monitored and only proceeded when on all cluster peers it has been replicated. Then on a specific peer (which changes through the runs) the file is deleted and then also the inexistence of the file is confirmed. 

Finally, an ipfs get is executed from the peer where the file was deleted.

In each case, the durations, quantities of packets, network and CPU/RAM restrictions and peculiarities are documented.

This method has some advantages and disadvantages. On one hand, slow networks can be simulated by reducing bandwidth and artificially increasing response times. In addition, slow peers can be simulated by allocating fewer resources to a particular peer. Thanks to the Docker environment, changes can also be made to the system rather quickly and data investigation with Docker in conjunction with Wireshark only needs to be performed on one host.

On the other hand, it is still only a simulation since the whole system is based on just one real network with just one real computer.

### Wireshark
When data has been added to the cluster, the data exchange can be inspected with Wireshark. To do this, start Wireshark ...

![Overview of wireshark](https://github.com/ag-gipp/acst/blob/main/graphics/Wireshark_ov.png?raw=true)

and select docker (docker0) to see the traffic of all containers. 
Then you can filter for a specific container (e.g. the one that executes a "get"). To show only IPFS relevant packages, it can be advantageous to filter by port 4001 and the IP of one container (example):

    ip.addr == 172.17.0.2 && tcp.port eq 4001


![Data of wireshark](https://github.com/ag-gipp/acst/blob/main/graphics/wireshark_data.png?raw=true)

Now you can filter even further or sort e.g. by length of the packages. At the bottom right you can also see the number of packages displayed.


### Results
By analyzing the data from *wireshark*, it can be observed that in fact the data for the one file is obtained from multiple peers. 
Bandwidth limitation 
IPFS works up from a bandwidth of about **100 Kbps** below that, it becomes difficult to communicate with the network. The *more bandwidth available to a peer, the more likely that peer is to provide data* in priority to the others. This results in a larger number of large packets at the end of the download. 
From a bandwidth of about **1000 KBit/s on, this effect is no longer noticeable**, since the proportion of packets from fast (10000 KBit/s) and slow (1000 KBit/s) peers is about the same.
During a few test runs with very low bandwidth (approx. 100 Kbit/s), I noticed that this peer slows down the entire network. After deactivating this peer, the download speed became faster again.
For a well running system it is therefore advantageous to connect all peers with at least 1000 kbps.

![Network speed restriction result](https://github.com/ag-gipp/acst/blob/main/graphics/speed_restric.png?raw=true)

Different tests show that using varying delays in the connection to simulate a slow response time has no effect on the peers used for data provisioning. Thus, the *peer with a high simulated ping was selected to provide data in a ***similar way*** as a peer with a low response time*. Measured were orders of magnitude 10 to 50 ms and 10 to 2000 ms. In the **extreme test**, on average, the peer with 10 ms delay was used for 7% of the packets, the one with 100 ms delay for 48%, the one with 1 s delay for 12.5% and the one with 2 s delay for 32.5%. Above one second, a response time is unrealistic in today's world. 
In a more **realistic test**, the peer with 10 ms delay was used for 25%, the peer with 20 ms delay was used for 30%, the peer with 30 ms delay was used for 20%, and the peer with the largest delay in the test (50 ms) was used for 23% of the packets. 
In all tests the download speed was not very much affected by the delay (as seen in the picture).
The combined results of the eight runs show that the response time of the peers (in normal orders of magnitude) does not have a negative impact on cluster utilization for common PDF file sizes.

![Network delay result](https://github.com/ag-gipp/acst/blob/main/graphics/delay_restric.png?raw=true)

Limitation in CPU and RAM
Limiting the CPU (down to 0.1 CPUs) did not lead to any measurable difference and was therefore not changed further in the network tests.
However, limiting the available RAM has an impact on the system. For example, a container with a PDF requires about 200 MB of memory. Since Docker stores most of the memory in the main memory during execution, bottlenecks can quickly occur here with large files. This is not to be expected in real systems for this moment.


### Conclusion
Working with IPFS and therefore a peer-to-peer network was interesting and relatively easy to setup. With just a few minutes of work, you can be part of a very powerful network for sharing data. However, there is much more to discover at IPFS than initially expected. The possibilities with a cluster for example are much greater than with a conventional server-client system, because the peers in the cluster can help each other out.
The real problem of the work is not IPFS itself, but the environment in which IPFS, or the cluster, operates. Thus, a changeable environment was created with as few uncertainties as possible to obtain consistent measurement data. 
For this purpose, docker was used. A program that can run many instances of IPFS in a very resource-efficient way but is not very intuitive to use with Dockerfiles and thus needs to be used with a unique language to manage the actual images and installation. Especially the possibilities through choosing one of many different base images can consume a lot of time. For example, package managers do not provide the same programs in every version and can only be updated a little. So choosing the right base image was very important but time consuming.
Therefore, many scripts were developed with which it is possible to start docker, the container for the server with IPFS peer and the additional IPFS peer, which together form a mini cluster, by just executing one line of command. Also all changeable parameters will be set while the script is running. This saves much time searching for the right image and manipulating the system after every restart of the system.

As expected, the bandwidth limitation had a negative impact on download speed, and the CPU limitation had very little to no impact, as IPFS works relatively light weight. In contrast, it was surprising to see that the simulated long response time had little effect on the choice of peers to provide. 


In the future, based on the results, a cluster can be set up in the real world at physically different locations and connected to each other. In this way, it can be tested whether the new results match those from the simulated environment. In addition, multiple files can be used to investigate the impact of replication on storage space.


## Appendix

### Table with measurement data
(-1) represents no restrictions or changes

|  Number  | BSN | GET @ |   CPU   | Memory |  DLRestr | Delay | Time | Particip. |
|:--------:|:---:|:-----:|:-------:|:------:|:--------:|:-----:|:----:|:---------:|
| Run.Node |     |       | [count] |  [MB]  | [kbit/s] |  [ms] |  [s] |    [%]    |
|      1.0 |  x  |       |      -1 |     -1 |       -1 |    -1 |    3 |         0 |
|      1.1 |     |       |       1 |   1000 |     1000 |     1 |    3 |       100 |
|      1.2 |     |       |       1 |   1000 |     1000 |     1 |    3 |         0 |
|      1.3 |     |   x   |       1 |   1000 |     1000 |     1 |    3 |         0 |
|      2.0 |  x  |       |      -1 |     -1 |       -1 |    -1 |    7 |       100 |
|      2.1 |     |       |       1 |   1000 |     1000 |     1 |    7 |         0 |
|      2.2 |     |       |       1 |   1000 |     1000 |     1 |    7 |         0 |
|      2.3 |     |   x   |       1 |   1000 |     1000 |     1 |    7 |         0 |
|      3.0 |  x  |       |      -1 |     -1 |       -1 |    -1 |   <1 |       100 |
|      3.1 |     |       |       1 |   1000 |     1000 |     1 |   <1 |         0 |
|      3.2 |     |       |       1 |   1000 |     1000 |     1 |   <1 |         0 |
|      3.3 |     |   x   |       1 |   1000 |     1000 |     1 |   <1 |         0 |
|      4.0 |  x  |       |      -1 |     -1 |       -1 |    -1 |   34 |         0 |
|      4.1 |     |       |       1 |   1000 |     1000 |     1 |   34 |       100 |
|      4.2 |     |       |       1 |   1000 |     1000 |     1 |   34 |         0 |
|      4.3 |     |   x   |       1 |   1000 |     1000 |     1 |   34 |         0 |
|      5.0 |  x  |       |      -1 |     -1 |       -1 |    -1 |   41 |         0 |
|      5.1 |     |       |       1 |   1000 |     1000 |     1 |   41 |        50 |
|      5.2 |     |       |       1 |   1000 |     1000 |     1 |   41 |        50 |
|      5.3 |     |   x   |       1 |   1000 |     1000 |     1 |   41 |         0 |
|      6.0 |  x  |       |      -1 |     -1 |       -1 |    -1 |   -1 |         0 |
|      6.1 |     |       |       1 |   1000 |      100 |   100 |   -1 |         0 |
|      6.2 |     |       |       1 |   1000 |      100 |   100 |   -1 |         0 |
|      6.3 |     |   x   |       1 |   1000 |      100 |   100 |   -1 |         0 |
|      6.4 |     |       |       1 |   1000 |     1000 |     1 |   -1 |         0 |
|      7.0 |  x  |       |      -1 |     -1 |       -1 |    -1 |   -1 |         0 |
|      7.1 |     |       |       1 |   1000 |      200 |    50 |   -1 |         0 |
|      7.2 |     |       |       1 |   1000 |      200 |    50 |   -1 |         0 |
|      7.3 |     |   x   |       1 |   1000 |      500 |    20 |   -1 |         0 |
|      7.4 |     |       |       1 |   1000 |     1000 |     1 |   -1 |         0 |
|      8.0 |  x  |       |      -1 |     -1 |       -1 |    -1 |    6 |       100 |
|      8.1 |     |       |       1 |   1000 |     1000 |    50 |    6 |         0 |
|      8.2 |     |       |       1 |   1000 |     1000 |    50 |    6 |         0 |
|      8.3 |     |   x   |       1 |   1000 |     1000 |    20 |    6 |         0 |
|      8.4 |     |       |       1 |   1000 |     1000 |    10 |    6 |         0 |
|      9.0 |  x  |       |      -1 |     -1 |       -1 |    -1 |   25 |         0 |
|      9.1 |     |       |       1 |   1000 |     1000 |    50 |   25 |        47 |
|      9.2 |     |       |       1 |   1000 |     1000 |    50 |   25 |        48 |
|      9.3 |     |   x   |       1 |   1000 |     1000 |    20 |   25 |         0 |
|      9.4 |     |       |       1 |   1000 |     1000 |    10 |   25 |         5 |
|     10.0 |  x  |       |      -1 |     -1 |       -1 |    -1 |   36 |         0 |
|     10.1 |     |       |       1 |   1000 |     1000 |    50 |   36 |        33 |
|     10.2 |     |       |       1 |   1000 |     1000 |    50 |   36 |        33 |
|     10.3 |     |   x   |       1 |   1000 |     1000 |    20 |   36 |         0 |
|     10.4 |     |       |       1 |   1000 |     1000 |    10 |   36 |        33 |
|     11.0 |  x  |       |      -1 |     -1 |       -1 |    -1 |    1 |         0 |
|     11.1 |     |       |       1 |   1000 |     1000 |    50 |    1 |       100 |
|     11.2 |     |       |       1 |   1000 |     1000 |    50 |    1 |         0 |
|     11.3 |     |   x   |       1 |   1000 |     1000 |    20 |    1 |         0 |
|     11.4 |     |       |       1 |   1000 |     1000 |    10 |    1 |         0 |
|     12.0 |  x  |       |      -1 |     -1 |       -1 |    -1 |   74 |         0 |
|     12.1 |     |       |       1 |   1000 |     1000 |    50 |   74 |         0 |
|     12.2 |     |       |       1 |   1000 |     1000 |    50 |   74 |        65 |
|     12.3 |     |   x   |       1 |   1000 |     1000 |    20 |   74 |         0 |
|     12.4 |     |       |       1 |   1000 |     1000 |    10 |   74 |        35 |
|     13.0 |  x  |       |      -1 |     -1 |       -1 |    -1 |    2 |         0 |
|     13.1 |     |       |       1 |   1000 |    10000 |    10 |    2 |        30 |
|     13.2 |     |       |       1 |   1000 |    10000 |    10 |    2 |        60 |
|     13.3 |     |   x   |       1 |   1000 |    10000 |    10 |    2 |         0 |
|     13.4 |     |       |       1 |   1000 |    10000 |    10 |    2 |        10 |
|     14.0 |  x  |       |      -1 |     -1 |       -1 |    -1 |    3 |         0 |
|     14.1 |     |       |       1 |   1000 |    10000 |    10 |    3 |        50 |
|     14.2 |     |       |       1 |   1000 |    10000 |    10 |    3 |         0 |
|     14.3 |     |   x   |       1 |   1000 |    10000 |    10 |    3 |         0 |
|     14.4 |     |       |       1 |   1000 |    10000 |    10 |    3 |        50 |
|     15.0 |  x  |       |      -1 |     -1 |       -1 |    -1 |    2 |         0 |
|     15.1 |     |       |       1 |   1000 |    10000 |    10 |    2 |        50 |
|     15.2 |     |       |       1 |   1000 |    10000 |    10 |    2 |        30 |
|     15.3 |     |   x   |       1 |   1000 |    10000 |    10 |    2 |         0 |
|     15.4 |     |       |       1 |   1000 |    10000 |    10 |    2 |        20 |
|     16.0 |  x  |       |      -1 |     -1 |       -1 |    -1 |    7 |         0 |
|     16.1 |     |       |       1 |   1000 |    10000 |    10 |    7 |        20 |
|     16.2 |     |       |       1 |   1000 |     5000 |    10 |    7 |        20 |
|     16.3 |     |       |       1 |   1000 |     2000 |    10 |    7 |        60 |
|     16.4 |     |   x   |       1 |   1000 |     1000 |    10 |    7 |         0 |
|     17.0 |  x  |       |      -1 |     -1 |       -1 |    -1 |   11 |         0 |
|     17.1 |     |       |       1 |   1000 |    10000 |    10 |   11 |        33 |
|     17.2 |     |       |       1 |   1000 |     5000 |    10 |   11 |        34 |
|     17.3 |     |       |       1 |   1000 |     2000 |    10 |   11 |        33 |
|     17.4 |     |   x   |       1 |   1000 |     1000 |    10 |   11 |         0 |
|     18.0 |  x  |       |      -1 |     -1 |       -1 |    -1 |   12 |         0 |
|     18.1 |     |       |       1 |   1000 |    10000 |    10 |   12 |        15 |
|     18.2 |     |       |       1 |   1000 |     5000 |    10 |   12 |        30 |
|     18.3 |     |       |       1 |   1000 |     2000 |    10 |   12 |        55 |
|     18.4 |     |   x   |       1 |   1000 |     1000 |    10 |   12 |         0 |
|     19.0 |  x  |       |      -1 |     -1 |       -1 |    -1 |   43 |         0 |
|     19.1 |     |       |       1 |   1000 |     1000 |    10 |   43 |        80 |
|     19.2 |     |   x   |       1 |   1000 |      500 |    10 |   43 |         0 |
|     19.3 |     |       |       1 |   1000 |      200 |    10 |   43 |        15 |
|     19.4 |     |       |       1 |   1000 |      100 |    10 |   43 |         5 |
|     20.0 |  x  |       |      -1 |     -1 |       -1 |    -1 |   87 |         0 |
|     20.1 |     |       |       1 |   1000 |     1000 |    10 |   87 |        90 |
|     20.2 |     |   x   |       1 |   1000 |      500 |    10 |   87 |         0 |
|     20.3 |     |       |       1 |   1000 |      200 |    10 |   87 |         5 |
|     20.4 |     |       |       1 |   1000 |      100 |    10 |   87 |         5 |
|     21.0 |  x  |       |      -1 |     -1 |       -1 |    -1 |   50 |         0 |
|     21.1 |     |       |       1 |   1000 |     1000 |    10 |   50 |        95 |
|     21.2 |     |   x   |       1 |   1000 |      500 |    10 |   50 |         0 |
|     21.3 |     |       |       1 |   1000 |      200 |    10 |   50 |         5 |
|     22.0 |  x  |       |      -1 |     -1 |       -1 |    -1 |   59 |         0 |
|     22.1 |     |       |       1 |   1000 |     1000 |    10 |   59 |        95 |
|     22.2 |     |   x   |       1 |   1000 |      500 |    10 |   59 |         0 |
|     22.3 |     |       |       1 |   1000 |      200 |    10 |   59 |         5 |
|     23.0 |  x  |       |      -1 |     -1 |       -1 |    -1 |   10 |         0 |
|     23.1 |     |       |       1 |   1000 |     1000 |    10 |   10 |         0 |
|     23.2 |     |   x   |       1 |   1000 |      500 |    10 |   10 |       100 |
|     23.3 |     |       |       1 |   1000 |      200 |    10 |   10 |         0 |
|     24.0 |  x  |       |      -1 |     -1 |       -1 |    -1 |   37 |         0 |
|     24.1 |     |   x   |       1 |   1000 |     1000 |    10 |   37 |         0 |
|     24.2 |     |       |       1 |   1000 |     1000 |   100 |   37 |        10 |
|     24.3 |     |       |       1 |   1000 |     1000 |  1000 |   37 |        30 |
|     24.4 |     |       |       1 |   1000 |     1000 |  2000 |   37 |        60 |
|     25.0 |  x  |       |      -1 |     -1 |       -1 |    -1 |   51 |         0 |
|     25.1 |     |       |       1 |   1000 |     1000 |    10 |   51 |        10 |
|     25.2 |     |   x   |       1 |   1000 |     1000 |   100 |   51 |         0 |
|     25.3 |     |       |       1 |   1000 |     1000 |  1000 |   51 |        20 |
|     25.4 |     |       |       1 |   1000 |     1000 |  2000 |   51 |        70 |
|     26.0 |  x  |       |      -1 |     -1 |       -1 |    -1 |   36 |         0 |
|     26.1 |     |       |       1 |   1000 |     1000 |    10 |   36 |         0 |
|     26.2 |     |       |       1 |   1000 |     1000 |   100 |   36 |         0 |
|     26.3 |     |   x   |       1 |   1000 |     1000 |  1000 |   36 |       100 |
|     26.4 |     |       |       1 |   1000 |     1000 |  2000 |   36 |         0 |
|     27.0 |  x  |       |      -1 |     -1 |       -1 |    -1 |   51 |         0 |
|     27.1 |     |       |       1 |   1000 |     1000 |    10 |   51 |        18 |
|     27.2 |     |       |       1 |   1000 |     1000 |   100 |   51 |        82 |
|     27.3 |     |       |       1 |   1000 |     1000 |  1000 |   51 |         0 |
|     27.4 |     |   x   |       1 |   1000 |     1000 |  2000 |   51 |         0 |
|     28.0 |  x  |       |      -1 |     -1 |       -1 |    -1 |   36 |        44 |
|     28.1 |     |   x   |       1 |   1000 |     1000 |    10 |   36 |         0 |
|     28.2 |     |       |       1 |   1000 |     1000 |    20 |   36 |        21 |
|     28.3 |     |       |       1 |   1000 |     1000 |    30 |   36 |        18 |
|     28.4 |     |       |       1 |   1000 |     1000 |    50 |   36 |        17 |
|     29.0 |  x  |       |      -1 |     -1 |       -1 |    -1 |   29 |         2 |
|     29.1 |     |       |       1 |   1000 |     1000 |    10 |   29 |        36 |
|     29.2 |     |   x   |       1 |   1000 |     1000 |    20 |   29 |         0 |
|     29.3 |     |       |       1 |   1000 |     1000 |    30 |   29 |        33 |
|     29.4 |     |       |       1 |   1000 |     1000 |    50 |   29 |        29 |
|     30.0 |  x  |       |      -1 |     -1 |       -1 |    -1 |   34 |         5 |
|     30.1 |     |       |       1 |   1000 |     1000 |    10 |   34 |        30 |
|     30.2 |     |       |       1 |   1000 |     1000 |    20 |   34 |        33 |
|     30.3 |     |   x   |       1 |   1000 |     1000 |    30 |   34 |         0 |
|     30.4 |     |       |       1 |   1000 |     1000 |    50 |   34 |        32 |
|     31.0 |  x  |       |      -1 |     -1 |       -1 |    -1 |   18 |         2 |
|     31.1 |     |       |       1 |   1000 |     1000 |    10 |   18 |        34 |
|     31.2 |     |       |       1 |   1000 |     1000 |    20 |   18 |        49 |
|     31.3 |     |       |       1 |   1000 |     1000 |    30 |   18 |        15 |
|     31.4 |     |   x   |       1 |   1000 |     1000 |    50 |   18 |         0 |

***

## Sources and references

### General resources

[1]	J. Benet, “IPFS - Content Addressed, Versioned, P2P File System,” arXiv:1407.3561 [cs], Jul. 2014, Accessed: Dec. 01, 2020. [Online]. Available: http://arxiv.org/abs/1407.3561.

[2]	J. Kan and K. S. Kim, “MTFS: Merkle-Tree-Based File System,” arXiv:1902.09100 [cs], Apr. 2019, Accessed: Dec. 01, 2020. [Online]. Available: http://arxiv.org/abs/1902.09100.

[3]	ipfs-shipyard/ipfs-desktop. IPFS Shipyard, 2021.: https://github.com/ipfs-shipyard/ipfs-desktop 

[4]	S. Walker, “KeySpace: End-to-End Encryption using Ethereum and IPFS,” Medium, Dec. 19, 2018. https://medium.com/fluidity/keyspace-end-to-end-encryption-using-ethereum-and-ipfs-87b04b18156b (accessed Mar. 12, 2021).

[5]	“Explore - Docker Hub.” https://hub.docker.com/search?q=&type=edition&offering=community (accessed Jan. 22, 2021).

[6]	craigloewen-msft, “An overview on the Windows Subsystem for Linux.” https://docs.microsoft.com/en-us/windows/wsl/ (accessed Jan. 22, 2021).

[7]	“FocalFossa/ReleaseNotes/ChangeSummary/20.04.1 - Ubuntu Wiki.” https://wiki.ubuntu.com/FocalFossa/ReleaseNotes/ChangeSummary/20.04.1 (accessed Jan. 21, 2021).

[8]	“ipfs/go-ipfs - Docker Hub.” https://hub.docker.com/r/ipfs/go-ipfs (accessed Jan. 22, 2021).

[9]	“ipfs-http-client,” npm. https://www.npmjs.com/package/ipfs-http-client (accessed Jan. 21, 2021).

[10] expressjs/express. expressjs, 2021.: https://expressjs.com/ 

[11] R. Girges, richardgirges/express-fileupload. 2021.: https://github.com/richardgirges/express-fileupload

### API and library references

go-ipfs by Steven Allen, Protocol Labs : https://github.com/ipfs/go-ipfs

ipfs-http-api by Protocol Labs, Inc.: https://github.com/ipfs/http-api-docs 

js-ipfs by Alex Potsides et. al.: https://github.com/ipfs/js-ipfs 

express by StrongLoop, IBM et. al.: https://expressjs.com/ 

express-fileupload by R. Girges: https://github.com/richardgirges/express-fileupload 

## License

Copyright 2021 Alexander von Tottleben

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0.

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions andlimitations under the License.
