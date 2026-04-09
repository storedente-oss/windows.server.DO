#!/bin/bash

# Konfigurasi File
IMG_FILE="windows10.img"
NEW_DISK_SIZE="115G"  # Sisakan sedikit dari 120GB agar host tetap stabil
NEW_RAM_SIZE="14G"    # Sisakan 2GB untuk Ubuntu Server

echo "--- Tahap 1: Memperbesar File Image ke $NEW_DISK_SIZE ---"
if [ -f "$IMG_FILE" ]; then
    qemu-img resize "$IMG_FILE" "$NEW_DISK_SIZE"
    echo "Resize file image berhasil!"
else
    echo "Error: File $IMG_FILE tidak ditemukan!"
    exit 1
fi

echo "--- Tahap 2: Menjalankan VM dengan Spek Baru ($NEW_RAM_SIZE RAM) ---"
# Menjalankan di background (daemonize)
qemu-system-x86_64 \
  -m $NEW_RAM_SIZE \
  -smp sockets=1,cores=2,threads=1 \
  -cpu host,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time \
  -enable-kvm \
  -drive file=$IMG_FILE,format=raw,if=virtio \
  -netdev user,id=net0,hostfwd=tcp::3389-:3389 \
  -device virtio-net-pci,netdev=net0 \
  -device usb-ehci,id=usb \
  -device usb-tablet \
  -vnc :0 \
  -daemonize

echo "--- Selesai! ---"
echo "VM sekarang berjalan dengan RAM $NEW_RAM_SIZE."
echo "Sekarang silakan masuk ke Windows via RDP untuk extend partisi Disk."
