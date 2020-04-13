#!/bin/bash
export USER_NAME="ceph-admin"
export USER_PASS="lab"
sudo useradd --create-home -s /bin/bash ${USER_NAME}
echo "${USER_NAME}:${USER_PASS}"|sudo chpasswd
echo "${USER_NAME} ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/${USER_NAME}
sudo chmod 0440 /etc/sudoers.d/${USER_NAME}
runuser -l ceph-admin -c 'ssh-keygen -N "" -f /home/ceph-admin/.ssh/id_rsa'
sudo apt install -y ntp python