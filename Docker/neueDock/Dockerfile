FROM alpine:latest

RUN uname -a
RUN ifconfig
RUN apk update

# install build essentials
RUN apk update 
RUN apk upgrade 
RUN apk add gcc bash git binutils musl musl-dev libc6-compat make go tmux tshark net-tools

# add bin to path
RUN export PATH=$PATH:/usr/local/go/bin
RUN export PATH=$PATH:$GOPATH/bin
RUN go version

COPY go-ipfs /go-ipfs
COPY startIPFS.sh /
RUN ls

WORKDIR /go-ipfs
RUN make -j 16 install
WORKDIR /go-ipfs/cmd/ipfs
RUN go build

# copy ipfs bin to path
RUN cp ipfs $GOPATH/bin

RUN ipfs init
WORKDIR /
RUN bash startIPFS.sh
