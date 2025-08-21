# 🏆 Fallout 4 Character Progression Tracker

<p align="center">
  <img src="https://img.shields.io/badge/Platform-Cross--Platform-brightgreen" alt="Platform">
  <img src="https://img.shields.io/badge/Shell-Bash_3.0+-blue" alt="Shell">
  <img src="https://img.shields.io/badge/License-MIT-yellow" alt="License">
  <img src="https://img.shields.io/badge/Game-Fallout_4-orange" alt="Game">
</p>

<p align="center">
  <strong>🎮 The ultimate command-line companion for tracking your Fallout 4 character progression, collectibles, and quest completion!</strong>
</p>

<p align="center">
  <img src="https://fallout.wiki.gg/images/thumb/a/a6/Fo4-logo.png/250px-Fo4-logo.png" alt="Fallout 4 Logo" width="200">
</p>

---

## 🌟 Why Use This Tracker?

Ever lost track of which **Bobbleheads** you've collected? Forgotten which **SPECIAL** stats you've upgraded? Can't remember if you completed that side quest? This tracker solves all these problems with a beautiful, interactive CLI interface that makes character management a breeze!

Perfect for:
- 🏅 **Completionists** aiming for 100% achievement runs
- 🎯 **Multiple character** playthroughs with different builds
- 📊 **Progress tracking** across Main Game, DLC, and Modded content
- 🔍 **Achievement hunters** who need detailed collectible tracking

---

## ✨ Key Features

### 🎯 **Character Management**
- **Multiple Characters**: Create and manage unlimited characters with unique builds
- **SPECIAL Stats Tracking**: Monitor and upgrade your Strength, Perception, Endurance, Charisma, Intelligence, Agility, and Luck
- **Faction Affiliation**: Track your allegiance (Brotherhood, Railroad, Institute, Minutemen, etc.)
- **Platform Support**: Works across PC (Steam, GOG, Epic), PlayStation, and Xbox
- **Game Type Support**: Main Game, Main+DLC, or Main+DLC+Modded configurations

### 📊 **Comprehensive Collectibles Database**
- **🎪 Bobbleheads**: Track all 20 SPECIAL and skill bobbleheads with exact locations
- **📖 Magazines**: Monitor collection of 133+ magazines across 17 different series
- **💾 Holotapes**: Keep tabs on important audio logs and game recordings
- **📝 Notes**: Track crucial story documents and lore pieces
- **⭐ Unique Items**: Monitor rare weapons, armor, and special loot

### 🔍 **Advanced Search & Organization**
- **Smart Search**: Find collectibles by name, location, or category
- **Progress Visualization**: Beautiful progress bars and percentage completion
- **Category Filtering**: Browse collectibles by type and series
- **Missing Items**: Quickly identify what you still need to collect

### 🎮 **Quest Management System**
- **Separate Tracking**: Organize Main Game, DLC, and Modded quests independently
- **Mod Integration**: Special support for modded content with creator attribution
- **Quest Status**: Add, complete, or remove quests with progress tracking
- **Game Type Restrictions**: Smart filtering based on your game configuration

### 🛠️ **Perk System Integration**
- **Complete Perk Database**: Access to all base game and DLC perks
- **Rank Tracking**: Monitor perk levels and progression requirements
- **SPECIAL Requirements**: See which stats you need for specific perks
- **Custom Perks**: Add modded or custom perks to your character

### 💾 **Data Management**
- **Backup & Restore**: Protect your progress with timestamped backups
- **Import/Export**: Share characters or migrate between systems
- **JSON Storage**: Human-readable data format for easy manipulation
- **Data Integrity**: Built-in validation and error recovery

---

## 🚀 Quick Start

