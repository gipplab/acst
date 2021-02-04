tmux new -d 
tmux send-keys -t 0 "ipfs daemon" ENTER
cd ipfs-app
tmux new -d
tmux send-keys -t 1 "node app.js" ENTER
tmux new -d
tmux send-keys -t 2 "ipfs-cluster-service daemon" ENTER