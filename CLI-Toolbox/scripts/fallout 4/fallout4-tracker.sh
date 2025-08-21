#!/bin/bash

# Fallout 4 - Tracker for games and 100%
# CLI Implementation
# Compatible with Bash 3.0+ on Linux, macOS, Windows (WSL/Cygwin/MSYS2), and BSD systems

# Exit on undefined variables and errors
set -u

# Color codes for better UI - with terminal capability detection
if [ -t 1 ] && [ -n "${TERM}" ] && [ "${TERM}" != "dumb" ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    MAGENTA='\033[0;35m'
    CYAN='\033[0;36m'
    WHITE='\033[1;37m'
    GRAY='\033[0;90m'
    NC='\033[0m' # No Color
else
    # Disable colors for non-interactive or unsupported terminals
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    MAGENTA=''
    CYAN=''
    WHITE=''
    GRAY=''
    NC=''
fi

# Get script directory - portable way
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Data directories
DATA_DIR="$HOME/.fallout4_tracker"
CHARACTERS_FILE="$DATA_DIR/characters.json"
CURRENT_CHAR_FILE="$DATA_DIR/current_character.txt"

# Reference data from script's data folder
REFERENCE_DATA_DIR="$SCRIPT_DIR/data"
BOBBLEHEADS_FILE="$REFERENCE_DATA_DIR/bobbleheads.json"
MAGAZINES_FILE="$REFERENCE_DATA_DIR/magazines.json"
HOLOTAPES_FILE="$REFERENCE_DATA_DIR/holotapes.json"
NOTES_FILE="$REFERENCE_DATA_DIR/notes.json"
UNIQUE_ITEMS_FILE="$REFERENCE_DATA_DIR/unique_items.json"
PERKS_FILE="$REFERENCE_DATA_DIR/perks.json"

# Initialize data directory
init_data() {
    if ! mkdir -p "$DATA_DIR" 2>/dev/null; then
        echo -e "${RED}Error: Cannot create data directory at $DATA_DIR${NC}"
        echo -e "${YELLOW}Please check permissions or disk space.${NC}"
        exit 1
    fi
    
    if [ ! -f "$CHARACTERS_FILE" ]; then
        if ! echo "[]" > "$CHARACTERS_FILE" 2>/dev/null; then
            echo -e "${RED}Error: Cannot create characters file at $CHARACTERS_FILE${NC}"
            echo -e "${YELLOW}Please check permissions.${NC}"
            exit 1
        fi
    fi
    
    # Check if reference data exists
    if [ ! -d "$REFERENCE_DATA_DIR" ]; then
        echo -e "${YELLOW}Warning: Reference data directory not found at $REFERENCE_DATA_DIR${NC}"
        echo -e "${YELLOW}Creating sample data files...${NC}"
        create_sample_data
    else
        # Create only missing sample data files (but not bobbleheads since it exists)
        create_missing_sample_data
    fi
}

# Create sample data files if they don't exist
create_sample_data() {
    if ! mkdir -p "$REFERENCE_DATA_DIR" 2>/dev/null; then
        echo -e "${RED}Error: Cannot create reference data directory at $REFERENCE_DATA_DIR${NC}"
        echo -e "${YELLOW}Please check permissions.${NC}"
        exit 1
    fi
    
    # Skip bobbleheads and magazines - using existing detailed JSON files
    
    # Sample holotapes
    if [ ! -f "$HOLOTAPES_FILE" ]; then
        cat > "$HOLOTAPES_FILE" << 'EOF'
[
  "Red Menace - Vault 111",
  "Atomic Command - Museum of Freedom",
  "Grognak & the Ruby Ruins - Goodneighbor",
  "Zeta Invaders - Valentine's Detective Agency",
  "Pipfall - Fort Hagen",
  "Automatron - Fort Hagen Hangar",
  "Hi Honey! - Sanctuary Hills",
  "Eddie Winter Holotape 0 - Andrew Station",
  "Eddie Winter Holotape 1 - Police Precinct 8",
  "Eddie Winter Holotape 2 - South Boston Police Department"
]
EOF
    fi
    
    # Sample notes
    if [ ! -f "$NOTES_FILE" ]; then
        cat > "$NOTES_FILE" << 'EOF'
[
  "Vault 111 Security Instructions",
  "War Never Changes",
  "Mama Murphy's Vision",
  "Piper's Story",
  "Valentine Case Files",
  "Railroad Faction Notes",
  "Brotherhood Manifesto",
  "Institute Observations",
  "Minutemen History"
]
EOF
    fi
    
    # Sample unique items
    if [ ! -f "$UNIQUE_ITEMS_FILE" ]; then
        cat > "$UNIQUE_ITEMS_FILE" << 'EOF'
[
  "Cryolator - Vault 111",
  "Overseer's Guardian - Vault 81",
  "Deliverer - Railroad HQ",
  "Righteous Authority - Paladin Danse",
  "Kellogg's Pistol - Fort Hagen",
  "Kremvh's Tooth - Dunwich Borers",
  "Pickman's Blade - Pickman Gallery",
  "Furious Power Fist - Swan's Pond",
  "Le Fusil Terribles - Libertalia",
  "Final Judgment - Elder Maxson"
]
EOF
    fi
    
    # Sample perks
    if [ ! -f "$PERKS_FILE" ]; then
        cat > "$PERKS_FILE" << 'EOF'
[
  {"name": "Iron Fist", "special": "Strength", "ranks": 5},
  {"name": "Big Leagues", "special": "Strength", "ranks": 5},
  {"name": "Armorer", "special": "Strength", "ranks": 4},
  {"name": "Blacksmith", "special": "Strength", "ranks": 3},
  {"name": "Heavy Gunner", "special": "Strength", "ranks": 5},
  {"name": "Pickpocket", "special": "Perception", "ranks": 4},
  {"name": "Rifleman", "special": "Perception", "ranks": 5},
  {"name": "Awareness", "special": "Perception", "ranks": 2},
  {"name": "Locksmith", "special": "Perception", "ranks": 4},
  {"name": "Toughness", "special": "Endurance", "ranks": 5},
  {"name": "Lead Belly", "special": "Endurance", "ranks": 3},
  {"name": "Life Giver", "special": "Endurance", "ranks": 3},
  {"name": "Cap Collector", "special": "Charisma", "ranks": 3},
  {"name": "Lone Wanderer", "special": "Charisma", "ranks": 4},
  {"name": "Attack Dog", "special": "Charisma", "ranks": 4},
  {"name": "V.A.N.S.", "special": "Intelligence", "ranks": 2},
  {"name": "Medic", "special": "Intelligence", "ranks": 4},
  {"name": "Gun Nut", "special": "Intelligence", "ranks": 4},
  {"name": "Hacker", "special": "Intelligence", "ranks": 3},
  {"name": "Science!", "special": "Intelligence", "ranks": 4},
  {"name": "Gunslinger", "special": "Agility", "ranks": 5},
  {"name": "Commando", "special": "Agility", "ranks": 5},
  {"name": "Sneak", "special": "Agility", "ranks": 5},
  {"name": "Ninja", "special": "Agility", "ranks": 3},
  {"name": "Fortune Finder", "special": "Luck", "ranks": 4},
  {"name": "Scrounger", "special": "Luck", "ranks": 4},
  {"name": "Bloody Mess", "special": "Luck", "ranks": 4},
  {"name": "Mysterious Stranger", "special": "Luck", "ranks": 4},
  {"name": "Idiot Savant", "special": "Luck", "ranks": 3}
]
EOF
    fi
}

# Create missing sample data files when reference directory exists
create_missing_sample_data() {
    # Skip bobbleheads and magazines - using existing detailed JSON files
    
    # Sample holotapes
    if [ ! -f "$HOLOTAPES_FILE" ]; then
        cat > "$HOLOTAPES_FILE" << 'EOF'
[
  "Red Menace - Vault 111",
  "Atomic Command - Museum of Freedom",
  "Grognak & the Ruby Ruins - Goodneighbor",
  "Zeta Invaders - Valentine's Detective Agency",
  "Pipfall - Fort Hagen",
  "Automatron - Fort Hagen Hangar",
  "Hi Honey! - Sanctuary Hills",
  "Eddie Winter Holotape 0 - Andrew Station",
  "Eddie Winter Holotape 1 - Police Precinct 8",
  "Eddie Winter Holotape 2 - South Boston Police Department"
]
EOF
    fi
    
    # Sample notes
    if [ ! -f "$NOTES_FILE" ]; then
        cat > "$NOTES_FILE" << 'EOF'
[
  "Vault 111 Security Instructions",
  "War Never Changes",
  "Mama Murphy's Vision",
  "Piper's Story",
  "Valentine Case Files",
  "Railroad Faction Notes",
  "Brotherhood Manifesto",
  "Institute Observations",
  "Minutemen History"
]
EOF
    fi
    
    # Sample unique items
    if [ ! -f "$UNIQUE_ITEMS_FILE" ]; then
        cat > "$UNIQUE_ITEMS_FILE" << 'EOF'
[
  "Cryolator - Vault 111",
  "Overseer's Guardian - Vault 81",
  "Deliverer - Railroad HQ",
  "Righteous Authority - Paladin Danse",
  "Kellogg's Pistol - Fort Hagen",
  "Kremvh's Tooth - Dunwich Borers",
  "Pickman's Blade - Pickman Gallery",
  "Furious Power Fist - Swan's Pond",
  "Le Fusil Terribles - Libertalia",
  "Final Judgment - Elder Maxson"
]
EOF
    fi
    
    # Sample perks
    if [ ! -f "$PERKS_FILE" ]; then
        cat > "$PERKS_FILE" << 'EOF'
[
  {"name": "Iron Fist", "special": "Strength", "ranks": 5},
  {"name": "Big Leagues", "special": "Strength", "ranks": 5},
  {"name": "Armorer", "special": "Strength", "ranks": 4},
  {"name": "Blacksmith", "special": "Strength", "ranks": 3},
  {"name": "Heavy Gunner", "special": "Strength", "ranks": 5},
  {"name": "Pickpocket", "special": "Perception", "ranks": 4},
  {"name": "Rifleman", "special": "Perception", "ranks": 5},
  {"name": "Awareness", "special": "Perception", "ranks": 2},
  {"name": "Locksmith", "special": "Perception", "ranks": 4},
  {"name": "Toughness", "special": "Endurance", "ranks": 5},
  {"name": "Lead Belly", "special": "Endurance", "ranks": 3},
  {"name": "Life Giver", "special": "Endurance", "ranks": 3},
  {"name": "Cap Collector", "special": "Charisma", "ranks": 3},
  {"name": "Lone Wanderer", "special": "Charisma", "ranks": 4},
  {"name": "Attack Dog", "special": "Charisma", "ranks": 4},
  {"name": "V.A.N.S.", "special": "Intelligence", "ranks": 2},
  {"name": "Medic", "special": "Intelligence", "ranks": 4},
  {"name": "Gun Nut", "special": "Intelligence", "ranks": 4},
  {"name": "Hacker", "special": "Intelligence", "ranks": 3},
  {"name": "Science!", "special": "Intelligence", "ranks": 4},
  {"name": "Gunslinger", "special": "Agility", "ranks": 5},
  {"name": "Commando", "special": "Agility", "ranks": 5},
  {"name": "Sneak", "special": "Agility", "ranks": 5},
  {"name": "Ninja", "special": "Agility", "ranks": 3},
  {"name": "Fortune Finder", "special": "Luck", "ranks": 4},
  {"name": "Scrounger", "special": "Luck", "ranks": 4},
  {"name": "Bloody Mess", "special": "Luck", "ranks": 4},
  {"name": "Mysterious Stranger", "special": "Luck", "ranks": 4},
  {"name": "Idiot Savant", "special": "Luck", "ranks": 3}
]
EOF
    fi
}

# Display header
show_header() {
    clear
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}         Fallout 4 - Tracker for games and 100%${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
    echo
}

# Helper function to check mod compatibility based on platform and game type
check_mod_compatibility() {
    local char_id="$1"
    local action_type="$2"  # "warn" or "block"
    
    if [ ! -f "$CHARACTERS_FILE" ]; then
        return 1
    fi
    
    local char_data=$(jq ".[] | select(.id == \"$char_id\")" "$CHARACTERS_FILE")
    if [ -z "$char_data" ]; then
        return 1
    fi
    
    local game_type=$(echo "$char_data" | jq -r '.game_type // "Main"')
    local platform_type=$(echo "$char_data" | jq -r '.platform.type // "PC"')
    local mod_support=$(echo "$char_data" | jq -r '.platform.mod_support // "Full"')
    
    # Only check if modded content is being accessed
    if [[ "$game_type" == *"Modded"* ]]; then
        case "$mod_support" in
            "Full")
                if [[ "$action_type" == "warn" ]]; then
                    echo -e "${GREEN}✓ Full mod support available on PC platform${NC}"
                fi
                return 0
                ;;
            "Limited")
                if [[ "$action_type" == "warn" ]]; then
                    if [[ "$platform_type" == "Console" ]]; then
                        local console_gen=$(echo "$char_data" | jq -r '.platform.generation // "Old Gen"')
                        if [[ "$console_gen" == "New Gen" ]]; then
                            echo -e "${YELLOW}⚠ Limited mod support on console. Some mods may not be available.${NC}"
                        else
                            echo -e "${YELLOW}⚠ Very limited mod support on old gen consoles.${NC}"
                        fi
                    fi
                    echo -e "${YELLOW}Note: Using modded content. Quest items may affect inventory.${NC}"
                fi
                return 0
                ;;
            *)
                if [[ "$action_type" == "block" ]]; then
                    echo -e "${RED}❌ Modded content not supported on this platform${NC}"
                    return 1
                fi
                return 0
                ;;
        esac
    fi
    
    return 0
}

# Main menu
main_menu() {
    show_header
    echo -e "${CYAN}Main Menu${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
    echo
    echo "1. 🆕 Create Character"
    echo "2. 👤 Select Character"
    echo "3. ✏️  Edit Character"
    echo "4. 🗑️  Remove Character"
    echo "5. 💾 Backup/Restore"
    echo "6. ❌ Exit"
    echo
    read -p "Select option: " choice
    
    case $choice in
        1) create_character ;;
        2) select_character ;;
        3) edit_character ;;
        4) remove_character ;;
        5) backup_restore_menu ;;
        6) 
            echo -e "${GREEN}Thank you for using Fallout 4 Tracker!${NC}"
            echo -e "${YELLOW}War... War never changes.${NC}"
            exit 0 
            ;;
        *) echo -e "${RED}Invalid option${NC}"; sleep 1; main_menu ;;
    esac
}

# Backup and Restore Menu
backup_restore_menu() {
    show_header
    echo -e "${CYAN}💾 Backup/Restore${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
    echo
    echo "1. Create Backup"
    echo "2. Restore from Backup"
    echo "3. View Available Backups"
    echo "4. Back"
    echo
    read -p "Select option: " choice
    
    case $choice in
        1)
            backup_name="fallout4_backup_$(date +%Y%m%d_%H%M%S).json"
            cp "$CHARACTERS_FILE" "$DATA_DIR/$backup_name"
            echo -e "${GREEN}Backup created: $backup_name${NC}"
            sleep 2
            backup_restore_menu
            ;;
        2)
            echo "Available backups:"
            ls -1 "$DATA_DIR"/fallout4_backup_*.json 2>/dev/null | nl -s ". "
            
            if [ $? -ne 0 ]; then
                echo -e "${RED}No backups found${NC}"
                sleep 2
                backup_restore_menu
                return
            fi
            
            read -p "Select backup number: " backup_num
            backup_file=$(ls -1 "$DATA_DIR"/fallout4_backup_*.json 2>/dev/null | sed -n "${backup_num}p")
            
            if [ -f "$backup_file" ]; then
                cp "$backup_file" "$CHARACTERS_FILE"
                echo -e "${GREEN}Restored from backup${NC}"
            else
                echo -e "${RED}Invalid selection${NC}"
            fi
            sleep 2
            backup_restore_menu
            ;;
        3)
            echo "Available backups:"
            ls -lh "$DATA_DIR"/fallout4_backup_*.json 2>/dev/null
            
            if [ $? -ne 0 ]; then
                echo -e "${RED}No backups found${NC}"
            fi
            
            echo
            read -p "Press Enter to continue..."
            backup_restore_menu
            ;;
        4)
            main_menu
            ;;
        *)
            echo -e "${RED}Invalid option${NC}"
            sleep 1
            backup_restore_menu
            ;;
    esac
}

