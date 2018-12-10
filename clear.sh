#!/bin/bash

slave_size=$1

delete_file=$2

if [[ $slave_size -eq '' ]]; then
    echo "Size of slaves not specified; quit"
    exit
fi

#stop&rm containers
echo "======================================"
echo "Stop and Remove Containers"
echo "======================================"
for((i=1;i<=$slave_size;i++))
{
    sudo docker container stop slave$i
#    sudo docker container rm slave$i
}

#remove image
echo "======================================"
echo "Remove Image"
echo "======================================"
image_id=`sudo docker images -f reference="hadoop_slave" -q`
sudo docker image rm $image_id


#rm subnet
echo "======================================"
echo "Remove Subnet"
echo "======================================"
sudo docker network rm hadoopnetwork

#delete hosts
echo "======================================"
echo "Delete Hosts"
echo "======================================"
for((i=1;i<=$slave_size;i++))
{
    sudo sed -i "/slave$i/d" /etc/hosts
}


#delete env
echo "======================================"
echo "Delete Env"
echo "======================================"
sudo sed -i "/HADOOP_CONF_DIR=/d" /etc/profile
source /etc/profile

if [[ delete_file -eq '-d' ]]; then
    sudo rm -rf /cluster
fi
