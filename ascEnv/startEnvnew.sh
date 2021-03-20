# Main script for starting the environment

# first docker needs to be restarted, which means closing / removing all old conatiners
echo "Restarting docker ..."
service docker restart
echo "Delete old containers ..."
docker container stop $(docker container ls -aq) &&
docker container rm $(docker container ls -aq) &&

# parameters are requested from the user
echo "NUM OF NODES (min 1 max 100): "
read NUM_OF_NODES

# for each node the parameters are queried for...
i=1
while [ $i -le $NUM_OF_NODES ]
do
# ... CPU count
echo "NUM OF CPUS for NODE $i (min 0.1 max 16): "
read NEW_NUM
NUM_CPU[$i]=$NEW_NUM

# ... RAM amount
echo "RAM for NODE $i [MB, min=4]: "
read NEW_NUM
NUM_RAM[$i]=$NEW_NUM

# ... network restriction bandwidth
echo "DOWNSTREAM for NODE $i [kbps]: "
read NEW_NUM
eval "NUM_DWN$i"=$NEW_NUM

# ... network restriction delay
echo "DELAY for NODE $i [ms]: "
read NEW_NUM
eval "NUM_DLY$i"=$NEW_NUM
((i++))
done

# print the parameters, so you can check for correctness
i=1
while [ $i -le $NUM_OF_NODES ]
do
echo "Node #$i:"
echo "CPUS: ${NUM_CPU[$i]} RAM: ${NUM_RAM[$i]}"
echo "DS: "
eval "echo \${NUM_DWN$i}"
echo "DELAY: "
eval "echo \${NUM_DLY$i}"
export NUM_DWN$i
export NUM_DLY$i
((i++))
done

# create variable on host to export it to container later
export LIBP2P_FORCE_PNET=1

# create cluster secret
export CLUSTER_SECRET=$(od -vN 32 -An -tx1 /dev/urandom | tr -d ' \n')
echo "SECRET:$CLUSTER_SECRET"

# START SETUP/INIT SERVER
docker run --cap-add=NET_ADMIN -e LIBP2P_FORCE_PNET -e CLUSTER_SECRET --name rs0p1 -dit -p 3000:3000 s0p3
echo "#1" #debug

# collect IDs, IPs
bsn="$(docker ps | awk 'NR==2{print $1}')"
n0="$(docker ps | awk 'NR==2{print $1}')"
bsnip="$(docker exec $bsn ifconfig | grep "inet addr:" | awk 'NR==1{print $2}'| cut -d ":" -f 2)"
bsnid="$(docker exec $bsn ipfs config show | grep "PeerID" | awk 'NR==1{print $2}' | cut -d "\"" -f 2)"

# debug
#docker exec $bsn ipfs shutdown
#docker exec $bsn ipfs pin ls --type recursive | cut -d' ' -f1 | xargs -n1 ipfs pin rm
#docker exec $bsn ipfs repo gc

echo "#2.2" #debug
docker exec $bsn rm startServer.sh 
docker cp getswarm.sh $bsn:/
docker cp clusterinst.sh $bsn:/
docker cp webAppServer/startServer.sh $bsn:/
echo "#2.3" #debug
docker exec $bsn bash clusterinst.sh
docker exec $bsn bash getswarm.sh
echo "#3" #debug
docker exec $bsn ipfs bootstrap rm --all
docker cp $bsn:/root/.ipfs/swarm.key .
docker exec $bsn ipfs bootstrap add /ip4/$bsnip/tcp/4001/ipfs/$bsnid
echo "#4" #debug
docker exec $bsn bash startServer.sh
echo "#5" #debug

# END SETUP/INIT SERVER

# START CLIENTS/NODES SETUP/INIT

# for each node ...
i=1
typeset -i i
while [ $i -le $NUM_OF_NODES ]
do
# ... copy parameters of ....
# .... network
eval "neua=\${NUM_DWN$i}"
neua="${neua}kbit"

eval "neub=\${NUM_DLY$i}"
neub="${neub}ms"
export neua
export neub

# .... CPU & RAM
# ... run the container
docker run --cap-add=NET_ADMIN --cpus="${NUM_CPU[$i]}" -m ${NUM_RAM[$i]}m -e i -e neua -e neub -e LIBP2P_FORCE_PNET -e CLUSTER_SECRET --name rc0p$i -dit c0p3
eval "n$i="$(docker ps | awk 'NR==2{print $1}')""
eval "now=\${n$i}"
echo "ICH BIN DRAN: $now"

# init cluster
docker cp clusterinst.sh $now:/
docker exec $now rm startIPFS.sh 
docker cp getswarm.sh $now:/
docker cp clusterinst.sh $now:/
docker cp neueDock/startIPFS.sh $now:/

# privatize
docker exec $now rm -r /root/.ipfs
docker exec $now ipfs init
docker exec $now ipfs bootstrap rm --all

# copy swarm key
docker cp swarm.key $now:/root/.ipfs/swarm.key
docker exec $now ipfs bootstrap add /ip4/$bsnip/tcp/4001/ipfs/$bsnid
docker exec $now ipfs shutdown
docker exec $now bash clusterinst.sh
docker exec $now bash startIPFS.sh
docker exec $now apk add iproute2

# set network restriction
docker exec $now tc qdisc add dev eth0 root handle 1: netem delay $neub
docker exec $now tc qdisc add dev eth0 parent 1: handle 2: tbf rate $neua burst 32kbit latency $neub

((i++))
done

# END CLIENT/NODES SETUP/INIT

# at the end print some useful information
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
