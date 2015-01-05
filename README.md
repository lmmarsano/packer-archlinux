# [Arch Linux](//www.archlinux.org/) Base Box for [Vagrant](//www.vagrantup.com/)

These [Packer](//packer.io/) templates and scripts build and update an [Arch Linux](//www.archlinux.org/) x86-64 base box for [Vagrant](//www.vagrantup.com/) hosted on [Atlas](//atlas.hashicorp.com/lmmarsano/boxes/archx86-64).
Examine these files to see everything that went into the box.
If you install packer and [VirtualBox](//www.virtualbox.org/), you may also use these templates to build and update the box.

# Adding the Box to Vagrant

No building is necessary.
Vagrant will download it from my repository.

`vagrant add lmmarsano/archx86-64`

# Build/Update
## Requirements

- [Packer](//packer.io/)
- [VirtualBox](//www.virtualbox.org/)

## Instructions

On the console, you'd change path to a directory containing these files

1. `git clone https://github.com/lmmarsano/packer-archlinux.git`
2. `cd packer-archlinux`

Then do either of the following:

- build:

	`packer build build.json`

- update:
	The box will need to be unpacked: unpack it yourself (boxes are compressed tarballs) or let Vagrant unpack it for you (add the box to Vagrant; Vagrant unpacks it under `~/.vagrant.d/boxes/`*tag*`/`*version*`/`)
	For a box unpacked at path *path/to/unpacked-box/*

	`packer build -var 'source_path=`*path/to/unpacked-box*`' update.json`

The last step, to upload it to my repository, will fail, but you'll still get the resulting `.box` file, ready to add to vagrant.

# Box Information

This vagrant box comes with modern virtual hardware defaults and keeps to [a standard, base install of Arch](//wiki.archlinux.org/index.php/Installation_guide) with only minor additions for usability.
For boot time and performance, it uses EFI firmware, the faster SATA storage controllers, enhanced USB controllers, and the faster virtio-net network interface.
For flexibility, it allows CPU hotplugging to change the number of CPUs, and Linux has the hard disk managed through [LVM](//wiki.archlinux.org/index.php/Lvm) to allow volume resizes and snapshots.

## Login Credentials

- root: passwordless
- vagrant: password "vagrant"

## Default Locale

- en_US.UTF-8
- keymap for standard US keyboard
- default console font

## VM Specifications

- EFI firmware
- CPU hotplugging enabled
- SATA storage controller
- Enhanced USB controller
- virtio network interface
- dynamic hard disk (up to 40 GiB)
- 512 MiB RAM

## Software

- [Base packages](//www.archlinux.org/groups/x86_64/base/)
- openSSH
- VirtualBox Guest Additions
- [gummiboot](//wiki.archlinux.org/index.php/Gummiboot) bootloader
- [LVM](//wiki.archlinux.org/index.php/Lvm)
- [zsh](//wiki.archlinux.org/index.php/Zsh) with auto-completion (bash compatible, featured in the Arch install environment)
- [reflector](//wiki.archlinux.org/index.php/Reflector) to optimize the package manager's mirror list
- curl
- ed, the standard editor

## Configuration

- /dev/sda1 (mounted on /boot) is an EFI System Partition; all other volumes are managed by LVM
- [reflector](//wiki.archlinux.org/index.php/Reflector) runs weekly
- [systemd](//wiki.archlinux.org/index.php/Systemd-networkd) manages networking (through systemd-networkd, systemd-resolved)