#!/usr/bin/env bash
#
# ThunderByte Theme Manager for Pterodactyl Panel
#
# Usage:
#   sudo bash apply-theme.sh           # interactive menu
#   sudo bash apply-theme.sh install   # non-interactive
#   sudo bash apply-theme.sh uninstall # non-interactive
#   sudo bash apply-theme.sh update    # non-interactive
#   sudo bash apply-theme.sh status    # non-interactive
#
# One-liner:
#   curl -sL https://raw.githubusercontent.com/brineajay-94/thunderbyte/master/apply-theme.sh | sudo bash
#

set -euo pipefail

# ---------------------------------------------------------------- config
PANEL_DIR="${PANEL_DIR:-/var/www/pterodactyl}"
PANEL_USER="${PANEL_USER:-pterodactyl}"
THEME_REPO="${THEME_REPO:-https://github.com/brineajay-94/thunderbyte.git}"
THEME_TMP="/tmp/thunderbyte"
BACKUP_DIR="$PANEL_DIR/.thunderbyte-backup"
MARKER_FILE="$PANEL_DIR/.thunderbyte-installed"

# Files changed by the theme (kept in sync with theme/manifest.json)
FILES=(
    "resources/scripts/components/auth/LoginContainer.tsx"
    "resources/scripts/components/auth/LoginFormContainer.tsx"
    "resources/scripts/components/auth/LoginInput.tsx"
    "resources/scripts/components/auth/Snowfall.tsx"
    "resources/views/templates/auth/core.blade.php"
)
ASSET_FILES=(
    "public/assets/thunderbyte/background.png"
    "public/assets/thunderbyte/logo.png"
)

# ---------------------------------------------------------------- colors
C_RESET='\033[0m'
C_BOLD='\033[1m'
C_GREEN='\033[32m'
C_YELLOW='\033[33m'
C_RED='\033[31m'
C_BLUE='\033[96m'
C_GRAY='\033[90m'

info()  { printf "${C_BLUE}[INFO]${C_RESET}  %s\n" "$*"; }
ok()    { printf "${C_GREEN}[ OK ]${C_RESET}  %s\n" "$*"; }
warn()  { printf "${C_YELLOW}[WARN]${C_RESET}  %s\n" "$*"; }
fail()  { printf "${C_RED}[FAIL]${C_RESET}  %s\n" "$*"; }

# ---------------------------------------------------------------- helpers
require_root() {
    if [ "$(id -u)" -ne 0 ]; then
        fail "This script must be run as root (use sudo)."
        exit 1
    fi
}

check_panel() {
    [ -d "$PANEL_DIR" ] || {
        fail "Panel directory not found at $PANEL_DIR"
        warn "Set the correct path with: PANEL_DIR=/var/www/pterodactyl sudo bash apply-theme.sh"
        exit 1
    }
    [ -f "$PANEL_DIR/artisan" ] || {
        fail "No 'artisan' found in $PANEL_DIR — this does not look like a Pterodactyl panel."
        exit 1
    }
    id -u "$PANEL_USER" >/dev/null 2>&1 || {
        fail "Panel user '$PANEL_USER' does not exist."
        warn "Set the correct user with: PANEL_USER=pterodactyl sudo bash apply-theme.sh"
        exit 1
    }
}

# Returns 0 = theme installed, 1 = not installed
theme_installed() {
    [ -f "$MARKER_FILE" ] && [ -f "$PANEL_DIR/resources/scripts/components/auth/Snowfall.tsx" ]
}

fetch_theme() {
    if [ -d "$THEME_TMP/.git" ]; then
        info "Refreshing theme source from $THEME_REPO"
        git -C "$THEME_TMP" pull --ff-only --quiet || rm -rf "$THEME_TMP"
    fi
    if [ ! -d "$THEME_TMP/.git" ]; then
        info "Downloading theme source from $THEME_REPO"
        rm -rf "$THEME_TMP"
        git clone --depth 1 "$THEME_REPO" "$THEME_TMP" >/dev/null 2>&1 || {
            fail "Could not clone $THEME_REPO. Check your network connection."
            exit 1
        }
    fi
    [ -d "$THEME_TMP/theme" ] || {
        fail "Theme package not found inside the repository (missing 'theme/' directory)."
        exit 1
    }
}

backup_originals() {
    if [ -d "$BACKUP_DIR" ]; then
        return
    fi
    info "Backing up original panel files to $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    for rel in "${FILES[@]}"; do
        if [ -f "$PANEL_DIR/$rel" ]; then
            mkdir -p "$(dirname "$BACKUP_DIR/$rel")"
            cp -p "$PANEL_DIR/$rel" "$BACKUP_DIR/$rel"
        fi
    done
    touch "$BACKUP_DIR/.complete"
}

copy_theme() {
    info "Copying theme files into panel"
    for rel in "${FILES[@]}"; do
        src="$THEME_TMP/theme/$rel"
        if [ -f "$src" ]; then
            cp -f "$src" "$PANEL_DIR/$rel"
        else
            warn "Missing from theme package: $rel"
        fi
    done
    mkdir -p "$PANEL_DIR/public/assets/thunderbyte"
    for rel in "${ASSET_FILES[@]}"; do
        src="$THEME_TMP/theme/$rel"
        if [ -f "$src" ]; then
            cp -f "$src" "$PANEL_DIR/$rel"
        fi
    done
    touch "$MARKER_FILE"
}

