all: 
	packer build template.json
	
clean:
	rm -rf output* packer_cache

virtualbox:
	PACKER_LOG=1 PACKER_LOG_PATH="./packer-build-${date}.log" packer build -only=virtualbox-iso template.json
	
libvirt:
	packer build -only=qemu template.json

add-box:
	vagrant box add --force output/archlinux-ansible_virtualbox.box --name archlinux-ansible
