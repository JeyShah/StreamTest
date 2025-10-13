#!/bin/bash

# Flutter WhiteLabel Configuration Switcher Script
# This script helps you quickly switch between different whitelabel configurations

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/lib/config.dart"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_color() {
    echo -e "${1}${2}${NC}"
}

# Function to show current configuration
show_current_config() {
    print_color $BLUE "Current Configuration:"
    echo "======================"
    
    # Extract current app type
    current_app_line=$(grep "static const int currentAppType" "$CONFIG_FILE")
    if [[ $current_app_line == *"GPSINA"* ]]; then
        current_app_type="0"
    elif [[ $current_app_line == *"XTRACK"* ]]; then
        current_app_type="1"
    elif [[ $current_app_line == *"STARTRACK"* ]]; then
        current_app_type="2"
    elif [[ $current_app_line == *"SOUNDSTREAM"* ]]; then
        current_app_type="3"
    else
        current_app_type="0"
    fi
    
    current_env=$(grep "static const Environment currentEnvironment" "$CONFIG_FILE" | sed 's/.*Environment\.//' | sed 's/;.*//')
    
    case $current_app_type in
        0) app_name="GPSINA" ;;
        1) app_name="XTRACK" ;;
        2) app_name="STARTRACK" ;;
        3) app_name="SOUNDSTREAM" ;;
        *) app_name="UNKNOWN" ;;
    esac
    
    print_color $GREEN "WhiteLabel: $app_name (Type: $current_app_type)"
    print_color $GREEN "Environment: $current_env"
    echo
}

# Function to switch whitelabel
switch_whitelabel() {
    local app_constant=$1
    local app_name=$2
    
    print_color $YELLOW "Switching to $app_name..."
    
    # Use sed to replace the currentAppType line
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS sed
        sed -i '' "s/static const int currentAppType = [A-Z]*;/static const int currentAppType = $app_constant;/" "$CONFIG_FILE"
    else
        # Linux sed
        sed -i "s/static const int currentAppType = [A-Z]*;/static const int currentAppType = $app_constant;/" "$CONFIG_FILE"
    fi
    
    print_color $GREEN "✓ Switched to $app_name successfully!"
    show_current_config
}

# Function to switch environment
switch_environment() {
    local target_env=$1
    
    print_color $YELLOW "Switching to $target_env environment..."
    
    # Use sed to replace the currentEnvironment line
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS sed
        sed -i '' "s/static const Environment currentEnvironment = Environment\.[a-z]*;/static const Environment currentEnvironment = Environment.$target_env;/" "$CONFIG_FILE"
    else
        # Linux sed
        sed -i "s/static const Environment currentEnvironment = Environment\.[a-z]*;/static const Environment currentEnvironment = Environment.$target_env;/" "$CONFIG_FILE"
    fi
    
    print_color $GREEN "✓ Switched to $target_env environment successfully!"
    show_current_config
}

# Function to show help
show_help() {
    echo "Flutter WhiteLabel Configuration Switcher"
    echo "========================================"
    echo
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo
    echo "Commands:"
    echo "  show                    Show current configuration"
    echo "  whitelabel <name>       Switch whitelabel (gpsina|xtrack|startrack|soundstream)"
    echo "  environment <env>       Switch environment (production|staging|development|local)"
    echo "  help                    Show this help message"
    echo
    echo "Examples:"
    echo "  $0 show"
    echo "  $0 whitelabel gpsina"
    echo "  $0 whitelabel xtrack"
    echo "  $0 environment staging"
    echo "  $0 environment production"
    echo
}

# Main script logic
case "${1:-}" in
    "show")
        show_current_config
        ;;
    "whitelabel")
        case "${2:-}" in
            "gpsina")
                switch_whitelabel "GPSINA" "GPSINA"
                ;;
            "xtrack")
                switch_whitelabel "XTRACK" "XTRACK"
                ;;
            "startrack")
                switch_whitelabel "STARTRACK" "STARTRACK"
                ;;
            "soundstream")
                switch_whitelabel "SOUNDSTREAM" "SOUNDSTREAM"
                ;;
            *)
                print_color $RED "Error: Invalid whitelabel. Use: gpsina|xtrack|startrack|soundstream"
                exit 1
                ;;
        esac
        ;;
    "environment")
        case "${2:-}" in
            "production"|"staging"|"development"|"local")
                switch_environment "${2}"
                ;;
            *)
                print_color $RED "Error: Invalid environment. Use: production|staging|development|local"
                exit 1
                ;;
        esac
        ;;
    "help"|"--help"|"-h")
        show_help
        ;;
    *)
        print_color $RED "Error: Unknown command '${1:-}'"
        echo
        show_help
        exit 1
        ;;
esac