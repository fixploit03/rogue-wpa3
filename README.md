![](https://github.com/fixploit03/rogue-wpa3/blob/main/wireshark.png)

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

Gunakan dengan bijak 🗿
