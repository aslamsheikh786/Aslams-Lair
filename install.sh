#!/bin/bash

# ============================================================
#   aslam's dotfiles installer
#   github.com/yourusername/dotfiles
# ============================================================

# ---------- CONFIG ----------
DOTFILES_REPO="https://github.com/yourusername/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"
PASSWORD_HASH="92545e654fd9455c468cdf455da3ae98cdf311dc6f711599bfe6ccfc618c0199"
# To change password, run:
#   echo -n 'yournewpassword' | sha256sum
# and replace the hash above
# ----------------------------

# ---------- COLORS ----------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'
# ----------------------------

# ---------- HELPERS ----------
print_header() {
    clear
    echo -e "${MAGENTA}${BOLD}"
    echo "   █████╗  ███████╗██╗      █████╗  ███╗   ███╗'███████╗"
    echo "   ██╔══██╗██╔════╝██║     ██╔══██╗ ████╗ ████║ ██╔════╝"
    echo "   ███████║███████╗██║     ███████║ ██╔████╔██║ ███████╗"
    echo "   ██╔══██║╚════██║██║     ██╔══██║ ██║╚██╔╝██║ ╚════██║"
    echo "   ██║  ██║███████║███████╗██║  ██║ ██║ ╚═╝ ██║ ███████║"
    echo "   ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝ ╚═╝     ╚═╝ ╚══════╝"
    echo -e "${RESET}${CYAN}${BOLD}"
    echo "    ██╗      █████╗  ██╗ ██████╗"
    echo "    ██║     ██╔══██╗ ██║ ██╔══██╗"
    echo "    ██║     ███████║ ██║ ██████╔╝"
    echo "    ██║     ██╔══██║ ██║ ██╔══██╗"
    echo "    ███████╗██║  ██║ ██║ ██║  ██║"
    echo "    ╚══════╝╚═╝  ╚═╝ ╚═╝ ╚═╝  ╚═╝"
    echo -e "${RESET}"
    echo -e "${DIM}   EndeavourOS • KDE Plasma • Catppuccin Mocha • by aslam${RESET}"
    echo -e "${DIM}   ─────────────────────────────────────────────────────${RESET}"
    echo ""
}

print_success() { echo -e "   ${GREEN}✓${RESET} $1"; }
print_error()   { echo -e "   ${RED}✗${RESET} $1"; }
print_info()    { echo -e "   ${CYAN}→${RESET} $1"; }
print_warn()    { echo -e "   ${YELLOW}!${RESET} $1"; }

check_dependency() {
    if ! command -v "$1" &>/dev/null; then
        print_warn "$1 not found, installing..."
        sudo pacman -S --noconfirm "$1"
    else
        print_success "$1 is available"
    fi
}

stow_package() {
    local pkg=$1
    if [ -d "$DOTFILES_DIR/$pkg" ]; then
        cd "$DOTFILES_DIR" && stow --restow "$pkg" 2>/dev/null
        print_success "Stowed $pkg"
    else
        print_warn "$pkg folder not found, skipping"
    fi
}

install_aur_packages() {
    if command -v yay &>/dev/null; then
        print_info "Installing AUR packages..."
        yay -S --noconfirm - < "$DOTFILES_DIR/pkglist-aur.txt"
    else
        print_warn "yay not found, installing yay first..."
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        cd /tmp/yay && makepkg -si --noconfirm
        yay -S --noconfirm - < "$DOTFILES_DIR/pkglist-aur.txt"
    fi
}

press_enter() {
    echo ""
    echo -e "   ${DIM}Press Enter to continue...${RESET}"
    read -r
}
# ----------------------------

# ---------- PASSWORD GATE ----------
print_header
echo -e "   ${BOLD}Access Required${RESET}"
echo -e "   ${DIM}This installer is password protected.${RESET}"
echo ""
read -rsp "   Enter password: " INPUT_PASS
echo ""

INPUT_HASH="$(echo -n "$INPUT_PASS" | sha256sum | awk '{print $1}')"

if [ "$INPUT_HASH" != "$PASSWORD_HASH" ]; then
    echo ""
    print_error "Incorrect password. Access denied."
    echo ""
    exit 1
fi

print_success "Access granted!"
sleep 1
# -----------------------------------

# ---------- CLONE REPO ----------
clone_repo() {
    print_header
    echo -e "   ${BOLD}Cloning dotfiles...${RESET}"
    echo ""
    if [ -d "$DOTFILES_DIR" ]; then
        print_warn "~/dotfiles already exists, pulling latest changes..."
        cd "$DOTFILES_DIR" && git pull
    else
        git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
        print_success "Cloned to $DOTFILES_DIR"
    fi
    press_enter
}
# --------------------------------

