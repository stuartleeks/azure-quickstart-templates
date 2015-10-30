This is a sample template to create a Docker Swarm cluster with Apache Mesos
on Azure. 

The Swarm created is not secure it is **not recommended for the production.**

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Frgardler%2Fazure-quickstart-templates%2Fmesos%2Fdocker-swarm-mesos-cluster-simple%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

Once your cluster has been created you will have a resource group containing a
number of VMs acting as nodes (configure this in your parameters) and another
which is your master. 

To connect to this swarm with Docker you need to set your environment with:

```sh
export DOCKER_TLS_VERIFY=
export DOCKER_HOST="tcp://YOURDNSNAME.eastus.cloudapp.azure.com:2375"
```

Note this turns off TLS (i.e. it is insecure) - **do not use in production**.
You need to replace 'YOURDNSNAME' with the DNS name you provide in the
parameters.

You can also view the mesos dashboard by visiting your the
YOURDNSNAME.eastus.cloudapp.net:5050

Below are the parameters that the template expects:

| Name   | Description    |
|:--- |:---|
| storageAccountName  | Name for the Storage Account where the Virtual Machine's disks will be placed.If the storage account does not aleady exist in this Resource Group it will be created. |
| adminUsername  | Username for the Virtual Machines  |
| adminPassword  | Password for the Virtual Machines  |
| dnsNameForPublicIP  | Unique DNS Name for the Public IP used to access the master Virtual Machine. |
| nodeCount | The number of nodes to create in addition to the master. |
