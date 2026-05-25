import 'package:flutter/material.dart';
import '../widgets/theme_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  final ThemeColorFlavor colors;

  const PrivacyPolicyScreen({Key? key, required this.colors}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sections = [
      const _SectionData(
        title: "1. Data yang Disimpan di Perangkat",
        body:
            "Catet Uang berfungsi secara offline-first. Semua data utama disimpan lokal di perangkat Kakak:",
        bullets: [
          "Profil (nama, emoji, tema, dan preferensi tampilan).",
          "Catatan transaksi (tanggal, jumlah, kategori, dan catatan singkat).",
          "Preferensi aplikasi seperti pengingat dan pengaturan tampilan.",
        ],
      ),
      const _SectionData(
        title: "2. Data Analitik (Firebase Analytics)",
        body:
            "Jika layanan Google Firebase tersedia dan perangkat terhubung ke internet, aplikasi dapat mengirim data penggunaan untuk meningkatkan kualitas layanan:",
        bullets: [
          "Event penggunaan seperti app_open dan transaksi sukses.",
          "Metadata event transaksi seperti jumlah, kategori, tipe transaksi, catatan singkat, dan waktu.",
          "Informasi perangkat dan aplikasi standar (misalnya jenis perangkat, versi sistem operasi, bahasa, dan ID instalasi).",
        ],
      ),
      const _SectionData(
        title: "3. Cara Penggunaan Data",
        bullets: [
          "Menampilkan ringkasan dan laporan keuangan di aplikasi.",
          "Menyimpan profil serta pengaturan tampilan pilihan Kakak.",
          "Menganalisis penggunaan aplikasi untuk perbaikan fitur dan stabilitas.",
        ],
      ),
      const _SectionData(
        title: "4. Berbagi Data",
        body:
            "Kami tidak menjual atau menyewakan data pribadi. Data analitik yang dikirim ke Firebase diproses oleh Google sesuai Kebijakan Privasi Google.",
      ),
      const _SectionData(
        title: "5. Izin Aplikasi",
        bullets: [
          "Notifikasi: digunakan untuk pengingat pencatatan harian.",
          "Penyimpanan lokal: digunakan untuk menyimpan data transaksi di perangkat.",
        ],
      ),
      const _SectionData(
        title: "6. Kontrol & Penghapusan Data",
        bullets: [
          "Kakak dapat menghapus transaksi atau profil langsung di aplikasi.",
          "Menghapus data aplikasi atau uninstall akan menghapus seluruh data lokal.",
          "Pengelolaan data analitik mengikuti pengaturan privasi perangkat dan layanan Google.",
        ],
      ),
      const _SectionData(
        title: "7. Perubahan Kebijakan",
        body:
            "Kebijakan privasi dapat diperbarui sewaktu-waktu. Perubahan penting akan ditampilkan pada halaman ini.",
      ),
      const _SectionData(
        title: "8. Kontak",
        body:
            "Jika Kakak memiliki pertanyaan, silakan hubungi email pengembang yang tertera pada halaman aplikasi di Play Store.",
      ),
    ];

    return Scaffold(
      backgroundColor: colors.backgroundPolish,
      appBar: AppBar(
        backgroundColor: colors.headerBg,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.brandText),
        title: Text(
          "Kebijakan Privasi",
          style: TextStyle(
            color: colors.brandText,
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.headerBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Terakhir diperbarui: 25 Mei 2026",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Kebijakan ini menjelaskan bagaimana Catet Uang mengelola data saat Kakak menggunakan aplikasi.",
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textPrimary,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              for (final section in sections) _buildSection(section),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(_SectionData section) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.headerBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: colors.brandText,
            ),
          ),
          if (section.body != null) ...[
            const SizedBox(height: 6),
            Text(
              section.body!,
              style: TextStyle(
                fontSize: 12,
                color: colors.textPrimary,
                height: 1.45,
              ),
            ),
          ],
          if (section.bullets.isNotEmpty) ...[
            const SizedBox(height: 8),
            for (final bullet in section.bullets) _buildBullet(bullet),
          ],
        ],
      ),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "• ",
            style: TextStyle(
              fontSize: 12,
              color: colors.textPrimary,
              height: 1.45,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: colors.textPrimary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionData {
  final String title;
  final String? body;
  final List<String> bullets;

  const _SectionData({
    required this.title,
    this.body,
    this.bullets = const [],
  });
}
