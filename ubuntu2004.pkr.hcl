packer {
  required_version = ">= 1.7.0"
  required_plugins {
    virtualbox = {
      version = ">= 1.0.1"
      source  = "github.com/hashicorp/virtualbox"
    }
    vagrant = {
      version = ">= 1.1.1"
      source  = "github.com/hashicorp/vagrant"
    }
  }
}

locals {
  version = formatdate("YYYY.MM.DD", timestamp())
}

variable "name" {
  type    = string
  default = "ubuntu2004"
}

variable "cpus" {
  type    = string
  default = "2"
}

variable "memory" {
  type    = string
  default = "4096"
}

variable "disk_size" {
  type    = string
  default = "20480"
}
variable "iso_url" {
  type    = string
  default = "/home/mohammad/ubuntu-box/ubuntu-20.04.4-live-server-amd64.iso"
}
source "virtualbox-iso" "efi" {
  boot_command = [
    "c",
    "linux /casper/vmlinuz autoinstall net.ifnames=0 biosdevname=0 ",
    "ds='nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/' --- <enter><wait>",
    "initrd /casper/initrd<enter><wait>",
    "boot<enter>"
  ]
  boot_wait      = "5s"
  communicator   = "ssh"
  vm_name        = "packer-${var.name}"
  cpus           = "${var.cpus}"
  memory         = "${var.memory}"
  disk_size      = "${var.disk_size}"
  http_directory = "http"
  ssh_username   = "vagrant"
  ssh_password   = "vagrant"
  ssh_port       = 22
  ssh_timeout    = "3600s"
  firmware       = "efi"
  iso_checksum	 = "md5:bf83ce95c8c002669f3a78d34422d08e" 
  iso_urls      = ["${var.iso_url}"]
  vboxmanage            = [
                            ["modifyvm", "{{.Name}}", "--nat-localhostreachable1", "on"],
                          ]  
  guest_os_type    = "Ubuntu_64"
  output_directory = "builds/${var.name}-${source.name}-${source.type}"
  shutdown_command = "echo 'vagrant' | sudo -S shutdown -P now"
}
build {
  sources = ["sources.virtualbox-iso.efi"]

  provisioner "shell" {
    execute_command   = "echo 'vagrant' | {{ .Vars }} sudo -S -E sh -eux '{{ .Path }}'"
    scripts           = ["scripts/setup.sh"]
    expect_disconnect = true
  }
  post-processors {
    post-processor "vagrant" {
      output = "builds/${var.name}-{{.Provider}}.box"
    }

  }
}
