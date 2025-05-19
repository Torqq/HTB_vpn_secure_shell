#!/bin/bash
#Author : Torqer

# Colors
GREEN="\e[32m"
RED="\e[31m"
RESET="\e[0m"

# Directory define
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
log_dir="$script_dir/secure_net_log"
log_prefix="secure_net_log"
log_enabled=false
timestamp=$(date "+%Y-%m-%d %H:%M:%S")

interfaces=("tun0" "tun1" "wg0" "wg1" "vpn0")

if [[ "$1" == "--help" ]]; then
    echo -e "${GREEN}Usage:${RESET} $0 [options]\n"
    echo -e "${GREEN}Options:${RESET}"
    echo -e "  -s           Save a log file with current and restored values (UFW, VPN interfaces, /etc/hosts)"
    echo -e "  --help       Show this help message"
    echo -e "\nThis script resets UFW and cleans traces for interfaces: ${interfaces[*]}"
    exit 0
fi

if [[ "$1" == "-s" ]]; then
    log_enabled=true
fi

get_log_filename() {
    mkdir -p "$log_dir"
    i=1
    while [[ -e "$log_dir/${log_prefix}_$i.log" ]]; do
        ((i++))
    done
    echo "$log_dir/${log_prefix}_$i.log"
}

read -rp "Do you want to secure VPN interfaces and reset UFW rules (/etc/hosts line 5 to 7 will be erased) ? (y/N): " confirm
if ! [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo -e "${RED}[!] Operation cancelled. Nothing was changed.${RESET}"
    exit 1
fi

echo -e "${GREEN}[+] Script started at: $timestamp${RESET}"

if $log_enabled; then
    logfile=$(get_log_filename)
    echo -e "${GREEN}[+] Logging enabled. Saving to: $logfile${RESET}"
    echo "=== SECURE NETWORK SCRIPT LOG ===" > "$logfile"
    echo "Timestamp: $timestamp" >> "$logfile"

    for iface in "${interfaces[@]}"; do
        echo -e "\n--- Open ports on $iface BEFORE ---" >> "$logfile"
        sudo ss -tulnp | grep "$iface" >> "$logfile" 2>/dev/null
    done

    echo -e "\n--- UFW STATUS BEFORE ---" >> "$logfile"
    sudo ufw status verbose >> "$logfile" 2>/dev/null

    echo -e "\n--- /etc/hosts lines 5-7 BEFORE ---" >> "$logfile"
    sed -n '5,7p' /etc/hosts >> "$logfile"
fi

for iface in "${interfaces[@]}"; do
    echo -e "${GREEN}[+] Cleaning UFW rules related to $iface...${RESET}"
    ufw_output=$(sudo ufw status numbered | grep "$iface")
    if [[ -z "$ufw_output" ]]; then
        echo -e "${RED}[!] No UFW rules found for $iface. Skipping.${RESET}"
    else
        echo "$ufw_output" | awk '{print $1}' | tac | while read -r num; do
            sudo ufw delete "$num"
        done
    fi
done

# /etc/hosts clearing
echo -e "${GREEN}[+] Cleaning custom lines in /etc/hosts...${RESET}"
sudo sed -i '5,7d' /etc/hosts

# Historique Bash
echo -e "${GREEN}[+] Clearing temporary Bash history...${RESET}"
export HISTFILE=~/.bash_history_session_clean
history -c

# -------------------------------
# Journal suppression - désactivée par défaut
# -------------------------------
# echo -e "${GREEN}[+] Removing system logs from this session...${RESET}"
# sudo journalctl --rotate
# sudo journalctl --vacuum-time=1s 2>/dev/null
# echo -e "${GREEN}[✓] System logs cleared.${RESET}"
# -------------------------------

# Log writing after modifications
if $log_enabled; then
    echo -e "\n--- UFW STATUS AFTER ---" >> "$logfile"
    sudo ufw status verbose >> "$logfile" 2>/dev/null

    for iface in "${interfaces[@]}"; do
        echo -e "\n--- Open ports on $iface AFTER ---" >> "$logfile"
        sudo ss -tulnp | grep "$iface" >> "$logfile" 2>/dev/null
    done

    echo -e "\n--- /etc/hosts lines 5-7 AFTER ---" >> "$logfile"
    sed -n '5,7p' /etc/hosts >> "$logfile"

    echo -e "${GREEN}[✓] Log file completed: $logfile${RESET}"
fi

# Terminal
for iface in "${interfaces[@]}"; do
    echo -e "${GREEN}[+] Checking open ports on $iface...${RESET}"
    sudo ss -tulnp | grep "$iface" || echo -e "${RED}[!] No open ports on $iface${RESET}"
done

echo -e "${GREEN}[+] UFW status:${RESET}"
sudo ufw status verbose

echo -e "${GREEN}[✓] Cleanup done. Journals have been preserved.${RESET}"
