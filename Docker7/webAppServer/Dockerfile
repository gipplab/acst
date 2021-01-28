FROM alpine:latest

RUN uname -a
RUN ifconfig

# install build essentials
RUN apk update 
RUN apk upgrade 
RUN apk add gcc bash git binutils musl musl-dev libc6-compat make go tmux tshark net-tools nodejs npm
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

COPY go-ipfs /go-ipfs
COPY ipfs-app /ipfs-app
COPY startServer.sh startServer.sh

RUN ls

WORKDIR /go-ipfs
RUN make -j 16 install
WORKDIR /go-ipfs/cmd/ipfs
RUN go build

# copy ipfs bin to path
RUN cp ipfs $GOPATH/bin

RUN ipfs init
WORKDIR /home/
RUN go get -u github.com/Kubuxu/go-ipfs-swarm-key-gen/ipfs-swarm-key-gen
WORKDIR /
RUN bash startServer.sh
