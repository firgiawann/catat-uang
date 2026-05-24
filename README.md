# 🪙 Catet Uang — Keuangan Rapi, Pikiran Tenang! ✨

<div align="center">
  <img src="https://raw.githubusercontent.com/andrilistianto/dompet_pintar/main/assets/app_logo_preview.png" alt="Catet Uang App Logo" width="120" style="border-radius: 30px; margin-bottom: 20px; box-shadow: 0 8px 24px rgba(0,0,0,0.12);" onError="this.style.display='none'"/>
  
  <p align="center">
    <strong>Aplikasi pencatat keuangan pribadi yang super imut, ringan, dan 100% offline-first.</strong>
    <br />
    Bebas iklan, bebas pelacakan internet, cepat dibuka, dan didesain dengan visual yang sangat memanjakan mata! 🌸🍃
  </p>

  <p align="center">
    <a href="#-fitur-unggulan-manis">Fitur Unggulan</a> •
    <a href="#-arsitektur--optimasi-ringan">Optimasi Ukuran</a> •
    <a href="#-panduan-instalasi">Instalasi</a> •
    <a href="#-kontribusi">Latar Belakang</a>
  </p>
</div>

---

## 🌸 Tentang Catet Uang

**Catet Uang** adalah proyek kecil hobi pribadi (*passion project*) yang dirancang khusus untuk mempermudah pencatatan transaksi keuangan harian tanpa ribet. Tidak seperti aplikasi keuangan pada umumnya yang berat dan harus login menggunakan server, **Catet Uang** menyimpan seluruh data langsung di dalam ponsel Kakak secara aman menggunakan database lokal SQLite.

Aplikasi ini didesain dengan pendekatan estetik premium yang terinspirasi dari keindahan warna-warna buah dan alam (*Theme Flavors*), ditambah animasi mikro yang halus sehingga proses mencatat uang terasa menyenangkan, bukan menjadi beban! 🧸🥞

---

## 🎨 Fitur Unggulan Manis

### 🍓 1. Multi-Profile & Kustomisasi Instan
* **Interactive Control Pad**: Kakak bisa membuat banyak profil keuangan (misal: "Harian", "Usaha Kecil", atau "Tabungan Liburan").
* **Avatar & Tema Reaktif**: Ubah Emoji Avatar, Mode Tampilan (Sistem, Terang, Gelap), dan **Tema Flavor** langsung dengan sekali ketukan jari di panel profil aktif. Aplikasi langsung berubah warna dalam sekejap!
* **Inline Name Editor**: Ganti nama profil secara aman dengan form teks terintegrasi langsung di tempat (*inline*).

### 🍵 2. 8 Tema Flavor Indah & Visual Premium
Tersedia 8 kombinasi palet warna manis yang sangat memukau:
* 🍓 **Strawberry**: Palet merah muda cerah yang romantis dan manis.
* 🍵 **Matcha**: Nuansa hijau daun teh yang menenangkan dan sejuk.
* 🌊 **Ocean**: Biru laut yang segar dan luas.
* 🪻 **Lavender**: Ungu pastel yang elegan dan damai.
* 🧱 **Terracotta**: Jingga bata yang hangat dan bersahaja.
* 🍯 **Amber**: Kuning madu yang cerah dan penuh energi.
* 🌸 **Sakura**: Merah muda kelopak bunga yang lembut.
* 🖤 **Charcoal**: Abu-abu monokromatik modern nan premium.

### 🏆 3. Sistem Lencana & Misi Hemat (Gamifikasi)
Mencatat keuangan jadi seru layaknya bermain game! Aplikasi ini memiliki **16 Lencana Milestone** unik yang terbagi dalam 4 kategori:
* **🌱 Pemula Hemat**: Langkah Pertama (catat perdana), Disiplin Pagi, Seimbang (masuk & keluar), dan Set Target anggaran.
* **🔥 Pejuang Hemat**: Rajin Mencatat (5x), Juara Hemat (sisa anggaran ≥30%), Ahli Keuangan (15x), dan Saldo Positif.
* **📅 Komitmen Hemat**: Lencana konsistensi hari aktif (2, 5, 7, hingga 30 hari penggunaan secara nyata).
* **🌟 Misi Misterius (Easter Eggs)**: Misi rahasia dengan judul tersembunyi yang hanya akan terbuka saat Kakak memicu kondisi tertentu (seperti mencatat tepat tengah malam, subuh hari, menyisakan anggaran ≥80%, atau mengumpulkan omzet pemasukan besar!).