# Create character
create_character() {
    show_header
    echo -e "${CYAN}Character Creator${NC}"
    echo
    
    read -p "Character Name: " char_name
    
    echo "Character Gender:"
    echo "1. Male"
    echo "2. Female"
    read -p "Select (1-2): " gender_choice
    
    case $gender_choice in
        1) gender="Male" ;;
        2) gender="Female" ;;
        *) gender="Not specified" ;;
    esac
    
    read -p "Character Level (1-300): " level
    
    echo
    echo "Character Special Stats (1-10 each):"
    read -p "Strength: " strength
    read -p "Perception: " perception
    read -p "Endurance: " endurance
    read -p "Charisma: " charisma
    read -p "Intelligence: " intelligence
    read -p "Agility: " agility
    read -p "Luck: " luck
    
    # Create character JSON entry
    char_id=$(date +%s)
    
    echo
    echo "What faction are you part of?"
    echo "1. Minutemen"
    echo "2. Brotherhood of Steel"
    echo "3. Railroad"
    echo "4. Institute"
    echo "5. None/Undecided"
    read -p "Select faction (1-5): " faction_choice
    
    case $faction_choice in
        1) faction="Minutemen" ;;
        2) faction="Brotherhood of Steel" ;;
        3) faction="Railroad" ;;
        4) faction="Institute" ;;
        5) faction="None" ;;
        *) faction="None" ;;
    esac
    
    echo
    echo "Game Type:"
    echo "1. Main Game Only"
    echo "2. Main Game + DLC"
    echo "3. Main Game + DLC + Modded"
    read -p "Select game type (1-3): " game_type_choice
    
    case $game_type_choice in
        1) game_type="Main" ;;
        2) game_type="Main+DLC" ;;
        3) game_type="Main+DLC+Modded" ;;
        *) game_type="Main" ;;
    esac
    
    echo
    echo "Platform:"
    echo "1. PC (Steam)"
    echo "2. PC (GOG)"
    echo "3. Console (Old Gen - PS4/Xbox One)"
    echo "4. Console (New Gen - PS5/Xbox Series X|S)"
    read -p "Select platform (1-4): " platform_choice
    
    case $platform_choice in
        1) platform="PC"; distribution="Steam" ;;
        2) platform="PC"; distribution="GOG" ;;
        3) platform="Console"; console_gen="Old Gen"; console_type="PS4/Xbox One" ;;
        4) platform="Console"; console_gen="New Gen"; console_type="PS5/Xbox Series X|S" ;;
        *) platform="PC"; distribution="Steam" ;;
    esac
    
    # Set mod compatibility based on platform
    if [[ "$platform" == "PC" ]]; then
        mod_support="Full"
        if [[ "$game_type" == *"Modded"* ]]; then
            echo -e "${GREEN}✓ Full mod support available on PC platform${NC}"
        fi
    elif [[ "$platform" == "Console" && "$console_gen" == "New Gen" ]]; then
        mod_support="Limited"
        if [[ "$game_type" == *"Modded"* ]]; then
            echo -e "${YELLOW}⚠ Limited mod support on console. Some mods may not be available.${NC}"
            echo -e "${YELLOW}Note: Using modded content. Quest items may affect inventory.${NC}"
        fi
    else
        mod_support="Limited"
        if [[ "$game_type" == *"Modded"* ]]; then
            echo -e "${YELLOW}⚠ Very limited mod support on old gen consoles.${NC}"
            echo -e "${YELLOW}Note: Using modded content. Quest items may affect inventory.${NC}"
        fi
    fi
    
    if [[ "$game_type" == *"Modded"* ]]; then
        sleep 2
    fi
    
    # Build platform JSON based on platform type
    if [[ "$platform" == "PC" ]]; then
        platform_json="\"platform\": {
        \"type\": \"$platform\",
        \"distribution\": \"$distribution\",
        \"mod_support\": \"$mod_support\"
    },"
    else
        platform_json="\"platform\": {
        \"type\": \"$platform\",
        \"generation\": \"$console_gen\",
        \"console_type\": \"$console_type\",
        \"mod_support\": \"$mod_support\"
    },"
    fi

    char_json=$(cat <<EOF
{
    "id": "$char_id",
    "name": "$char_name",
    "gender": "$gender",
    "level": $level,
    "faction": "$faction",
    "game_type": "$game_type",
    $platform_json
    "special": {
        "strength": $strength,
        "perception": $perception,
        "endurance": $endurance,
        "charisma": $charisma,
        "intelligence": $intelligence,
        "agility": $agility,
        "luck": $luck
    },
    "perks": [],
    "collectibles": {
        "bobbleheads": [],
        "magazines": [],
        "holotapes": [],
        "notes": [],
        "unique_items": []
    },
    "quests": {
        "main": [],
        "dlc": [],
        "modded": []
    }
}
EOF
)
    
    # Add character to file
    if [ -f "$CHARACTERS_FILE" ]; then
        jq ". += [$char_json]" "$CHARACTERS_FILE" > "$CHARACTERS_FILE.tmp" && mv "$CHARACTERS_FILE.tmp" "$CHARACTERS_FILE"
    fi
    
    echo "$char_id" > "$CURRENT_CHAR_FILE"
    
    echo -e "${GREEN}Character created successfully!${NC}"
    sleep 2
    character_menu
}

# Select character
select_character() {
    show_header
    echo -e "${CYAN}Select Character:${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
    echo
    
    # List all characters
    if [ -f "$CHARACTERS_FILE" ]; then
        characters=$(jq -r '.[] | "\(.id)|\(.name)|\(.level)|\(.faction // "None")|\(.game_type // "Main")|\(.platform.type // "PC")|\(.platform.distribution // .platform.console_type // "Steam")"' "$CHARACTERS_FILE")
        
        if [ -z "$characters" ]; then
            echo -e "${RED}No characters found. Create one first!${NC}"
            sleep 2
            main_menu
            return
        fi
        
        echo -e "${WHITE}   Name                Level    Faction              Game Type       Platform${NC}"
        echo -e "${YELLOW}─────────────────────────────────────────────────────────────────────────────${NC}"
        
        counter=1
        while IFS='|' read -r id name level faction game_type platform_type platform_detail; do
            # Format platform display
            if [[ "$platform_type" == "PC" ]]; then
                platform_display="PC ($platform_detail)"
            else
                platform_display="$platform_type ($platform_detail)"
            fi
            
            # Format the output with proper spacing
            printf "${CYAN}%2d.${NC} %-18s ${GREEN}Lvl %-4s${NC} %-18s ${MAGENTA}%-14s${NC} ${BLUE}%s${NC}\n" \
                "$counter" "$name" "$level" "$faction" "$game_type" "$platform_display"
            counter=$((counter + 1))
        done <<< "$characters"
        
        echo -e "${YELLOW}─────────────────────────────────────────────────────────────────────────────${NC}"
        echo
        read -p "Select character number (or 0 to go back): " char_num
        
        if [ "$char_num" = "0" ]; then
            main_menu
            return
        fi
        
        char_id=$(echo "$characters" | sed -n "${char_num}p" | cut -d'|' -f1)
        
        if [ -z "$char_id" ]; then
            echo -e "${RED}Invalid selection${NC}"
            sleep 1
            select_character
            return
        fi
        
        echo "$char_id" > "$CURRENT_CHAR_FILE"
        
        character_menu
    fi
}

# Character menu (after selection)
character_menu() {
    show_header
    
    if [ ! -f "$CURRENT_CHAR_FILE" ]; then
        echo -e "${RED}No character selected${NC}"
        sleep 2
        main_menu
        return
    fi
    
    char_id=$(cat "$CURRENT_CHAR_FILE")
    char_data=$(jq -r ".[] | select(.id == \"$char_id\")" "$CHARACTERS_FILE")
    
    if [ -z "$char_data" ]; then
        echo -e "${RED}Character not found${NC}"
        sleep 2
        main_menu
        return
    fi
    
    char_name=$(echo "$char_data" | jq -r '.name')
    char_level=$(echo "$char_data" | jq -r '.level')
    game_type=$(echo "$char_data" | jq -r '.game_type // "Main"')
    faction=$(echo "$char_data" | jq -r '.faction // "None"')
    
    # Get platform information
    platform_type=$(echo "$char_data" | jq -r '.platform.type // "PC"')
    if [[ "$platform_type" == "PC" ]]; then
        distribution=$(echo "$char_data" | jq -r '.platform.distribution // "Steam"')
        platform_display="$platform_type ($distribution)"
    else
        console_type=$(echo "$char_data" | jq -r '.platform.console_type // "PS4/Xbox One"')
        platform_display="$platform_type ($console_type)"
    fi
    
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}Character: $char_name${NC} | ${CYAN}Level $char_level${NC} | ${MAGENTA}$game_type${NC}"
    echo -e "${YELLOW}Platform: $platform_display${NC} | ${YELLOW}Faction: $faction${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
    echo
    echo "1. 📊 Character Stats & Level"
    echo "2. ⚔️  Perks & S.P.E.C.I.A.L"
    echo "3. 🎒 Collectibles & Items"
    echo "4. 📜 Quests & Progress"
    echo "5. ✏️  Edit Character"
    echo "6. 📈 Progress Overview"
    echo "7. ← Back to Main Menu"
    echo
    read -p "Select option: " choice
    
    case $choice in
        1) stats_menu ;;
        2) perks_special_menu ;;
        3) collectibles_menu ;;
        4) dlc_modded_menu ;;
        5) edit_character_details ;;
        6) progress_overview ;;
        7) main_menu ;;
        *) echo -e "${RED}Invalid option${NC}"; sleep 1; character_menu ;;
    esac
}

# Stats and Level Menu
stats_menu() {
    show_header
    char_id=$(cat "$CURRENT_CHAR_FILE")
    
    echo -e "${CYAN}📊 Character Stats & Level${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
    echo
    echo "1. View Current Level"
    echo "2. Update Level"
    echo "3. View Character Summary"
    echo "4. Back"
    echo
    read -p "Select option: " choice
    
    case $choice in
        1)
            level=$(jq -r ".[] | select(.id == \"$char_id\") | .level" "$CHARACTERS_FILE")
            echo -e "${GREEN}Current Level: $level${NC}"
            
            # Show XP needed for next level (example calculation)
            next_level=$((level + 1))
            xp_needed=$((200 + (level * 75)))
            echo -e "${CYAN}XP needed for Level $next_level: ~$xp_needed${NC}"
            
            read -p "Press Enter to continue..."
            stats_menu
            ;;
        2)
            read -p "Enter new level (1-300): " new_level
            if [ "$new_level" -ge 1 ] && [ "$new_level" -le 300 ]; then
                jq "map(if .id == \"$char_id\" then .level = $new_level else . end)" "$CHARACTERS_FILE" > "$CHARACTERS_FILE.tmp" && mv "$CHARACTERS_FILE.tmp" "$CHARACTERS_FILE"
                echo -e "${GREEN}Level updated to $new_level${NC}"
            else
                echo -e "${RED}Invalid level. Must be between 1 and 300${NC}"
            fi
            sleep 1
            stats_menu
            ;;
        3)
            view_character_summary
            stats_menu
            ;;
        4)
            character_menu
            ;;
        *)
            echo -e "${RED}Invalid option${NC}"
            sleep 1
            stats_menu
            ;;
    esac
}

# Perks and SPECIAL Menu
perks_special_menu() {
    show_header
    char_id=$(cat "$CURRENT_CHAR_FILE")
    
    echo -e "${CYAN}⚔️ Perks & S.P.E.C.I.A.L${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
    echo
    echo "📊 S.P.E.C.I.A.L:"
    echo "  1. View S.P.E.C.I.A.L Stats"
    echo "  2. Upgrade S.P.E.C.I.A.L Stats"
    echo
    echo "⭐ Perks:"
    echo "  3. Add New Perk"
    echo "  4. Upgrade Existing Perk"
    echo "  5. View All Perks"
    echo "  6. Perk Recommendations"
    echo
    echo "7. Back"
    echo
    read -p "Select option: " choice
    
    case $choice in
        1) view_special ;;
        2) upgrade_special ;;
        3) add_perk ;;
        4) upgrade_perk ;;
        5) view_all_perks ;;
        6) perk_recommendations ;;
        7) character_menu ;;
        *) echo -e "${RED}Invalid option${NC}"; sleep 1; perks_special_menu ;;
    esac
}

# Collectibles Menu
collectibles_menu() {
    show_header
    char_id=$(cat "$CURRENT_CHAR_FILE")
    
    # Get character data and game type
    char_data=$(jq ".[] | select(.id == \"$char_id\")" "$CHARACTERS_FILE")
    game_type=$(echo "$char_data" | jq -r '.game_type // "Main"')
    
    echo -e "${CYAN}🎒 Collectibles & Items${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
    echo
    
    # Quick stats
    collectibles=$(echo "$char_data" | jq -r '.collectibles')
    bobblehead_count=$(echo "$collectibles" | jq '.bobbleheads | length')
    magazine_count=$(echo "$collectibles" | jq '.magazines | length')
    
    echo -e "${GREEN}Quick Stats:${NC}"
    echo "  Bobbleheads: $bobblehead_count/20"
    echo "  Magazines: $magazine_count/133"
    
    # Add modded-only quick stats
    if [[ "$game_type" == "Main+DLC+Modded" ]]; then
        holotape_count=$(echo "$collectibles" | jq '.holotapes | length')
        note_count=$(echo "$collectibles" | jq '.notes | length')
        unique_count=$(echo "$collectibles" | jq '.unique_items | length')
        echo
        echo -e "${PURPLE}Quick Stats - Modded Only${NC}"
        echo "  Holotapes: $holotape_count (Use custom entries for mod items)"
        echo "  Notes: $note_count (Use custom entries for mod items)"
        echo "  Unique Items: $unique_count (Use custom entries for mod items)"
    fi
    
    echo
    echo "1. 📊 Add Bobblehead"
    echo "2. 📖 Add Magazine"
    
    # Show different options for modded vs non-modded
    if [[ "$game_type" == "Main+DLC+Modded" ]]; then
        echo "3. 💾 Add Holotape (Use custom entries for mod items)"
        echo "4. 📝 Add Note (Use custom entries for mod items)"
        echo "5. ⭐ Add Unique Item (Use custom entries for mod items)"
    else
        echo "3. 💾 Add Holotape"
        echo "4. 📝 Add Note"
        echo "5. ⭐ Add Unique Item"
    fi
    
    echo "6. 📋 View All Collectibles"
    echo "7. 🔍 Search Collectibles"
    echo "8. 🗑️ Remove Collectible"
    echo "9. Back"
    echo
    read -p "Select option: " choice
    
    case $choice in
        1) add_specific_collectible "bobbleheads" "$BOBBLEHEADS_FILE" "Bobblehead" ;;
        2) add_magazine_by_category ;;
        3) 
            if [[ "$game_type" == "Main+DLC+Modded" ]]; then
                add_modded_collectible "holotapes" "Holotape"
            else
                add_specific_collectible "holotapes" "$HOLOTAPES_FILE" "Holotape"
            fi
            ;;
        4) 
            if [[ "$game_type" == "Main+DLC+Modded" ]]; then
                add_modded_collectible "notes" "Note"
            else
                add_specific_collectible "notes" "$NOTES_FILE" "Note"
            fi
            ;;
        5) 
            if [[ "$game_type" == "Main+DLC+Modded" ]]; then
                add_modded_collectible "unique_items" "Unique Item"
            else
                add_specific_collectible "unique_items" "$UNIQUE_ITEMS_FILE" "Unique Item"
            fi
            ;;
        6) view_all_collectibles ;;
        7) search_collectibles ;;
        8) remove_collectible_menu ;;
        9) character_menu ;;
        *) echo -e "${RED}Invalid option${NC}"; sleep 1; collectibles_menu ;;
    esac
}

