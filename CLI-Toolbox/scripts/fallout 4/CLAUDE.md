# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Fallout 4 character progression tracker implemented as a bash CLI script. It helps players track their characters' SPECIAL stats, perks, collectibles (bobbleheads, magazines, holotapes, notes, unique items), and quest progress across Main Game, DLC, and Modded content.

## How to Run

Execute the main script:
```bash
./fallout4-tracker.sh
```

**Dependencies**: `jq` (JSON processor) must be installed on the system.

## Architecture & Data Structure

### Core Components

- **Main Script**: `fallout4-tracker.sh` - Complete interactive CLI application
- **Data Storage**: 
  - User data stored in `~/.fallout4_tracker/` directory
  - `characters.json` - All character data in JSON format
  - `current_character.txt` - Currently selected character ID
- **Reference Data**: `data/` directory contains JSON files with game collectibles data

### Character Data Model

Each character is stored as a JSON object with:
- Basic info: name, gender, level, faction, game_type
- SPECIAL stats: strength, perception, endurance, charisma, intelligence, agility, luck (1-10 each)
- Perks: array of {name, rank} objects
- Collectibles: categorized arrays for bobbleheads, magazines, holotapes, notes, unique_items
- Quests: separate arrays for main, dlc, and modded quest tracking

### Game Type Support

Three game types are supported:
- **Main**: Base game only
- **Main+DLC**: Base game plus official DLC content
- **Main+DLC+Modded**: Full content including mods (warns about quest item inventory effects)

## Key Features

### Character Management
- Create/select/edit/remove characters
- SPECIAL stat tracking and upgrading
- Perk management with reference data validation
- Faction affiliation tracking

### Collectibles Tracking
- Comprehensive bobblehead tracking (20 total) with location details
- Magazine collection tracking (123+ total)
- Holotape, note, and unique item collections
- Progress visualization with bars and percentages
- Search functionality across all collectible types

### Quest Management
- Separate quest tracking for main/DLC/modded content
- Add/complete/remove quest functionality
- Game type restrictions for DLC/modded content access

### Data Management
- Backup/restore functionality with timestamped files
- JSON-based data storage for easy manipulation
- Character export/import capabilities

## Development Notes

### Code Organization
- Functions are organized by feature area (character creation, collectibles, perks, etc.)
- Heavy use of `jq` for JSON manipulation
- Color-coded terminal UI with escape sequences
- Progress bars and visual indicators for better UX

### Data Validation
- Reference data files provide validation for collectibles and perks
- Character level limits (1-300)
- SPECIAL stat limits (1-10)
- Game type compatibility checks

### Common Development Tasks

When modifying the script:
1. Test JSON operations carefully - malformed JSON will break character data
2. Preserve color coding and UI formatting for consistency
3. Maintain backward compatibility with existing character data
4. Test with missing reference data files (graceful fallbacks)
5. Verify character data integrity after modifications

### Known Issues & TODOs

From the "Need to add" file, pending improvements include:
- Separate upgrade path for SPECIAL stats vs perks
- Enhanced perk viewing similar to collectibles display
- Improved character editing interface
- Better DLC/modded content separation
- Enhanced faction integration in character creator
