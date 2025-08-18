# Fallout 4 Tracker - Portable Version

This is a portable version of the Fallout 4 character progression tracker that can be run on any system without modifications. All data is stored locally within the script directory.

## Features

- **Portable**: Uses relative paths, runs from any location
- **Self-contained**: Data stored in local `.data` directory
- **Cross-platform**: Works on Linux, macOS, and Windows (with bash/WSL)
- **No installation required**: Just download and run

## Usage

### Quick Start

1. Download or copy the entire `portable/` folder to your desired location
2. Open a terminal in the portable folder
3. Run the script:
   ```bash
   ./fallout4-tracker.sh
   ```

### Requirements

- **bash** shell (available on Linux/macOS, or Windows via WSL/Git Bash)
- **jq** JSON processor (install instructions shown if missing)

### Data Storage

All character data is stored in:
- `portable/.data/characters.json` - Character save data
- `portable/.data/current_character.txt` - Currently selected character
- `portable/.data/fallout4_backup_*.json` - Backup files

## Directory Structure

```
portable/
├── fallout4-tracker.sh          # Main executable script
├── README.md                     # This file
├── data/                         # Reference data files
│   ├── bobbleheads.json
│   ├── magazines.json
│   ├── holotapes.json
│   ├── notes.json
│   ├── perks.json
│   └── unique_items.json
└── .data/                        # Created automatically
    ├── characters.json           # Your character data
    ├── current_character.txt     # Current selection
    └── fallout4_backup_*.json    # Backup files
```

## Portable Features

### Character Management
- Create, select, edit, and remove characters
- Track SPECIAL stats and character progression
- Support for Main Game, DLC, and Modded content types

### Core Functionality
- Character creation with SPECIAL stats
- Basic character selection and summary viewing
- Data backup and restore functionality
- Faction and game type selection

### Simplified Interface
This portable version includes core character management features. For advanced features like detailed collectibles tracking, perk management, and quest tracking, use the full version.

## Moving Between Systems

To transfer your data to another system:

1. Copy the entire `portable/` folder
2. Your character data travels with the folder
3. No reconfiguration needed

## Backup Your Data

The script includes backup functionality:
- Create backups from the main menu (option 5)
- Backups are stored in the `.data` folder
- Restore from any backup when needed

## Installation of Dependencies

If `jq` is not installed, the script will show installation instructions:

- **Ubuntu/Debian**: `sudo apt install jq`
- **macOS**: `brew install jq`
- **Fedora**: `sudo dnf install jq`
- **Arch Linux**: `sudo pacman -S jq`
- **Windows**: Install via package manager or WSL

## Differences from Full Version

This portable version provides:
- ✅ Character creation and basic management
- ✅ SPECIAL stats tracking
- ✅ Backup/restore functionality
- ✅ Faction and game type selection
- ✅ Portable data storage
- ⚠️ Simplified menu options (advanced features show placeholder messages)

For the complete feature set including detailed collectibles tracking, perk management, and quest progression, use the full version.

## Troubleshooting

**Script won't run:**
- Ensure the script is executable: `chmod +x fallout4-tracker.sh`
- Check that you're in the correct directory

**Missing jq error:**
- Install jq using the instructions shown by the script

**Data not persisting:**
- Ensure you have write permissions in the script directory
- Check that the `.data` folder is created automatically

## License

This is part of the Gaming CLI Toolbox project. Use freely for personal gaming progress tracking.

War... War never changes. 🎮