# Remove Collectible Menu
remove_collectible_menu() {
    show_header
    char_id=$(cat "$CURRENT_CHAR_FILE")
    
    echo -e "${CYAN}🗑️ Remove Collectible${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
    echo
    
    echo "Select collectible type to remove from:"
    echo "1. 📊 Bobbleheads"
    echo "2. 📖 Magazines"
    echo "3. 💾 Holotapes"
    echo "4. 📝 Notes"
    echo "5. ⭐ Unique Items"
    echo "6. Back"
    echo
    read -p "Select option: " choice
    
    case $choice in
        1) remove_specific_collectible "bobbleheads" "Bobblehead" ;;
        2) remove_specific_collectible "magazines" "Magazine" ;;
        3) remove_specific_collectible "holotapes" "Holotape" ;;
        4) remove_specific_collectible "notes" "Note" ;;
        5) remove_specific_collectible "unique_items" "Unique Item" ;;
        6) collectibles_menu ;;
        *) echo -e "${RED}Invalid option${NC}"; sleep 1; remove_collectible_menu ;;
    esac
}

# Remove specific collectible
remove_specific_collectible() {
    local coll_type=$1
    local type_name=$2
    
    show_header
    char_id=$(cat "$CURRENT_CHAR_FILE")
    
    echo -e "${CYAN}Remove $type_name${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
    echo
    
    # Get collected items for this type
    collected_items=$(jq -r ".[] | select(.id == \"$char_id\") | .collectibles.$coll_type[]" "$CHARACTERS_FILE" 2>/dev/null)
    
    if [ -z "$collected_items" ]; then
        echo -e "${YELLOW}No ${type_name}s collected yet${NC}"
        sleep 2
        remove_collectible_menu
        return
    fi
    
    echo -e "${GREEN}Collected ${type_name}s:${NC}"
    echo
    
    item_array=()
    counter=1
    
    while IFS= read -r item; do
        echo "$counter. $item"
        item_array+=("$item")
        counter=$((counter + 1))
    done <<< "$collected_items"
    
    echo
    echo "0. Back to remove menu"
    echo
    read -p "Select item to remove (0-$((counter-1))): " item_choice
    
    if [ "$item_choice" = "0" ]; then
        remove_collectible_menu
        return
    fi
    
    if [ "$item_choice" -ge 1 ] && [ "$item_choice" -lt "$counter" ]; then
        item_to_remove="${item_array[$((item_choice-1))]}"
        
        echo
        echo -e "${RED}⚠️  Are you sure you want to remove:${NC}"
        echo -e "${YELLOW}$item_to_remove${NC}"
        read -p "Type 'yes' to confirm: " confirm
        
        if [ "$confirm" = "yes" ]; then
            # Remove the item from character's collection
            jq "map(if .id == \"$char_id\" then .collectibles.$coll_type = [.collectibles.$coll_type[] | select(. != \"$item_to_remove\")] else . end)" "$CHARACTERS_FILE" > "$CHARACTERS_FILE.tmp" && mv "$CHARACTERS_FILE.tmp" "$CHARACTERS_FILE"
            
            echo -e "${GREEN}✓ $type_name removed: $item_to_remove${NC}"
        else
            echo -e "${YELLOW}Removal cancelled${NC}"
        fi
    else
        echo -e "${RED}Invalid selection${NC}"
    fi
    
    sleep 2
    remove_collectible_menu
}

# Add specific collectible (streamlined)
add_specific_collectible() {
    local coll_type=$1
    local reference_file=$2
    local type_name=$3
    
    show_header
    char_id=$(cat "$CURRENT_CHAR_FILE")
    
    echo -e "${CYAN}Add $type_name${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
    echo
    
    if [ -f "$reference_file" ]; then
        echo -e "${GREEN}0.${NC} Type custom entry"
        
        # Get already collected items for this type
        collected_items=$(jq -r ".[] | select(.id == \"$char_id\") | .collectibles.$coll_type[]" "$CHARACTERS_FILE" 2>/dev/null)
        
        # Handle magazines with special structure
        if [ "$coll_type" = "magazines" ]; then
            # Extract all magazine names from structured JSON
            available_items=$(jq -r '.[].items[].issues[].name' "$reference_file")
        else
            # Display available items from reference file (simple array)
            available_items=$(jq -r '.[]' "$reference_file")
        fi
        
        item_array=()
        counter=1
        
        while IFS= read -r item; do
            # Check if item is already collected
            if echo "$collected_items" | grep -Fxq "$item" 2>/dev/null; then
                printf "${GREEN}%2d. ✓ %s (Collected)${NC}\n" "$counter" "$item"
            else
                printf "${WHITE}%2d.${NC} %s\n" "$counter" "$item"
            fi
            item_array+=("$item")
            counter=$((counter + 1))
        done <<< "$available_items"
        
        echo
        read -p "Select option (0-$((counter-1))): " item_choice
        
        if [ "$item_choice" = "0" ]; then
            read -p "Enter custom $type_name name: " item_name
            # Validate that custom entry is not empty
            if [ -z "$item_name" ] || [ "$item_name" = " " ]; then
                echo -e "${RED}Error: Custom entry cannot be empty${NC}"
                sleep 2
                collectibles_menu
                return
            fi
        elif [[ "$item_choice" =~ ^[0-9]+$ ]] && [ "$item_choice" -ge 1 ] && [ "$item_choice" -lt "$counter" ]; then
            item_name="${item_array[$((item_choice-1))]}"
            
            # Check if already collected
            if echo "$collected_items" | grep -Fxq "$item_name" 2>/dev/null; then
                echo -e "${YELLOW}This item is already collected!${NC}"
                sleep 2
                collectibles_menu
                return
            fi
        else
            echo -e "${RED}Invalid selection${NC}"
            sleep 1
            collectibles_menu
            return
        fi
    else
        read -p "Enter $type_name name: " item_name
    fi
    
    # Add the item to character's collection
    jq "map(if .id == \"$char_id\" then .collectibles.$coll_type += [\"$item_name\"] else . end)" "$CHARACTERS_FILE" > "$CHARACTERS_FILE.tmp" && mv "$CHARACTERS_FILE.tmp" "$CHARACTERS_FILE"
    
    echo -e "${GREEN}✓ $type_name added: $item_name${NC}"
    sleep 2
    collectibles_menu
}

# Add Magazine by Category
add_magazine_by_category() {
    show_header
    char_id=$(cat "$CURRENT_CHAR_FILE")
    
    echo -e "${CYAN}📖 Add Magazine by Category${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
    echo
    
    if [ ! -f "$MAGAZINES_FILE" ]; then
        echo -e "${RED}Magazines file not found${NC}"
        sleep 2
        collectibles_menu
        return
    fi
    
    # Display magazine categories
    echo -e "${GREEN}Select Magazine Category:${NC}"
    echo
    echo " 1. You're SPECIAL! & Astoundingly Awesome Tales"
    echo " 2. Grognak the Barbarian"
    echo " 3. Guns and Bullets"
    echo " 4. Hot Rodder"
    echo " 5. La Coiffe"
    echo " 6. Live & Love"
    echo " 7. Massachusetts Surgical Journal"
    echo " 8. Picket Fences"
    echo " 9. RobCo Fun!"
    echo "10. Taboo Tattoos"
    echo "11. Tales of a Junktown Jerky Vendor"
    echo "12. Tesla Science Magazine"
    echo "13. Total Hack"
    echo "14. Tumblers Today"
    echo "15. U.S. Covert Operations Manual"
    echo "16. Unstoppables"
    echo "17. Wasteland Survival Guide"
    echo "18. Islander's Almanac (Far Harbor)"
    echo "19. SCAV! (Nuka-World)"
    echo "20. Creation Club"
    echo " 0. Back to Collectibles Menu"
    echo
    read -p "Select category (0-20): " category_choice
    
    case $category_choice in
        0) collectibles_menu; return ;;
        1) 
            # Special handling for SPECIAL and Astoundingly Awesome Tales
            available_magazines=$(
                jq -r '.[].items[] | select(.title | contains("SPECIAL")) | .issues[].name' "$MAGAZINES_FILE"
                jq -r '.[].items[] | select(.title == "Astoundingly Awesome Tales") | .issues[].name' "$MAGAZINES_FILE"
            )
            ;;
        2) 
            category_titles=("Grognak the Barbarian")
            ;;
        3) 
            category_titles=("Guns and Bullets")
            ;;
        4) 
            category_titles=("Hot Rodder")
            ;;
        5) 
            category_titles=("La Coiffe")
            ;;
        6) 
            category_titles=("Live & Love")
            ;;
        7) 
            category_titles=("Massachusetts Surgical Journal")
            ;;
        8) 
            category_titles=("Picket Fences")
            ;;
        9) 
            category_titles=("RobCo Fun")
            ;;
        10) 
            category_titles=("Taboo Tattoos")
            ;;
        11) 
            category_titles=("Tales of a Junktown Jerky Vendor")
            ;;
        12) 
            category_titles=("Tesla Science Magazine")
            ;;
        13) 
            category_titles=("Total Hack")
            ;;
        14) 
            category_titles=("Tumblers Today")
            ;;
        15) 
            category_titles=("U.S. Covert Operations Manual")
            ;;
        16) 
            category_titles=("Unstoppables")
            ;;
        17) 
            category_titles=("Wasteland Survival Guide")
            ;;
        18) 
            category_titles=("Islander's Almanac")
            ;;
        19) 
            category_titles=("SCAV!")
            ;;
        20) 
            category_titles=("Creation Club")
            ;;
        *) 
            echo -e "${RED}Invalid selection${NC}"
            sleep 1
            add_magazine_by_category
            return
            ;;
    esac
    
    # Show magazines from selected categories
    show_header
    echo -e "${CYAN}📖 Magazines in Selected Category${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
    echo
    
    # Get already collected magazines
    collected_magazines=$(jq -r ".[] | select(.id == \"$char_id\") | .collectibles.magazines[]" "$CHARACTERS_FILE" 2>/dev/null)
    
    # Extract magazines from selected categories (unless already set for special case)
    if [ -z "$available_magazines" ]; then
        available_magazines=""
        for title in "${category_titles[@]}"; do
            category_magazines=$(jq -r --arg title "$title" '.[].items[] | select(.title == $title) | .issues[].name' "$MAGAZINES_FILE")
            if [ ! -z "$category_magazines" ]; then
                available_magazines="$available_magazines$category_magazines"$'\n'
            fi
        done
    fi
    
    if [ -z "$available_magazines" ]; then
        echo -e "${RED}No magazines found in selected category${NC}"
        sleep 2
        add_magazine_by_category
        return
    fi
    
    echo -e "${GREEN}0.${NC} Type custom entry"
    
    item_array=()
    counter=1
    
    while IFS= read -r magazine; do
        if [ ! -z "$magazine" ]; then
            # Check if magazine is already collected
            if echo "$collected_magazines" | grep -Fxq "$magazine" 2>/dev/null; then
                printf "${GREEN}%2d. ✓ %s (Collected)${NC}\n" "$counter" "$magazine"
            else
                printf "${WHITE}%2d.${NC} %s\n" "$counter" "$magazine"
            fi
            item_array+=("$magazine")
            counter=$((counter + 1))
        fi
    done <<< "$available_magazines"
    
    echo
    read -p "Select magazine (0-$((counter-1))): " magazine_choice
    
    if [ "$magazine_choice" = "0" ]; then
        read -p "Enter custom magazine name: " magazine_name
        if [ -z "$magazine_name" ] || [ "$magazine_name" = " " ]; then
            echo -e "${RED}Error: Custom entry cannot be empty${NC}"
            sleep 2
            add_magazine_by_category
            return
        fi
    elif [ "$magazine_choice" -ge 1 ] && [ "$magazine_choice" -lt "$counter" ]; then
        magazine_name="${item_array[$((magazine_choice-1))]}"
        
        # Check if already collected
        if echo "$collected_magazines" | grep -Fxq "$magazine_name" 2>/dev/null; then
            echo -e "${YELLOW}This magazine is already collected!${NC}"
            sleep 2
            add_magazine_by_category
            return
        fi
    else
        echo -e "${RED}Invalid selection${NC}"
        sleep 1
        add_magazine_by_category
        return
    fi
    
    # Add the magazine to character's collection
    jq "map(if .id == \"$char_id\" then .collectibles.magazines += [\"$magazine_name\"] else . end)" "$CHARACTERS_FILE" > "$CHARACTERS_FILE.tmp" && mv "$CHARACTERS_FILE.tmp" "$CHARACTERS_FILE"
    
    echo -e "${GREEN}✓ Magazine added: $magazine_name${NC}"
    sleep 2
    collectibles_menu
}

# Add modded collectible (for mod-specific items)
add_modded_collectible() {
    local coll_type=$1
    local type_name=$2
    
    show_header
    char_id=$(cat "$CURRENT_CHAR_FILE")
    
    echo -e "${CYAN}💾 Add $type_name (Modded)${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
    echo
    
    # Ask which mod this collectible is for
    echo -e "${PURPLE}What mod is this $type_name for?${NC}"
    read -p "Mod Name: " mod_name
    
    if [ -z "$mod_name" ]; then
        echo -e "${RED}Error: Mod name is required${NC}"
        sleep 2
        collectibles_menu
        return
    fi
    
    echo
    read -p "Enter $type_name name: " item_name
    
    if [ -z "$item_name" ]; then
        echo -e "${RED}Error: $type_name name is required${NC}"
        sleep 2
        collectibles_menu
        return
    fi
    
    # Create the item entry with mod information
    item_entry="$item_name ($mod_name)"
    
    # Add the item to character's collection
    jq "map(if .id == \"$char_id\" then .collectibles.$coll_type += [\"$item_entry\"] else . end)" "$CHARACTERS_FILE" > "$CHARACTERS_FILE.tmp" && mv "$CHARACTERS_FILE.tmp" "$CHARACTERS_FILE"
    
    echo -e "${GREEN}✓ $type_name added: $item_entry${NC}"
    sleep 2
    collectibles_menu
}

# Existing Modded Quest Menu
existing_modded_quest_menu() {
    show_header
    char_id=$(cat "$CURRENT_CHAR_FILE")
    char_data=$(jq -r ".[] | select(.id == \"$char_id\")" "$CHARACTERS_FILE")
    
    echo -e "${CYAN}📦 Existing Modded Quest${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
    echo
    
    # Get modded quests
    modded_quests=$(echo "$char_data" | jq -r '.quests.modded[]?')
    
    if [ -z "$modded_quests" ]; then
        echo -e "${YELLOW}No modded quests found. Create a new modded quest first.${NC}"
        echo
        read -p "Press Enter to continue..."
        collectibles_menu
        return
    fi
    
    echo -e "${GREEN}Select a modded quest:${NC}"
    echo
    
    # List existing modded quests
    quest_array=()
    counter=1
    
    while IFS= read -r quest_json; do
        if [ ! -z "$quest_json" ]; then
            quest_name=$(echo "$quest_json" | jq -r '.quest_name // .name')
            mod_name=$(echo "$quest_json" | jq -r '.mod_name // "Unknown"')
            status=$(echo "$quest_json" | jq -r '.status // "active"')
            
            if [ "$status" = "completed" ]; then
                echo -e "${GREEN}$counter. ✓ $quest_name - $mod_name (Completed)${NC}"
            else
                echo -e "${WHITE}$counter. $quest_name - $mod_name${NC}"
            fi
            
            quest_array+=("$quest_json")
            counter=$((counter + 1))
        fi
    done <<< "$modded_quests"
    
    echo
    echo "0. Back"
    echo
    read -p "Select quest (0-$((counter-1))): " quest_choice
    
    if [ "$quest_choice" = "0" ]; then
        collectibles_menu
        return
    fi
    
    if [ "$quest_choice" -ge 1 ] && [ "$quest_choice" -lt "$counter" ]; then
        selected_quest="${quest_array[$((quest_choice-1))]}"
        manage_existing_modded_quest "$selected_quest"
    else
        echo -e "${RED}Invalid selection${NC}"
        sleep 1
        existing_modded_quest_menu
    fi
}

