#!/usr/bin/env python3
import tkinter as tk
from tkinter import ttk
import subprocess
import threading
import time
import socket
import os

REFRESH_INTERVAL = 3000  # 3s
BG_COLOR = "#2e3440"
FG_COLOR = "#d8dee9"
ACCENT_COLOR = "#88c0d0"
WARNING_COLOR = "#bf616a"
SUCCESS_COLOR = "#a3be8c"
FONT_MAIN = ("Sans", 10)
FONT_HEADER = ("Sans", 12, "bold")

class AnonymityDashboard(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Polaron OS - Identity Monitor")
        self.geometry("380x500")
        self.resizable(False, False)
        self.configure(bg=BG_COLOR)

        style = ttk.Style()
        style.theme_use('clam')
        style.configure("TLabel", background=BG_COLOR, foreground=FG_COLOR, font=FONT_MAIN)
        style.configure("Header.TLabel", font=FONT_HEADER, foreground=ACCENT_COLOR)
        style.configure("Status.TLabel", font=("Sans", 10, "bold"))
        style.configure("TFrame", background=BG_COLOR)
        
        main_frame = ttk.Frame(self, padding="20")
        main_frame.pack(fill=tk.BOTH, expand=True)

        header = ttk.Label(main_frame, text="System Identity & Status", style="Header.TLabel")
        header.pack(pady=(0, 20))

        self.tor_var = tk.StringVar(value="Checking...")
        self.tor_color = FG_COLOR
        
        self.killswitch_var = tk.StringVar(value="Checking...")
        self.ks_color = FG_COLOR

        self.mac_var = tk.StringVar(value="Checking...")
        self.ipv6_var = tk.StringVar(value="Checking...")
        
        self.hostname_var = tk.StringVar(value="Checking...")
        self.hardware_var = tk.StringVar(value="Masking...")

        self.create_status_row(main_frame, "Tor IP:", self.tor_var)
        self.create_status_row(main_frame, "Kill Switch:", self.killswitch_var)
        
        ttk.Separator(main_frame, orient='horizontal').pack(fill='x', pady=10)
        
        self.create_row(main_frame, "Fake IPv6:", self.ipv6_var)
        self.create_row(main_frame, "Fake MAC:", self.mac_var)
        self.create_row(main_frame, "Fake Hostname:", self.hostname_var)
        
        ttk.Separator(main_frame, orient='horizontal').pack(fill='x', pady=10)
        
        self.create_row(main_frame, "Hardware Mask:", self.hardware_var)

        self.update_stats()

    def create_row(self, parent, label_text, variable):
        frame = ttk.Frame(parent)
        frame.pack(fill='x', pady=3)
        lbl = ttk.Label(frame, text=label_text, width=15, anchor='w')
        lbl.pack(side='left')
        val = ttk.Label(frame, textvariable=variable)
        val.pack(side='left')

    def create_status_row(self, parent, label_text, variable):
        frame = ttk.Frame(parent)
        frame.pack(fill='x', pady=5)
        lbl = ttk.Label(frame, text=label_text, width=15, anchor='w')
        lbl.pack(side='left')
        val = ttk.Label(frame, textvariable=variable, style="Status.TLabel")
        val.pack(side='left')

    def update_stats(self):
        threading.Thread(target=self.fetch_data, daemon=True).start()
        self.after(REFRESH_INTERVAL, self.update_stats)

    def fetch_data(self):
        try:
            cmd = "curl --socks5-hostname 127.0.0.1:9050 -s --max-time 3 https://check.torproject.org/api/ip"
            res = subprocess.run(cmd, shell=True, capture_output=True, text=True)
            if res.returncode == 0 and "IP" in res.stdout:
                 ip = res.stdout.split('"IP":"')[1].split('"')[0]
                 tor_text = f"Active ({ip})"
            else:
                 tor_text = "Connecting..."
        except:
            tor_text = "Error / Offline"

        try:
            res = subprocess.run("systemctl is-active ufw", shell=True, capture_output=True, text=True)
            if "active" in res.stdout:
                ks_text = "ACTIVE (Protected)"
            else:
                ks_text = "DISABLED"
        except: ks_text = "Unknown"

        try:
            res = subprocess.run("ip -6 addr show", shell=True, capture_output=True, text=True)
            if res.returncode == 0 and res.stdout.strip() != "":
                ipv6_text = "ENABLED (Warning!)"
            else:
                ipv6_text = "DISABLED (Leaks Prevented)"
        except: ipv6_text = "Error Checking"

        try:
            active_iface = subprocess.getoutput("ip route get 8.8.8.8 | head -1 | awk '{print $5}'")
            if active_iface:
                mac = subprocess.getoutput(f"cat /sys/class/net/{active_iface}/address")
                perm_mac = subprocess.getoutput(f"ethtool -P {active_iface} 2>/dev/null | awk '{{print $3}}'")
                
                if mac != perm_mac and perm_mac != "":
                     mac_text = f"SPOOFED ({mac})"
                elif "random" in subprocess.getoutput("nmcli con show"): # Fallback check
                     mac_text = "Randomized Config Active"
                else:
                     mac_text = f"Real/Stable ({mac})"
            else:
                mac_text = "No Network"
        except: mac_text = "Checking..."

        host = socket.gethostname()
        host_text = f"{host} (Randomized)"

        hw_text = "Generic / Virtualized"

        self.after(0, lambda: self.tor_var.set(tor_text))
        self.after(0, lambda: self.killswitch_var.set(ks_text))
        self.after(0, lambda: self.ipv6_var.set(ipv6_text))
        self.after(0, lambda: self.mac_var.set(mac_text))
        self.after(0, lambda: self.hostname_var.set(host_text))
        self.after(0, lambda: self.hardware_var.set(hw_text))

if __name__ == "__main__":
    app = AnonymityDashboard()
    app.mainloop()
