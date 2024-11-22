#!/bin/bash

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root."
  exit 1
fi

echo "Starting user password recovery routine..."

# Find and mount the disk
echo "Searching for available partitions..."
PARTITIONS=$(lsblk -ln -o NAME,FSTYPE,MOUNTPOINT | grep -v "part $" | grep -i "ext\|btrfs" | awk '{print $1}')

if [ -z "$PARTITIONS" ]; then
  echo "No suitable partitions found."
  exit 1
fi

echo "Found partitions:"
echo "$PARTITIONS"

read -p "Please enter the partition to mount (e.g., sda1): " SELECTED_PART

MOUNT_DIR="/mnt/recovery"

mkdir -p "$MOUNT_DIR"
mount "/dev/$SELECTED_PART" "$MOUNT_DIR" || { echo "Failed to mount the partition."; exit 1; }

echo "Partition successfully mounted at $MOUNT_DIR."

# List users
echo "Users on the system:"
USER_FILE="$MOUNT_DIR/etc/passwd"
if [ ! -f "$USER_FILE" ]; then
  echo "The /etc/passwd file was not found. Please check the mounted partition."
  exit 1
fi

USERS=$(awk -F: '{if ($3 >= 1000 && $3 != 65534) print $1}' "$USER_FILE")
echo "$USERS"

read -p "Please select a user: " SELECTED_USER

# Set a new password for the selected user
echo "Setting a new password for user $SELECTED_USER."
chroot "$MOUNT_DIR" passwd "$SELECTED_USER"

# Cleanup
umount "$MOUNT_DIR"
rmdir "$MOUNT_DIR"
echo "Done. Password has been changed, and the system has been cleaned up."
