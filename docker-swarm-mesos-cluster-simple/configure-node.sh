#!/bin/bash
set -e +x

##################
# Configure a Node
##################

# The VM Name for the master should be passed in as a parameter
masterVMName=$1

##################
# Install Mesos
##################
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF
DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
CODENAME=$(lsb_release -cs)

echo "deb http://repos.mesosphere.com/${DISTRO} ${CODENAME} main" | \
  sudo tee /etc/apt/sources.list.d/mesosphere.list
sudo apt-get -y update

sudo apt-get -y install mesos

################
# Install Docker
################

wget -qO- https://get.docker.com | sh

##################
# Configure Mesos
##################

# Stop and disable mesos-master
sudo service mesos-master stop
echo manual | sudo tee /etc/init/mesos-master.override

# Add docker containerizer
echo "docker,mesos" | sudo tee /etc/mesos-slave/containerizers

# Configure zk
echo "zk://$masterVMName:2181/mesos" | sudo tee /etc/mesos/zk

# Disable and stop zookeeper
sudo service zookeeper stop
echo manual | sudo tee /etc/init/zookeeper.override

##################
# Configure Docker
##################

# Start Docker and listen on :2375 (no auth, but in vnet)
echo 'DOCKER_OPTS="-H unix:// -H 0.0.0.0:2375"' | sudo tee /etc/default/docker
sudo service docker restart

# Restart node process
sudo service mesos-slave restart