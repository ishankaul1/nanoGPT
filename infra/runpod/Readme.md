# Runpod Infra

Mostly just helper scripts so I have all the commands etc to succeed on hand & don't have to keep going to their docs.


1) To see what GPUs are currently available:
```
runpodctl get cloud
```

2) Create a pod with a specific Image/GPU config:

```
NAME=my-smoke \
GPU_TYPE="NVIDIA RTX 4000 Ada" \
IMAGE="<yourusername>/nanogpt-trainer:latest" \
DISK_GB=5 \
VOL_GB=0 \
./rp_create_pod.sh
```

3) Remove a pod 

```
PID=<pod_id> ./rm_pod.sh
```

4) Stop a pod (just pauses it, but the pod sticks around)
```
PID=<pod_id> ./stop_pod.sh
```


5) Get the logs
```
PID=<pod_id> ./pod_logs.sh
```