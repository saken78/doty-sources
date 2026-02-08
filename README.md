<p align="center">
<img src="./assets/doty/doty-banner.png" alt="Doty Logo" style="width: 60%;" align="center" />
  <br>
A <i><b>Dot</b>files</i> management system.
</p>

  <p align="center">
  <a href="https://github.com/saken78/doty-sources/stargazers">
    <img src="https://img.shields.io/github/stars/saken78/doty-sources?style=for-the-badge&logo=github&color=E3B341&logoColor=D9E0EE&labelColor=000000" alt="GitHub stars">
  </a>
  <a href="https://ko-fi.com/saken78">
    <img src="https://img.shields.io/badge/Support me on-Ko--fi-FF6433?style=for-the-badge&logo=kofi&logoColor=white&labelColor=000000" alt="Ko-Fi">
  </a>
  <a href="https://discord.gg/doty">
    <img src="https://img.shields.io/discord/669048311034150914?style=for-the-badge&logo=discord&logoColor=D9E0EE&labelColor=000000&color=5865F2&label=Discord" alt="Discord">
  </a>
</p>

---

<h2><sub><img src="https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Objects/Camera%20with%20Flash.png" alt="Camera with Flash" width="32" height="32" /></sub> Screenshots</h2>

<div align="center">
  <img src="./assets/screenshots/1.png" width="100%" />

  <br />

  <img src="./assets/screenshots/2.png" width="32%" />
  <img src="./assets/screenshots/3.png" width="32%" />
  <img src="./assets/screenshots/4.png" width="32%" />

  <img src="./assets/screenshots/5.png" width="32%" />
  <img src="./assets/screenshots/6.png" width="32%" />
  <img src="./assets/screenshots/7.png" width="32%" />

  <img src="./assets/screenshots/8.png" width="32%" />
  <img src="./assets/screenshots/9.png" width="32%" />
  <img src="./assets/screenshots/10.png" width="32%" />
</div>

---

<h2><sub><img src="https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Objects/Package.png" alt="Package" width="32" height="32" /></sub> Installation</h2>

```bash
curl -L get.doty.sh/install | sh
```

> [!WARNING]
> Doty is currently in active development.

---

### What does the installation do?

> [!IMPORTANT]
> For now Doty is installed via Nix flakes, so **Nix is required** for supporting it on as many distros as possible. But we are looking for contributions to support other package managers (and make this easier for everyone).

On **non-NixOS** distros, the installation script does the following:

* Installs [Nix](https://en.wikipedia.org/wiki/Nix_%28package_manager%29) if it's not already installed.
* Installs some necessary system dependencies (only a few that Nix cannot handle by itself).
* Installs Doty as a Nix flake. (*Dependency hell*? No, thanks. 😎)
* Creates an alias to launch `doty` from anywhere
  (for example: `exec-once = doty` in your `hyprland.conf`).
* Gives you a kiss on the cheek. 😘 (Optional, of course.)

On **NixOS**:

* Installs Doty via:

  ```bash
  nix profile add github:saken78/doty-sources
  ```

> [!NOTE]
> The installation script doesn't do anything else on NixOS, so you can declare it however you like in your system.

---

<h2><sub><img src="https://raw.githubusercontent.com/Tarikul-Islam-Anik/Telegram-Animated-Emojis/main/Activity/Sparkles.webp" alt="Sparkles" width="32" height="32" /></sub> Features</h2>

* [x] Dotfiles management
* [x] Configuration synchronization
* [x] Theme management
* [x] System integration
* [x] Backup and restore
* [x] Modular configuration system
* [x] Cross-platform compatibility
* [x] Version control integration
* [x] Automated deployment
* [x] Template system
* [x] Environment detection
* [x] Package management integration
* [x] Security best practices
* [x] Performance optimization
* [x] Extensible architecture
* [x] Plugin system
* [x] Migration tools
* [x] Documentation system
* [ ] Advanced automation scripts
* [ ] GUI configuration editor
* [ ] Cloud synchronization
* [ ] Community sharing platform

---

## What about the *docs*?

Complete documentation is coming soon! For now, the most important things to know are:

* The main configuration is located at `~/.config/doty`
* Removing Doty is as simple as:

  ```bash
  doty uninstall
  ```
* You can ask anything on the:

  * [Doty Discord server](https://discord.gg/doty)
  * [GitHub discussions](https://github.com/saken78/doty-sources/discussions)

> [!CAUTION]
> Packages installed via Nix will take priority over system ones.
> Keep this in mind if you run into version conflicts.

## Credits
- [Original Ambxst contributors](https://github.com/Axenide/Ambxst) for the foundation of this project.
- [saken78](https://github.com/saken78) for continuing the development and creating Doty.
- [Community contributors](https://github.com/saken78/doty-sources/graphs/contributors) for their valuable input and improvements.

(If I forgot someone, please let me know. 🙏)