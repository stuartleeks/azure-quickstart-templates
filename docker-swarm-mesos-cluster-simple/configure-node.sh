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

# Disable and stop zookeeper
sudo service zookeeper stop
echo manual | sudo tee /etc/init/zookeeper.override

# Configure zk
echo "zk://mesos-master:2181/mesos" | sudo tee /etc/mesos/zk

# Stop and disable mesos-master
sudo service mesos-master stop
echo manual | sudo tee /etc/init/mesos-master.override

# Install docker and listen on :2375 (no auth, but in vnet)
wget -qO- https://get.docker.com | sh
echo 'DOCKER_OPTS="-H unix:// -H 0.0.0.0:2375"' | sudo tee /etc/default/docker
sudo service docker restart

# Add docker containerizer
echo "docker,mesos" | sudo tee /etc/mesos-slave/containerizers

# Restart slave process
sudo service mesos-slave restart