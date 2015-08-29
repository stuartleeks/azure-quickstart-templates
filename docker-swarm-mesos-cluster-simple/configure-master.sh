# Setup
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF
DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
CODENAME=$(lsb_release -cs)

# Add the repository
echo "deb http://repos.mesosphere.com/${DISTRO} ${CODENAME} main" | \
  sudo tee /etc/apt/sources.list.d/mesosphere.list
sudo apt-get -y update

# Install mesos
sudo apt-get -y install mesos

# Configure zk
echo 1 | sudo tee /etc/zookeeper/conf/myid
sudo service zookeeper restart

# Stop and disable mesos-slave 
sudo service mesos-slave stop
echo manual | sudo tee /etc/init/mesos-slave.override


# Install Docker
wget -qO- https://get.docker.com | sh

# Run swarm manager container on port 2375 (no auth)
sudo docker run --d -it -p 2375:2375 -p 3375:3375 swarm manage \
    -c mesos-experimental \
    --cluster-opt mesos.address=0.0.0.0 \
    --cluster-opt mesos.port=3375 mesos-master:5050

# Restart master process
sudo service mesos-master restart