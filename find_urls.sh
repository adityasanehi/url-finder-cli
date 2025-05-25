#!/bin/bash

# URL Finder Script - Modern CLI Version
# Searches for URLs in all files within a specified directory or GitHub repository

# Modern color palette
declare -r BLACK='\033[0;30m'
declare -r RED='\033[0;31m'
declare -r GREEN='\033[0;32m'
declare -r YELLOW='\033[0;33m'
declare -r BLUE='\033[0;34m'
declare -r MAGENTA='\033[0;35m'
declare -r CYAN='\033[0;36m'
declare -r WHITE='\033[0;37m'
declare -r BRIGHT_BLACK='\033[1;30m'
declare -r BRIGHT_RED='\033[1;31m'
declare -r BRIGHT_GREEN='\033[1;32m'
declare -r BRIGHT_YELLOW='\033[1;33m'
declare -r BRIGHT_BLUE='\033[1;34m'
declare -r BRIGHT_MAGENTA='\033[1;35m'
declare -r BRIGHT_CYAN='\033[1;36m'
declare -r BRIGHT_WHITE='\033[1;37m'
declare -r BG_BLUE='\033[44m'
declare -r BG_GREEN='\033[42m'
declare -r BG_RED='\033[41m'
declare -r BG_YELLOW='\033[43m'
declare -r BOLD='\033[1m'
declare -r DIM='\033[2m'
declare -r ITALIC='\033[3m'
declare -r UNDERLINE='\033[4m'
declare -r REVERSE='\033[7m'
declare -r NC='\033[0m' # No Color

# Unicode icons and symbols
declare -r ICON_SUCCESS="✅"
declare -r ICON_ERROR="❌"
declare -r ICON_WARNING="⚠️"
declare -r ICON_INFO="ℹ️"
declare -r ICON_SEARCH="🔍"
declare -r ICON_FOLDER="📁"
declare -r ICON_FILE="📄"
declare -r ICON_LINK="🔗"
declare -r ICON_GITHUB="🐙"
declare -r ICON_DOWNLOAD="⬇️"
declare -r ICON_CLEANUP="🧹"
declare -r ICON_ROCKET="🚀"
declare -r ICON_SPARKLES="✨"
declare -r ICON_TARGET="🎯"
declare -r ICON_GEAR="⚙️"

# Global variables for results (compatible with older bash)
FOUND_FILES=()
FOUND_URLS=()
TOTAL_FILES=0
TOTAL_URLS=0
SCAN_DIR=""
CLEANUP_NEEDED=false

# Function to set terminal title
set_terminal_title() {
    local title="$1"
    printf '\033]0;%s\007' "$title"
}

# Function to wait for user to press down arrow
wait_for_next() {
    local message="$1"
    echo
    echo -e "${DIM}${message}${NC}"
    echo -e "${BRIGHT_YELLOW}Press ${BOLD}↓ (down arrow)${NC}${BRIGHT_YELLOW} to continue...${NC}"
    
    while true; do
        read -rsn3 key
        case $key in
            $'\e[B') # Down arrow key
                clear
                break
                ;;
            'q'|'Q')
                echo
                set_terminal_title "URL Finder - Goodbye!"
                echo -e "${BRIGHT_YELLOW}${ICON_SPARKLES} Thanks for using URL Finder! Stay secure! ${ICON_SPARKLES}${NC}"
                exit 0
                ;;
            *)
                # Invalid key, continue waiting
                ;;
        esac
    done
}

