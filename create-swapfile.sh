#!/usr/bin/env bash


# To create a new swap file, we will use the fallocate command. 
# This command creates a file with a specified size. 

echo
echo -n ">>> Enter size of swap file in GB (e.g. 1, 2, 4 or 16) : "
read SIZE

echo
echo ">>> Allocating $SIZE GB to /swapfile"
sudo fallocate -l ${SIZE}G /swapfile


# Next, we need to restrict access to the swap file to root only. Run the following command:
sudo chmod 600 /swapfile


# Enabling the Swap File
echo
echo ">>> Enabling swap file"
sudo /usr/sbin/mkswap /swapfile
sudo /usr/sbin/swapon /swapfile

# To make the swap file permanent, we need to add it to the /etc/fstab file.
sudo echo "/swapfile swap swap defaults 0 0" >> /etc/fstab