### 📈 4. Ringkasan Keuangan & Donut Chart
* Tampilan **Donut Chart** interaktif yang secara dinamis memetakan persentase pengeluaran harian dan bulanan berdasarkan kategori secara intuitif.
* Ringkasan saldo berjalan, target pengeluaran bulanan, dan sisa limit anggaran yang terhitung otomatis.

### 🔔 5. Pengingat Ramah & Widget sinkronisasi
* **Daily Reminder**: Aplikasi akan mengirim notifikasi pengingat secara ramah 2 kali sehari (Siang & Malam) dengan pesan santun yang diacak agar dompet Kakak tetap terjaga rapi.
* **Smart Home Widget**: Widget layar utama yang terintegrasi penuh untuk memantau rekap saldo secara instan tanpa perlu membuka aplikasi.

---

## ⚡ Arsitektur & Optimasi Ringan

Untuk menjaga performa aplikasi ini tetap mulus dan berukuran sekecil mungkin di ponsel Kakak, proses build dilakukan dengan teknik **Obfuscation (Penyandian Kode)** dan **Symbol Stripping (Penghapusan Simbol Debug)** menggunakan optimasi R8/Proguard:

* **Universal APK (`app-release.apk`)**: Mengandung seluruh arsitektur biner, siap diinstal di ponsel Android mana saja.
* **Architecture-Specific Splits**: Dipisah menjadi 3 file APK yang sangat kecil untuk meminimalkan memori penyimpanan:
  1. **`app-armeabi-v7a-release.apk` (~15.0 MB)**: Sangat ringan, optimal untuk ponsel Android 32-bit.
  2. **`app-arm64-v8a-release.apk` (~17.4 MB)**: Super cepat, optimal untuk mayoritas ponsel Android 64-bit modern.
  3. **`app-x86_64-release.apk` (~18.8 MB)**: Optimal untuk laptop/komputer emulasi.

---

## 🛠️ Panduan Instalasi

### Prasyarat
Sebelum memulai, pastikan Kakak telah menginstal:
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (versi 3.10 ke atas direkomendasikan)
* [Android SDK / Android Studio](https://developer.android.com/)

### Langkah Menjalankan Kode
1. **Klon Repositori ini:**
   ```bash
   git clone https://github.com/username/dompet_pintar.git
   cd dompet_pintar
   ```
2. **Dapatkan Dependensi Paket:**
   ```bash
   flutter pub get
   ```
3. **Jalankan Aplikasi dalam Mode Debug:**
   ```bash
   flutter run
   ```

### Cara Build APK Ringan Sendiri
Gunakan perintah berikut untuk menghasilkan APK yang sudah teroptimasi penuh:
* **Untuk Universal APK tunggal:**
  ```bash
  flutter build apk --release --obfuscate --split-debug-info=build/app/symbols
  ```
* **Untuk APK Terpisah per Arsitektur (Hemat ruang):**
  ```bash
  flutter build apk --release --obfuscate --split-debug-info=build/app/symbols --split-per-abi
  ```

---

## 📂 Struktur File APK Hasil Build

File APK release yang siap diinstal terletak pada folder berikut setelah kompilasi berhasil:
* **Universal APK**: `build/app/outputs/flutter-apk/app-release.apk`
* **Split ABI (Lightweight)**: `build/app/outputs/flutter-apk/app-[arsitektur]-release.apk`

---

## ☕ Latar Belakang Proyek

Aplikasi **Catet Uang** didevelop murni sebagai hobi pribadi untuk menyalurkan kesenangan dalam mendesain antarmuka pengguna yang bersih, fungsional, dan menyenangkan. Keuangan harian seringkali rumit, namun dengan alat bantu yang dirancang dengan cinta dan kesederhanaan, mengelola uang bisa menjadi kebiasaan kecil yang manis setiap harinya. 🍀🌻

*Terima kasih telah berkunjung, semoga aplikasi kecil ini dapat membantu menjaga dompet Kakak tetap tersenyum ramah!* 😉👋