# Function to print ASCII art header
print_ascii_header() {
    local subtitle="$1"
    echo
    echo -e "${BRIGHT_CYAN}"
    cat << 'EOF'
    ██╗   ██╗██████╗ ██╗         ███████╗██╗███╗   ██╗██████╗ ███████╗██████╗ 
    ██║   ██║██╔══██╗██║         ██╔════╝██║████╗  ██║██╔══██╗██╔════╝██╔══██╗
    ██║   ██║██████╔╝██║         █████╗  ██║██╔██╗ ██║██║  ██║█████╗  ██████╔╝
    ██║   ██║██╔══██╗██║         ██╔══╝  ██║██║╚██╗██║██║  ██║██╔══╝  ██╔══██╗
    ╚██████╔╝██║  ██║███████╗    ██║     ██║██║ ╚████║██████╔╝███████╗██║  ██║
     ╚═════╝ ╚═╝  ╚═╝╚══════╝    ╚═╝     ╚═╝╚═╝  ╚═══╝╚═════╝ ╚══════╝╚═╝  ╚═╝
EOF
    echo -e "${NC}"
    echo -e "${BRIGHT_WHITE}${BOLD}                    🔍 Advanced URL Detection Tool 🔍${NC}"
    if [ -n "$subtitle" ]; then
        echo -e "${DIM}                           $subtitle${NC}"
    fi
    echo
    echo -e "${BRIGHT_YELLOW}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BRIGHT_YELLOW}║${NC}  ${ICON_SPARKLES} ${BRIGHT_WHITE}Scan local directories or GitHub repositories for URLs${NC}    ${BRIGHT_YELLOW}║${NC}"
    echo -e "${BRIGHT_YELLOW}║${NC}  ${ICON_TARGET} ${DIM}Built with ${BRIGHT_RED}♥${NC}${DIM} for developers and security researchers${NC}       ${BRIGHT_YELLOW}║${NC}"
    echo -e "${BRIGHT_YELLOW}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo
}

# Function to print smaller ASCII art for sections
print_section_ascii() {
    local title="$1"
    local icon="$2"
    echo
    echo -e "${BRIGHT_CYAN}"
    case "$title" in
        "SCANNING")
            cat << 'EOF'
    ███████╗ ██████╗ █████╗ ███╗   ██╗███╗   ██╗██╗███╗   ██╗ ██████╗ 
    ██╔════╝██╔════╝██╔══██╗████╗  ██║████╗  ██║██║████╗  ██║██╔════╝ 
    ███████╗██║     ███████║██╔██╗ ██║██╔██╗ ██║██║██╔██╗ ██║██║  ███╗
    ╚════██║██║     ██╔══██║██║╚██╗██║██║╚██╗██║██║██║╚██╗██║██║   ██║
    ███████║╚██████╗██║  ██║██║ ╚████║██║ ╚████║██║██║ ╚████║╚██████╔╝
    ╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═══╝╚═╝╚═╝  ╚═══╝ ╚═════╝ 
EOF
            ;;
        "RESULTS")
            cat << 'EOF'
    ██████╗ ███████╗███████╗██╗   ██╗██╗  ████████╗███████╗
    ██╔══██╗██╔════╝██╔════╝██║   ██║██║  ╚══██╔══╝██╔════╝
    ██████╔╝█████╗  ███████╗██║   ██║██║     ██║   ███████╗
    ██╔══██╗██╔══╝  ╚════██║██║   ██║██║     ██║   ╚════██║
    ██║  ██║███████╗███████║╚██████╔╝███████╗██║   ███████║
    ╚═╝  ╚═╝╚══════╝╚══════╝ ╚═════╝ ╚══════╝╚═╝   ╚══════╝
EOF
            ;;
        "SUMMARY")
            cat << 'EOF'
    ███████╗██╗   ██╗███╗   ███╗███╗   ███╗ █████╗ ██████╗ ██╗   ██╗
    ██╔════╝██║   ██║████╗ ████║████╗ ████║██╔══██╗██╔══██╗╚██╗ ██╔╝
    ███████╗██║   ██║██╔████╔██║██╔████╔██║███████║██████╔╝ ╚████╔╝ 
    ╚════██║██║   ██║██║╚██╔╝██║██║╚██╔╝██║██╔══██║██╔══██╗  ╚██╔╝  
    ███████║╚██████╔╝██║ ╚═╝ ██║██║ ╚═╝ ██║██║  ██║██║  ██║   ██║   
    ╚══════╝ ╚═════╝ ╚═╝     ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   
EOF
            ;;
    esac
    echo -e "${NC}"
    echo -e "${BRIGHT_WHITE}${BOLD}                    $icon $title IN PROGRESS $icon${NC}"
    echo
}

# Function to print success message
print_success() {
    echo -e "${GREEN}${ICON_SUCCESS} ${BOLD}$1${NC}"
}

# Function to print error message
print_error() {
    echo -e "${RED}${ICON_ERROR} ${BOLD}$1${NC}"
}

# Function to print warning message
print_warning() {
    echo -e "${YELLOW}${ICON_WARNING} ${BOLD}$1${NC}"
}

