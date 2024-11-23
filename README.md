
# 🔐 Password Recovery Script

Easily reset a forgotten password on your Linux system using this script! Designed for both **interactive** and **non-interactive** modes, this script guides you through mounting your system partition, selecting a user, and setting a new password.

---

## 🖥 Prerequisites

To reset a user's password, you'll need a **live USB stick** with a Linux distribution of your choice.

### Create a Live USB Stick:
1. Download [Ventoy](https://www.ventoy.net/en/download.html) to easily manage bootable USB drives.
2. Install Ventoy on your USB stick.
3. Add the ISO file of your preferred Linux distribution to the Ventoy drive.
4. Boot from the USB stick on the system where you need to reset the password.

---

## 🛠 Features

- **Interactive Mode**: User-friendly menus for selecting partitions and users.
- **Non-Interactive Mode**: Quickly reset passwords via a terminal.
- **Auto Partition Detection**: Automatically lists available system partitions.
- **Reboot Option**: Prompts to reboot after completing the process.

---

## 🚀 Quick Start

Run the script directly using `curl`:

```bash
curl -fsSL https://raw.githubusercontent.com/ebbo/resetmypw/master/resetmypw.sh -o /tmp/resetmypw.sh && sudo bash /tmp/resetmypw.sh
```

> **⚠️ Important:** Ensure the script source is trusted before executing it.

---

## 📚 Usage

```bash
sudo ./resetmypw.sh [OPTIONS]
```

### Options:
| Option | Description                           |
|--------|---------------------------------------|
| `-h`   | Show help message and usage examples. |
| `-n`   | Launch non-interactive mode directly. |

---

## 🔍 How It Works

1. **Partition Selection**:
   - Detects and lists all available system partitions.
   - In interactive mode, you select the correct partition.
   - In non-interactive mode, you input the partition manually.

2. **User Selection**:
   - Reads valid user accounts from `/etc/passwd`.
   - Interactive mode presents a clean menu for selection.
   - Non-interactive mode requires manual username input.

3. **Password Reset**:
   - Prompts for a new password for the selected user.
   - Ensures secure password entry.

4. **Reboot Option**:
   - After completing the process, you can choose to reboot or exit.

---

## 📂 Contributing

Contributions are welcome! Feel free to fork the repository, make improvements, and submit a pull request. 🤝

---

## 📝 License

This project is licensed under the [MIT License](LICENSE).

---

### ✨ Stay Connected

🌟 If you find this project useful, consider starring the repository to show your support!
