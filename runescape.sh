#!/bin/sh
cd `dirname $(readlink -f "$0")`

CONTAINER=$1
if [ -z "$CONTAINER" ]; then
	CONTAINER="runescape"
fi

CUR_IMG_ID=$(docker images --filter=reference=runescape --format='{{ .ID }}')

docker build -t runescape \
    --build-arg AUDIO=$(getent group audio | cut -d':' -f3) \
    --build-arg VIDEO=$(getent group video | cut -d':' -f3) \
    --build-arg DRIVER=NVIDIA-Linux-x86_64-418.56.run \
    ./

NEW_IMG_ID=$(docker images --filter=reference=runescape --format='{{ .ID }}')
CONTAINER_ID=$(docker ps -a --filter="name=$CONTAINER" --format="{{ .ID }}")

if [ "$CUR_IMG_ID" != "$NEW_IMG_ID" ] || [ -z "$CONTAINER_ID" ]; then
	if [ ! -z "$CONTAINER_ID" ]; then
		docker rm $CONTAINER_ID
	fi

	docker create \
		-e DISPLAY=unix$DISPLAY \
		--device /dev/nvidia0:/dev/nvidia0 \
		--device /dev/nvidiactl:/dev/nvidiactl \
		--device /dev/nvidia-modeset:/dev/nvidia-modeset \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		--device /dev/snd \
		-e PULSE_SERVER=unix:/run/user/1000/pulse/native \
		-e PULSE_LATENCY_MSEC="60" \
		-v /run/user/$UID/pulse:/run/user/1000/pulse \
		-v /dev/shm:/dev/shm \
		-v /etc/localtime:/etc/localtime:ro \
		--name $CONTAINER \
		runescape
fi

xhost +local:`docker inspect --format='{{ .Config.Hostname }}' $CONTAINER`

docker start $CONTAINER
