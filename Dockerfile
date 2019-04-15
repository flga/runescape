#docker run --rm \
#	--device /dev/nvidia0:/dev/nvidia0 \
#	--device /dev/nvidiactl:/dev/nvidiactl \
#	--device /dev/nvidia-modeset:/dev/nvidia-modeset \
#	--device /dev/snd \
#	-v /etc/localtime:/etc/localtime:ro \
#	-v /tmp/.X11-unix:/tmp/.X11-unix \
#	-e DISPLAY=unix$DISPLAY \
#	--name runescape \
#	runescape

# touch /tmp/.docker.xauth && xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f /tmp/.docker.xauth nmerge - && \
# docker run -it --rm \
# --device /dev/nvidia0:/dev/nvidia0 \
# --device /dev/nvidiactl:/dev/nvidiactl \
# --device /dev/nvidia-modeset:/dev/nvidia-modeset \
# --device /dev/snd \
# -v /etc/localtime:/etc/localtime:ro \
# -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
# -v /tmp/.docker.xauth:/tmp/.docker.xauth:ro \
# -v ${HOME}/.runescape:/home/runescape/.runescape \
# -v ${HOME}/Jagex:/home/runescape/Jagex \
# -v /run/user/1000/pulse:/run/user/1000/pulse \
# -e XAUTHORITY=/tmp/.docker.xauth \
# -e PULSE_SERVER=unix:/run/user/1000/pulse/native \
# -e DISPLAY=unix$DISPLAY \
# --name runescape runescape /bin/bash

FROM debian:8

COPY runescape.gpg.key /

RUN apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends\
		ca-certificates \
		apt-transport-https \
		libcurl3 \
		module-init-tools \
		pkg-config \
		gcc-multilib \
		xorg \
		xorg-dev \
		alsa-utils \
		libpulse0 \
		libasound2 \
		pulseaudio \
		pulseaudio-utils \
	&& apt-key add runescape.gpg.key \
	&& echo "deb https://content.runescape.com/downloads/ubuntu trusty non-free" > /etc/apt/sources.list.d/runescape.list \
	&& apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y runescape-launcher --no-install-recommends
	# && rm -rf /var/lib/apt/lists/*

RUN echo $' \n\
# Connect to the hosts server using the mounted UNIX socket \n\
default-server = unix:/run/user/1000/pulse/native \n\
# Prevent a server running in the container \n\
autospawn = no \n\
daemon-binary = /bin/true \n\
# Prevent the use of shared memory \n\
enable-shm = true' >> /etc/pulse/client.conf

ARG AUDIO
ARG VIDEO
RUN groupmod -g ${AUDIO} audio
RUN groupmod -g ${VIDEO} video

ARG DRIVER
COPY ${DRIVER} /

RUN /${DRIVER} -s -Z -X --no-kernel-module

RUN groupadd -g 1000 -r runescape \
	&& useradd -u 1000 --no-log-init -m -g runescape -G audio,video runescape \
	&& chown -R runescape:runescape /home/runescape

WORKDIR /home/runescape
VOLUME [ "/home/runescape" ]

USER runescape
CMD /usr/bin/runescape-launcher