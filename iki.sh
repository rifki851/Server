#!/bin/bash

echo "Mengecek koneksi internet..."
ping 8.8.8.8

if [ $? -eq 0 ]; then
    echo "Internet terhubung."
else
    echo "Tidak ada koneksi internet."
fi
