<div align="center">

# 🐧 OmniPKG — Universal Package Bootstrapper

**One script. Any distro. Any package manager. Zero manual hunting.**

![Version](https://img.shields.io/badge/version-v2.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Shell](https://img.shields.io/badge/shell-bash-1f425f)
![Python](https://img.shields.io/badge/python-3-yellow)
![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS%20%7C%20Windows-orange)

</div>

---


## 📖 About

**OmniPKG** is a smart, cross-platform package bootstrapper. Point it at any system — Debian, Fedora, Arch, macOS, even Windows — and it detects the right package manager, updates your system, installs your package list, and cleans up after itself. No more remembering whether it's `apt`, `dnf`, `pacman`, `brew`, or `winget`.

Built for people who set up a new machine often and are tired of looking up install commands every single time.

---

## ✨ What's New in v2.4.0

- 🗂️ **Unified config file** — package lists and package-manager commands now live in a single `packages.json`, no more juggling two separate files
- 🌍 **Massive package manager coverage** — `apt`, `dnf`, `yum`, `pacman`, `zypper`, `apk`, `xbps`, `eopkg`, `emerge`, `nix`, `guix`, `pkg`, `brew`, `flatpak`, `snap`, `winget`, `choco`, `scoop`, `pkgin`, `opkg`, `swupd`, `urpmi`, `tdnf` — 22 package managers out of the box
- 🔐 **One-time sudo prompt** — enter your password once, the script keeps your session alive in the background instead of asking every step
- ⏳ **Live spinner & progress feedback** — animated spinner and progress dots so you always know something's happening, not frozen
- 🎨 **Fully redesigned terminal UI** — boxed banner, color-coded sections, cleaner status messages
AI-assisted UI/Documentation. Core architecture and project logic designed and implemented by the author.
- 🧹 **Automatic post-install cleanup** — orphaned packages and caches removed automatically per package manager
- 🐋 **Docker automation suite** — complete Docker image creator with `docker-compose.yml`, automated setup script, and dedicated engine-syntax modules for installing, removing, and managing Docker packages and repositories

---

## ⚙️ How It Works

```
📂 omniPKG
[CAgent_47]omniPKG
├── omnipkg.sh                      # Main entry point script
├── core/                           # Core functionality modules
│   ├── packages.json               # Central config: pkg manager commands + package lists
│   ├── updatePKG.py                # Detects pkg manager & returns update command
│   ├── installPKG.py               # Returns install command for detected pkg manager
│   └── cleanPKG.py                 # Returns cleanup command for detected pkg manager
├── dockerfile/                     # Docker automation suite
│   └── Dockerimage/                # Docker image build context
│       ├── dockerimg/              # Mounted core scripts & main script for Docker
│       │   ├── core/               # (Mirror of main core/ for container usage)
│       │   │   ├── packages.json
│       │   │   ├── updatePKG.py
│       │   │   ├── installPKG.py
│       │   │   └── cleanPKG.py
│       │   └── omnipkg.sh          # (Mirror of main script for container)
│       ├── engine-syntax/          # Docker engine management modules
│       │   ├── dockerinstall.json  # Docker setup commands per pkg manager
│       │   ├── dockermadule.py     # Modularized Docker functions (all Python logic)
│       │   ├── install.py          # Prints Docker pkg install command
│       │   ├── autoremove.py       # Prints command to remove invalid Docker pkgs
│       │   ├── setup-Repository.py # Prints repo setup command for Docker
│       │   ├── createjson.py       # Creates dockerinstall.json if missing
│       │   └── dchange.py          # Checks Dockerfile changes & prints compose command
│       ├── docker-compose.yml      # Docker Compose orchestration file
│       └── docker-setup.sh         # Automation script for Docker prerequisites & setup
├── Guide/                          # Documentation & user guidance
│   └── guid.html                   # Simple web page guide for the project
├── Images/                         # (Optional) Project images/screenshots
├── README.md                       # Project documentation
└── SECURITY.md                     # Security policy & notes
```

Every package manager's `update`, `install`, and `clean` commands are defined once in `packages.json` — the Python helpers just look up the right block for your system and hand the shell script a ready-to-run command.

---

## 🚀 Installation & Usage

```bash
git clone https://github.com/CAgent47/OmniPKG.git
cd OmniPKG
chmod +x omnipkg.sh
./omnipkg.sh
```

You'll be asked for your sudo password once at the start — after that, the whole process runs unattended through update → install → cleanup.

---

## 📂 Project Structure

```
OmniPKG/
├── omnipkg.sh              # main entry point
├── core/
│   ├── packages.json       # package manager commands + package list, all in one place
│   ├── updatePKG.py        # detects package manager, returns the update command
│   ├── installPKG.py       # returns the install command for the detected package manager
│   └── cleanPKG.py         # returns the cleanup command for the detected package manager
└── README.md
```

---

## 🛠️ Requirements

| Requirement | Notes |
|---|---|
| Bash | any modern version |
| Python 3 | used by the `core/` scripts |
| sudo access | needed for system-level package installs |
| A supported package manager | see the list above — 22 supported |

---

## 📝 Customizing Packages

Open `core/packages.json` and edit the `install` line for your package manager. Each package manager has its own block with `update`, `install`, and `clean` commands:

```json
"apt": {
    "update": "sudo apt update && sudo apt full-upgrade -y",
    "install": "sudo apt install -y curl git btop",
    "clean": "sudo apt autoremove -y && sudo apt clean"
}
```

Add or remove package names from the `install` line for your relevant package manager, save, and run `./omnipkg.sh` again.

---

## ⚠️ Security Note

OmniPKG asks for your sudo password once and keeps the session alive for the duration of the script instead of asking repeatedly. This is meant for convenience on machines you control — always review scripts before running them with elevated privileges.

---

## 🤝 Contributing

Issues and pull requests are welcome — especially additions of new package managers or corrections to package names that differ across distros.

---
**Created Guid HTML File With Help AI**

## 📜 License

Distributed under the **MIT License**. See `LICENSE` for details.

---
[#Automation](https://github.com/topics/automation)
[#Linux](https://github.com/topics/linux)
[#Bash](https://github.com/topics/bash)
[#CAgent_47](https://github.com/topics/CAgent47)
---

<div align="center">

**Author:** CAgent_47
[GitHub](https://github.com/CAgent47) · [LinkedIn](https://www.linkedin.com/in/mohammad-shaygan-2a96a8387) · [X](https://x.com/CAgent_47)

</div>

---

![banner](Images/banner.png)