# Function to print info message
print_info() {
    echo -e "${BRIGHT_BLUE}${ICON_INFO} $1${NC}"
}

# Function to display modern usage
show_usage() {
    set_terminal_title "URL Finder - Help"
    clear
    print_ascii_header "Help & Documentation"
    
    echo -e "${BRIGHT_WHITE}${BOLD}DESCRIPTION:${NC}"
    echo -e "  ${DIM}A powerful CLI tool to search for URLs in source code and repositories${NC}"
    echo
    echo -e "${BRIGHT_WHITE}${BOLD}USAGE:${NC}"
    echo -e "  ${BRIGHT_GREEN}$0${NC} ${DIM}[options]${NC}"
    echo
    echo -e "${BRIGHT_WHITE}${BOLD}OPTIONS:${NC}"
    echo -e "  ${BRIGHT_YELLOW}-h, --help${NC}     Show this help message"
    echo
    echo -e "${BRIGHT_WHITE}${BOLD}SUPPORTED INPUTS:${NC}"
    echo -e "  ${ICON_FOLDER} ${BRIGHT_GREEN}Local Directory${NC}     ${DIM}/path/to/your/project${NC}"
    echo -e "  ${ICON_GITHUB} ${BRIGHT_BLUE}GitHub Repository${NC}   ${DIM}https://github.com/user/repo${NC}"
    echo
}

# Function to check if git is installed
check_git() {
    if ! command -v git &> /dev/null; then
        print_error "Git is not installed. GitHub repository scanning unavailable."
        return 1
    fi
    return 0
}

