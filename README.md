#  Blockchain 1: Academic Storage Cluster
Seminar Selected Topics in Data & Knowledge Engineering WS 2020/2021 
***
## Academic Storage Cluster
This project is about finding out the benefits and shortcomings of recent decentralized content addressable storage in the form of `IPFS` and if we can use it to store, retrieve and manage academic documents. For this purpose, data will made available inside a private cluster. Then other peers will try to read the data previously added.
Instead of downloading the data from a specific server to my client, my peer asks other (nearby) peers for the information. In the same way, new data should not only be hosted by my peer, but also by others in the network, so the information should still be retrieved when my own peer is deactivated or lost the data.

## Motivation
IPFS brings high availability while only requiring one comparatively lightweight peer on my side.With IPFS the data transport can be faster and therefore more energy-efficient than the conventional server-client way, assuming the information requested is available on a geographically closer peer and replication is cheaper than routing.

## Features
This project is mainly about the creation of a Dockerfile and a script, with which it is possible to start a test environment. In this environment, some parameters of the Docker containers were then changed so that network properties and hardware changes can be simulated. With a single command, the environment can be started. At runtime, the user is asked for parameters:

    ./startEnv.sh

## Installation and Start
### 0. Setup
To start the test environment, Docker ([Get Docker](https://docs.docker.com/get-docker/ "Get Docker")) must first be installed.
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

   *If you want to use a different image, be sure to change the image in `startEnvnew.sh` in the `docker run` lines (line 53 and 91)-*

### 1. Start
#### 1. Navigate to `startEnvnew.sh`:

        cd acst/ascEnv

#### 2. Start the environment:
   
        sudo ./startEnvnew.sh

All required data should be contained in the subfolders, or should have been loaded by the Dockerfiles.

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

If everything is finished, you get a table with information:
    BSN: 3d941c1d45fb ID: 12D3KooWSzkpmdEsaTJjAjZs4u1wMMpNF8RUrx9L4DzdBYgRnSi8 BSNIP: 172.17.0.2
    N1: ff1b61312a1b
    N2: dd5ba61f2c11

#### 4. Interact with containers

    docker exec -it <container_id> bash


## Inter Planetary File System (theoretical part)

### Overview / how it works
To understand, what makes IPFS special, we first need to know the “conventional” way of file systems in the web. **HTTP** at this time is the most successful “distributed system of files” and will be used by all of us many times per day, for example for reading news, streaming video or learning at home. If your client wants any data, it needs to know where it is located. Then we get the information from a domain like “www.mywebsite.tld/important/somedata.html”. So, the data should be stored at this location, but since we just specify the data by its location, it is not guaranteed to be the exact data we want. The server could serve a different file with the same name at the location or provide a different version. If just one server is deactivated, the data is not available for the downtime.

The Inter Planetary File System on the other hand works different. 
Let us look at the following scenario: 

>> Alice is a student downloading a paper for her bachelor thesis. Since many are homeschooling and the university server is busy, she can only download the data very slowly.
>    
> > Bob, on the other hand, has the file on his computer and is an active IPFS peer. Alice remembers a lecture in which IPFS was introduced and activates her client out of boredom because the download from the university is still not finished. She simply asks the network for the file and gets the required paper directly from Bob.
> 
> So the data is not only hosted by one peer, but by others in the network, so the information should still be retrieved when a peer is not available or lost the data, but this only works, if the data is relevant enough or if it is been pinned by an active peer.


As we saw in the scenario, *IPFS does not address the data according to the location of the data, but according to the content of the data itself (content-addressing)* [1]. For this, however, a unique fingerprint, also called a **cryptographic hash**, must be created for each file. This allows the data to be uniquely described and verified. So, another benefit is that there is **no need to trust** other peers. 
Furthermore, **duplicates can be avoided** by cleverly dividing the files into chunks and using intelligent data structures (**Merkle DAG**)[2], thus saving on storage space. Each node can store only the data it considers important and additionally a table (**distributes hash table**), in which the peers that hold other data are stored [1]. 

### Installation & Setup
To provide or view data in the IPFS the IPFS-client is needed on the computer. Installers for MacOs, Windows and some Linux distributions as well as binaries in repositories like GitHub [3] are available. They are also accessible through package managers like brew and choco.
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
PA/PB:

    mkdir ipfstest
    cd ipfstest
    echo "Test" > file1
    ipfs add file1

PB/PA:

    ipfs cat <hash>

## Cluster
When we use IPFS as a single node, we have to store all the data we need or want to make available. 
We also share just one network connection, power grid etc. 
On the other hand, if we use multiple IPFS nodes as a storage cluster, we have many advantages: 
* When our cluster is busy, we do not have to upgrade the peers, we just add more peers to our cluster, so the load is distributed in the system *(scalability)*.
* The *availability* is better, because the probability that the information is available is higher with a large number of peers than with just one. 
* Additionally, the amount of stored data can be *distributed* across the peers.

### Private Cluster
As default IPFS runs in a *public* mode, in which every peer can request data, and the first ones to serve it sends the data. Also, everyone can make data available from the own peer.
Sometimes the data should *not be distributed* all over the world. 

In this scenario we want the data to be distributed only on some of our peers, so the test environment is consistent so we can **change only one parameter and measure the impact of the change**. But a private cluster cannot be used by other peers than the ones we initialize. This means that the storage capacity and network connectivity of external peers cannot be used. 


## WebApp

## API reference
For small projects with a simple enough API, include the reference docs in this README. For medium-sized and larger projects, provide a link to the API reference docs.

## Tests (optional: only if you have tests)
Describe and show how to run the tests with code examples.

## How to use and extend the project? (maybe)
Include a step-by-step guide that enables others to use and extend your code for their projects. Whether this section is required and whether it should be part of the `README.md` or a separate file depends on your project. If the **very short** `Code Examples` from above comprehensively cover (despite being concise!) all the major functionality of your project already, this section can be omitted. **If you think that users/developers will need more information than the brief code examples above to fully understand your code, this section is mandatory.** If your project requires significant information on code reuse, place the information into a new `.md` file.

## Results
By analyzing the data from `wireshark`, it can be observed that in fact the data for the one file is obtained from multiple peers. 
Bandwidth limitation 
IPFS works up from a bandwidth of about **100 Kbps** below that, it becomes difficult to communicate with the network. The *more bandwidth available to a peer, the more likely that peer is to provide data* in priority to the others. This results in a larger number of large packets at the end of the download. 
From a bandwidth of about **1000 KBit/s on, this effect is no longer noticeable**, since the proportion of packets from fast (10000 KBit/s) and slow (1000 KBit/s) peers is about the same.
During a few test runs with very low bandwidth (approx. 100 Kbit/s), I noticed that this peer slows down the entire network. After deactivating this peer, the download speed became faster again.
For a well running system it is therefore advantageous to connect all peers with at least 1000 kbps.

Different tests show that using varying delays in the connection to simulate a slow response time has no effect on the peers used for data provisioning. Thus, the *peer with a high simulated ping was selected to provide data in a ***similar way*** as a peer with a low response time*. Measured were orders of magnitude 10 to 50 ms and 10 to 2000 ms. In the **extreme test**, on average, the peer with 10 ms delay was used for 7% of the packets, the one with 100 ms delay for 48%, the one with 1 s delay for 12.5% and the one with 2 s delay for 32.5%. Above this, a response time is unrealistic in today's world. 
In a more **realistic test**, the peer with 10 ms delay was used for 25%, the peer with 20 ms delay was used for 30%, the peer with 30 ms delay was used for 20%, and the peer with the largest delay in the test (50 ms) was used for 23% of the packets. 
In all tests the download speed was not very much affected by the delay (as seen in Figure 6).
The combined results of the eight runs show that the response time of the peers (in normal orders of magnitude) does not have a negative impact on cluster utilization for common PDF file sizes.

Limitation in CPU and RAM
Limiting the CPU (down to 0.1 CPUs, which corresponds to about 2 GFLOPS) did not lead to any measurable difference and was therefore not changed further in the network tests.
However, limiting the available RAM has an impact on the system. For example, a container with a PDF requires about 200 MB of memory. Since Docker stores most of the memory in the main memory during execution, bottlenecks can quickly occur here with large files. This is not to be expected in real systems for this moment.
Overall
In all tests, peer 0 was the bootstrap node and thus had to work the most. The peers 1 to 4 were further restricted with increasing number. This can also be seen in Figure 8. Since peer 4 was not used in some tests, the participation of this peer is slightly different from the expected trend.


## Conclusion
Working with IPFS and therefore a peer-to-peer network was interesting and relatively easy to setup. With just a few minutes of work, you can be part of a very powerful network for sharing data. However, there is much more to discover at IPFS than initially expected. The possibilities with a cluster for example are much greater than with a conventional server-client system, because the peers in the cluster can help each other out.
The real problem of the work is not IPFS itself, but the environment in which IPFS, or the cluster, operates. Thus, a changeable environment was created with as few uncertainties as possible to obtain consistent measurement data. 
For this purpose, docker was used. A program that can run many instances of IPFS in a very resource-efficient way but is not very intuitive with Dockerfiles and thus must be used with a unique language to manage the actual images and installation. Especially the large number of possibilities through different base images can consume a lot of time. For example, package managers do not contain the same programs in every version and can only be updated a little. So choosing the right base image was very important but time consuming.
Therefore, many scripts were developed with which it is possible to start docker, the container for the server with IPFS peer and the additional IPFS peer, which together form a mini cluster, by just executing one line of command. Also all changeable parameters will be set while the script is running. This saves much time searching for the right image and manipulating the system after every restart of the system.
As expected, the bandwidth limitation had a negative impact on download speed, and the CPU limitation had very little to no impact, as IPFS works relatively light weight. In contrast, it was surprising to see that the simulated long response time had little effect on the choice of peers to provide. 
In the future, based on the results, a cluster can be set up in the real world at physically different locations and connected to each other. In this way, it can be tested whether the new results match those from the simulated environment. In addition, multiple files can be used to investigate the impact of replication on storage space.

## License
Include the project's license. Usually, we suggest MIT or Apache. Ask your supervisor. For example:

Licensed under the Apache License, Version 2.0 (the "License"); you may not use news-please except in compliance with the License. A copy of the License is included in the project, see the file [LICENSE](LICENSE).

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License

## License of this readme-template (remove this once you replaced this readme-template with your own content)
This file itself is partially based on [this file](https://gist.github.com/sujinleeme/ec1f50bb0b6081a0adcf9dd84f4e6271). 
