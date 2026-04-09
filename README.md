
## Langkah-langkah Instalasi

### 1. Unduh dan Instal File Installer
Jalankan perintah berikut untuk mengunduh installer:

```bash
wget https://raw.githubusercontent.com/storedente-oss/windows.server.DO/main/windows-server-autoinstaller.sh

```

### 2. Berikan Izin Eksekusi pada File
Setelah diunduh, berikan izin agar file dapat dijalankan:

```bash
chmod +x windows-server-autoinstaller.sh

```

### 3. Jalankan Installer
Jalankan installer dengan perintah berikut:

```bash
./windows-server-autoinstaller.sh

```

### 4. Jalankan QEMU
Setelah installer selesai, jalankan QEMU untuk memulai Windows Server. Ganti `xx` dengan versi Windows yang Anda pilih (misal, `windows10`):

```bash
qemu-system-x86_64 \
-m 4G \
-cpu host \
-enable-kvm \
-boot order=d \
-drive file=windowsxx.iso,media=cdrom \
-drive file=windowsxx.img,format=raw,if=virtio \
-drive file=virtio-win.iso,media=cdrom \
-device usb-ehci,id=usb,bus=pci.0,addr=0x4 \
-device usb-tablet \
-vnc :0


```

**Catatan: Tekan Enter dua kali untuk melanjutkan.**

### 5. Akses via VNC
Setelah QEMU berjalan, ikuti langkah berikut untuk mengakses dan mengonfigurasi Windows Server:

1. Aktifkan **Remote Desktop** di pengaturan Windows Server.
2. Nonaktifkan **CTRL+ALT+DEL** di Local Security.
3. Atur agar Windows Server **tidak pernah tidur**.

### Jika VNC tidak bisa di akses
Buka firewall ufw untuk port 5900 nya dulu :

```bash
# Check apakah Firewall UFW active
sudo ufw status

# Jika belum aktifkan telebih dahulu
sudo ufw enable

# Lalu aktifkan port 5900
sudo ufw allow 5900/tcp

# Reload firewall
sudo ufw reload

```


### 6. Buat script run automatis qemu
Untuk menjalankan service qemu di server secara otomatis agar bisa di remote oleh local RDP windows, jalankan perintah ini :

### Buat script file baru

```bash
sudo nano run_windows.sh

```

### Copy & paste script ini
Ganti `xxxx`dengan versi Windows yang Anda pilih (misal, `windows10`):

```bash
#!/bin/bash

# Pastikan nama file image dan ISO sesuai dengan hasil download script sebelumnya
IMG_FILE="windowsxxxx.img"
WIN_ISO="windowsxxxx.iso"
VIRTIO_ISO="virtio-win.iso"

qemu-system-x86_64 \
  -m 4G \
  -smp 2,sockets=1,cores=2,threads=1 \
  -cpu host,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time \
  -enable-kvm \
  -drive file=$IMG_FILE,format=raw,if=virtio \
  -drive file=$WIN_ISO,index=1,media=cdrom \
  -drive file=$VIRTIO_ISO,index=2,media=cdrom \
  -netdev user,id=net0,hostfwd=tcp::3389-:3389 \
  -device virtio-net-pci,netdev=net0 \
  -device usb-ehci,id=usb \
  -device usb-tablet \
  -vnc :0 \
  -daemonize

echo "VM Windows sedang berjalan di background."
echo "Silakan akses VNC di port 5900 untuk instalasi awal."
echo "Setelah instalasi driver & RDP selesai, akses via RDP di port 3389."

```

### Berikan izin agar file dapat dijalankan:

```bash
chmod +x run_windows.sh

```

### Jalankan installer dengan perintah berikut:

```bash
./run_windows.sh

```

### Buka Port RDP di Ubuntu

```bash
sudo ufw allow 3389/tcp
sudo ufw reload

```

### 7. Kompres File Windows Server
Setelah konfigurasi selesai, kompres image Windows Server. Ganti `xxxx` dengan versi Windows yang Anda pilih (misal, `windows10`):

```bash
dd if=windowsxxxx.img | gzip -c > windowsxxxx.gz

```

### 8. Instal Apache
Instal Apache untuk melayani file melalui web:

```bash
apt install apache2 -y

```

### 9. Berikan Akses Firewall untuk Apache
Izinkan akses Apache melalui firewall:

```bash
sudo ufw allow 'Apache'

```

### 10. Pindahkan File Windows Server ke Lokasi Web
Salin file Windows Server yang sudah dikompres ke direktori web Apache:

```bash
cp windowsxxxx.gz /var/www/html/

```

### 11. Link Download
Setelah file dipindahkan, akses file tersebut melalui alamat IP droplet Anda:

```
http://[IP_Droplet]/windowsxxxx.gz

```

**Contoh:**
```
http://188.166.190.241/windows10.gz

```

## Menjalankan Windows Server di Droplet Baru

Untuk menjalankan Windows Server di droplet baru, gunakan perintah berikut. Ganti `LINK` dengan link unduhan file yang sudah dikompres sebelumnya:

```bash
wget -O- --no-check-certificate LINK | gunzip | dd of=/dev/vda

```
## Upload File Windows Dari server Langsung ke Gdrive
Perintah ini menggunakan rclone, jadi pastikan dulu install rclone dan atur config di server lalu sambungkan ke Gdrive

**Cek Isi Folder**
```bash
ls -l /var/www/html/winser/

```
**Perintah Upload**
```
rclone copy /var/www/html/winser/windows2019.gz gdrive: --progress

```
### Catatan Penting:
- Pastikan Anda mengganti placeholder `xxxx` dengan versi Windows yang benar.
- Jangan lupa untuk mengganti `LINK` dengan URL file Anda yang sebenarnya.