restore_originals() {
    if [ ! -d "$BACKUP_DIR" ]; then
        warn "No backup found — cannot restore untouched originals."
        warn "Reinstalling the official panel file ('git checkout') is required."
        return 1
    fi
    info "Restoring original panel files from backup"
    for rel in "${FILES[@]}"; do
        if [ -f "$BACKUP_DIR/$rel" ]; then
            cp -f "$BACKUP_DIR/$rel" "$PANEL_DIR/$rel"
        else
            warn "No backup for: $rel (leaving as-is)"
        fi
    done
    rm -f "$MARKER_FILE"
    return 0
}

fix_permissions() {
    info "Fixing ownership of $PANEL_DIR (user: $PANEL_USER)"
    chown -R "$PANEL_USER:$PANEL_USER" "$PANEL_DIR/public/assets" "$PANEL_DIR/resources" \
        "$PANEL_DIR/storage" "$PANEL_DIR/bootstrap/cache" 2>/dev/null || true
}

build_panel() {
    info "Installing panel dependencies (yarn install)…"
    if ! sudo -u "$PANEL_USER" bash -c "cd '$PANEL_DIR' && yarn install --non-interactive" >/dev/null; then
        warn "yarn install failed — retrying as $PANEL_USER once more; if it keeps failing check network."
        sudo -u "$PANEL_USER" bash -c "cd '$PANEL_DIR' && yarn install" || {
            fail "yarn install failed. See errors above."
            return 1
        }
    fi
    ok "Dependencies installed"

    info "Building panel assets (this can take a while)…"
    sudo -u "$PANEL_USER" bash -c "cd '$PANEL_DIR' && yarn build:production" || {
        fail "yarn build:production failed. See errors above."
        return 1
    }
    ok "Assets built"
}

clear_caches() {
    info "Clearing panel caches"
    sudo -u "$PANEL_USER" php artisan view:clear >/dev/null 2>&1 || true
    sudo -u "$PANEL_USER" php artisan config:clear >/dev/null 2>&1 || true
    sudo -u "$PANEL_USER" php artisan cache:clear >/dev/null 2>&1 || true
    ok "Caches cleared"
}

# ---------------------------------------------------------------- actions
status() {
    local installed
    if theme_installed; then
        installed="${C_GREEN}INSTALLED${C_RESET}"
    else
        installed="${C_YELLOW}NOT INSTALLED${C_RESET}"
    fi

    echo
    echo "  ${C_BOLD}ThunderByte Theme Manager${C_RESET}"
    echo "  ──────────────────────────────────────────────"
    echo "  Panel directory : $PANEL_DIR"
    echo "  Panel user      : $PANEL_USER"
    echo "  Theme status    : $installed"
    if [ -d "$BACKUP_DIR" ]; then
        echo "  Original backup : present ($BACKUP_DIR)"
    else
        echo "  Original backup : none"
    fi
    echo
}

install_theme() {
    check_panel
    fetch_theme
    backup_originals
    copy_theme
    fix_permissions
    build_panel
    clear_caches
    echo
    ok "${C_BOLD}ThunderByte theme installed successfully!${C_RESET}"
    info "Visit your panel's login page: https://your-panel/auth/login"
    if [ -d "$THEME_TMP" ]; then
        info "Theme cache left at $THEME_TMP (can be deleted with 'rm -rf $THEME_TMP')"
    fi
}

uninstall_theme() {
    check_panel
    if ! theme_installed; then
        warn "Theme does not appear to be installed — nothing to do."
        return 0
    fi
    restore_originals
    fix_permissions
    build_panel
    clear_caches
    echo
    ok "${C_BOLD}ThunderByte theme uninstalled. Original panel restored.${C_RESET}"
}

update_theme() {
    check_panel
    fetch_theme
    backup_originals
    copy_theme
    fix_permissions
    build_panel
    clear_caches
    echo
    ok "${C_BOLD}ThunderByte theme updated to latest version!${C_RESET}"
}

# ---------------------------------------------------------------- menu
run_menu() {
    local choice
    while true; do
        status
        echo "  ${C_BOLD}Choose an option:${C_RESET}"
        echo "    ${C_GREEN}1${C_RESET}) Install theme"
        echo "    ${C_YELLOW}2${C_RESET}) Uninstall theme"
        echo "    ${C_BLUE}3${C_RESET}) Update theme"
        echo "    ${C_GRAY}4${C_RESET}) Show status"
        echo "    ${C_RED}Q${C_RESET}) Quit"
        printf "\n  Enter your choice [1-4/q]: "
        read -r choice
        case "$choice" in
            1) install_theme ;;
            2) uninstall_theme ;;
            3) update_theme ;;
            4) status ;;
            q|Q) echo; info "Goodbye!"; exit 0 ;;
            *) warn "Invalid choice: $choice" ;;
        esac
        echo
        printf "  Press Enter to return to the menu… "
        read -r _
    done
}

# ---------------------------------------------------------------- entry
require_root

case "${1:-}" in
    install|uninstall|update|status)
        "$1" ;;
    ""|-h|--help)
        run_menu ;;
    *)
        warn "Unknown command: $1"
        echo "Usage: sudo bash apply-theme.sh [install|uninstall|update|status]"
        exit 1
        ;;
esac