#!/usr/bin/zsh
set -o verbose
#clean
pacman --noconfirm --sync --clean --clean
#find /var/log -type f -execdir sh -c "echo -n >{}" \; #causes shutdown failures
for i in {,/{home,var}}/fillfile
do
		dd if=/dev/zero of=$i bs=4M
		rm $i
done
#clear history
[ -f /root/.bash_history ] && rm /root/.bash_history
