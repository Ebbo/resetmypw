#!/bin/bash

show_help() {
  echo "Usage: $0 [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  -h                Show this help message and exit."
  echo "  -n                Launch the script in non-interactive mode directly."
  exit 0
}

# Non-interactive fallback function
fallback_mode() {
  echo "Starting fallback mode (non-interactive)..."

  # Step 1: Select partition
  echo "Available partitions:"
  PARTITIONS=$(lsblk -ln -o NAME,FSTYPE,MOUNTPOINT | grep -v "part $" | grep -i "ext\|btrfs" | awk '{print $1}')
  if [ -z "$PARTITIONS" ]; then
    echo "No suitable partitions found. Ensure your disk is connected and try again."
    exit 1
  fi

  echo "$PARTITIONS"
  echo "Select the partition where your Linux system is installed (e.g., sda1 for /dev/sda1)."
  read -p "Enter the partition to mount (e.g., sda1): " SELECTED_PART

  MOUNT_DIR="/mnt/recovery"
  mkdir -p "$MOUNT_DIR"
  mount "/dev/$SELECTED_PART" "$MOUNT_DIR" || {
    echo "Failed to mount partition /dev/$SELECTED_PART. Exiting."
    exit 1
  }

  echo "Partition /dev/$SELECTED_PART successfully mounted at $MOUNT_DIR."

  # Step 2: List users
  USER_FILE="$MOUNT_DIR/etc/passwd"
  if [ ! -f "$USER_FILE" ]; then
    echo "The /etc/passwd file was not found. Ensure you selected the correct partition."
    exit 1
  fi

  USERS=$(awk -F: '{if ($3 >= 1000 && $3 != 65534) print $1}' "$USER_FILE")
  echo "Users on the system:"
  echo "$USERS"
  echo "Select the username for which you want to reset the password."
  read -p "Enter the username to reset the password for: " SELECTED_USER

  # Step 3: Set new password
  echo "Setting a new password for user $SELECTED_USER."
  echo "Enter a strong password that the user will use to log in."
  chroot "$MOUNT_DIR" passwd "$SELECTED_USER"

  # Cleanup
  echo "Cleaning up..."
  if umount "$MOUNT_DIR"; then
    echo "Unmounted successfully."
  else
    echo "Unmount failed. Forcing unmount..."
    fuser -km "$MOUNT_DIR" && umount -l "$MOUNT_DIR"
  fi

  # Offer reboot
  read -p "Do you want to reboot now? (y/N): " REBOOT_CHOICE
  if [[ "$REBOOT_CHOICE" =~ ^[Yy]$ ]]; then
    echo "Rebooting..."
    reboot
  else
    echo "Reboot skipped. Exiting."
  fi
}

# Parse arguments
while getopts ":hn" opt; do
  case $opt in
    h)
      show_help
      ;;
    n)
      fallback_mode
      exit 0
      ;;
    *)
      echo "Invalid option: -$OPTARG" >&2
      show_help
      ;;
  esac
done

# Check if `whiptail` is installed
if command -v whiptail &> /dev/null; then
  # Interactive mode with `whiptail`

  # Function to display a menu and return the selected option
  select_option() {
    local title="$1"
    local text="$2"
    shift 2
    local options=("$@")
    local result
    result=$(whiptail --title "$title" --menu "$text" 20 78 10 "${options[@]}" 3>&1 1>&2 2>&3)
    echo "$result"
  }

  # Step 1: Select partition
  PARTITIONS=$(lsblk -ln -o NAME,FSTYPE,MOUNTPOINT | grep -v "part $" | grep -i "ext\|btrfs" | awk '{print $1}')
  if [ -z "$PARTITIONS" ]; then
    whiptail --msgbox "No suitable partitions found.\n\nEnsure your disk is connected and try again." 8 60
    exit 1
  fi

  PARTITION_OPTIONS=()
  for PART in $PARTITIONS; do
    PARTITION_OPTIONS+=("$PART" "/dev/$PART")
  done

  SELECTED_PART=$(select_option "Partition Selection" \
    "Select the partition where your Linux system is installed." \
    "${PARTITION_OPTIONS[@]}")

  if [ -z "$SELECTED_PART" ]; then
    whiptail --msgbox "No partition selected. Exiting." 8 50
    exit 1
  fi

  MOUNT_DIR="/mnt/recovery"
  mkdir -p "$MOUNT_DIR"
  if ! mount "/dev/$SELECTED_PART" "$MOUNT_DIR"; then
    whiptail --msgbox "Failed to mount partition /dev/$SELECTED_PART.\n\nVerify your selection and try again." 8 70
    exit 1
  fi

  whiptail --msgbox "Partition /dev/$SELECTED_PART successfully mounted." 8 70

  # Step 2: Select user
  USER_FILE="$MOUNT_DIR/etc/passwd"
  if [ ! -f "$USER_FILE" ]; then
    whiptail --msgbox "The /etc/passwd file is missing.\n\nEnsure you selected the correct partition." 8 70
    exit 1
  fi

  USERS=$(awk -F: '{if ($3 >= 1000 && $3 != 65534) print $1}' "$USER_FILE")
  USER_OPTIONS=()
  for USER in $USERS; do
    USER_OPTIONS+=("$USER" "")
  done

  SELECTED_USER=$(select_option "User Selection" \
    "Select the user account for which you want to reset the password." \
    "${USER_OPTIONS[@]}")

  if [ -z "$SELECTED_USER" ]; then
    whiptail --msgbox "No user selected. Exiting." 8 50
    exit 1
  fi

  # Step 3: Reset password
  NEW_PASSWORD=$(whiptail --passwordbox "Enter the new password for user $SELECTED_USER:\n\nUse a strong password." 10 70 3>&1 1>&2 2>&3)

  if [ -z "$NEW_PASSWORD" ]; then
    whiptail --msgbox "No password entered. Exiting." 8 50
    exit 1
  fi

  if echo -e "$NEW_PASSWORD\n$NEW_PASSWORD" | chroot "$MOUNT_DIR" passwd "$SELECTED_USER"; then
    whiptail --msgbox "Password for user $SELECTED_USER successfully updated." 8 70
  else
    whiptail --msgbox "Password update failed. Please try again." 8 70
    exit 1
  fi

  # Cleanup
  if umount "$MOUNT_DIR"; then
    whiptail --msgbox "Unmounted successfully." 8 50
  else
    whiptail --msgbox "Unmount failed.\n\nAttempting forced unmount..." 8 70
    fuser -km "$MOUNT_DIR" && umount -l "$MOUNT_DIR"
  fi

  # Offer reboot
  if whiptail --title "Reboot" --yesno "Do you want to reboot now?" 8 50; then
    reboot
  else
    whiptail --msgbox "Reboot skipped.\n\nYou can manually reboot later." 8 50
  fi
else
  # Fallback to non-interactive mode
  echo "whiptail not found. Switching to non-interactive fallback mode."
  fallback_mode
fi