# Manage a specific existing modded quest
manage_existing_modded_quest() {
    local quest_data=$1
    
    show_header
    char_id=$(cat "$CURRENT_CHAR_FILE")
    
    quest_name=$(echo "$quest_data" | jq -r '.quest_name // .name')
    mod_name=$(echo "$quest_data" | jq -r '.mod_name // "Unknown"')
    author=$(echo "$quest_data" | jq -r '.author // "Unknown"')
    release_date=$(echo "$quest_data" | jq -r '.release_date // "Unknown"')
    version=$(echo "$quest_data" | jq -r '.version // "Unknown"')
    status=$(echo "$quest_data" | jq -r '.status // "active"')
    
    echo -e "${CYAN}📦 $quest_name${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
    echo
    echo -e "${GREEN}Mod Information:${NC}"
    echo "  Mod Name: $mod_name"
    echo "  Author: $author"
    echo "  Release Date: $release_date"
    echo "  Version: $version"
    echo "  Status: $status"
    echo
    
    # Show quest progression
    quests=$(echo "$quest_data" | jq -r '.quests[]? // empty')
    if [ ! -z "$quests" ]; then
        echo -e "${GREEN}Quest Progress:${NC}"
        while IFS= read -r quest; do
            if [ ! -z "$quest" ]; then
                echo "  • $quest"
            fi
        done <<< "$quests"
        echo
    fi
    
    if [ "$status" != "completed" ]; then
        echo "1. Add Quest"
        echo "2. Mark Quest as Completed"
        echo "3. Mark Mod as Completed"
    else
        echo -e "${GRAY}This mod is completed${NC}"
    fi
    echo "4. Back"
    echo
    read -p "Select option: " choice
    
    case $choice in
        1) 
            if [ "$status" != "completed" ]; then
                add_quest_to_mod "$quest_data"
            else
                echo -e "${RED}Invalid option${NC}"; sleep 1
                manage_existing_modded_quest "$quest_data"
            fi
            ;;
        2) 
            if [ "$status" != "completed" ]; then
                mark_quest_completed "$quest_data"
            else
                echo -e "${RED}Invalid option${NC}"; sleep 1
                manage_existing_modded_quest "$quest_data"
            fi
            ;;
        3) 
            if [ "$status" != "completed" ]; then
                mark_mod_completed "$quest_data"
            else
                echo -e "${RED}Invalid option${NC}"; sleep 1
                manage_existing_modded_quest "$quest_data"
            fi
            ;;
        4) existing_modded_quest_menu ;;
        *) echo -e "${RED}Invalid option${NC}"; sleep 1; manage_existing_modded_quest "$quest_data" ;;
    esac
}

# New Modded Quest Menu
new_modded_quest_menu() {
    show_header
    char_id=$(cat "$CURRENT_CHAR_FILE")
    
    echo -e "${CYAN}✨ New Modded Quest${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
    echo
    
    echo -e "${GREEN}Create New Modded Quest${NC}"
    echo
    
    # Get quest information
    read -p "Quest Name: " quest_name
    if [ -z "$quest_name" ]; then
        echo -e "${RED}Error: Quest name is required${NC}"
        sleep 2
        collectibles_menu
        return
    fi
    
    read -p "Author Name: " author_name
    if [ -z "$author_name" ]; then
        echo -e "${RED}Error: Author name is required${NC}"
        sleep 2
        collectibles_menu
        return
    fi
    
    read -p "When did it come out: " release_date
    if [ -z "$release_date" ]; then
        echo -e "${RED}Error: Release date is required${NC}"
        sleep 2
        collectibles_menu
        return
    fi
    
    read -p "Quest Version: " quest_version
    if [ -z "$quest_version" ]; then
        echo -e "${RED}Error: Quest version is required${NC}"
        sleep 2
        collectibles_menu
        return
    fi
    
    # Create the new modded quest object
    new_quest=$(jq -n \
        --arg quest_name "$quest_name" \
        --arg mod_name "$quest_name" \
        --arg author "$author_name" \
        --arg release_date "$release_date" \
        --arg version "$quest_version" \
        '{
            quest_name: $quest_name,
            mod_name: $mod_name,
            author: $author,
            release_date: $release_date,
            version: $version,
            status: "active",
            quests: []
        }')
    
    # Add the new modded quest to character data
    jq "map(if .id == \"$char_id\" then .quests.modded += [$new_quest] else . end)" "$CHARACTERS_FILE" > "$CHARACTERS_FILE.tmp" && mv "$CHARACTERS_FILE.tmp" "$CHARACTERS_FILE"
    
    echo
    echo -e "${GREEN}✓ New modded quest created: $quest_name${NC}"
    sleep 2
    
    # Now go to manage this quest
    manage_existing_modded_quest "$new_quest"
}

# Add quest to existing mod
add_quest_to_mod() {
    local quest_data=$1
    local mod_name=$(echo "$quest_data" | jq -r '.mod_name')
    
    echo
    read -p "Quest Name: " new_quest_name
    
    if [ -z "$new_quest_name" ]; then
        echo -e "${RED}Error: Quest name is required${NC}"
        sleep 2
        manage_existing_modded_quest "$quest_data"
        return
    fi
    
    char_id=$(cat "$CURRENT_CHAR_FILE")
    
    # Add quest to the specific mod
    jq "map(if .id == \"$char_id\" then .quests.modded = [.quests.modded[] | if .mod_name == \"$mod_name\" then .quests += [\"$new_quest_name\"] else . end] else . end)" "$CHARACTERS_FILE" > "$CHARACTERS_FILE.tmp" && mv "$CHARACTERS_FILE.tmp" "$CHARACTERS_FILE"
    
    echo -e "${GREEN}✓ Quest added: $new_quest_name${NC}"
    sleep 2
    
    # Reload the updated quest data and continue managing
    updated_quest_data=$(jq -r ".[] | select(.id == \"$char_id\") | .quests.modded[] | select(.mod_name == \"$mod_name\")" "$CHARACTERS_FILE")
    manage_existing_modded_quest "$updated_quest_data"
}

# Mark individual quest as completed
mark_quest_completed() {
    local quest_data=$1
    local mod_name=$(echo "$quest_data" | jq -r '.mod_name')
    
    # Get list of active quests
    active_quests=$(echo "$quest_data" | jq -r '.quests[]? // empty')
    
    if [ -z "$active_quests" ]; then
        echo -e "${YELLOW}No active quests to complete${NC}"
        sleep 2
        manage_existing_modded_quest "$quest_data"
        return
    fi
    
    echo
    echo -e "${GREEN}Select quest to mark as completed:${NC}"
    echo
    
    quest_array=()
    counter=1
    
    while IFS= read -r quest; do
        if [ ! -z "$quest" ]; then
            echo "$counter. $quest"
            quest_array+=("$quest")
            counter=$((counter + 1))
        fi
    done <<< "$active_quests"
    
    echo
    echo "0. Back"
    echo
    read -p "Select quest (0-$((counter-1))): " quest_choice
    
    if [ "$quest_choice" = "0" ]; then
        manage_existing_modded_quest "$quest_data"
        return
    fi
    
    if [ "$quest_choice" -ge 1 ] && [ "$quest_choice" -lt "$counter" ]; then
        quest_to_complete="${quest_array[$((quest_choice-1))]}"
        char_id=$(cat "$CURRENT_CHAR_FILE")
        
        # Remove the completed quest from the mod's quest list
        jq "map(if .id == \"$char_id\" then .quests.modded = [.quests.modded[] | if .mod_name == \"$mod_name\" then .quests = [.quests[] | select(. != \"$quest_to_complete\")] else . end] else . end)" "$CHARACTERS_FILE" > "$CHARACTERS_FILE.tmp" && mv "$CHARACTERS_FILE.tmp" "$CHARACTERS_FILE"
        
        echo -e "${GREEN}✓ Quest completed: $quest_to_complete${NC}"
        sleep 2
        
        # Reload and continue
        updated_quest_data=$(jq -r ".[] | select(.id == \"$char_id\") | .quests.modded[] | select(.mod_name == \"$mod_name\")" "$CHARACTERS_FILE")
        manage_existing_modded_quest "$updated_quest_data"
    else
        echo -e "${RED}Invalid selection${NC}"
        sleep 1
        mark_quest_completed "$quest_data"
    fi
}

# Mark entire mod as completed
mark_mod_completed() {
    local quest_data=$1
    local mod_name=$(echo "$quest_data" | jq -r '.mod_name')
    
    echo
    echo -e "${YELLOW}⚠️  Are you sure you want to mark the entire mod '$mod_name' as completed?${NC}"
    read -p "Type 'yes' to confirm: " confirm
    
    if [ "$confirm" = "yes" ]; then
        char_id=$(cat "$CURRENT_CHAR_FILE")
        
        # Mark the mod as completed and clear remaining quests
        jq "map(if .id == \"$char_id\" then .quests.modded = [.quests.modded[] | if .mod_name == \"$mod_name\" then .status = \"completed\" | .quests = [] else . end] else . end)" "$CHARACTERS_FILE" > "$CHARACTERS_FILE.tmp" && mv "$CHARACTERS_FILE.tmp" "$CHARACTERS_FILE"
        
        echo -e "${GREEN}✓ Mod completed: $mod_name${NC}"
        sleep 2
        existing_modded_quest_menu
    else
        echo -e "${YELLOW}Operation cancelled${NC}"
        sleep 1
        manage_existing_modded_quest "$quest_data"
    fi
}

# Quick Quest Actions - Enhanced Quest Management
quick_quest_actions() {
    show_header
    char_id=$(cat "$CURRENT_CHAR_FILE")
    
    echo -e "${CYAN}🎯 Quick Quest Actions${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
    echo
    
    echo -e "${GREEN}Quick Actions:${NC}"
    echo "1. 🔥 Complete Multiple Quests"
    echo "2. 📝 Bulk Add Quests to Mod"
    echo "3. 🗂️ Quest Status Overview"
    echo "4. 🔄 Transfer Quests Between Mods"
    echo "5. 📊 Quest Statistics"
    echo "6. 🗑️ Remove Completed Mods"
    echo "7. ← Back"
    echo
    read -p "Select option: " choice
    
    case $choice in
        1) complete_multiple_quests ;;
        2) bulk_add_quests ;;
        3) quest_status_overview ;;
        4) transfer_quests ;;
        5) quest_statistics ;;
        6) remove_completed_mods ;;
        7) dlc_modded_menu ;;
        *) echo -e "${RED}Invalid option${NC}"; sleep 1; quick_quest_actions ;;
    esac
}

# Complete multiple quests at once
complete_multiple_quests() {
    show_header
    char_id=$(cat "$CURRENT_CHAR_FILE")
    
    echo -e "${CYAN}🔥 Complete Multiple Quests${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
    echo
    
    # Get all active modded quests
    char_data=$(jq ".[] | select(.id == \"$char_id\")" "$CHARACTERS_FILE")
    modded_quests=$(echo "$char_data" | jq -c '.quests.modded[]? | select(.status != "completed")')
    
    if [ -z "$modded_quests" ]; then
        echo -e "${YELLOW}No active modded quests found.${NC}"
        read -p "Press Enter to continue..."
        quick_quest_actions
        return
    fi
    
    echo -e "${GREEN}Select quests to complete (space-separated numbers):${NC}"
    echo
    
    quest_list=()
    counter=1
    
    while IFS= read -r quest_data; do
        if [ ! -z "$quest_data" ]; then
            mod_name=$(echo "$quest_data" | jq -r '.mod_name')
            quest_count=$(echo "$quest_data" | jq -r '.quests | length')
            echo "$counter. $mod_name ($quest_count active quests)"
            quest_list+=("$quest_data")
            counter=$((counter + 1))
        fi
    done <<< "$modded_quests"
    
    echo
    echo "0. Back"
    echo
    read -p "Enter quest numbers (e.g., 1 3 5): " selections
    
    if [ "$selections" = "0" ]; then
        quick_quest_actions
        return
    fi
    
    # Process selections
    for selection in $selections; do
        if [ "$selection" -ge 1 ] && [ "$selection" -lt "$counter" ]; then
            quest_data="${quest_list[$((selection-1))]}"
            mod_name=$(echo "$quest_data" | jq -r '.mod_name')
            jq "map(if .id == \"$char_id\" then .quests.modded = [.quests.modded[] | if .mod_name == \"$mod_name\" then .status = \"completed\" | .quests = [] else . end] else . end)" "$CHARACTERS_FILE" > "$CHARACTERS_FILE.tmp" && mv "$CHARACTERS_FILE.tmp" "$CHARACTERS_FILE"
            echo -e "${GREEN}✓ Completed all quests in: $mod_name${NC}"
        fi
    done
    
    echo
    read -p "Press Enter to continue..."
    quick_quest_actions
}

# Bulk add quests to a mod
bulk_add_quests() {
    show_header
    char_id=$(cat "$CURRENT_CHAR_FILE")
    
    echo -e "${CYAN}📝 Bulk Add Quests to Mod${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
    echo
    
    # Get all active mods
    char_data=$(jq ".[] | select(.id == \"$char_id\")" "$CHARACTERS_FILE")
    active_mods=$(echo "$char_data" | jq -c '.quests.modded[]? | select(.status != "completed")')
    
    if [ -z "$active_mods" ]; then
        echo -e "${YELLOW}No active mods found. Create a new modded quest first.${NC}"
        read -p "Press Enter to continue..."
        quick_quest_actions
        return
    fi
    
    echo -e "${GREEN}Select mod to add quests to:${NC}"
    echo
    
    mod_list=()
    counter=1
    
    while IFS= read -r mod_data; do
        if [ ! -z "$mod_data" ]; then
            mod_name=$(echo "$mod_data" | jq -r '.mod_name')
            echo "$counter. $mod_name"
            mod_list+=("$mod_data")
            counter=$((counter + 1))
        fi
    done <<< "$active_mods"
    
    echo
    echo "0. Back"
    echo
    read -p "Select mod (0-$((counter-1))): " mod_choice
    
    if [ "$mod_choice" = "0" ]; then
        quick_quest_actions
        return
    fi
    
    if [ "$mod_choice" -ge 1 ] && [ "$mod_choice" -lt "$counter" ]; then
        selected_mod="${mod_list[$((mod_choice-1))]}"
        mod_name=$(echo "$selected_mod" | jq -r '.mod_name')
        
        echo
        echo -e "${GREEN}Adding quests to: $mod_name${NC}"
        echo -e "${CYAN}Enter quest names (one per line, empty line to finish):${NC}"
        echo
        
        quest_names=()
        while true; do
            read -p "Quest name: " quest_name
            if [ -z "$quest_name" ]; then
                break
            fi
            quest_names+=("$quest_name")
        done
        
        # Add all quests to the mod
        for quest_name in "${quest_names[@]}"; do
            jq "map(if .id == \"$char_id\" then .quests.modded = [.quests.modded[] | if .mod_name == \"$mod_name\" then .quests += [\"$quest_name\"] else . end] else . end)" "$CHARACTERS_FILE" > "$CHARACTERS_FILE.tmp" && mv "$CHARACTERS_FILE.tmp" "$CHARACTERS_FILE"
            echo -e "${GREEN}✓ Added: $quest_name${NC}"
        done
        
        echo
        echo -e "${GREEN}Added ${#quest_names[@]} quests to $mod_name${NC}"
    else
        echo -e "${RED}Invalid selection${NC}"
        sleep 1
        bulk_add_quests
        return
    fi
    
    echo
    read -p "Press Enter to continue..."
    quick_quest_actions
}

