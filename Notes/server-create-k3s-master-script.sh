set -x
set +x; source /home/stack/devstack/openrc demo demo > /dev/null; set -x
openstack server show k3s-master > /dev/null 2>&1
if [ $? -ne 0 ]; then
  # Prepare user data file for k3s master
  cat <<EOF > /home/stack/devstack/init_k3s.yaml
  #cloud-config
  manage_etc_hosts: \"localhost\"
  package_update: true
  runcmd:
    - update-ca-certificates
    - mkdir -p /var/lib/rancher/k3s/agent/images/
    - curl -sSL https://github.com/k3s-io/k3s/releases/download/v1.31.0+k3s1/k3s-airgap-images-amd64.tar -o /var/lib/rancher/k3s/agent/images/k3s-airgap-images.tar
    - curl -sSL https://github.com/k3s-io/k3s/releases/download/v1.31.0+k3s1/k3s -o /usr/local/bin/k3s
    - curl -sSL https://get.k3s.io -o /var/lib/rancher/k3s/install.sh
    - chmod u+x /var/lib/rancher/k3s/install.sh /usr/local/bin/k3s
    - INSTALL_K3S_SKIP_DOWNLOAD=true /var/lib/rancher/k3s/install.sh --disable traefik --disable metrics-server --disable servicelb --disable-cloud-controller --kubelet-arg=\"cloud-provider=external\" --tls-san 172.24.5.230 --token K1039d1cf76d1f8b0e8b0d48e7c60d9c4a43c2e7a56de5d86f346f2288a2677f1d7::server:2acba4e60918c0e2d1f1d1a7c4e81e7b
  write_files:
    - path: /usr/local/share/ca-certificates/registry-ca.crt
      content: |
$(awk '{printf \"        %s\
\", $0}' < /root/certs/ca.pem)
EOF
  # Create k3s master
    port_id=$(openstack port show k3s_master -c id -f value)
    openstack server create k3s-master --image ubuntu-jammy --flavor ds2G --key-name k3s_keypair --nic port-id=$port_id --user-data /home/stack/devstack/init_k3s.yaml --wait
  fi
  