#!/bin/bash

####################
# Configure a Master
####################

# The VM Name for the master should be passed in as the first parameter
masterVMName=$1
# The Cluster Name should be passed in as the second parameter
clusterName=$2

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

#################
# Configure Mesos
#################

# Disable mesos-slave on this node
sudo service mesos-slave stop
echo manual | sudo tee /etc/init/mesos-slave.override

# Set the master Zookeeper
echo zk://$masterVMName:2181/mesos | sudo tee /etc/mesos/zk

# Specify a human readable name for the Cluster
echo $clusterName | sudo tee /etc/mesos-master/cluster

#####################
# Configure Zookeeper
#####################

# each Zookeeper needs to know its position in the quorum
echo 1 | sudo tee /etc/zookeeper/conf/myid

#################
# Configure Docker
#################

# Run swarm manager container on port 2375 (no auth)
sudo docker run -d -e SWARM_MESOS_USER=root \
	--restart=always 
    -p 2375:2375 -p 3375:3375 swarm manage \
    -c mesos-experimental \
    --cluster-opt mesos.address=0.0.0.0 \
    --cluster-opt mesos.port=3375 $masterVMName:5050

# Restart master processes
sudo service zookeeper restart
sudo service mesos-master restart