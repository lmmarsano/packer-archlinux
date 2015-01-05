#!/usr/bin/zsh
set -o verbose
#partition disk
sgdisk --clear \
       --new=0:0:+512M --typecode=0:ef00 \
			 --new=0:0:0 --typecode=0:8e00 \
			 /dev/sda
pvcreate /dev/sda2
vgcreate vg /dev/sda2
lvcreate vg --name lvroot --size 10G
lvcreate vg --name lvvar --size 5G
lvcreate vg --name lvhome --size 1G
#format volumes
mkfs.fat -F32 /dev/sda1
for i in /dev/mapper/vg-lv*
do
		mkfs.ext4 $i
done
#mount disk
mount /dev/vg/lvroot /mnt
mkdir /mnt/{boot,home,var}
mount /dev/sda1 /mnt/boot
for i in {home,var}
do
		mount /dev/vg/lv$i /mnt/$i
done
#install
pacstrap /mnt base reflector rsync zsh grml-zsh-config zsh-completions
sed --in-place '/^SHELL=/ s/bash/zsh/' /mnt/etc/default/useradd
echo 'autoload -U compinit
compinit' >>/mnt/etc/zsh/zshrc
genfstab -p /mnt >>/mnt/etc/fstab
#setup and copy network
for i in stop disable
do
		systemctl $i netctl dhcpcd.service systemd-networkd
done
cat <<eof >/etc/systemd/network/ethernet.network
[Match]
Name=eth*
[Network]
DHCP=v4
eof
for i in enable start
do
		systemctl $i systemd-{network,resolve}d
done
ln --symbolic --force /run/systemd/resolve/resolv.conf /etc/
cp --parents /etc/systemd/network/ethernet.network /etc/sudoers.d/g_wheel /mnt
#change root
arch-chroot /mnt <<EOF
set -o verbose
chsh --shell $(which zsh)
#update mirror service
reflector='/usr/bin/reflector --connection-timeout 5 --protocol http --latest 15 --fastest 10 --sort rate --save /etc/pacman.d/mirrorlist'
\$reflector
cat <<eof >/etc/systemd/system/reflector.service
[Unit]
Description=Pacman mirrorlist update
[Service]
Type=oneshot
ExecStart=\$reflector
eof
cat <<eof >/etc/systemd/system/reflector.timer
[Unit]
Description=Run reflector weekly
[Timer]
OnCalendar=weekly
AccuracySec=12h
Persistent=true
[Install]
WantedBy=timers.target
eof
mkdir --parents /etc/systemd/system/timers.target.wants/
ln --symbolic /etc/systemd/system/reflector.timer /etc/systemd/system/timers.target.wants/
pacman-db-upgrade
#setup services
pacman --noconfirm --sync --refresh --refresh openssh sudo ed curl virtualbox-guest-utils mesa-libgl gummiboot
for i in systemd-{network,resolve}d sshd vboxservice
do
ln --symbolic /usr/lib/systemd/system/\$i.service /etc/systemd/system/multi-user.target.wants/
done
#build initramfs
sed --in-place '/^MODULES/ s/""/"dm_snapshot"/
/^HOOKS/ s/\(block\) \(file\)/\1 lvm2 \2/' /etc/mkinitcpio.conf
mkinitcpio --preset linux
#bootloader
/usr/bin/gummiboot install
cat <<eof >/boot/loader/entries/arch.conf
title Arch Linux
efi /vmlinuz-linux
options root=/dev/mapper/vg-lvroot dolvm rw initrd=initramfs-linux.img
eof
echo 'default arch
#timeout 3' >/boot/loader/loader.conf
#set locale
sed --in-place '/^#$locale/ s/#//' /etc/locale.gen
locale-gen
systemd-firstboot --locale=$locale --root-password=$root_password
# --timezone=$timezone
mandb --quiet
#add user
useradd --create-home --groups wheel,vboxsf $username
chpasswd <<<"$username:$password"
mkdir --parents --mode=700 ~$username/.ssh
curl --location https://github.com/mitchellh/vagrant/raw/master/keys/vagrant.pub --output ~$username/.ssh/authorized_keys
chmod 600 ~$username/.ssh/authorized_keys
chown --recursive $username:$username ~$username/.ssh
#clean
pacman --noconfirm --sync --clean --clean
find /var/log -type f -execdir sh -c "echo -n >{}" \;
for i in {,/{home,var}}/fillfile
do
dd if=/dev/zero of=\$i bs=4M
rm \$i
done
#clear history
[ -f /root/.bash_history ] && rm /root/.bash_history
EOF
ln --symbolic --force /run/systemd/resolve/resolv.conf /mnt/etc/
umount --recursive /mnt
