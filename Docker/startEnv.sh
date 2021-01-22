service docker restart

docker container stop $(docker container ls -aq) &&
docker container rm $(docker container ls -aq) &&

docker run --name rs0p1 -dit -p 3000:3000 s0p1
docker exec rs0p1 bash startServer.sh

#for every client start ipfs
docker run --name rc0p1 -dit c0p1
docker exec rc0p1 bash startIPFS.sh

docker ps