#!/bin/bash

WS_DIR=$(readlink -f $(dirname $0)/../../)
echo "mounting host directory $WS_DIR as container directory /home/docker/catkin_ws"

docker run --rm -it \
  -e DISPLAY \
  -e LIBGL_ALWAYS_INDIRECT \
  -e NVIDIA_DRIVER_CAPABILITIES=all \
  -v $XAUTHORITY:/home/docker/.Xauthority:ro \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v $WS_DIR:/home/docker/catkin_ws \
  -v /home/$USER/.ssh:/home/docker/.ssh \
  -v /home/$USER/.gitconfig:/home/docker/.gitconfig:ro \
  --name xyzt-dev \
  $@ \
  odas-dev:latest
