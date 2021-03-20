# alpine is used because of its package managing system
FROM alpine:latest

# some infos for debug
RUN uname -a
RUN ifconfig
RUN apk update

# install build essentials
RUN apk update 
RUN apk upgrade 
RUN apk add gcc bash git binutils musl musl-dev libc6-compat make go tmux tshark net-tools

RUN wget https://dist.ipfs.io/ipfs-cluster-ctl/v0.13.1/ipfs-cluster-ctl_v0.13.1_linux-amd64.tar.gz
RUN wget https://dist.ipfs.io/ipfs-cluster-service/v0.13.1/ipfs-cluster-service_v0.13.1_linux-amd64.tar.gz
RUN tar -zxvf ipfs-cluster-ctl_v0.13.1_linux-amd64.tar.gz 
RUN tar -zxvf ipfs-cluster-service_v0.13.1_linux-amd64.tar.gz 
RUN cp ipfs-cluster-ctl/ipfs-cluster-ctl /bin/
RUN cp ipfs-cluster-service/ipfs-cluster-service /bin/
RUN export IPFS_CLUSTER_PATH=/root/.ipfs-cluster/

# add bin to path
RUN export PATH=$PATH:/usr/local/go/bin
RUN export PATH=$PATH:$GOPATH/bin
RUN go version

# copy ipfs and server stuff
COPY go-ipfs /go-ipfs
COPY startIPFS.sh /
RUN ls

# compile and build IPFS
WORKDIR /go-ipfs
RUN make -j 16 install
WORKDIR /go-ipfs/cmd/ipfs
RUN go build

# copy ipfs bin to path
RUN cp ipfs $GOPATH/bin

# initialize IPFS
RUN ipfs init
WORKDIR /

# start IPFS daemon
RUN bash startIPFS.sh
