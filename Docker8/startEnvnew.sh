echo "Restarting docker ..."
service docker restart
echo "Delete old containers ..."
docker container stop $(docker container ls -aq) &&
docker container rm $(docker container ls -aq) &&

echo "NUM OF NODES (min 1 max 100): "
read NUM_OF_NODES

i=1
while [ $i -le $NUM_OF_NODES ]
do
echo "NUM OF CPUS for NODE $i (min 0.1 max 16): "
read NEW_NUM
NUM_CPU[$i]=$NEW_NUM

echo "RAM for NODE $i [MB, min=4]: "
read NEW_NUM
NUM_RAM[$i]=$NEW_NUM

echo "DOWNSTREAM for NODE $i [kbps]: "
read NEW_NUM
NUM_DWN[$i]=$NEW_NUM

echo "DELAY for NODE $i [ms]: "
read NEW_NUM
NUM_DLY[$i]=$NEW_NUM

((i++))
done

i=1
while [ $i -le $NUM_OF_NODES ]
do
echo "NUM OF CPUS for NODE $i: ${NUM_CPU[$i]} RAM for NODE $i: ${NUM_RAM[$i]} DS for NODE $i: ${NUM_DWN[$i]} DELAY CPUS for NODE $i: ${NUM_DLY[$i]}"
export NUM_DWN[$i]=${NUM_DWN[$i]}
export NUM_DLY[$i]=${NUM_DLY[$i]}
((i++))
done




export LIBP2P_FORCE_PNET=1
export CLUSTER_SECRET=$(od -vN 32 -An -tx1 /dev/urandom | tr -d ' \n')
echo "SECRET:$CLUSTER_SECRET"

#start server + ipfs bootstrap node

docker run --cap-add=NET_ADMIN -e LIBP2P_FORCE_PNET -e CLUSTER_SECRET --name rs0p1 -dit -p 3000:3000 s0p3
echo "#1"

bsn="$(docker ps | awk 'NR==2{print $1}')"
n0="$(docker ps | awk 'NR==2{print $1}')"
bsnip="$(docker exec $bsn ifconfig | grep "inet addr:" | awk 'NR==1{print $2}'| cut -d ":" -f 2)"
bsnid="$(docker exec $bsn ipfs config show | grep "PeerID" | awk 'NR==1{print $2}' | cut -d "\"" -f 2)"
#docker exec $bsn ipfs shutdown
#docker exec $bsn ipfs pin ls --type recursive | cut -d' ' -f1 | xargs -n1 ipfs pin rm
#docker exec $bsn ipfs repo gc
echo "#2.2"
docker exec $bsn rm startServer.sh 
docker cp getswarm.sh $bsn:/
docker cp clusterinst.sh $bsn:/
docker cp webAppServer/startServer.sh $bsn:/
echo "#2.3"
docker exec $bsn bash clusterinst.sh
docker exec $bsn bash getswarm.sh
echo "#3"
docker exec $bsn ipfs bootstrap rm --all
docker cp $bsn:/root/.ipfs/swarm.key .
docker exec $bsn ipfs bootstrap add /ip4/$bsnip/tcp/4001/ipfs/$bsnid
echo "#4"
docker exec $bsn bash startServer.sh
echo "#5"
i=1
typeset -i i
while [ $i -le $NUM_OF_NODES ]
do
#for every client start ipfs
docker run --cap-add=NET_ADMIN --cpus="${NUM_CPU[$i]}" -m ${NUM_RAM[$i]}m -e NUM_DWN[$i] -e NUM_DLY[$i] -e LIBP2P_FORCE_PNET -e CLUSTER_SECRET --name rc0p$i -dit c0p3
eval "n$i="$(docker ps | awk 'NR==2{print $1}')""
eval "now=\${n$i}"
echo "ICH BIN DRAN: $now"

docker cp clusterinst.sh $now:/
docker exec $now rm startIPFS.sh 
docker cp getswarm.sh $now:/
docker cp clusterinst.sh $now:/
docker cp neueDock/startIPFS.sh $now:/

docker exec $now rm -r /root/.ipfs
docker exec $now ipfs init
docker exec $now ipfs bootstrap rm --all
docker cp swarm.key $now:/root/.ipfs/swarm.key
docker exec $now ipfs bootstrap add /ip4/$bsnip/tcp/4001/ipfs/$bsnid
docker exec $now ipfs shutdown
docker exec $now bash clusterinst.sh
docker exec $now bash startIPFS.sh
docker exec $now apk add iproute2
docker exec $now tc qdisc add dev eth0 root tbf rate 100kbit burst 32kbit latency 1ms
((i++))
done

docker exec $bsn ipfs-cluster-ctl peers ls
echo "#6"
docker ps
echo "BSN: $bsn ID: $bsnid BSNIP: $bsnip"
j=1
typeset -i j
while [ $j -le $NUM_OF_NODES ]
do
eval "now=\${n$j}"
echo "N$j: $now"
((j++))
done


#1 wget https://dist.ipfs.io/ipfs-cluster-ctl/v0.13.1/ipfs-cluster-ctl_v0.13.1_linux-amd64.tar.gz
#2 wget https://dist.ipfs.io/ipfs-cluster-service/v0.13.1/ipfs-cluster-service_v0.13.1_linux-amd64.tar.gz
#3 tar -zxvf ipfs-cluster-ctl_v0.13.1_linux-amd64.tar.gz 
#4 cp ipfs-cluster-ctl/ipfs-cluster-ctl /bin/
#5 cp ipfs-cluster-service/ipfs-cluster-service /bin/
#6 export IPFS_CLUSTER_PATH=/root/.ipfs-cluster/
#7 ipfs-cluster-service init
#8 get "secret": "" from /root/.ipfs-cluster/service.json (cat /root/.ipfs-cluster/service.json | grep "secret" | cut -d "\"" -f 4)
#9 set secret at other nodes
#9.5 tmux new -d
#10 tmux send-keys -t1 "ipfs-cluster-service daemon" ENTER

#alternative
#1 GOPATH=/root/go
#2 git clone https://github.com/ipfs/ipfs-cluster.git $GOPATH/src/github.com/ipfs/ipfs-cluster
#3 cd $GOPATH/src/github.com/ipfs/ipfs-cluster
#4 make install
#5 

#tbi
# apk add iftop
# apk add iproute2

