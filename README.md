This is my Homelab infrastructure.

# Requirements

- Ansible (version >= 2.9.6)
	- Python3 and Pip
- Packer (version >= 1.6.0)
- Terraform (version >= 0.12.28)
	- Terragrunt (version >= 0.23.29)

Fill ansible/secrets.yml based on ansible/secrets.example and encrypt the file with ansible-vault

# Ansible
`cd ansible`  

Install dependencies `pip3 install -r requirements.txt`

fill all `secrets.yml` based on `secrets.example` in each subdirectory of `groups_vars`

### Playbooks to add fingerprint on know_hosts
`ansible-playbook -i <inventory_file> playbooks/add-ssh-keys.yml`  

### Playbooks to deploy SSH configuration
`ansible-playbook -i <inventory_file> playbooks/deploy_authorized_keys.yml`  

### Playbooks to deploy dmz
`ansible-playbook -i dmz deploy_dmz.yml`

### Playbooks to deploy lab
`ansible-playbook -i lab deploy_lab.yml`

# Packer
Port 8888 used for debian build
Port 8889 used for ubuntu build

Open both ports on windows firewall  
Start powershell prompt with admin right `netsh interface portproxy add v4tov4 listenport=<PORT> listenaddress=<IP> connectport=<PORT> connectaddress=127.0.0.1`  
Replace <IP> with the LAN IP of your PC and <PORT> with [8888, 8889]
To delete the rules `netsh interface portproxy del v4tov4 listenport=<PORT>  listenaddress=<IP>`

`cd packer`

Supported distributions :
- Debian (10.4.0) - [iso](https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-10.4.0-amd64-netinst.iso)  
- Ubuntu (20.04) - [iso](http://cdimage.ubuntu.com/ubuntu-server/daily/current/focal-legacy-server-amd64.iso)

### Create template
Linux : `./build.sh`  
Windows : `./build.ps1`

### Validate syntax template
Linux : `./validate.sh`  
Windows : `./validate.ps1`

# Terraform
`cd terraform`  

Install dependencies `< packages.txt xargs sudo apt-get install -y`

fill `account.hcl` based on `account.example`

Infrastructure is split in 2 parts :  
- dmz
- lab

**Command must be run in one of this two directories (dmz/lab)**

### Create an execution plan
`terragrunt plan-all`

### Deploy/update infrastructure
`terragrunt apply-all`

# Credits

Copyright © Ludovic Ortega, 2019

Contributor(s):

-Ortega Ludovic - mastership@hotmail.fr