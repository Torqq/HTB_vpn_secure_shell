# HTB_vpn_secure

Author: Torqer

This script launches a secure and isolated shell environment for working on Hack The Box labs and machines via VPN. It ensures that all network tools run exclusively through the tun0 interface and that all commands are automatically logged for traceability.
Features :

    VPN interface enforcement: Tools like nmap, ffuf, curl, wget, etc. are forced to use tun0 (HTB VPN).

    Automatic logging: Each session is logged in a uniquely named file using the format YYYY-MM-DD-machineName.log.

    Log location isolation: Logs are saved in a dedicated subdirectory next to the script (./htb_log/).

    Safe session: Uses bash --norc --noprofile to start a clean, non-persistent shell.

    No real IP leaks: Prevents tools from accidentally using the default network interface.

    Reverse shell ready: Safe to use for nc -lvnp or reverse connections inside this isolated shell.

    Anti-reuse protection: Prevents overwriting existing logs by exiting if a log file already exists.

    Machine-specific logs: You are prompted to enter the HTB machine name, which is included in the log filename.

    Clean exit: All temporary command overrides (functions) are removed after the session.

Example log path

./htb_log/2025-05-19-Timelapse.log

Recommended use

    Run the script in each terminal you open:

    bash ~/htb_shell/vpn_secure_shell.sh

    Always perform scans, reverse shells, web fuzzing, and exploitation only inside this shell.

    Optionally, block all traffic except through tun0 using ufw or iptables for maximum isolation.

# secure_vpn

secure_vpn is designed to secure and clean up network traces related to common VPN interfaces on a Linux system. It’s useful after a pentest or any sensitive network activity. Specifically, it:

    Resets UFW firewall rules associated with VPN interfaces (tun0, wg0, etc.).

    Cleans lines 5 to 7 of the /etc/hosts file, often used for temporary host overrides.

    Clears the current Bash history to hide recent terminal commands.

    (Optionally) Logs the before/after state of:

        Open ports on VPN interfaces.

        UFW rules.

        /etc/hosts content.

    Keeps these logs in a local subfolder: secure_net_log/

    (Optionally) allows for future log deletion logic (e.g., journalctl) via commented code.

It’s designed to be safe by default, with logging and cleanup actions only affecting user-space changes, not system-critical data.