# Quest Status Overview
quest_status_overview() {
    show_header
    char_id=$(cat "$CURRENT_CHAR_FILE")
    
    echo -e "${CYAN}🗂️ Quest Status Overview${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
    echo
    
    char_data=$(jq ".[] | select(.id == \"$char_id\")" "$CHARACTERS_FILE")
    
    # Count totals
    total_mods=$(echo "$char_data" | jq '.quests.modded | length // 0')
    active_mods=$(echo "$char_data" | jq '[.quests.modded[]? | select(.status != "completed")] | length')
    completed_mods=$(echo "$char_data" | jq '[.quests.modded[]? | select(.status == "completed")] | length')
    
    # Count total quests
    total_active_quests=0
    active_mods_data=$(echo "$char_data" | jq -c '.quests.modded[]? | select(.status != "completed")')
    while IFS= read -r mod_data; do
        if [ ! -z "$mod_data" ]; then
            quest_count=$(echo "$mod_data" | jq '.quests | length')
            total_active_quests=$((total_active_quests + quest_count))
        fi
    done <<< "$active_mods_data"
    
    echo -e "${CYAN}📊 Summary:${NC}"
    echo "  Total Mods: $total_mods"
    echo "  Active Mods: $active_mods"
    echo "  Completed Mods: $completed_mods"
    echo "  Active Quests: $total_active_quests"
    echo
    
    if [ "$active_mods" -gt 0 ]; then
        echo -e "${GREEN}Active Mods:${NC}"
        echo
        while IFS= read -r mod_data; do
            if [ ! -z "$mod_data" ]; then
                mod_name=$(echo "$mod_data" | jq -r '.mod_name')
                author=$(echo "$mod_data" | jq -r '.author // "Unknown"')
                quest_count=$(echo "$mod_data" | jq '.quests | length')
                echo "  📦 $mod_name by $author ($quest_count active)"
            fi
        done <<< "$active_mods_data"
        echo
    fi
    
    if [ "$completed_mods" -gt 0 ]; then
        echo -e "${GRAY}Completed Mods:${NC}"
        echo
        completed_mods_data=$(echo "$char_data" | jq -c '.quests.modded[]? | select(.status == "completed")')
        while IFS= read -r mod_data; do
            if [ ! -z "$mod_data" ]; then
                mod_name=$(echo "$mod_data" | jq -r '.mod_name')
                author=$(echo "$mod_data" | jq -r '.author // "Unknown"')
                echo "  ✅ $mod_name by $author"
            fi
        done <<< "$completed_mods_data"
    fi
    
    echo
    read -p "Press Enter to continue..."
    quick_quest_actions
}

# Quest Progress Report - Enhanced reporting
quest_progress_report() {
    show_header
    char_id=$(cat "$CURRENT_CHAR_FILE")
    
    echo -e "${CYAN}📋 Quest Progress Report${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
    echo
    
    char_data=$(jq ".[] | select(.id == \"$char_id\")" "$CHARACTERS_FILE")
    char_name=$(echo "$char_data" | jq -r '.name')
    game_type=$(echo "$char_data" | jq -r '.game_type // "Main"')
    
    echo -e "${GREEN}Character:${NC} $char_name"
    echo -e "${GREEN}Game Type:${NC} $game_type"
    echo
    
    # Main and DLC quest counts
    main_quests=$(echo "$char_data" | jq '.quests.main | length // 0')
    dlc_quests=$(echo "$char_data" | jq '.quests.dlc | length // 0')
    
    echo -e "${CYAN}📊 Quest Summary:${NC}"
    echo "  Main Quests: $main_quests active"
    echo "  DLC Quests: $dlc_quests active"
    
    # Modded quest details
    if [[ "$game_type" == *"Modded"* ]]; then
        total_mods=$(echo "$char_data" | jq '.quests.modded | length // 0')
        active_mods=$(echo "$char_data" | jq '[.quests.modded[]? | select(.status != "completed")] | length')
        completed_mods=$(echo "$char_data" | jq '[.quests.modded[]? | select(.status == "completed")] | length')
        
        echo "  Modded Content:"
        echo "    - Total Mods: $total_mods"
        echo "    - Active Mods: $active_mods"
        echo "    - Completed Mods: $completed_mods"
        
        if [ "$active_mods" -gt 0 ]; then
            echo
            echo -e "${GREEN}📦 Active Modded Quests:${NC}"
            active_mods_data=$(echo "$char_data" | jq -c '.quests.modded[]? | select(.status != "completed")')
            while IFS= read -r mod_data; do
                if [ ! -z "$mod_data" ]; then
                    mod_name=$(echo "$mod_data" | jq -r '.mod_name')
                    author=$(echo "$mod_data" | jq -r '.author // "Unknown"')
                    version=$(echo "$mod_data" | jq -r '.version // "Unknown"')
                    quest_count=$(echo "$mod_data" | jq '.quests | length')
                    
                    echo "  $mod_name"
                    echo "    Author: $author | Version: $version"
                    echo "    Active Quests: $quest_count"
                    
                    # Show quest list if not too many
                    if [ "$quest_count" -le 5 ] && [ "$quest_count" -gt 0 ]; then
                        quests=$(echo "$mod_data" | jq -r '.quests[]?')
                        while IFS= read -r quest; do
                            if [ ! -z "$quest" ]; then
                                echo "      • $quest"
                            fi
                        done <<< "$quests"
                    elif [ "$quest_count" -gt 5 ]; then
                        echo "      • (Too many quests to display individually)"
                    fi
                    echo
                fi
            done
        fi
    else
        echo "  Modded Content: Not Available"
    fi
    
    # Completion rate
    if [[ "$game_type" == *"Modded"* ]] && [ "$total_mods" -gt 0 ]; then
        completion_rate=$((completed_mods * 100 / total_mods))
        echo -e "${CYAN}📈 Mod Completion Rate:${NC} $completion_rate% ($completed_mods/$total_mods mods completed)"
    fi
    
    echo
    read -p "Press Enter to continue..."
    dlc_modded_menu
}

# Transfer quests between mods (advanced feature)
transfer_quests() {
    echo -e "${YELLOW}🚧 Transfer Quests feature coming soon!${NC}"
    echo "This feature will allow you to move quests between different mods."
    sleep 2
    quick_quest_actions
}

# Quest statistics
quest_statistics() {
    show_header
    char_id=$(cat "$CURRENT_CHAR_FILE")
    
    echo -e "${CYAN}📊 Quest Statistics${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
    echo
    
    char_data=$(jq ".[] | select(.id == \"$char_id\")" "$CHARACTERS_FILE")
    
    # Calculate various statistics
    total_mods=$(echo "$char_data" | jq '.quests.modded | length // 0')
    active_mods=$(echo "$char_data" | jq '[.quests.modded[]? | select(.status != "completed")] | length')
    completed_mods=$(echo "$char_data" | jq '[.quests.modded[]? | select(.status == "completed")] | length')
    
    # Find most active mod
    if [ "$active_mods" -gt 0 ]; then
        most_active_mod=""
        most_active_count=0
        active_mods_data=$(echo "$char_data" | jq -c '.quests.modded[]? | select(.status != "completed")')
        while IFS= read -r mod_data; do
            if [ ! -z "$mod_data" ]; then
                mod_name=$(echo "$mod_data" | jq -r '.mod_name')
                quest_count=$(echo "$mod_data" | jq '.quests | length')
                if [ "$quest_count" -gt "$most_active_count" ]; then
                    most_active_count="$quest_count"
                    most_active_mod="$mod_name"
                fi
            fi
        done <<< "$active_mods_data"
    fi
    
    # Count total active quests
    total_active_quests=0
    active_mods_data=$(echo "$char_data" | jq -c '.quests.modded[]? | select(.status != "completed")')
    while IFS= read -r mod_data; do
        if [ ! -z "$mod_data" ]; then
            quest_count=$(echo "$mod_data" | jq '.quests | length')
            total_active_quests=$((total_active_quests + quest_count))
        fi
    done <<< "$active_mods_data"
    
    # Average quests per mod
    if [ "$active_mods" -gt 0 ]; then
        avg_quests=$((total_active_quests / active_mods))
    else
        avg_quests=0
    fi
    
    echo -e "${CYAN}📈 Statistics:${NC}"
    echo "  Total Mods Installed: $total_mods"
    echo "  Active Mods: $active_mods"
    echo "  Completed Mods: $completed_mods"
    echo "  Total Active Quests: $total_active_quests"
    echo "  Average Quests per Mod: $avg_quests"
    
    if [ ! -z "$most_active_mod" ]; then
        echo "  Most Active Mod: $most_active_mod ($most_active_count quests)"
    fi
    
    if [ "$total_mods" -gt 0 ]; then
        completion_percentage=$((completed_mods * 100 / total_mods))
        echo "  Completion Rate: $completion_percentage%"
    fi
    
    echo
    read -p "Press Enter to continue..."
    quick_quest_actions
}

# Remove completed mods
remove_completed_mods() {
    show_header
    char_id=$(cat "$CURRENT_CHAR_FILE")
    
    echo -e "${CYAN}🗑️ Remove Completed Mods${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
    echo
    
    char_data=$(jq ".[] | select(.id == \"$char_id\")" "$CHARACTERS_FILE")
    completed_mods=$(echo "$char_data" | jq -c '.quests.modded[]? | select(.status == "completed")')
    
    if [ -z "$completed_mods" ]; then
        echo -e "${YELLOW}No completed mods found.${NC}"
        read -p "Press Enter to continue..."
        quick_quest_actions
        return
    fi
    
    echo -e "${GREEN}Completed mods that can be removed:${NC}"
    echo
    
    mod_list=()
    counter=1
    
    while IFS= read -r mod_data; do
        if [ ! -z "$mod_data" ]; then
            mod_name=$(echo "$mod_data" | jq -r '.mod_name')
            author=$(echo "$mod_data" | jq -r '.author // "Unknown"')
            echo "$counter. $mod_name by $author"
            mod_list+=("$mod_data")
            counter=$((counter + 1))
        fi
    done <<< "$completed_mods"
    
    echo
    echo "0. Remove All Completed Mods"
    echo "-1. Back"
    echo
    read -p "Select mods to remove (space-separated numbers or 0 for all): " selections
    
    if [ "$selections" = "-1" ]; then
        quick_quest_actions
        return
    fi
    
    if [ "$selections" = "0" ]; then
        echo
        echo -e "${YELLOW}⚠️  Are you sure you want to remove ALL completed mods?${NC}"
        read -p "Type 'yes' to confirm: " confirm
        if [ "$confirm" = "yes" ]; then
            jq "map(if .id == \"$char_id\" then .quests.modded = [.quests.modded[]? | select(.status != \"completed\")] else . end)" "$CHARACTERS_FILE" > "$CHARACTERS_FILE.tmp" && mv "$CHARACTERS_FILE.tmp" "$CHARACTERS_FILE"
            echo -e "${GREEN}✓ All completed mods removed${NC}"
        else
            echo -e "${YELLOW}Operation cancelled${NC}"
        fi
    else
        # Remove selected mods
        for selection in $selections; do
            if [ "$selection" -ge 1 ] && [ "$selection" -lt "$counter" ]; then
                mod_data="${mod_list[$((selection-1))]}"
                mod_name=$(echo "$mod_data" | jq -r '.mod_name')
                jq "map(if .id == \"$char_id\" then .quests.modded = [.quests.modded[]? | select(.mod_name != \"$mod_name\")] else . end)" "$CHARACTERS_FILE" > "$CHARACTERS_FILE.tmp" && mv "$CHARACTERS_FILE.tmp" "$CHARACTERS_FILE"
                echo -e "${GREEN}✓ Removed: $mod_name${NC}"
            fi
        done
    fi
    
    echo
    read -p "Press Enter to continue..."
    quick_quest_actions
}

# Progress Overview
progress_overview() {
    show_header
    char_id=$(cat "$CURRENT_CHAR_FILE")
    char_data=$(jq -r ".[] | select(.id == \"$char_id\")" "$CHARACTERS_FILE")
    
    echo -e "${CYAN}📈 Progress Overview${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
    echo
    
    # Character basic info
    char_name=$(echo "$char_data" | jq -r '.name')
    char_level=$(echo "$char_data" | jq -r '.level')
    faction=$(echo "$char_data" | jq -r '.faction // "None"')
    game_type=$(echo "$char_data" | jq -r '.game_type // "Main"')
    
    # Get platform information
    platform_type=$(echo "$char_data" | jq -r '.platform.type // "PC"')
    if [[ "$platform_type" == "PC" ]]; then
        distribution=$(echo "$char_data" | jq -r '.platform.distribution // "Steam"')
        platform_display="$platform_type ($distribution)"
    else
        console_type=$(echo "$char_data" | jq -r '.platform.console_type // "PS4/Xbox One"')
        platform_display="$platform_type ($console_type)"
    fi
    
    echo -e "${GREEN}Character:${NC} $char_name | Level $char_level | $faction | $game_type"
    echo -e "${GREEN}Platform:${NC} $platform_display"
    echo
    
    # SPECIAL total
    special=$(echo "$char_data" | jq -r '.special')
    special_total=$((
        $(echo "$special" | jq -r '.strength') +
        $(echo "$special" | jq -r '.perception') +
        $(echo "$special" | jq -r '.endurance') +
        $(echo "$special" | jq -r '.charisma') +
        $(echo "$special" | jq -r '.intelligence') +
        $(echo "$special" | jq -r '.agility') +
        $(echo "$special" | jq -r '.luck')
    ))
    
    echo -e "${CYAN}S.P.E.C.I.A.L Total:${NC} $special_total/70"
    
    # Perks count
    perk_count=$(echo "$char_data" | jq '.perks | length')
    echo -e "${CYAN}Total Perks:${NC} $perk_count"
    
    # Collectibles
    collectibles=$(echo "$char_data" | jq -r '.collectibles')
    bobblehead_count=$(echo "$collectibles" | jq '.bobbleheads | length')
    magazine_count=$(echo "$collectibles" | jq '.magazines | length')
    holotape_count=$(echo "$collectibles" | jq '.holotapes | length')
    note_count=$(echo "$collectibles" | jq '.notes | length')
    unique_count=$(echo "$collectibles" | jq '.unique_items | length')
    
    echo
    echo -e "${YELLOW}Collectibles Progress:${NC}"
    
    # Progress bars
    draw_progress_bar "Bobbleheads" $bobblehead_count 20
    draw_progress_bar "Magazines" $magazine_count 133
    echo -e "  Holotapes:    $holotape_count collected"
    echo -e "  Notes:        $note_count collected"
    echo -e "  Unique Items: $unique_count collected"
    
    # Quest progress
    echo
    echo -e "${YELLOW}Quest Progress:${NC}"
    main_quests=$(echo "$char_data" | jq '.quests.main | length')
    dlc_quests=$(echo "$char_data" | jq '.quests.dlc | length')
    modded_quests=$(echo "$char_data" | jq '.quests.modded | length')
    
    echo -e "  Main Quests:   ${GRAY}$main_quests active (tracking disabled)${NC}"
    if [[ "$game_type" == *"DLC"* ]]; then
        echo -e "  DLC Quests:    ${GRAY}$dlc_quests active (tracking disabled)${NC}"
    fi
    if [[ "$game_type" == *"Modded"* ]]; then
        echo "  Modded Quests: $modded_quests active"
    fi
    
    # Completion percentage
    echo
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
    
    # Calculate rough completion percentage
    completion=0
    completion=$((completion + (bobblehead_count * 100 / 20) / 4))  # 25% weight
    completion=$((completion + (magazine_count * 100 / 133) / 4))   # 25% weight
    completion=$((completion + (perk_count * 100 / 70) / 4))        # 25% weight
    completion=$((completion + (char_level * 100 / 300) / 4))       # 25% weight
    
    echo -e "${GREEN}Overall Completion: ~$completion%${NC}"
    
    echo
    read -p "Press Enter to continue..."
    character_menu
}

