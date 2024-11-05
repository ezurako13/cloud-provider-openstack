#* How to fix k3s installation
# Find the line;
	openstack subnet set private-subnet --dns-nameserver 8.8.8.8 || true
#in the file;
	/<WHEREVER YOU PLACED THE FOLDER>/cloud-provider-openstack/tests/playbooks/roles/install-k3s/tasks/main.yml
# It was under the scope of "- name: Create openstack resources" in my case.

# Replace with;
	openstack subnet set private-subnet --dns-nameserver 10.1.34.5 --dns-nameserver 10.1.34.6 || true
# That dns-nameservers are the ones that we use in B3Lab network to be able to connect to the internet.



#* How to fix ssh connection
# Run the ansible command with added this option to the ssh-common-args;
	-i ~/.ssh/copilot-keypair.pem
# At the end, it should look like this (at least in my case);
	ansible-playbook -v   --user ubuntu   --inventory 10.8.135.112,   --ssh-common-args " -i ~/.ssh/copilot-keypair.pem -o StrictHostKeyChecking=no"   tests/playbooks/test-occm-e2e.yaml   -e octavia_provider=amphora   -e run_e2e=false
	ansible-playbook -v   --user ubuntu   --inventory 10.8.135.112,   --ssh-common-args " -o StrictHostKeyChecking=no"   tests/playbooks/test-occm-e2e.yaml   -e octavia_provider=amphora   -e run_e2e=false
#* Just found better and permenent solution for this issue;
# Create a file named "ansible.cfg" with the following content (of course, change the values according to your needs);
	[defaults]
	inventory = 10.8.129.127
	remote_user = ubuntu
	private_key_file = ~/.ssh/copilot-keypair.pem
	host_key_checking = False
# And then run the ansible command without any ssh-common-args and with ANSIBLE_CONFIG environment variable like this ;
	ANSIBLE_CONFIG=./Notes/ansible.cfg ansible-playbook -v \
	  --user ubuntu \
	  --inventory 10.8.129.127, \
	  --ssh-common-args " -o StrictHostKeyChecking=no" \
	  tests/playbooks/test-occm-e2e.yaml \
	  -e octavia_provider=amphora \
	  -e run_e2e=false



#* (Out of context) I had also added horizon to the ansible playbook to be able to access the OpenStack dashboard.
# It was in the file;
	/<WHEREVER YOU PLACED THE FOLDER>/cloud-provider-openstack/tests/playbooks/test-occm-e2e.yaml
# Like this;
	roles:
    .
	.
    - role: install-devstack
      enable_services:
        - horizon
		.
		.
#* Apperantly, not works so, you can forget it.
