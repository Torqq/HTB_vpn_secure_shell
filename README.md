# HTB_vpn_secure

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