# Function to validate GitHub URL
validate_github_url() {
    local url="$1"
    
    if [[ "$url" =~ ^https://github\.com/[^/]+/[^/]+/?$ ]] || \
       [[ "$url" =~ ^git@github\.com:[^/]+/[^/]+\.git$ ]] || \
       [[ "$url" =~ ^https://github\.com/[^/]+/[^/]+\.git$ ]]; then
        return 0
    else
        return 1
    fi
}

# Function to clone GitHub repository with progress
clone_github_repo() {
    local repo_url="$1"
    local temp_dir=$(mktemp -d)
    
    print_info "Cloning repository..."
    echo -e "${DIM}${ICON_GITHUB} Repository: ${BRIGHT_WHITE}$repo_url${NC}"
    echo -e "${DIM}${ICON_FOLDER} Temporary location: ${BRIGHT_WHITE}$temp_dir${NC}"
    echo
    
    if git clone --depth 1 --progress "$repo_url" "$temp_dir" &>/dev/null; then
        print_success "Repository cloned successfully!"
        echo "$temp_dir"
        return 0
    else
        print_error "Failed to clone repository. Check URL and internet connection."
        rm -rf "$temp_dir"
        return 1
    fi
}

# Function to cleanup temporary directory
cleanup_temp_dir() {
    local temp_dir="$1"
    if [[ "$temp_dir" =~ ^/tmp/ ]] && [ -d "$temp_dir" ]; then
        echo -e "${BRIGHT_YELLOW}${ICON_CLEANUP} Cleaning up temporary files...${NC}"
        rm -rf "$temp_dir"
        print_success "Cleanup completed"
    fi
}

# Function to detect input type
detect_input_type() {
    local input="$1"
    
    if [[ "$input" =~ ^https://github\.com/ ]] || [[ "$input" =~ ^git@github\.com: ]]; then
        echo "github"
    else
        echo "local"
    fi
}

# Function to validate directory
validate_directory() {
    local dir="$1"
    
    if [ ! -d "$dir" ]; then
        print_error "Directory '$dir' does not exist"
        return 1
    fi
    
    if [ ! -r "$dir" ]; then
        print_error "Directory '$dir' is not readable"
        return 1
    fi
    
    return 0
}

# PAGE 1: Main configuration and setup
page_main() {
    set_terminal_title "URL Finder - Main Configuration"
    print_ascii_header "v2.0 - Security & Development Edition"
    
    # Check git availability
    local git_available=true
    if ! check_git; then
        print_warning "GitHub scanning unavailable (git not found)"
        git_available=false
    else
        print_success "All dependencies available"
    fi
    
    echo
    echo -e "${BRIGHT_YELLOW}╔════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BRIGHT_YELLOW}║${NC}                        ${ICON_GEAR} ${BRIGHT_WHITE}CONFIGURATION SETUP${NC} ${ICON_GEAR}                          ${BRIGHT_YELLOW}║${NC}"
    echo -e "${BRIGHT_YELLOW}╚════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo
    
    # Interactive input
    while true; do
        echo -e "${BRIGHT_WHITE}${BOLD}🎯 Choose your scanning target:${NC}"
        echo
        echo -e "  ${ICON_FOLDER} ${BRIGHT_GREEN}${BOLD}1)${NC} ${BRIGHT_WHITE}Local Directory${NC}     ${DIM}Scan files on your machine${NC}"
        echo -e "  ${ICON_GITHUB} ${BRIGHT_BLUE}${BOLD}2)${NC} ${BRIGHT_WHITE}GitHub Repository${NC}   ${DIM}Clone and scan remote repo${NC}"
        echo -e "  ${BRIGHT_RED}${BOLD}q)${NC} ${BRIGHT_WHITE}Quit${NC}                   ${DIM}Exit the application${NC}"
        echo
        echo -e "${BRIGHT_CYAN}┌──────────────────────────────────────────────────────────────────────────────┐${NC}"
        echo -n -e "${BRIGHT_CYAN}│${NC} ${BRIGHT_WHITE}Enter choice or paste path/URL:${NC} "
        read -r user_input
        echo -e "${BRIGHT_CYAN}└──────────────────────────────────────────────────────────────────────────────┘${NC}"
        echo
        
        # Handle quit
        if [ "$user_input" = "q" ] || [ "$user_input" = "Q" ]; then
            echo
            set_terminal_title "URL Finder - Goodbye!"
            echo -e "${BRIGHT_YELLOW}${ICON_SPARKLES} Thanks for using URL Finder! Stay secure! ${ICON_SPARKLES}${NC}"
            exit 0
        fi
        
        # Handle choice selection
        if [ "$user_input" = "1" ]; then
            echo -n -e "${BRIGHT_WHITE}📁 Enter local directory path: ${NC}"
            read -r user_input
        elif [ "$user_input" = "2" ]; then
            if [ "$git_available" = false ]; then
                print_error "GitHub scanning requires git to be installed"
                echo
                continue
            fi
            echo -n -e "${BRIGHT_WHITE}🐙 Enter GitHub repository URL: ${NC}"
            read -r user_input
        fi
        
        # Handle empty input
        if [ -z "$user_input" ]; then
            print_error "Please enter a valid path or URL"
            echo
            continue
        fi
        
        # Detect and process input
        input_type=$(detect_input_type "$user_input")
        
        if [ "$input_type" = "github" ]; then
            if [ "$git_available" = false ]; then
                print_error "Cannot clone repository: git not available"
                echo
                continue
            fi
            
            if validate_github_url "$user_input"; then
                temp_dir=$(clone_github_repo "$user_input")
                if [ $? -eq 0 ]; then
                    SCAN_DIR="$temp_dir"
                    CLEANUP_NEEDED=true
                    break
                else
                    echo
                    continue
                fi
            else
                print_error "Invalid GitHub URL format"
                echo -e "${DIM}Supported formats:${NC}"
                echo -e "${DIM}  • https://github.com/username/repository${NC}"
                echo -e "${DIM}  • https://github.com/username/repository.git${NC}"
                echo -e "${DIM}  • git@github.com:username/repository.git${NC}"
                echo
                continue
            fi
        else
            # Process local directory
            user_input="${user_input%\"}"
            user_input="${user_input#\"}"
            user_input="${user_input%\'}"
            user_input="${user_input#\'}"
            user_input="${user_input//\\ / }"
            user_input="${user_input/#\~/$HOME}"
            
            if [[ ! "$user_input" = /* ]]; then
                user_input="$(pwd)/$user_input"
            fi
            
            if validate_directory "$user_input"; then
                SCAN_DIR="$user_input"
                CLEANUP_NEEDED=false
                break
            else
                echo
            fi
        fi
    done
    
    wait_for_next "Configuration complete! Ready to begin scanning."
}

# PAGE 2: Scanning process
page_scanning() {
    set_terminal_title "URL Finder - Scanning Files"
    print_section_ascii "SCANNING" "${ICON_SEARCH}"
    
    echo -e "${BRIGHT_BLUE}${ICON_TARGET} Target: ${BRIGHT_WHITE}$SCAN_DIR${NC}"
    echo
    echo -e "${BRIGHT_BLUE}${ICON_GEAR} Analyzing source files...${NC}"
    echo
    
    # URL regex pattern
    local url_pattern='https?://[a-zA-Z0-9._/-]+[a-zA-Z0-9_/-]|ftp://[a-zA-Z0-9._/-]+[a-zA-Z0-9_/-]|www\.[a-zA-Z0-9._/-]+[a-zA-Z0-9_/-]'
    
    # Progress indicators
    echo -e "${DIM}🔎 Searching for source code files...${NC}"
    echo -e "${DIM}⚡ Filtering out dependencies and build files...${NC}"
    echo -e "${DIM}🔗 Extracting URLs from content...${NC}"
    echo
    
    # Find and process files
    local temp_file=$(mktemp)
    find "$SCAN_DIR" -type f \( \
        -name "*.js" -o -name "*.jsx" -o -name "*.ts" -o -name "*.tsx" \
        -o -name "*.py" -o -name "*.java" -o -name "*.cpp" -o -name "*.c" \
        -o -name "*.h" -o -name "*.hpp" -o -name "*.cs" -o -name "*.php" \
        -o -name "*.rb" -o -name "*.go" -o -name "*.rs" -o -name "*.swift" \
        -o -name "*.kt" -o -name "*.scala" -o -name "*.dart" -o -name "*.vue" \
        -o -name "*.html" -o -name "*.htm" -o -name "*.css" -o -name "*.scss" \
        -o -name "*.sass" -o -name "*.less" -o -name "*.sql" -o -name "*.sh" \
        -o -name "*.bash" -o -name "*.zsh" -o -name "*.fish" -o -name "*.ps1" \
        -o -name "*.bat" -o -name "*.cmd" -o -name "*.yml" -o -name "*.yaml" \
        -o -name "*.xml" -o -name "*.json" -o -name "*.toml" -o -name "*.ini" \
        -o -name "*.cfg" -o -name "*.conf" -o -name "*.env" -o -name "*.md" \
        -o -name "*.txt" -o -name "*.rst" -o -name "*.tex" -o -name "*.r" \
        -o -name "*.R" -o -name "*.m" -o -name "*.pl" -o -name "*.lua" \
        -o -name "*.vim" -o -name "*.dockerfile" -o -name "Dockerfile*" \
        -o -name "Makefile*" -o -name "*.mk" \
    \) \
        ! -path "*/node_modules/*" ! -path "*/.git/*" ! -path "*/build/*" \
        ! -path "*/dist/*" ! -path "*/.vscode/*" ! -path "*/.idea/*" \
        ! -path "*/target/*" ! -path "*/bin/*" ! -path "*/obj/*" \
        ! -path "*/__pycache__/*" ! -path "*/.pytest_cache/*" \
        ! -path "*/.next/*" ! -path "*/.nuxt/*" ! -path "*/.cache/*" \
        ! -path "*/coverage/*" ! -path "*/.nyc_output/*" \
        ! -path "*/vendor/*" ! -path "*/public/build/*" \
        ! -name "package-lock.json" ! -name "yarn.lock" ! -name "pnpm-lock.yaml" \
        ! -name "uv.lock" ! -name "Pipfile.lock" ! -name "poetry.lock" \
        ! -name "Cargo.lock" ! -name "Gemfile.lock" ! -name "composer.lock" \
        ! -name "go.sum" ! -name "*.min.js" ! -name "*.min.css" \
        ! -name "bundle.js" ! -name "*.bundle.*" ! -name "*.chunk.*" \
        -exec grep -l -E "$url_pattern" {} \; 2>/dev/null > "$temp_file"
    
    # Reset global arrays
    FOUND_FILES=()
    FOUND_URLS=()
    TOTAL_FILES=0
    TOTAL_URLS=0
    
    if [ -s "$temp_file" ]; then
        while IFS= read -r file; do
            if [ -f "$file" ] && [ -r "$file" ]; then
                ((TOTAL_FILES++))
                
                # Get relative path for cleaner output
                local rel_path=$(realpath --relative-to="$SCAN_DIR" "$file" 2>/dev/null || echo "$file")
                FOUND_FILES+=("$rel_path")
                
                # Extract URLs from this file
                local file_urls=""
                while IFS=: read -r line_num content; do
                    while read -r url; do
                        if [ -n "$file_urls" ]; then
                            file_urls="$file_urls"$'\n'"Line $line_num: $url"
                        else
                            file_urls="Line $line_num: $url"
                        fi
                        ((TOTAL_URLS++))
                    done < <(echo "$content" | grep -oE "$url_pattern")
                done < <(grep -n -E "$url_pattern" "$file" 2>/dev/null)
                
                # Store URLs for this file
                FOUND_URLS+=("$file_urls")
            fi
        done < "$temp_file"
    fi
    
    rm "$temp_file"
    
    # Show scan completion
    if [ $TOTAL_FILES -eq 0 ]; then
        print_warning "No URLs found in the specified directory"
        echo
        wait_for_next "Scan completed with no results found."
        # Skip to summary page
        page_summary
        return
    else
        print_success "Scan completed! Found URLs in $TOTAL_FILES files"
        echo -e "${BRIGHT_GREEN}${ICON_LINK} Total URLs discovered: ${BOLD}$TOTAL_URLS${NC}"
    fi
    
    wait_for_next "URLs discovered! Ready to display detailed results."
}

# PAGE 3: Results display
page_results() {
    set_terminal_title "URL Finder - Displaying Results"
    print_section_ascii "RESULTS" "${ICON_LINK}"
    
    for i in "${!FOUND_FILES[@]}"; do
        echo -e "${BRIGHT_CYAN}${ICON_FILE} ${BOLD}${FOUND_FILES[$i]}${NC}"
        
        # Display URLs for this file
        if [ -n "${FOUND_URLS[$i]}" ]; then
            while IFS= read -r url_line; do
                if [ -n "$url_line" ]; then
                    local line_num=$(echo "$url_line" | cut -d: -f1-2)
                    local url=$(echo "$url_line" | cut -d: -f3- | sed 's/^ *//')
                    echo -e "  ${DIM}$line_num:${NC} ${BRIGHT_GREEN}$url${NC}"
                fi
            done <<< "${FOUND_URLS[$i]}"
        fi
        echo
    done
    
    wait_for_next "All URLs displayed! Ready to show final statistics."
}

# PAGE 4: Summary
page_summary() {
    set_terminal_title "URL Finder - Scan Complete"
    print_section_ascii "SUMMARY" "${ICON_SPARKLES}"
    echo
    echo -e "${BRIGHT_WHITE}${BOLD}📊 Final Statistics:${NC}"
    echo -e "  ${ICON_FILE} Files with URLs: ${BRIGHT_CYAN}${BOLD}$TOTAL_FILES${NC}"
    echo -e "  ${ICON_LINK} Total URLs found: ${BRIGHT_GREEN}${BOLD}$TOTAL_URLS${NC}"
    echo
    
    # Cleanup if needed
    if [ "$CLEANUP_NEEDED" = true ] && [ -n "$SCAN_DIR" ]; then
        cleanup_temp_dir "$SCAN_DIR"
        echo
    fi
    
    echo -e "${BRIGHT_GREEN}╔══════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BRIGHT_GREEN}║${NC}  ${ICON_SPARKLES} ${BRIGHT_WHITE}${BOLD}Mission Complete! URLs discovered and catalogued successfully!${NC} ${ICON_SPARKLES}    ${BRIGHT_GREEN}║${NC}"
    echo -e "${BRIGHT_GREEN}╚══════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo -e "${DIM}${ICON_TARGET} Keep your URLs secure and stay vigilant! ${NC}"
    echo
}

# Main script execution with 4 pages
main() {
        # Clear terminal at startup for clean presentation
    clear
    # PAGE 1: Main configuration
    page_main
    
    # PAGE 2: Scanning
    page_scanning
    
    # PAGE 3: Results (only if URLs found)
    if [ $TOTAL_FILES -gt 0 ]; then
        page_results
    fi
    
    # PAGE 4: Summary
    page_summary
}

# Handle help flag
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_usage
    exit 0
fi

# Run main function
main