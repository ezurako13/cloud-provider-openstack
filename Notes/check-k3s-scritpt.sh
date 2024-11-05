ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /root/.ssh/id_rsa ubuntu@172.24.5.230 
sudo chmod 777 /etc/rancher/k3s/k3s.yaml