# Draw progress bar
draw_progress_bar() {
    local label=$1
    local current=$2
    local max=$3
    local percentage=$((current * 100 / max))
    local bar_length=20
    local filled=$((percentage * bar_length / 100))
    
    printf "  %-12s [" "$label:"
    
    for ((i=0; i<bar_length; i++)); do
        if [ $i -lt $filled ]; then
            printf "█"
        else
            printf "░"
        fi
    done
    
    printf "] %3d/%d (%d%%)\n" "$current" "$max" "$percentage"
}

# View character summary
view_character_summary() {
    show_header
    char_id=$(cat "$CURRENT_CHAR_FILE")
    char_data=$(jq -r ".[] | select(.id == \"$char_id\")" "$CHARACTERS_FILE")
    
    echo -e "${CYAN}Character Summary${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
    echo
    
    echo -e "${GREEN}Basic Information:${NC}"
    echo "  Name:     $(echo "$char_data" | jq -r '.name')"
    echo "  Gender:   $(echo "$char_data" | jq -r '.gender')"
    echo "  Level:    $(echo "$char_data" | jq -r '.level')"
    echo "  Faction:  $(echo "$char_data" | jq -r '.faction // "None"')"
    echo "  Game:     $(echo "$char_data" | jq -r '.game_type // "Main"')"
    
    # Platform information
    platform_type=$(echo "$char_data" | jq -r '.platform.type // "PC"')
    if [[ "$platform_type" == "PC" ]]; then
        distribution=$(echo "$char_data" | jq -r '.platform.distribution // "Steam"')
        platform_display="$platform_type ($distribution)"
    else
        console_type=$(echo "$char_data" | jq -r '.platform.console_type // "PS4/Xbox One"')
        platform_display="$platform_type ($console_type)"
    fi
    mod_support=$(echo "$char_data" | jq -r '.platform.mod_support // "Full"')
    echo "  Platform: $platform_display"
    echo "  Mod Support: $mod_support"
    
    echo
    echo -e "${GREEN}S.P.E.C.I.A.L:${NC}"
    special=$(echo "$char_data" | jq -r '.special')
    echo "  S: $(echo "$special" | jq -r '.strength') | P: $(echo "$special" | jq -r '.perception') | E: $(echo "$special" | jq -r '.endurance')"
    echo "  C: $(echo "$special" | jq -r '.charisma') | I: $(echo "$special" | jq -r '.intelligence') | A: $(echo "$special" | jq -r '.agility') | L: $(echo "$special" | jq -r '.luck')"
    
    echo
    read -p "Press Enter to continue..."
}

# Perk recommendations
perk_recommendations() {
    show_header
    char_id=$(cat "$CURRENT_CHAR_FILE")
    
    echo -e "${CYAN}Perk Recommendations${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
    echo
    
    special=$(jq -r ".[] | select(.id == \"$char_id\") | .special" "$CHARACTERS_FILE")
    char_level=$(jq -r ".[] | select(.id == \"$char_id\") | .level" "$CHARACTERS_FILE")
    
    echo -e "${GREEN}Based on your S.P.E.C.I.A.L stats and level $char_level:${NC}"
    echo
    
    # Check each SPECIAL stat and recommend perks
    strength=$(echo "$special" | jq -r '.strength')
    if [ "$strength" -ge 3 ]; then
        echo "💪 Strength ($strength):"
        echo "   • Armorer (Rank 1 requires STR 3)"
        [ "$strength" -ge 5 ] && echo "   • Heavy Gunner (Rank 1 requires STR 5)"
        echo
    fi
    
    perception=$(echo "$special" | jq -r '.perception')
    if [ "$perception" -ge 3 ]; then
        echo "👁️ Perception ($perception):"
        echo "   • Rifleman (Rank 1 requires PER 2)"
        [ "$perception" -ge 4 ] && echo "   • Locksmith (Rank 1 requires PER 4)"
        echo
    fi
    
    intelligence=$(echo "$special" | jq -r '.intelligence')
    if [ "$intelligence" -ge 3 ]; then
        echo "🧠 Intelligence ($intelligence):"
        echo "   • Gun Nut (Rank 1 requires INT 3)"
        [ "$intelligence" -ge 6 ] && echo "   • Science! (Rank 1 requires INT 6)"
        echo
    fi
    
    echo -e "${YELLOW}Tip: Higher level perks become available as you level up!${NC}"
    
    echo
    read -p "Press Enter to continue..."
    perks_special_menu
}

# Search collectibles
search_collectibles() {
    show_header
    char_id=$(cat "$CURRENT_CHAR_FILE")
    
    echo -e "${CYAN}🔍 Search Collectibles${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
    echo
    
    read -p "Enter search term: " search_term
    echo
    
    collectibles=$(jq -r ".[] | select(.id == \"$char_id\") | .collectibles" "$CHARACTERS_FILE")
    
    echo -e "${GREEN}Search Results for '$search_term':${NC}"
    echo
    
    # Search in each category
    for category in bobbleheads magazines holotapes notes unique_items; do
        results=$(echo "$collectibles" | jq -r ".$category[] | select(. | ascii_downcase | contains(\"$search_term\" | ascii_downcase))")
        if [ ! -z "$results" ]; then
            case $category in
                bobbleheads) echo -e "${GREEN}📊 Bobbleheads:${NC}" ;;
                magazines) echo -e "${MAGENTA}📖 Magazines:${NC}" ;;
                holotapes) echo -e "${BLUE}💾 Holotapes:${NC}" ;;
                notes) echo -e "${YELLOW}📝 Notes:${NC}" ;;
                unique_items) echo -e "${RED}⭐ Unique Items:${NC}" ;;
            esac
            echo "$results" | while read -r item; do
                echo "   • $item"
            done
            echo
        fi
    done
    
    read -p "Press Enter to continue..."
    collectibles_menu
}

# Update character level
update_level() {
    show_header
    char_id=$(cat "$CURRENT_CHAR_FILE")
    
    echo -e "${CYAN}Update Level${NC}"
    echo
    echo "1. Current Level"
    echo "2. Change Level"
    echo "3. Back"
    echo
    read -p "Select option: " choice
    
    case $choice in
        1)
            level=$(jq -r ".[] | select(.id == \"$char_id\") | .level" "$CHARACTERS_FILE")
            echo -e "${GREEN}Current Level: $level${NC}"
            read -p "Press Enter to continue..."
            update_level
            ;;
        2)
            read -p "Enter new level (1-300): " new_level
            jq "map(if .id == \"$char_id\" then .level = $new_level else . end)" "$CHARACTERS_FILE" > "$CHARACTERS_FILE.tmp" && mv "$CHARACTERS_FILE.tmp" "$CHARACTERS_FILE"
            echo -e "${GREEN}Level updated to $new_level${NC}"
            sleep 1
            update_level
            ;;
        3)
            character_menu
            ;;
        *)
            echo -e "${RED}Invalid option${NC}"
            sleep 1
            update_level
            ;;
    esac
}

# Character additions menu
character_additions() {
    show_header
    char_id=$(cat "$CURRENT_CHAR_FILE")
    
    echo -e "${CYAN}Character Additions${NC}"
    echo
    echo "1. Add Perk"
    echo "2. Upgrade Perk"
    echo "3. View All Perks"
    echo "4. Upgrade SPECIAL Stats"
    echo "5. Add Collectible"
    echo "6. View All Collectibles"
    echo "7. Back"
    echo
    read -p "Select option: " choice
    
    case $choice in
        1) add_perk ;;
        2) upgrade_perk ;;
        3) view_all_perks ;;
        4) upgrade_special ;;
        5) add_collectible ;;
        6) view_all_collectibles ;;
        7) character_menu ;;
        *) echo -e "${RED}Invalid option${NC}"; sleep 1; character_additions ;;
    esac
}

# Add perk
add_perk() {
    show_header
    char_id=$(cat "$CURRENT_CHAR_FILE")
    
    echo -e "${CYAN}Add Perk${NC}"
    echo
    
    # Check if perks reference file exists
    if [ -f "$PERKS_FILE" ]; then
        echo "Select a perk:"
        echo "0. Type custom perk"
        
        # Get already added perks
        existing_perks=$(jq -r ".[] | select(.id == \"$char_id\") | .perks[].name" "$CHARACTERS_FILE" 2>/dev/null)
        
        # Display available perks from reference file
        perks_list=$(jq -r '.[] | "\(.name) (\(.special)) - Max Rank: \(.ranks)"' "$PERKS_FILE")
        perk_array=()
        perk_ranks=()
        counter=1
        
        while IFS= read -r perk_info; do
            perk_name=$(echo "$perk_info" | sed 's/ (.*//')
            max_rank=$(echo "$perk_info" | sed 's/.*Max Rank: //')
            
            # Check if perk already exists
            if echo "$existing_perks" | grep -Fxq "$perk_name" 2>/dev/null; then
                current_rank=$(jq -r ".[] | select(.id == \"$char_id\") | .perks[] | select(.name == \"$perk_name\") | .rank" "$CHARACTERS_FILE")
                echo -e "$counter. ${GREEN}✓${NC} $perk_info ${GREEN}(Current Rank: $current_rank)${NC}"
            else
                echo "$counter. $perk_info"
            fi
            
            perk_array+=("$perk_name")
            perk_ranks+=("$max_rank")
            counter=$((counter + 1))
        done <<< "$perks_list"
        
        echo
        read -p "Select perk (0-$((counter-1))): " perk_choice
        
        if [ "$perk_choice" = "0" ]; then
            read -p "Perk name: " perk_name
            read -p "Perk rank (1-5): " perk_rank
        elif [ "$perk_choice" -ge 1 ] && [ "$perk_choice" -lt "$counter" ]; then
            perk_name="${perk_array[$((perk_choice-1))]}"
            max_rank="${perk_ranks[$((perk_choice-1))]}"
            
            # Check if perk already exists
            if echo "$existing_perks" | grep -Fxq "$perk_name" 2>/dev/null; then
                echo -e "${YELLOW}This perk already exists! Use 'Upgrade Perk' to increase its rank.${NC}"
                sleep 2
                character_additions
                return
            fi
            
            echo "Enter rank for $perk_name (1-$max_rank):"
            read -p "Rank: " perk_rank
            
            # Validate rank
            if [ "$perk_rank" -lt 1 ] || [ "$perk_rank" -gt "$max_rank" ]; then
                echo -e "${RED}Invalid rank. Must be between 1 and $max_rank${NC}"
                sleep 2
                add_perk
                return
            fi
        else
            echo -e "${RED}Invalid selection${NC}"
            sleep 1
            add_perk
            return
        fi
    else
        # Fallback to manual entry
        echo -e "${YELLOW}Perks reference file not found. Using manual entry.${NC}"
        read -p "Perk name: " perk_name
        read -p "Perk rank (1-5): " perk_rank
    fi
    
    perk_json="{\"name\": \"$perk_name\", \"rank\": $perk_rank}"
    
    jq "map(if .id == \"$char_id\" then .perks += [$perk_json] else . end)" "$CHARACTERS_FILE" > "$CHARACTERS_FILE.tmp" && mv "$CHARACTERS_FILE.tmp" "$CHARACTERS_FILE"
    
    echo -e "${GREEN}Perk added: $perk_name (Rank $perk_rank)${NC}"
    sleep 2
    character_additions
}

# Upgrade perk
upgrade_perk() {
    show_header
    char_id=$(cat "$CURRENT_CHAR_FILE")
    
    echo -e "${CYAN}Upgrade Perk${NC}"
    echo
    
    perks=$(jq -r ".[] | select(.id == \"$char_id\") | .perks[] | \"\(.name) (Rank \(.rank))\"" "$CHARACTERS_FILE")
    
    if [ -z "$perks" ]; then
        echo -e "${RED}No perks found${NC}"
        sleep 2
        character_additions
        return
    fi
    
    echo "$perks" | nl -s ". "
    echo
    read -p "Select perk to upgrade: " perk_num
    read -p "New rank (1-5): " new_rank
    
    perk_name=$(echo "$perks" | sed -n "${perk_num}p" | sed 's/ (Rank.*//')
    
    jq "map(if .id == \"$char_id\" then .perks = [.perks[] | if .name == \"$perk_name\" then .rank = $new_rank else . end] else . end)" "$CHARACTERS_FILE" > "$CHARACTERS_FILE.tmp" && mv "$CHARACTERS_FILE.tmp" "$CHARACTERS_FILE"
    
    echo -e "${GREEN}Perk upgraded!${NC}"
    sleep 1
    character_additions
}

# Add collectible
add_collectible() {
    show_header
    char_id=$(cat "$CURRENT_CHAR_FILE")
    
    echo -e "${CYAN}Add Collectible${NC}"
    echo
    echo "1. Bobblehead"
    echo "2. Magazines"
    echo "3. Holotape"
    echo "4. Note"
    echo "5. Unique Item/Loot"
    echo "6. Back"
    echo
    read -p "Select type: " type_choice
    
    case $type_choice in
        1) 
            coll_type="bobbleheads"
            reference_file="$BOBBLEHEADS_FILE"
            type_name="Bobblehead"
            ;;
        2) add_magazine_by_category; return ;;
        3) 
            coll_type="holotapes"
            reference_file="$HOLOTAPES_FILE"
            type_name="Holotape"
            ;;
        4) 
            coll_type="notes"
            reference_file="$NOTES_FILE"
            type_name="Note"
            ;;
        5) 
            coll_type="unique_items"
            reference_file="$UNIQUE_ITEMS_FILE"
            type_name="Unique Item"
            ;;
        6) character_additions; return ;;
        *) echo -e "${RED}Invalid option${NC}"; sleep 1; add_collectible; return ;;
    esac
    
    # Check if reference file exists
    if [ -f "$reference_file" ]; then
        echo
        echo -e "${CYAN}Select $type_name:${NC}"
        echo "0. Type custom entry"
        
        # Get already collected items for this type
        collected_items=$(jq -r ".[] | select(.id == \"$char_id\") | .collectibles.$coll_type[]" "$CHARACTERS_FILE" 2>/dev/null)
        
        # Handle magazines with special structure
        if [ "$coll_type" = "magazines" ]; then
            # Extract all magazine names from structured JSON
            available_items=$(jq -r '.[].items[].issues[].name' "$reference_file")
        else
            # Display available items from reference file (simple array)
            available_items=$(jq -r '.[]' "$reference_file")
        fi
        
        item_array=()
        counter=1
        
        while IFS= read -r item; do
            # Check if item is already collected
            if echo "$collected_items" | grep -Fxq "$item" 2>/dev/null; then
                echo -e "$counter. ${GREEN}✓${NC} $item ${GREEN}(Collected)${NC}"
            else
                echo "$counter. $item"
            fi
            item_array+=("$item")
            counter=$((counter + 1))
        done <<< "$available_items"
        
        echo
        read -p "Select option (0-$((counter-1))): " item_choice
        
        if [ "$item_choice" = "0" ]; then
            read -p "Enter custom $type_name name: " item_name
            # Validate that custom entry is not empty
            if [ -z "$item_name" ] || [ "$item_name" = " " ]; then
                echo -e "${RED}Error: Custom entry cannot be empty${NC}"
                sleep 2
                add_collectible
                return
            fi
        elif [ "$item_choice" -ge 1 ] && [ "$item_choice" -lt "$counter" ]; then
            item_name="${item_array[$((item_choice-1))]}"
            
            # Check if already collected
            if echo "$collected_items" | grep -Fxq "$item_name" 2>/dev/null; then
                echo -e "${YELLOW}This item is already collected!${NC}"
                sleep 2
                add_collectible
                return
            fi
        else
            echo -e "${RED}Invalid selection${NC}"
            sleep 1
            add_collectible
            return
        fi
    else
        # Fallback to manual entry if reference file doesn't exist
        echo -e "${YELLOW}Reference file not found. Using manual entry.${NC}"
        read -p "Enter $type_name name: " item_name
        # Validate that manual entry is not empty
        if [ -z "$item_name" ] || [ "$item_name" = " " ]; then
            echo -e "${RED}Error: Entry cannot be empty${NC}"
            sleep 2
            add_collectible
            return
        fi
    fi
    
    # Add the item to character's collection
    jq "map(if .id == \"$char_id\" then .collectibles.$coll_type += [\"$item_name\"] else . end)" "$CHARACTERS_FILE" > "$CHARACTERS_FILE.tmp" && mv "$CHARACTERS_FILE.tmp" "$CHARACTERS_FILE"
    
    echo -e "${GREEN}$type_name added: $item_name${NC}"
    sleep 2
    add_collectible
}

