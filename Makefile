all: 
	packer build template.json
	
clean:
	rm -rf output* packer_cache

virtualbox:
	packer build -only=virtualbox-iso template.json
	
libvirt:
	packer build -only=qemu template.json
