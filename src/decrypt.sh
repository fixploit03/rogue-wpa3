#!/bin/bash
#
# Decrypt trafik Wi-Fi OWE (Opportunistic Wireless Encryption) menggunakan kunci TK
# Dibuat oleh: Rofi (Fixploit03)

set -e

# cek jumlah argumen
if [[ "${#}" -ne 2 ]]; then
	echo "Usage: $0 <file_capture> <kunci_tk>"
	exit 1
fi

# konfigurasi
file_capture="${1}"
kunci_tk="${2}"
ekstensi="${file_capture##*.}"
output=$(basename "${file_capture}")
output="${output%.*}-dec.${ekstensi}"

# validasi keberadaan file capture
if [[ ! -f "${file_capture}" ]]; then
	echo "ERROR: File '${file_capture}' tidak ditemukan!"
	exit 1
fi

# validasi ekstensi file capture
case "${file_capture}" in
	*.cap|*.pcap|*.pcapng)
        	;;
	*)
		echo "ERROR: File '${file_capture}' bukan file capture!"
		exit 1
	;;
esac

# validasi kunci tk
if [[ "${#kunci_tk}" -ne 32 || ! "${kunci_tk}" =~ ^[0-9A-Fa-f]+$ ]]; then
	echo "ERROR: Kunci TK '${kunci_tk}' tidak valid!"
	exit 1
fi

# ngedecrypt file capture
echo "[*] Ngedecrypt file capture '${file_capture}'..."

if tshark -r "${file_capture}" -o wlan.enable_decryption:TRUE -o "uat:80211_keys:\"tk\",\"${kunci_tk}\"" -w "${output}"; then
	echo "[+] File capture '${file_capture}' berhasil didecrypt."
	echo "[+] Disimpan di: ${output}"
	exit 0
else
	echo "[-] Gagal ngedecrypt file capture '${file_capture}'!"
	exit 1
fi
