step 1: apt install -y packer
step 2: packer plugins install github.com/hashicorp/virtualbox
step 3: packer plugins install github.com/hashicorp/vagrant
step 4: packer validate ubuntu2004.pkr.hcl
step 5: packer build ubuntu2004.pkr.hcl
