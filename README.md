# resetmypw

This repository contains a **Bash script** to recover and reset a forgotten user password on a Linux system. The script is designed to be run from a **live Linux environment** and automates the process of mounting the system's disk, selecting a user, and resetting their password.

---

## Features

- **Partition Detection**: Automatically detects available partitions and prompts for selection.
- **User Listing**: Lists valid system users (UID ≥ 1000) for selection.
- **Password Reset**: Allows setting a new password for the selected user.
- **Cleanup**: Unmounts the disk and removes temporary directories after execution.

---

## How to Use

### Prerequisites

1. Boot into a **live Linux environment** (e.g., Ubuntu Live USB).
2. Make sure the target disk is connected and accessible.

### Steps

1. Clone this repository or download the script:

   ```bash
   git clone https://github.com/your-username/password-recovery-script.git
   cd password-recovery-script
   ```

2. Make the script executable:

   ```bash
   chmod +x reset_password.sh
   ```

3. Run the script as root:

   ```bash
   sudo ./reset_password.sh
   ```

4. Follow the prompts to:
   - Select the target partition.
   - Choose a user from the listed accounts.
   - Set a new password for the selected user.

---

## Quick Run with `curl`

You can run the script directly without cloning the repository:

```bash
curl -fsSL https://raw.githubusercontent.com/Ebbo/resetmypw/master/resetmypw.sh | sudo bash
```

> ⚠️ **Note**: Only execute scripts from trusted and verified sources.

---

## Example Output

```plaintext
Starting user password recovery routine...
Searching for available partitions...
Found partitions:
sda1
sda2
Please enter the partition to mount (e.g., sda1): sda2
Partition successfully mounted at /mnt/recovery.
Users on the system:
john
jane
Please select a user: john
Setting a new password for user john.
Enter new UNIX password:
Retype new UNIX password:
passwd: password updated successfully
Unmounting and cleaning up...
Done. Password has been changed, and the system has been cleaned up.
```

---

## Contribution

Contributions are welcome! Feel free to fork this repository, make improvements, and submit a pull request.

---

## License

This project is licensed under the MIT License.

---

## Disclaimer

- This script is for recovery purposes and should be used responsibly.
- Test in a safe environment before using it on production systems.
- The script assumes the target disk has a standard Linux filesystem structure.

---

For any issues, open an issue on the [GitHub repository](https://github.com/ebbo/resetmypw).
