##################
# Configure a Node
##################

# The VM Name for the master should be passed in as a parameter
masterVMName=$1

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

# Force the root user for SWARM executors
echo export SWARM_MESOS_USER=daemon | sudo tee /etc/profile.d/swarm_user.sh

##################
# Configure Docker
##################

# Start Docker and listen on :2375 (no auth, but in vnet)
echo 'DOCKER_OPTS="-H unix:// -H 0.0.0.0:2375"' | sudo tee /etc/default/docker
sudo service docker restart

# Restart node process
sudo service mesos-slave restart