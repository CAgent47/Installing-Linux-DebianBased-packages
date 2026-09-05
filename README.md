<div align="center">

# 🐧 OmniPKG — Universal Package Bootstrapper

**One script. Any distro. Any package manager. Zero manual hunting.**

![Version](https://img.shields.io/badge/version-v2.5.1-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Shell](https://img.shields.io/badge/shell-bash-1f425f)
![Python](https://img.shields.io/badge/python-3-yellow)
![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS%20%7C%20Windows%20%7C%20BSD-orange)

</div>

---

## 📖 About

**OmniPKG** is a smart, cross-platform package bootstrapper. Point it at any system — Debian, Fedora, Arch, macOS, BSD, even Windows — and it detects the right package manager, updates your system, installs your package list, and cleans up after itself. No more remembering whether it's `apt`, `dnf`, `pacman`, `brew`, or `winget`.

Built for people who set up a new machine often and are tired of looking up install commands every single time.

---

## ✨ What's New in v2.5.1

- 👤 **Root/non-root aware command selection** — every package manager entry in `distroPKG.json` now carries two variants, `sudo` and `root`. A new `omnimodule.userMod()` helper checks `os.geteuid()` and picks the right one automatically, so the correct syntax is used whether you're running as a regular user or already as root.
- 🗂️ **Config renamed & restructured** — the central config file is now `core/distroPKG.json`, read through the shared `omnimodule` (`loadJson`, `loopInDICT`, `userMod`) instead of separate ad-hoc scripts.
- 🌍 **30 package managers supported** — including additions like `port` (MacPorts), `yay` / `paru` (AUR helpers), `slackpkg`, `pkg_add` (OpenBSD), `rpm-ostree`, and `prt-get` (CRUX), on top of the original 22.
- 🐋 **Full Docker automation suite** — a dedicated `dockerfile/Dockerimage/engine-syntax/` module set (`install.py`, `autoremove.py`, `setup-Repository.py`, `dchange.py`, `createjson.py`) that installs Docker itself, detects Dockerfile changes, and drives a full `docker-compose.yml` setup end to end.
- 🔐 **Safer root handling in the terminal prompt** — if you're already root, the script now tells you to leave the password prompt empty instead of guessing.
- ⏳ **Live spinner & progress feedback**, unchanged from v2.0 — animated spinner and progress dots so you always know something's happening.
- 🎨 **Refined terminal UI** — boxed banner, color-coded sections, cleaner status messages.
- 🧹 **Automatic post-install cleanup** — orphaned packages and caches removed automatically per package manager.

> UI polish and this document were put together with AI assistance. Core architecture, the package-manager logic, and the Docker automation modules were designed and implemented by the author.

---

## ⚙️ How It Works

```
📂 omniPKG
├── omnipkg.sh                      # Main entry point script
├── core/                           # Core functionality modules
│   ├── distroPKG.json              # Central config: pkg manager commands (sudo + root variants)
│   ├── omnimodule.py                # Shared helpers: loadJson(), loopInDICT(), userMod()
│   ├── updatePKG.py                 # Detects pkg manager & returns update command
│   ├── installPKG.py                # Returns install command for detected pkg manager
│   └── cleanPKG.py                  # Returns cleanup command for detected pkg manager
├── dockerfile/                     # Docker automation suite
│   └── Dockerimage/
│       ├── dockerimg/               # Mounted core scripts & main script for container use
│       │   ├── core/                 # Mirror of main core/ for container usage
│       │   └── omnipkg.sh
│       ├── engine-syntax/           # Docker engine management modules
│       │   ├── dockerinstall.json    # Docker setup commands per pkg manager (sudo + root)
│       │   ├── dockermadule.py       # Shared Docker helper functions
│       │   ├── install.py            # Prints Docker package install command
│       │   ├── autoremove.py         # Prints command to remove conflicting Docker packages
│       │   ├── setup-Repository.py   # Prints Docker repo setup command
│       │   ├── createjson.py         # Creates dockerinstall.json if missing
│       │   └── dchange.py            # Detects Dockerfile changes, prints the right compose command
│       ├── docker-compose.yml
│       └── docker-setup.sh
├── Guide/
│   └── guid.html                   # Web-based project guide
├── Images/
├── README.md
└── SECURITY.md
```

Every package manager's `update`, `install`, and `clean` commands live in `distroPKG.json`, each split into `sudo` and `root` variants. The Python helpers read the right block for your system and privilege level, and hand the shell script a ready-to-run command.

---

## 🚀 Installation & Usage

```bash
git clone https://github.com/CAgent47/omniPKG.git
cd omniPKG
chmod +x omnipkg.sh
./omnipkg.sh
```

- **If you're already root**, OmniPKG detects this automatically and skips the password prompt entirely — nothing to type, it just starts.
- **If you're a regular user**, you'll be asked for your sudo password exactly once, at the very start. From that point on, you can just sit back and watch — the script never asks again for the rest of the run.

---

## 🐋 Docker Automation

Beyond general package bootstrapping, OmniPKG ships a self-contained Docker setup suite under `dockerfile/Dockerimage/`:

- Installs Docker itself using the correct method for your package manager (`dockerinstall.json`, also split into `sudo`/`root` variants)
- Detects whether your `Dockerfile` has changed since the last run and automatically decides between `docker compose up` and `docker compose up --build`
- Comes with a ready-to-use `docker-compose.yml` and a dedicated `docker-setup.sh` to bootstrap prerequisites

---

## 🛠️ Requirements

| Requirement | Notes |
|---|---|
| Bash | any modern version |
| Python 3 | used by the `core/` and `engine-syntax/` scripts |
| A supported package manager | 30 supported — see `distroPKG.json` |
| sudo access (or root) | needed for system-level package installs |

---

## 📝 Customizing Packages

Open `core/distroPKG.json` and edit the `install` line for your package manager. Each entry has separate `sudo` and `root` blocks so the correct syntax is picked automatically:

```json
"apt": {
    "sudo": {
        "update": "sudo apt update && sudo apt full-upgrade -y",
        "install": "sudo apt install -y curl git btop",
        "clean": "sudo apt autoremove -y && sudo apt clean"
    },
    "root": {
        "update": "apt update && apt full-upgrade -y",
        "install": "apt install -y curl git btop",
        "clean": "apt autoremove -y && apt clean"
    }
}
```

Add or remove package names, save, and run `./omnipkg.sh` again.

---

## ⚠️ Security Note

If you're root, OmniPKG never touches a password at all. Otherwise, it asks for your sudo password exactly once, uses it only to validate and cache a `sudo` ticket (`sudo -v`), then immediately discards it — it's never stored in a variable, piped repeatedly, or visible in `ps` output. A lightweight background refresh (`sudo -n -v` every 60 seconds) keeps that ticket alive so the rest of the run needs zero further input. This is meant for convenience on machines you personally control — always read a script before running it with elevated privileges.

---

## 🤝 Contributing

Issues and pull requests are welcome — especially additions of new package managers, corrections to package names that differ across distros, or improvements to the root/non-root detection logic.

---

## 📜 License

Distributed under the **MIT License**. See `LICENSE` for details.

---

<div align="center">

**Author:** CAgent_47
[GitHub](https://github.com/CAgent47) · [LinkedIn](https://www.linkedin.com/in/mohammad-shaygan-2a96a8387) · [X](https://x.com/CAgent_47)

</div>

![banner](Images/banner.png)