### Prerequisites
- **Bash 3.0+** (available on all modern systems)
- **jq** (JSON processor - auto-installed if missing)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/fallout4-tracker.git
   cd fallout4-tracker
   ```

2. **Make executable:**
   ```bash
   chmod +x fallout4-tracker.sh
   ```

3. **Run the tracker:**
   ```bash
   ./fallout4-tracker.sh
   ```

The script will automatically:
- ✅ Check for dependencies (installs `jq` if missing)
- ✅ Create necessary data directories
- ✅ Set up reference data files
- ✅ Launch the interactive menu

### First Time Setup

1. **Create your first character** with the Character Management menu
2. **Set your game type** (Main, Main+DLC, or Main+DLC+Modded)
3. **Configure your platform** (PC, PlayStation, Xbox)
4. **Start tracking** your progress!

---

## 🎮 Usage Examples

### Creating a New Character
```
🎯 Character Management
═══════════════════════
1. Create New Character
2. Select Character
3. Edit Character
4. Remove Character
5. List All Characters
```

### Tracking Collectibles
```
📊 Collectibles Management
═══════════════════════
📊 Bobbleheads: (15/20) ████████████░░░░ 75%
📖 Magazines: (89/133) █████████░░░ 67%
💾 Holotapes: (23) ████████████████ 100%
📝 Notes: (12) ████████████████ 100%
⭐ Unique Items: (45) ████████████████ 100%
```

### SPECIAL Stats Overview
```
🎯 SPECIAL Stats for "Vault Dweller"
═══════════════════════════════════
💪 Strength:     7/10 ███████░░░
👁️  Perception:   5/10 █████░░░░░
🛡️  Endurance:   8/10 ████████░░
💬 Charisma:     3/10 ███░░░░░░░
🧠 Intelligence: 9/10 █████████░
⚡ Agility:      6/10 ██████░░░░
🍀 Luck:         4/10 ████░░░░░░
```

---

## 🌍 Cross-Platform Compatibility

This tracker is designed to work seamlessly across different operating systems:

### 🐧 **Linux**
- **Ubuntu/Debian**: `apt install jq`
- **Fedora/CentOS/RHEL**: `dnf install jq` or `yum install jq`
- **Arch/Manjaro**: `pacman -S jq`
- **openSUSE**: `zypper install jq`
- **Alpine**: `apk add jq`

### 🍎 **macOS**
- **Homebrew**: `brew install jq`
- **MacPorts**: `port install jq`

### 🪟 **Windows**
- **WSL**: Full Linux compatibility
- **Cygwin/MSYS2**: Native Windows support
- **Chocolatey**: `choco install jq`
- **winget**: `winget install jqlang.jq`

### 🔧 **Auto-Installation**
The script automatically detects your system and offers to install `jq` if it's missing!

---

## 📁 Project Structure

```
fallout4-tracker/
├── fallout4-tracker.sh     # Main script
├── README.md               # This file
├── LICENSE                 # MIT License
├── CLAUDE.md              # Development guidelines
└── data/                  # Reference data
    ├── bobbleheads.json   # Bobblehead locations & info
    ├── magazines.json     # Magazine series & issues
    ├── holotapes.json     # Holotape collection
    ├── notes.json         # Important notes
    ├── unique_items.json  # Unique weapons & armor
    └── perks.json         # Perk database
```

### 📂 User Data Location
Your character data is stored in:
- **Linux/macOS**: `~/.fallout4_tracker/`
- **Windows**: `%USERPROFILE%\.fallout4_tracker\`

---

## 🎯 Advanced Features

### 🔧 **Modded Content Support**
- Track quests from popular mods with creator attribution
- Custom collectible entries for modded items
- Compatibility warnings for console limitations

### 📊 **Progress Analytics**
- Detailed completion percentages
- Missing item identification
- Achievement progress tracking

### 🔄 **Data Portability**
- JSON-based storage for easy data manipulation
- Character export/import functionality
- Backup system with timestamp preservation

### 🎨 **Customizable Interface**
- Color-coded progress indicators
- Smart terminal detection (colors auto-disable on unsupported terminals)
- Organized menu system with intuitive navigation

---

## 🐛 Troubleshooting

### Common Issues

**Q: "jq: command not found"**
```bash
# The script will offer auto-installation, or install manually:
# Ubuntu/Debian
sudo apt update && sudo apt install jq

# macOS with Homebrew
brew install jq

# Windows with Chocolatey
choco install jq
```

**Q: "Permission denied" when creating data directory**
```bash
# Check if you have write permissions to your home directory
ls -la ~/
# If needed, create the directory manually:
mkdir -p ~/.fallout4_tracker
```

**Q: Character data seems corrupted**
```bash
# The script creates automatic backups in ~/.fallout4_tracker/backups/
# You can restore from a backup using the built-in restore function
```

### 🔍 **Debug Mode**
Run with debug output:
```bash
bash -x ./fallout4-tracker.sh
```

---

## 🤝 Contributing

We welcome contributions! Here's how you can help:

### 🎯 **Ways to Contribute**
- 🐛 **Bug Reports**: Found an issue? Open an issue with details
- ✨ **Feature Requests**: Have an idea? Share it with us
- 📝 **Documentation**: Help improve our guides and examples
- 🔧 **Code**: Submit pull requests with improvements
- 📊 **Data**: Help expand our collectibles and reference databases

### 📋 **Development Setup**
1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes and test thoroughly
4. Follow the coding style in the existing codebase
5. Submit a pull request with a clear description

### 📖 **Code Guidelines**
- Follow POSIX compliance where possible
- Add comments for complex logic
- Test on multiple platforms
- Maintain backward compatibility
- Update documentation for new features

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **Bethesda Game Studios** for creating the amazing Fallout 4 universe
- **The Fallout Community** for comprehensive game data and wikis
- **Contributors** who help improve this project
- **jq developers** for the excellent JSON processing tool

---

## 📞 Support & Community

- 🐛 **Issues**: [GitHub Issues](https://github.com/yourusername/fallout4-tracker/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/yourusername/fallout4-tracker/discussions)
- 📧 **Contact**: [your.email@example.com](mailto:your.email@example.com)

---

<p align="center">
  <strong>🎮 Happy Vault Dwelling! 🎮</strong>
</p>

<p align="center">
  Made with ❤️ for the Fallout community
</p>

---

*⚠️ Note: This tracker is a fan-made tool and is not affiliated with Bethesda Game Studios or Fallout 4. All game content references are for educational and tracking purposes only.*