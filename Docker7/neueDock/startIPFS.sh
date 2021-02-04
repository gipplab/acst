tmux new -d 
tmux send-keys -t 0 "ipfs daemon" ENTER
tmux new -d
tmux send-keys -t 1 "ipfs-cluster-service daemon" ENTER