# View all collectibles
view_all_collectibles() {
    show_header
    char_id=$(cat "$CURRENT_CHAR_FILE")
    
    echo -e "${CYAN}All Collectibles${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
    echo
    
    collectibles=$(jq -r ".[] | select(.id == \"$char_id\") | .collectibles" "$CHARACTERS_FILE")
    
    # Bobbleheads
    bobbleheads=$(echo "$collectibles" | jq -r '.bobbleheads[]' 2>/dev/null)
    bobblehead_count=$(echo "$collectibles" | jq '.bobbleheads | length')
    echo -e "${GREEN}📊 Bobbleheads: ($bobblehead_count/20)${NC}"
    if [ "$bobblehead_count" -eq 0 ]; then
        echo "   None collected"
    else
        echo "$bobbleheads" | while read -r item; do
            echo "   • $item"
        done
    fi
    echo
    
    # Magazines
    magazines=$(echo "$collectibles" | jq -r '.magazines[]' 2>/dev/null)
    magazine_count=$(echo "$collectibles" | jq '.magazines | length')
    echo -e "${MAGENTA}📖 Magazines: ($magazine_count/133)${NC}"
    if [ "$magazine_count" -eq 0 ]; then
        echo "   None collected"
    else
        echo "$magazines" | while read -r item; do
            echo "   • $item"
        done
    fi
    echo
    
    # Holotapes
    holotapes=$(echo "$collectibles" | jq -r '.holotapes[]' 2>/dev/null)
    holotape_count=$(echo "$collectibles" | jq '.holotapes | length')
    echo -e "${BLUE}💾 Holotapes: ($holotape_count)${NC}"
    if [ "$holotape_count" -eq 0 ]; then
        echo "   None collected"
    else
        echo "$holotapes" | while read -r item; do
            echo "   • $item"
        done
    fi
    echo
    
    # Notes
    notes=$(echo "$collectibles" | jq -r '.notes[]' 2>/dev/null)
    note_count=$(echo "$collectibles" | jq '.notes | length')
    echo -e "${YELLOW}📝 Notes: ($note_count)${NC}"
    if [ "$note_count" -eq 0 ]; then
        echo "   None collected"
    else
        echo "$notes" | while read -r item; do
            echo "   • $item"
        done
    fi
    echo
    
    # Unique Items
    unique_items=$(echo "$collectibles" | jq -r '.unique_items[]' 2>/dev/null)
    unique_count=$(echo "$collectibles" | jq '.unique_items | length')
    echo -e "${RED}⭐ Unique Items/Loot: ($unique_count)${NC}"
    if [ "$unique_count" -eq 0 ]; then
        echo "   None collected"
    else
        echo "$unique_items" | while read -r item; do
            echo "   • $item"
        done
    fi
    
    # Show totals
    echo
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
    total_count=$((bobblehead_count + magazine_count + holotape_count + note_count + unique_count))
    
    echo -e "${CYAN}Collection Statistics:${NC}"
    echo "  Bobbleheads:   $bobblehead_count/20"
    echo "  Magazines:     $magazine_count/133"
    echo "  Holotapes:     $holotape_count"
    echo "  Notes:         $note_count"
    echo "  Unique Items:  $unique_count"
    echo "  -------------"
    echo "  Total Items:   $total_count"
    
    echo
    read -p "Press Enter to continue..."
    character_additions
}

# View character special stats
view_special() {
    show_header
    char_id=$(cat "$CURRENT_CHAR_FILE")
    
    echo -e "${CYAN}S.P.E.C.I.A.L Stats${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
    echo
    
    special=$(jq -r ".[] | select(.id == \"$char_id\") | .special" "$CHARACTERS_FILE")
    
    # Display with visual bars
    display_special_stat "Strength" $(echo "$special" | jq -r '.strength')
    display_special_stat "Perception" $(echo "$special" | jq -r '.perception')
    display_special_stat "Endurance" $(echo "$special" | jq -r '.endurance')
    display_special_stat "Charisma" $(echo "$special" | jq -r '.charisma')
    display_special_stat "Intelligence" $(echo "$special" | jq -r '.intelligence')
    display_special_stat "Agility" $(echo "$special" | jq -r '.agility')
    display_special_stat "Luck" $(echo "$special" | jq -r '.luck')
    
    echo
    echo -e "${YELLOW}───────────────────────────────────────────────────────────────${NC}"
    
    # Calculate total
    total=$((
        $(echo "$special" | jq -r '.strength') +
        $(echo "$special" | jq -r '.perception') +
        $(echo "$special" | jq -r '.endurance') +
        $(echo "$special" | jq -r '.charisma') +
        $(echo "$special" | jq -r '.intelligence') +
        $(echo "$special" | jq -r '.agility') +
        $(echo "$special" | jq -r '.luck')
    ))
    
    echo -e "${GREEN}Total S.P.E.C.I.A.L Points: $total/70${NC}"
    
    echo
    read -p "Press Enter to continue..."
    perks_special_menu
}

# Display SPECIAL stat with visual bar
display_special_stat() {
    local stat_name=$1
    local value=$2
    
    printf "${GREEN}%-13s${NC} [" "$stat_name:"
    
    for ((i=1; i<=10; i++)); do
        if [ $i -le $value ]; then
            printf "█"
        else
            printf "░"
        fi
    done
    
    printf "] %2d/10\n" "$value"
}

# Upgrade SPECIAL stats
upgrade_special() {
    show_header
    char_id=$(cat "$CURRENT_CHAR_FILE")
    
    echo -e "${CYAN}Upgrade S.P.E.C.I.A.L Stats${NC}"
    echo
    
    special=$(jq -r ".[] | select(.id == \"$char_id\") | .special" "$CHARACTERS_FILE")
    
    echo "Current S.P.E.C.I.A.L:"
    echo "1. Strength:     $(echo "$special" | jq -r '.strength')"
    echo "2. Perception:   $(echo "$special" | jq -r '.perception')"
    echo "3. Endurance:    $(echo "$special" | jq -r '.endurance')"
    echo "4. Charisma:     $(echo "$special" | jq -r '.charisma')"
    echo "5. Intelligence: $(echo "$special" | jq -r '.intelligence')"
    echo "6. Agility:      $(echo "$special" | jq -r '.agility')"
    echo "7. Luck:         $(echo "$special" | jq -r '.luck')"
    echo "8. Back"
    echo
    read -p "Select stat to upgrade (1-8): " stat_choice
    
    case $stat_choice in
        1) stat_name="strength" ;;
        2) stat_name="perception" ;;
        3) stat_name="endurance" ;;
        4) stat_name="charisma" ;;
        5) stat_name="intelligence" ;;
        6) stat_name="agility" ;;
        7) stat_name="luck" ;;
        8) character_additions; return ;;
        *) echo -e "${RED}Invalid option${NC}"; sleep 1; upgrade_special; return ;;
    esac
    
    current_value=$(echo "$special" | jq -r ".$stat_name")
    echo
    echo "Current $stat_name: $current_value"
    read -p "Enter new value (1-10): " new_value
    
    if [ "$new_value" -lt 1 ] || [ "$new_value" -gt 10 ]; then
        echo -e "${RED}Invalid value. Must be between 1 and 10${NC}"
        sleep 2
        upgrade_special
        return
    fi
    
    jq "map(if .id == \"$char_id\" then .special.$stat_name = $new_value else . end)" "$CHARACTERS_FILE" > "$CHARACTERS_FILE.tmp" && mv "$CHARACTERS_FILE.tmp" "$CHARACTERS_FILE"
    
    echo -e "${GREEN}$stat_name updated to $new_value${NC}"
    sleep 1
    upgrade_special
}

# View all perks
view_all_perks() {
    show_header
    char_id=$(cat "$CURRENT_CHAR_FILE")
    
    echo -e "${CYAN}All Perks${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
    echo
    
    perks=$(jq -r ".[] | select(.id == \"$char_id\") | .perks" "$CHARACTERS_FILE")
    perk_count=$(echo "$perks" | jq '. | length')
    
    if [ "$perk_count" -eq 0 ]; then
        echo -e "${YELLOW}No perks acquired yet${NC}"
        echo
        echo "Tip: Add perks to track your character's progression!"
    else
        # Simple formatted list
        echo -e "${GREEN}Acquired Perks ($perk_count total):${NC}"
        echo
        
        echo "$perks" | jq -r '.[] | "  • \(.name) - Rank \(.rank)"' | sort
        
        echo
        echo -e "${YELLOW}───────────────────────────────────────────────────────────────${NC}"
        
        # Show perk point calculation
        level=$(jq -r ".[] | select(.id == \"$char_id\") | .level" "$CHARACTERS_FILE")
        available_points=$((level - perk_count))
        
        if [ "$available_points" -gt 0 ]; then
            echo -e "${GREEN}Available Perk Points: $available_points${NC}"
        else
            echo -e "${YELLOW}All perk points used${NC}"
        fi
    fi
    
    echo
    read -p "Press Enter to continue..."
    perks_special_menu
}

# Edit character details
edit_character_details() {
    show_header
    char_id=$(cat "$CURRENT_CHAR_FILE")
    
    echo -e "${CYAN}Edit Character${NC}"
    echo
    echo "1. Change Name"
    echo "2. Change Gender"
    echo "3. Change Faction"
    echo "4. Change Game Type"
    echo "5. Back"
    echo
    read -p "Select option: " choice
    
    case $choice in
        1)
            read -p "Enter new name: " new_name
            jq "map(if .id == \"$char_id\" then .name = \"$new_name\" else . end)" "$CHARACTERS_FILE" > "$CHARACTERS_FILE.tmp" && mv "$CHARACTERS_FILE.tmp" "$CHARACTERS_FILE"
            echo -e "${GREEN}Name updated to $new_name${NC}"
            sleep 1
            edit_character_details
            ;;
        2)
            echo "Select new gender:"
            echo "1. Male"
            echo "2. Female"
            read -p "Select (1-2): " gender_choice
            case $gender_choice in
                1) new_gender="Male" ;;
                2) new_gender="Female" ;;
                *) new_gender="Not specified" ;;
            esac
            jq "map(if .id == \"$char_id\" then .gender = \"$new_gender\" else . end)" "$CHARACTERS_FILE" > "$CHARACTERS_FILE.tmp" && mv "$CHARACTERS_FILE.tmp" "$CHARACTERS_FILE"
            echo -e "${GREEN}Gender updated to $new_gender${NC}"
            sleep 1
            edit_character_details
            ;;
        3)
            echo "Select new faction:"
            echo "1. Minutemen"
            echo "2. Brotherhood of Steel"
            echo "3. Railroad"
            echo "4. Institute"
            echo "5. None/Undecided"
            read -p "Select (1-5): " faction_choice
            case $faction_choice in
                1) new_faction="Minutemen" ;;
                2) new_faction="Brotherhood of Steel" ;;
                3) new_faction="Railroad" ;;
                4) new_faction="Institute" ;;
                *) new_faction="None" ;;
            esac
            jq "map(if .id == \"$char_id\" then .faction = \"$new_faction\" else . end)" "$CHARACTERS_FILE" > "$CHARACTERS_FILE.tmp" && mv "$CHARACTERS_FILE.tmp" "$CHARACTERS_FILE"
            echo -e "${GREEN}Faction updated to $new_faction${NC}"
            sleep 1
            edit_character_details
            ;;
        4)
            echo "Select new game type:"
            echo "1. Main Game Only"
            echo "2. Main Game + DLC"
            echo "3. Main Game + DLC + Modded"
            read -p "Select (1-3): " game_type_choice
            case $game_type_choice in
                1) new_game_type="Main" ;;
                2) new_game_type="Main+DLC" ;;
                3) new_game_type="Main+DLC+Modded" ;;
                *) new_game_type="Main" ;;
            esac
            jq "map(if .id == \"$char_id\" then .game_type = \"$new_game_type\" else . end)" "$CHARACTERS_FILE" > "$CHARACTERS_FILE.tmp" && mv "$CHARACTERS_FILE.tmp" "$CHARACTERS_FILE"
            if [[ "$new_game_type" == *"Modded"* ]]; then
                check_mod_compatibility "$char_id" "warn"
                sleep 2
            fi
            echo -e "${GREEN}Game type updated to $new_game_type${NC}"
            sleep 1
            edit_character_details
            ;;
        5)
            character_menu
            ;;
        *)
            echo -e "${RED}Invalid option${NC}"
            sleep 1
            edit_character_details
            ;;
    esac
}