# ---------- INSTALL FUNCTIONS ----------
do_bash() {
    print_header
    echo -e "   ${BOLD}Installing: Bash${RESET}"
    echo ""
    stow_package bash
    print_info "Reloading bash..."
    source "$HOME/.bashrc" 2>/dev/null
    press_enter
}

do_kde() {
    print_header
    echo -e "   ${BOLD}Installing: KDE Config${RESET}"
    echo ""
    stow_package kde
    print_warn "You may need to log out and back in for KDE changes to apply."
    press_enter
}

do_konsole() {
    print_header
    echo -e "   ${BOLD}Installing: Konsole${RESET}"
    echo ""
    stow_package konsole
    press_enter
}

do_kvantum() {
    print_header
    echo -e "   ${BOLD}Installing: Kvantum${RESET}"
    echo ""
    check_dependency kvantum
    stow_package kvantum
    press_enter
}

do_themes() {
    print_header
    echo -e "   ${BOLD}Installing: Themes (Catppuccin)${RESET}"
    echo ""
    stow_package themes
    press_enter
}

do_fonts() {
    print_header
    echo -e "   ${BOLD}Installing: Fonts (JetBrainsMono Nerd Font)${RESET}"
    echo ""
    stow_package fonts
    print_info "Refreshing font cache..."
    fc-cache -fv &>/dev/null
    print_success "Font cache refreshed"
    press_enter
}

do_packages() {
    print_header
    echo -e "   ${BOLD}Installing: All Packages${RESET}"
    echo ""
    if [ ! -f "$DOTFILES_DIR/pkglist.txt" ]; then
        print_error "pkglist.txt not found!"
        press_enter
        return
    fi
    print_info "Installing official packages..."
    sudo pacman -S --noconfirm - < "$DOTFILES_DIR/pkglist.txt"
    install_aur_packages
    press_enter
}

do_all() {
    print_header
    echo -e "   ${BOLD}Installing: Everything${RESET}"
    echo ""
    print_info "This will install all packages and configs."
    echo ""
    read -rp "   Are you sure? (y/N): " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        print_warn "Aborted."
        press_enter
        return
    fi

    echo ""
    print_info "Checking dependencies..."
    check_dependency stow
    check_dependency git

    echo ""
    print_info "Installing official packages..."
    sudo pacman -S --noconfirm - < "$DOTFILES_DIR/pkglist.txt" 2>/dev/null

    echo ""
    print_info "Installing AUR packages..."
    install_aur_packages

    echo ""
    print_info "Stowing all configs..."
    for pkg in bash kde konsole kvantum themes fonts; do
        stow_package "$pkg"
    done

    echo ""
    print_info "Refreshing font cache..."
    fc-cache -fv &>/dev/null
    print_success "Font cache refreshed"

    echo ""
    print_success "All done! Your rice is ready."
    print_warn "Log out and back in for all KDE changes to take effect."
    press_enter
}
# ---------------------------------------

# ---------- MAIN MENU ----------
main_menu() {
    while true; do
        print_header
        echo -e "   ${BOLD}What would you like to install?${RESET}"
        echo ""
        echo -e "   ${CYAN}1)${RESET} Everything ${DIM}(recommended for fresh install)${RESET}"
        echo -e "   ${CYAN}─────────────────────────────────${RESET}"
        echo -e "   ${CYAN}2)${RESET} Bash config"
        echo -e "   ${CYAN}3)${RESET} KDE config"
        echo -e "   ${CYAN}4)${RESET} Konsole"
        echo -e "   ${CYAN}5)${RESET} Kvantum"
        echo -e "   ${CYAN}6)${RESET} Themes ${DIM}(Catppuccin)${RESET}"
        echo -e "   ${CYAN}7)${RESET} Fonts ${DIM}(JetBrainsMono Nerd Font)${RESET}"
        echo -e "   ${CYAN}8)${RESET} Packages only ${DIM}(no configs)${RESET}"
        echo -e "   ${CYAN}─────────────────────────────────${RESET}"
        echo -e "   ${CYAN}q)${RESET} Quit"
        echo ""
        read -rp "   Choose an option: " choice

        case $choice in
            1) clone_repo; do_all ;;
            2) clone_repo; do_bash ;;
            3) clone_repo; do_kde ;;
            4) clone_repo; do_konsole ;;
            5) clone_repo; do_kvantum ;;
            6) clone_repo; do_themes ;;
            7) clone_repo; do_fonts ;;
            8) clone_repo; do_packages ;;
            q|Q)
                print_header
                echo -e "   ${DIM}Goodbye!${RESET}"
                echo ""
                exit 0
                ;;
            *)
                print_error "Invalid option, try again."
                sleep 1
                ;;
        esac
    done
}

main_menu
