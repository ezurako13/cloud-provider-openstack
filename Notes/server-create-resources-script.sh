set -x
cd /home/stack/devstack

set +x; source openrc admin admin > /dev/null; set -x
openstack image show ubuntu-jammy > /dev/null 2>&1

if [[ \"$?\" != \"0\" ]]; then
# retry ubuntu image download on failure,
# e.g. \"curl: (35) OpenSSL SSL_connect: Connection reset by peer in connection to cloud-images.ubuntu.com:443\"
tries=0
until [ \"$tries\" -ge 5 ]; do
	curl -sSL https://cloud-images.ubuntu.com/releases/jammy/release/ubuntu-22.04-server-cloudimg-amd64.img -o ubuntu-jammy.img && break
	echo \"Error downloading an image\"
	((tries++))
	sleep 10
done
openstack image create ubuntu-jammy --container-format bare --disk-format qcow2 --public --file ubuntu-jammy.img
fi

set +x; source openrc demo demo > /dev/null; set -x
openstack keypair show k3s_keypair > /dev/null 2>&1
if [[ \"$?\" != \"0\" ]]; then
test -e /root/.ssh/id_rsa || ssh-keygen -t rsa -b 4096 -N \"\" -f /root/.ssh/id_rsa
openstack keypair create --public-key /root/.ssh/id_rsa.pub k3s_keypair
fi

openstack security group show k3s_sg > /dev/null 2>&1
if [[ \"$?\" != \"0\" ]]; then
openstack security group create k3s_sg
openstack security group rule create --proto icmp k3s_sg
openstack security group rule create --protocol tcp --dst-port 1:65535 k3s_sg
openstack security group rule create --protocol udp --dst-port 1:65535 k3s_sg
fi

openstack subnet set private-subnet --dns-nameserver 8.8.8.8 || true
