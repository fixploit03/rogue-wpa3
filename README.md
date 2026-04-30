# Rogue OWE

<img src="https://github.com/fixploit03/rogue-owe/blob/main/img/rogue%20owe.png" width=800/>

`Rogue OWE` adalah script Bash sederhana yang dirancang untuk membuat [Rogue AP](https://en.wikipedia.org/wiki/Rogue_access_point) dengan keamanan [OWE (Opportunistic Wireless Encryption)](https://en.wikipedia.org/wiki/Opportunistic_Wireless_Encryption).

Tujuan dari Rogue AP ini adalah mengekstrak _PMK (Pairwise Master Key)_ milik client yang terhubung, yang diperoleh dari log `hostapd` selama proses handshake OWE berlangsung. PMK tersebut kemudian dapat digunakan untuk mendekripsi trafik Wi-Fi yang terenkripsi.

> [!WARNING]
> **DISCLAIMER!**
> 
> Script ini dibuat untuk tujuan edukasi dan penelitian keamanan jaringan.

## Referensi
- [Wi-Fi CERTIFIED Enhanced Open™](https://www.wi-fi.org/beacon/dan-harkins/wi-fi-certified-enhanced-open-transparent-wi-fi-protections-without-complexity)
- [RFC 8110 Opportunistic Wireless Encryption](https://www.rfc-editor.org/rfc/rfc8110.html)
- [Pertukaran kunci Diffie–Hellman](https://id.wikipedia.org/wiki/Pertukaran_kunci_Diffie%E2%80%93Hellman)
- [WPA Key Hierarchy Explained](https://networklessons.com/wireless/wpa-key-hierarchy-explained)
- [hostapd: IEEE 802.11 AP, IEEE 802.1X/WPA/WPA2/WPA3/EAP/RADIUS Authenticator](https://w1.fi/hostapd/)
- [IEEE 802.11 WLAN Decryption Keys](https://www.wireshark.org/docs/wsug_html_chunked/Ch80211Keys.html)