# DLC and Modded content menu
dlc_modded_menu() {
    show_header
    char_id=$(cat "$CURRENT_CHAR_FILE")
    
    game_type=$(jq -r ".[] | select(.id == \"$char_id\") | .game_type // \"Main\"" "$CHARACTERS_FILE")
    
    echo -e "${CYAN}📜 Quests & Progress${NC}"
    echo -e "${GREEN}Current Game Type: $game_type${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
    echo
    
    if [[ "$game_type" == *"Modded"* ]]; then
        check_mod_compatibility "$char_id" "warn"
        echo
    fi
    
    # Quest Progress Overview
    char_data=$(jq ".[] | select(.id == \"$char_id\")" "$CHARACTERS_FILE")
    main_quests=$(echo "$char_data" | jq '.quests.main | length // 0')
    dlc_quests=$(echo "$char_data" | jq '.quests.dlc | length // 0')
    modded_quests=$(echo "$char_data" | jq '.quests.modded | length // 0')
    
    echo -e "${CYAN}📊 Quest Overview:${NC}"
    echo -e "  Main Quests: $main_quests active"
    echo -e "  DLC Quests: $dlc_quests active" 
    if [[ "$game_type" == *"Modded"* ]]; then
        echo -e "  Modded Quests: $modded_quests active"
    fi
    echo
    
    echo -e "${GREEN}Quest Management:${NC}"
    echo -e "${GRAY}1. Main Quest Progress (Temporarily Disabled)${NC}"
    echo -e "${GRAY}2. DLC Quest Progress (Temporarily Disabled)${NC}"
    
    if [[ "$game_type" == *"Modded"* ]]; then
        echo "3. 🔧 Modded Quest Management"
        echo "4. 📦 View Existing Modded Quests"
        echo "5. ✨ Create New Modded Quest"
        echo "6. 🎯 Quick Quest Actions"
        echo "7. 📋 Quest Progress Report"
    else
        echo -e "${GRAY}3. Modded Quest Management (Not Available)${NC}"
        echo -e "${GRAY}4. View Existing Modded Quests (Not Available)${NC}"
        echo -e "${GRAY}5. Create New Modded Quest (Not Available)${NC}"
        echo -e "${GRAY}6. Quick Quest Actions (Not Available)${NC}"
        echo -e "${GRAY}7. Quest Progress Report (Limited)${NC}"
    fi
    
    echo "8. ⚙️ Change Game Type"
    echo "9. ← Back"
    echo
    read -p "Select option: " choice
    
    case $choice in
        1)
            echo -e "${RED}Main quest tracking is temporarily disabled${NC}"
            sleep 2
            dlc_modded_menu
            ;;
        2)
            echo -e "${RED}DLC quest tracking is temporarily disabled${NC}"
            sleep 2
            dlc_modded_menu
            ;;
        3)
            if [[ "$game_type" == *"Modded"* ]]; then
                if check_mod_compatibility "$char_id" "block"; then
                    quest_manager "modded"
                else
                    sleep 2
                    dlc_modded_menu
                fi
            else
                echo -e "${RED}Modded content not enabled for this character${NC}"
                sleep 2
                dlc_modded_menu
            fi
            ;;
        4)
            if [[ "$game_type" == *"Modded"* ]]; then
                existing_modded_quest_menu
            else
                echo -e "${RED}Modded content not enabled for this character${NC}"
                sleep 2
                dlc_modded_menu
            fi
            ;;
        5)
            if [[ "$game_type" == *"Modded"* ]]; then
                new_modded_quest_menu
            else
                echo -e "${RED}Modded content not enabled for this character${NC}"
                sleep 2
                dlc_modded_menu
            fi
            ;;
        6)
            if [[ "$game_type" == *"Modded"* ]]; then
                quick_quest_actions
            else
                echo -e "${RED}Modded content not enabled for this character${NC}"
                sleep 2
                dlc_modded_menu
            fi
            ;;
        7)
            quest_progress_report
            ;;
        8)
            echo "Select new game type:"
            echo "1. Main Game Only"
            echo "2. Main Game + DLC"
            echo "3. Main Game + DLC + Modded"
            read -p "Select (1-3): " game_type_choice
            case $game_type_choice in
                1) new_game_type="Main" ;;
                2) new_game_type="Main+DLC" ;;
                3) new_game_type="Main+DLC+Modded" ;;
                *) new_game_type="Main" ;;
            esac
            jq "map(if .id == \"$char_id\" then .game_type = \"$new_game_type\" else . end)" "$CHARACTERS_FILE" > "$CHARACTERS_FILE.tmp" && mv "$CHARACTERS_FILE.tmp" "$CHARACTERS_FILE"
            if [[ "$new_game_type" == *"Modded"* ]]; then
                check_mod_compatibility "$char_id" "warn"
                sleep 2
            fi
            echo -e "${GREEN}Game type updated to $new_game_type${NC}"
            sleep 2
            dlc_modded_menu
            ;;
        9)
            character_menu
            ;;
        *)
            echo -e "${RED}Invalid option${NC}"
            sleep 1
            dlc_modded_menu
            ;;
    esac
}

# Quest manager
quest_manager() {
    local quest_type=$1
    show_header
    char_id=$(cat "$CURRENT_CHAR_FILE")
    
    case $quest_type in
        main) quest_title="Main Quests" ;;
        dlc) quest_title="DLC Quests" ;;
        modded) quest_title="Modded Quests" ;;
    esac
    
    echo -e "${CYAN}$quest_title${NC}"
    echo
    
    if [ "$quest_type" = "modded" ]; then
        # For modded quests, display with mod information
        quests=$(jq -r ".[] | select(.id == \"$char_id\") | .quests.$quest_type[]? | if type == \"object\" then \"\(.name) (\(.mod_name) by \(.creator))\" else . end" "$CHARACTERS_FILE" 2>/dev/null)
    else
        quests=$(jq -r ".[] | select(.id == \"$char_id\") | .quests.$quest_type[]" "$CHARACTERS_FILE" 2>/dev/null)
    fi
    
    if [ -z "$quests" ]; then
        echo "No quests tracked yet"
    else
        echo "$quests" | nl -s ". "
    fi
    
    echo
    echo "1. Add Quest"
    echo "2. Mark Quest Complete"
    echo "3. Remove Quest"
    echo "4. Back"
    echo
    read -p "Select option: " choice
    
    case $choice in
        1)
            if [ "$quest_type" = "modded" ]; then
                read -p "Enter quest name: " quest_name
                read -p "Enter mod name: " mod_name
                read -p "Enter mod creator: " creator
                read -p "Enter mod source (optional): " source
                
                if [ -z "$source" ]; then
                    quest_obj="{\"name\": \"$quest_name\", \"mod_name\": \"$mod_name\", \"creator\": \"$creator\"}"
                else
                    quest_obj="{\"name\": \"$quest_name\", \"mod_name\": \"$mod_name\", \"creator\": \"$creator\", \"source\": \"$source\"}"
                fi
                
                jq "map(if .id == \"$char_id\" then .quests.$quest_type += [$quest_obj] else . end)" "$CHARACTERS_FILE" > "$CHARACTERS_FILE.tmp" && mv "$CHARACTERS_FILE.tmp" "$CHARACTERS_FILE"
                echo -e "${GREEN}Modded quest added: $quest_name from $mod_name${NC}"
            else
                read -p "Enter quest name: " quest_name
                jq "map(if .id == \"$char_id\" then .quests.$quest_type += [\"$quest_name\"] else . end)" "$CHARACTERS_FILE" > "$CHARACTERS_FILE.tmp" && mv "$CHARACTERS_FILE.tmp" "$CHARACTERS_FILE"
                echo -e "${GREEN}Quest added: $quest_name${NC}"
            fi
            sleep 1
            quest_manager "$quest_type"
            ;;
        2)
            if [ -z "$quests" ]; then
                echo -e "${RED}No quests to mark complete${NC}"
                sleep 1
                quest_manager "$quest_type"
            else
                read -p "Enter quest number to mark complete: " quest_num
                quest_display=$(echo "$quests" | sed -n "${quest_num}p")
                
                if [ "$quest_type" = "modded" ]; then
                    # For modded quests, we need to find by index since we have objects
                    quest_index=$((quest_num - 1))
                    jq "map(if .id == \"$char_id\" then .quests.$quest_type |= del(.[$quest_index]) else . end)" "$CHARACTERS_FILE" > "$CHARACTERS_FILE.tmp" && mv "$CHARACTERS_FILE.tmp" "$CHARACTERS_FILE"
                else
                    jq "map(if .id == \"$char_id\" then .quests.$quest_type = [.quests.${quest_type}[] | select(. != \"$quest_display\")] else . end)" "$CHARACTERS_FILE" > "$CHARACTERS_FILE.tmp" && mv "$CHARACTERS_FILE.tmp" "$CHARACTERS_FILE"
                fi
                echo -e "${GREEN}Quest completed: $quest_display${NC}"
                sleep 1
                quest_manager "$quest_type"
            fi
            ;;
        3)
            if [ -z "$quests" ]; then
                echo -e "${RED}No quests to remove${NC}"
                sleep 1
                quest_manager "$quest_type"
            else
                read -p "Enter quest number to remove: " quest_num
                quest_display=$(echo "$quests" | sed -n "${quest_num}p")
                
                if [ "$quest_type" = "modded" ]; then
                    # For modded quests, we need to find by index since we have objects
                    quest_index=$((quest_num - 1))
                    jq "map(if .id == \"$char_id\" then .quests.$quest_type |= del(.[$quest_index]) else . end)" "$CHARACTERS_FILE" > "$CHARACTERS_FILE.tmp" && mv "$CHARACTERS_FILE.tmp" "$CHARACTERS_FILE"
                else
                    jq "map(if .id == \"$char_id\" then .quests.$quest_type = [.quests.${quest_type}[] | select(. != \"$quest_display\")] else . end)" "$CHARACTERS_FILE" > "$CHARACTERS_FILE.tmp" && mv "$CHARACTERS_FILE.tmp" "$CHARACTERS_FILE"
                fi
                echo -e "${GREEN}Quest removed: $quest_display${NC}"
                sleep 1
                quest_manager "$quest_type"
            fi
            ;;
        4)
            dlc_modded_menu
            ;;
        *)
            echo -e "${RED}Invalid option${NC}"
            sleep 1
            quest_manager "$quest_type"
            ;;
    esac
}

# Edit character (stub for now)
edit_character() {
    show_header
    echo -e "${CYAN}Edit Character${NC}"
    echo "Select a character to edit..."
    sleep 1
    select_character
}

# Remove character
remove_character() {
    show_header
    echo -e "${CYAN}🗑️ Remove Character${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
    echo
    
    # List all characters
    if [ -f "$CHARACTERS_FILE" ]; then
        characters=$(jq -r '.[] | "\(.id)|\(.name)|\(.level)|\(.faction // "None")"' "$CHARACTERS_FILE")
        
        if [ -z "$characters" ]; then
            echo -e "${RED}No characters found${NC}"
            sleep 2
            main_menu
            return
        fi
        
        echo "Select character to remove:"
        echo
        
        counter=1
        while IFS='|' read -r id name level faction; do
            printf "${CYAN}%2d.${NC} %-18s (Level %-3s | %s)\n" "$counter" "$name" "$level" "$faction"
            counter=$((counter + 1))
        done <<< "$characters"
        
        echo
        read -p "Select character number (0 to cancel): " char_num
        
        if [ "$char_num" = "0" ]; then
            main_menu
            return
        fi
        
        char_info=$(echo "$characters" | sed -n "${char_num}p")
        char_id=$(echo "$char_info" | cut -d'|' -f1)
        char_name=$(echo "$char_info" | cut -d'|' -f2)
        
        echo
        echo -e "${RED}⚠️  WARNING: This action cannot be undone!${NC}"
        echo -e "Are you sure you want to remove ${YELLOW}$char_name${NC}?"
        read -p "Type 'DELETE' to confirm: " confirm
        
        if [ "$confirm" = "DELETE" ]; then
            jq "map(select(.id != \"$char_id\"))" "$CHARACTERS_FILE" > "$CHARACTERS_FILE.tmp" && mv "$CHARACTERS_FILE.tmp" "$CHARACTERS_FILE"
            
            # Clear current character if it was the deleted one
            if [ -f "$CURRENT_CHAR_FILE" ]; then
                current_id=$(cat "$CURRENT_CHAR_FILE")
                if [ "$current_id" = "$char_id" ]; then
                    rm "$CURRENT_CHAR_FILE"
                fi
            fi
            
            echo -e "${GREEN}Character '$char_name' removed successfully${NC}"
        else
            echo -e "${YELLOW}Removal cancelled${NC}"
        fi
        
        sleep 2
        main_menu
    fi
}

# Check for jq dependency and offer auto-installation
check_dependencies() {
    # Check for jq
    if ! command -v jq >/dev/null 2>&1; then
        echo -e "${RED}Error: jq is required but not installed.${NC}"
        echo -e "${YELLOW}Would you like to install jq automatically? [y/N]${NC}"
        read -p "> " install_choice
        
        case "$install_choice" in
            [Yy]|[Yy][Ee][Ss])
            echo -e "${CYAN}Detecting platform and attempting installation...${NC}"
            
            # Detect OS and package manager
            install_jq
            ;;
            *)
                echo -e "${YELLOW}Installation cancelled.${NC}"
                show_manual_install_instructions
                exit 1
                ;;
        esac
    fi
    
    # Check for bash version (need at least 3.0 for arrays)
    if [ "${BASH_VERSION%%.*}" -lt 3 ]; then
        echo -e "${RED}Error: This script requires Bash 3.0 or later.${NC}"
        echo -e "${YELLOW}Current version: $BASH_VERSION${NC}"
        exit 1
    fi
}

# Install jq based on detected platform
install_jq() {
    echo -e "${CYAN}Detecting platform and attempting installation...${NC}"
    
    # Detect OS type more reliably
    local os_type=""
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        os_type="$ID"
    elif [ "$(uname)" = "Darwin" ]; then
        os_type="macos"
    elif [ "$(uname -o 2>/dev/null)" = "Msys" ] || [ "$(uname -o 2>/dev/null)" = "Cygwin" ]; then
        os_type="windows"
    else
        os_type="$(uname | tr '[:upper:]' '[:lower:]')"
    fi
    
    case "$os_type" in
        ubuntu|debian|raspbian)
            if command -v apt >/dev/null 2>&1; then
                echo "Installing jq using apt..."
                sudo apt update && sudo apt install -y jq
            else
                echo -e "${RED}apt not found on Debian-based system.${NC}"
                show_manual_install_instructions
                exit 1
            fi
            ;;
        fedora|centos|rhel)
            if command -v dnf >/dev/null 2>&1; then
                echo "Installing jq using dnf..."
                sudo dnf install -y jq
            elif command -v yum >/dev/null 2>&1; then
                echo "Installing jq using yum..."
                sudo yum install -y jq
            else
                echo -e "${RED}Neither dnf nor yum found on Red Hat-based system.${NC}"
                show_manual_install_instructions
                exit 1
            fi
            ;;
        arch|manjaro)
            if command -v pacman >/dev/null 2>&1; then
                echo "Installing jq using pacman..."
                sudo pacman -S --noconfirm jq
            else
                echo -e "${RED}pacman not found on Arch-based system.${NC}"
                show_manual_install_instructions
                exit 1
            fi
            ;;
        opensuse*|sles)
            if command -v zypper >/dev/null 2>&1; then
                echo "Installing jq using zypper..."
                sudo zypper install -y jq
            else
                echo -e "${RED}zypper not found on SUSE-based system.${NC}"
                show_manual_install_instructions
                exit 1
            fi
            ;;
        alpine)
            if command -v apk >/dev/null 2>&1; then
                echo "Installing jq using apk..."
                sudo apk add jq
            else
                echo -e "${RED}apk not found on Alpine system.${NC}"
                show_manual_install_instructions
                exit 1
            fi
            ;;
        macos)
            if command -v brew >/dev/null 2>&1; then
                echo "Installing jq using Homebrew..."
                brew install jq
            elif command -v port >/dev/null 2>&1; then
                echo "Installing jq using MacPorts..."
                sudo port install jq
            else
                echo -e "${YELLOW}Installing Homebrew first...${NC}"
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                if command -v brew >/dev/null 2>&1; then
                    brew install jq
                else
                    echo -e "${RED}Failed to install Homebrew.${NC}"
                    show_manual_install_instructions
                    exit 1
                fi
            fi
            ;;
        windows)
            echo "Windows environment detected. Installing jq using package manager..."
            if command -v choco >/dev/null 2>&1; then
                choco install jq
            elif command -v winget >/dev/null 2>&1; then
                winget install jqlang.jq
            else
                echo -e "${RED}Please install Chocolatey or use Windows Package Manager to install jq.${NC}"
                show_manual_install_instructions
                exit 1
            fi
            ;;
        *)
            echo -e "${RED}Unsupported operating system: $os_type${NC}"
            show_manual_install_instructions
            exit 1
            ;;
    esac
            
    # Verify installation
    if command -v jq >/dev/null 2>&1; then
        echo -e "${GREEN}jq successfully installed!${NC}"
    else
        echo -e "${RED}Installation failed. Please install jq manually.${NC}"
        show_manual_install_instructions
        exit 1
    fi
}

# Show manual installation instructions
show_manual_install_instructions() {
    echo -e "${CYAN}Manual installation instructions:${NC}"
    echo "  Ubuntu/Debian: sudo apt install jq"
    echo "  Fedora/RHEL:   sudo dnf install jq"
    echo "  CentOS:        sudo yum install jq"
    echo "  Arch Linux:    sudo pacman -S jq"
    echo "  openSUSE:      sudo zypper install jq"
    echo "  macOS:         brew install jq"
    echo "  Windows:       choco install jq  OR  winget install jqlang.jq"
    echo ""
    echo "Or download from: https://github.com/stedolan/jq/releases"
}

# Main execution
check_dependencies
init_data
echo -e "${GREEN}Thank you for using Fallout 4 - Tracker${NC}"
main_menu