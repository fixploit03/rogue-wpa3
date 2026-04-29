# Rogue OWE

<img src="https://github.com/fixploit03/rogue-owe/blob/main/img/ilustrasi.ng" width="800"/>

Decrypt trafik Wi-Fi OWE (Opportunistic Wireless Encryption) menggunakan kunci TK. 

## Cara Menggunakan
1. Jalankan Rogue AP
2. Capture trafik
3. Copy nilai kunci TK
4. Buka Wireshark
5. Decrypt
   
## Cara Decrypt
1. Buka file capture
2. Klik menu `Edit` ⟶ `Preferences` ⟶ `Protocols` ⟶ `IEEE 802.11`
3. Centang box `Enable decryption`
4. Klik `Edit`
5. Klik `+`
6. Untuk `Key type` pilih `tk`
7. Masukkan nilai kunci TK yang ada di `rogue_wpa3.sh` di kolom `Key`
8. Klik `OK`
9. Klik `Apply`

## Screenshot

<img src="https://github.com/fixploit03/rogue-owe/blob/main/img/wireshark.png" width="800"/>

## Referensi
- [Wi-Fi CERTIFIED Enhanced Open™](https://www.wi-fi.org/beacon/dan-harkins/wi-fi-certified-enhanced-open-transparent-wi-fi-protections-without-complexity)
- [RFC 8110 Opportunistic Wireless Encryption](https://www.rfc-editor.org/rfc/rfc8110.html)
- [Pertukaran kunci Diffie–Hellman](https://id.wikipedia.org/wiki/Pertukaran_kunci_Diffie%E2%80%93Hellman)
