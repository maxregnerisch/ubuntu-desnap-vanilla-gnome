#!/bin/bash

# Prepare the environment for the script
dbus-uuidgen > /var/lib/dbus/machine-id
dpkg-divert --local --rename --add /sbin/initctl
ln -s /bin/true /sbin/initctl
mount -t proc none /proc
mount -t sysfs none /sys
mount -t devpts none /dev/pts
export HOME=/root
export LC_ALL=C

# Get the latest kernel version
KERNEL=$(ls -Art /lib/modules | tail -n 1)

# Rename the initrd and vmlinuz files
mv "/boot/initrd.fromiso" "/boot/initrd.img-$KERNEL"
mv "/boot/vmlinuz.fromiso" "/boot/vmlinuz-$KERNEL"

# Change directory to the build folder
cd /build/

# Run the remix script and remove unnecessary packages
bash remix.sh && apt-get autoremove -y --purge

# Clean up the environment
update-initramfs -k all -u
apt-get clean
rm -f /var/lib/apt/lists/*_Packages
rm -f /var/lib/apt/lists/*_Sources
rm -f /var/lib/apt/lists/*_Translation-*
rm -rf /tmp/* ~/.bash_history
echo -n > /etc/machine-id
rm -f /var/lib/dbus/machine-id
rm /sbin/initctl
dpkg-divert --rename --remove /sbin/initctl
umount /proc || umount -lf /proc
umount /sys
umount /dev/pts
