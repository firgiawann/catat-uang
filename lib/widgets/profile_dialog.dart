import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/budget_provider.dart';
import 'theme_colors.dart';

class ProfileDialog extends StatefulWidget {
  final ThemeColorFlavor colors;

  const ProfileDialog({Key? key, required this.colors}) : super(key: key);

  @override
  State<ProfileDialog> createState() => _ProfileDialogState();
}

class _ProfileDialogState extends State<ProfileDialog> {
  final _createFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  // Active Profile Editing states
  late TextEditingController _editNameController;

  final List<String> _emojis = const ["🐱", "🐻", "🐰", "🐼", "🐸", "🦊"];
  final List<String> _flavors = const [
    "Strawberry",
    "Matcha",
    "Ocean",
    "Lavender",
    "Charcoal",
    "Amber",
    "Terracotta",
    "Sakura"
  ];
  final List<String> _themeModes = const ["Sistem", "Terang", "Gelap"];

  bool _isEditingName = false;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<BudgetProvider>(context, listen: false);
    final active = provider.activeProfile;
    _editNameController = TextEditingController(text: active?.name ?? "");
  }

  @override
  void dispose() {
    _nameController.dispose();
    _editNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BudgetProvider>(context);
    final allProfiles = provider.allProfiles;
    final activeProfile = provider.activeProfile;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Kelola Profil & Tema",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: widget.colors.brandText,
              ),
            ),
            const SizedBox(height: 16),

            // Profile List Section
            Text(
              "Pilih Profil Aktif:",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: widget.colors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 180),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemCount: allProfiles.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final p = allProfiles[index];
                  final isActive = p.id == activeProfile?.id;
                  final pFlavors = getThemeColorFlavor(p.themeFlavor);

                  return Container(
                    decoration: BoxDecoration(
                      color: isActive ? widget.colors.headerBg : widget.colors.backgroundPolish,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isActive ? widget.colors.accent : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      onTap: () {
                        provider.selectProfile(p.id!);
                        setState(() {
                          _isEditingName = false;
                          _editNameController.text = p.name;
                        });
                      },
                      leading: CircleAvatar(
                        radius: 18,
                        backgroundColor: pFlavors.lightAccent.withOpacity(0.4),
                        child: Text(p.emoji, style: const TextStyle(fontSize: 18)),
                      ),
                      title: Text(
                        p.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isActive ? widget.colors.brandText : widget.colors.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        "${p.themeFlavor} • Mode: ${p.themeMode}",
                        style: TextStyle(
                          fontSize: 11,
                          color: widget.colors.textSecondary,
                        ),
                      ),
                      trailing: allProfiles.length > 1
                          ? IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: amountRed, size: 20),
                              onPressed: () {
                                _showDeleteConfirmDialog(p.id!, p.name, provider);
                              },
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
            // Active Profile Settings Editor
            if (activeProfile != null) ...[
              Text(
                "Pengaturan Profil Aktif:",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: widget.colors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: widget.colors.backgroundPolish,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: widget.colors.border.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Inline Name Editor
                    Row(
                      children: [
                        Text(
                          activeProfile.emoji,
                          style: const TextStyle(fontSize: 26),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _isEditingName
                              ? Form(
                                  key: _createFormKey, // Reusing formkey for name validation
                                  child: TextFormField(
                                    controller: _editNameController,
                                    autofocus: true,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: widget.colors.textPrimary,
                                    ),
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      isDense: true,
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(color: widget.colors.accent),
                                      ),
                                    ),
                                    validator: (val) {
                                      if (val == null || val.trim().isEmpty) {
                                        return "Nama tidak boleh kosong";
                                      }
                                      return null;
                                    },
                                  ),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      activeProfile.name,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                        color: widget.colors.brandText,
                                      ),
                                    ),
                                    Text(
                                      "Tema Flavor: ${activeProfile.themeFlavor} (${activeProfile.themeMode})",
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: widget.colors.textSecondary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                        const SizedBox(width: 8),
                        if (_isEditingName) ...[
                          IconButton(
                            icon: const Icon(Icons.check_rounded, color: amountGreen, size: 22),
                            onPressed: () {
                              if (_createFormKey.currentState!.validate()) {
                                provider.updateProfile(
                                  activeProfile.id!,
                                  _editNameController.text.trim(),
                                  activeProfile.emoji,
                                  activeProfile.themeFlavor,
                                  activeProfile.themeMode,
                                );
                                setState(() {
                                  _isEditingName = false;
                                });
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: amountRed, size: 22),
                            onPressed: () {
                              setState(() {
                                _editNameController.text = activeProfile.name;
                                _isEditingName = false;
                              });
                            },
                          ),
                        ] else ...[
                          IconButton(
                            icon: Icon(Icons.edit_rounded, color: widget.colors.accent, size: 20),
                            onPressed: () {
                              setState(() {
                                _editNameController.text = activeProfile.name;
                                _isEditingName = true;
                              });
                            },
                          ),
                        ]
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 12),

                    // Edit Emoji Selector (Direct update!)
                    const Text(
                      "Ubah Emoji Avatar (Langsung Ganti):",
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: _emojis.map((emoji) {
                        final isSel = activeProfile.emoji == emoji;
                        return GestureDetector(
                          onTap: () {
                            provider.updateProfile(
                              activeProfile.id!,
                              activeProfile.name,
                              emoji,
                              activeProfile.themeFlavor,
                              activeProfile.themeMode,
                            );
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isSel ? widget.colors.headerBg : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSel ? widget.colors.accent : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Text(emoji, style: const TextStyle(fontSize: 20)),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // Edit Flavor Selector (Direct update!)
                    const Text(
                      "Ubah Tema Flavor (Langsung Ganti):",
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _flavors.map((flavor) {
                        final isSel = activeProfile.themeFlavor == flavor;
                        final flColors = getThemeColorFlavor(flavor);
                        return InkWell(
                          onTap: () {
                            provider.updateProfile(
                              activeProfile.id!,
                              activeProfile.name,
                              activeProfile.emoji,
                              flavor,
                              activeProfile.themeMode,
                            );
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSel ? flColors.headerBg : flColors.backgroundPolish,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSel ? flColors.accent : flColors.border.withOpacity(0.5),
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              flavor,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: flColors.brandText,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // Theme Mode Selection Row (Direct update!)
                    const Text(
                      "Ubah Mode Tampilan (Langsung Ganti):",
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: _themeModes.map((mode) {
                        final isSel = activeProfile.themeMode == mode;
                        return ChoiceChip(
                          label: Text(mode, style: const TextStyle(fontSize: 10)),
                          selected: isSel,
                          selectedColor: widget.colors.accent,
                          labelStyle: TextStyle(
                            color: isSel ? Colors.white : widget.colors.brandText,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              provider.updateProfile(
                                activeProfile.id!,
                                activeProfile.name,
                                activeProfile.emoji,
                                activeProfile.themeFlavor,
                                mode,
                              );
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),

            // Profile Creation Trigger Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.colors.accent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
              ),
              icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 18),
              label: const Text(
                "Tambah Profil Baru ＋",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              onPressed: () {
                _showCreateProfileDialog(context, provider);
              },
            ),

            if (activeProfile != null) ...[
              const SizedBox(height: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: amountRed,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                ),
                icon: const Icon(Icons.delete_forever_rounded, color: Colors.white, size: 16),
                label: Text(
                  "Hapus Profil '${activeProfile.name}' 🗑️",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
                onPressed: () {
                  _showDeleteConfirmDialog(activeProfile.id!, activeProfile.name, provider);
                },
              ),
            ],
            const SizedBox(height: 16),

            OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: BorderSide(color: widget.colors.border),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Tutup",
                style: TextStyle(
                  color: widget.colors.textSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(int profileId, String profileName, BudgetProvider provider) {
    // Pop up Ke-1: Menanyakan konfirmasi & menjelaskan resiko
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: amountRed, size: 24),
              const SizedBox(width: 8),
              Text(
                "Hapus Profil? ⚠️",
                style: TextStyle(fontWeight: FontWeight.bold, color: widget.colors.brandText, fontSize: 16),
              ),
            ],
          ),
          content: Text(
            "Apakah Kakak benar-benar yakin ingin menghapus profil '$profileName'?\n\nResiko Tindakan Ini:\n• Seluruh riwayat transaksi Kakak akan DIHAPUS PERMANEN.\n• Batasan limit anggaran bulanan akan disetel ulang.\n• Tindakan ini 100% offline dan TIDAK BISA DIBATALKAN!",
            style: const TextStyle(fontSize: 13, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Batal", style: TextStyle(color: widget.colors.accent, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: amountRed,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.pop(context); // Close Popup 1
                _showSecondDeleteVerification(profileId, profileName, provider); // Open Popup 2
              },
              child: const Text("Lanjut Hapus ➡️", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showSecondDeleteVerification(int profileId, String profileName, BudgetProvider provider) {
    final deleteNameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            "Verifikasi Terakhir 🛡️",
            style: TextStyle(fontWeight: FontWeight.bold, color: widget.colors.brandText, fontSize: 16),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Untuk mengonfirmasi penghapusan, silakan ketik nama profil tepat di bawah ini:\n\nKetik \"$profileName\" untuk menghapus profil.",
                  style: const TextStyle(fontSize: 12, height: 1.4),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: deleteNameController,
                  autofocus: true,
                  style: TextStyle(fontSize: 13, color: widget.colors.textPrimary, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: "Ketik nama tanpa tanda kutip",
                    hintStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: amountRed, width: 1.5),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim() != profileName) {
                      return "Nama tidak cocok Kak! 📝";
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Batal", style: TextStyle(color: widget.colors.accent, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: amountRed,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  provider.deleteProfile(profileId);
                  Navigator.pop(context); // Close Popup 2
                  Navigator.pop(context); // Close main profile dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Profil '$profileName' berhasil dihapus seutuhnya! 🧹")),
                  );
                }
              },
              child: const Text("YA, HAPUS SEKARANG", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showCreateProfileDialog(BuildContext context, BudgetProvider provider) {
    final formKey = GlobalKey<FormState>();
    final newNameController = TextEditingController();
    String newEmoji = "🐱";
    String newFlavor = "Strawberry";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text(
                "Buat Profil Baru 🆕",
                style: TextStyle(fontWeight: FontWeight.bold, color: widget.colors.brandText, fontSize: 16),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: newNameController,
                        style: TextStyle(fontSize: 13, color: widget.colors.textPrimary),
                        decoration: InputDecoration(
                          labelText: "Nama Profil Baru",
                          labelStyle: TextStyle(color: widget.colors.accent),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: widget.colors.accent),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Nama profil tidak boleh kosong";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Emoji Selector
                      const Text("Pilih Emoji Avatar:", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: _emojis.map((emoji) {
                          final isSel = newEmoji == emoji;
                          return GestureDetector(
                            onTap: () => setDialogState(() => newEmoji = emoji),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isSel ? widget.colors.headerBg : Colors.transparent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSel ? widget.colors.accent : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Text(emoji, style: const TextStyle(fontSize: 18)),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),

                      // Theme Flavor Selector
                      const Text("Tema Flavor:", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _flavors.map((flavor) {
                          final isSel = newFlavor == flavor;
                          final flColors = getThemeColorFlavor(flavor);
                          return InkWell(
                            onTap: () => setDialogState(() => newFlavor = flavor),
                            borderRadius: BorderRadius.circular(8),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSel ? flColors.headerBg : flColors.backgroundPolish,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSel ? flColors.accent : flColors.border.withOpacity(0.5),
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                flavor,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: flColors.brandText,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Batal", style: TextStyle(color: widget.colors.textSecondary, fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.colors.accent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      provider.createProfile(
                        newNameController.text.trim(),
                        newEmoji,
                        newFlavor,
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Profil baru berhasil ditambahkan! ✨")),
                      );
                    }
                  },
                  child: const Text("Buat Profil ＋", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
