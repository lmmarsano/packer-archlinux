#!/usr/bin/zsh
set -o verbose
pacman --noconfirm --sync davfs2 git emacs xorg-x{auth,host}
sed --in-place "/^#X11Forwarding/ {p
s/no/yes/
s/#//}" /etc/ssh/sshd_config
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAtOJ90/0C1kdI8Jo6YK0btIkKGK+YEWamrIR174nKIQRJbjsXO68fgS/LLd1nQQY7F2enn7qGM3CKnH7cioPJCXYWP8CrY+obT9oxhqmXI0LK+zZCekOcjEDneEuXHa5GiWTOLTBCghJvnB39ILklO727WD9RHPCeNQtCRKepDj0p8Z1002tId3zc9xkYEaZm4jlvdlqzyCnCr8+A9mwsEqP4IwnQ/mw8i10S3VN0ALpytAx5kD2hgVlpGIBUKR4h7ayzax4nJdBVfYQhiz1EH9uiaEB21GK8Q3iSB3Y2C8jF+U91cE36YxnO8KBFXTz3Q7MHC8RqBWbkTBuf0IP3NQ== rsa-key-20140410' >>~vagrant/.ssh/authorized_keys
