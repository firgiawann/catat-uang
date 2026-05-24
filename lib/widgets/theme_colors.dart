import 'package:flutter/material.dart';

class ThemeColorFlavor {
  final Color backgroundPolish;
  final Color headerBg;
  final Color accent;
  final Color brandText;
  final Color textPrimary;
  final Color textSecondary;
  final Color bottomNavBg;
  final Color border;
  final Color progressTrack;
  final Color lightAccent;

  const ThemeColorFlavor({
    required this.backgroundPolish,
    required this.headerBg,
    required this.accent,
    required this.brandText,
    required this.textPrimary,
    required this.textSecondary,
    required this.bottomNavBg,
    required this.border,
    required this.progressTrack,
    required this.lightAccent,
  });
}

// Special Global Colors
const Color amountRed = Color(0xFFE57373);
const Color amountGreen = Color(0xFF6FBF84);
const Color softGreen = Color(0xFFF0F9F4);
const Color softGreenText = Color(0xFF3B8F55);
const Color softRed = Color(0xFFFFF7F7);
const Color softRedText = Color(0xFFD35C5E);

// Flavor Definitions
const strawberryLight = ThemeColorFlavor(
  backgroundPolish: Color(0xFFFCF6F6),
  headerBg: Color(0xFFFADCDD),
  accent: Color(0xFFE07A7C),
  brandText: Color(0xFF6D3C3E),
  textPrimary: Color(0xFF2D1E1F),
  textSecondary: Color(0xFF9E7778),
  bottomNavBg: Color(0xFFFDF0F1),
  border: Color(0xFFF5D0D2),
  progressTrack: Color(0xFFFCECED),
  lightAccent: Color(0xFFED9D9E),
);

const strawberryDark = ThemeColorFlavor(
  backgroundPolish: Color(0xFF1D1717),
  headerBg: Color(0xFF2A2020),
  accent: Color(0xFFE58789),
  brandText: Color(0xFFFAD7D8),
  textPrimary: Color(0xFFFAF3F3),
  textSecondary: Color(0xFFB39293),
  bottomNavBg: Color(0xFF1D1717),
  border: Color(0xFF3D2E2E),
  progressTrack: Color(0xFF2A2020),
  lightAccent: Color(0xFFEA9A9B),
);

const matchaLight = ThemeColorFlavor(
  backgroundPolish: Color(0xFFF5F8F5),
  headerBg: Color(0xFFDCEADD),
  accent: Color(0xFF668C6F),
  brandText: Color(0xFF2B4231),
  textPrimary: Color(0xFF1E2820),
  textSecondary: Color(0xFF75937B),
  bottomNavBg: Color(0xFFF1F6F1),
  border: Color(0xFFD2E3D4),
  progressTrack: Color(0xFFEAF1EB),
  lightAccent: Color(0xFF8FBA98),
);

const matchaDark = ThemeColorFlavor(
  backgroundPolish: Color(0xFF131915),
  headerBg: Color(0xFF1C2720),
  accent: Color(0xFF86AC8E),
  brandText: Color(0xFFD4E5D8),
  textPrimary: Color(0xFFF2F7F4),
  textSecondary: Color(0xFF96B09D),
  bottomNavBg: Color(0xFF131915),
  border: Color(0xFF2F3C34),
  progressTrack: Color(0xFF1C2720),
  lightAccent: Color(0xFF9EC1A6),
);

const oceanLight = ThemeColorFlavor(
  backgroundPolish: Color(0xFFF3F7FA),
  headerBg: Color(0xFFD3E5F3),
  accent: Color(0xFF5F8BB0),
  brandText: Color(0xFF264057),
  textPrimary: Color(0xFF1E2C3A),
  textSecondary: Color(0xFF7499B8),
  bottomNavBg: Color(0xFFEEF3F8),
  border: Color(0xFFC8DCED),
  progressTrack: Color(0xFFEAF1F7),
  lightAccent: Color(0xFF82A6C5),
);

const oceanDark = ThemeColorFlavor(
  backgroundPolish: Color(0xFF111721),
  headerBg: Color(0xFF1A2332),
  accent: Color(0xFF80A6C7),
  brandText: Color(0xFFD4E5F2),
  textPrimary: Color(0xFFF0F5FA),
  textSecondary: Color(0xFF93ABB9),
  bottomNavBg: Color(0xFF111721),
  border: Color(0xFF2A3749),
  progressTrack: Color(0xFF1A2332),
  lightAccent: Color(0xFF94BBE0),
);

const lavenderLight = ThemeColorFlavor(
  backgroundPolish: Color(0xFFF7F5FC),
  headerBg: Color(0xFFEADDF7),
  accent: Color(0xFF8A6C9B),
  brandText: Color(0xFF432C52),
  textPrimary: Color(0xFF2E1E38),
  textSecondary: Color(0xFF9A82A8),
  bottomNavBg: Color(0xFFF3EEFA),
  border: Color(0xFFE2CDF2),
  progressTrack: Color(0xFFF1EBF7),
  lightAccent: Color(0xFFA78BB8),
);

const lavenderDark = ThemeColorFlavor(
  backgroundPolish: Color(0xFF17131B),
  headerBg: Color(0xFF241D2B),
  accent: Color(0xFFA389B3),
  brandText: Color(0xFFE7DBED),
  textPrimary: Color(0xFFFAF2FD),
  textSecondary: Color(0xFFABA0B2),
  bottomNavBg: Color(0xFF17131B),
  border: Color(0xFF372D40),
  progressTrack: Color(0xFF241D2B),
  lightAccent: Color(0xFFBCAAD4),
);

const charcoalLight = ThemeColorFlavor(
  backgroundPolish: Color(0xFFF3F4F6),
  headerBg: Color(0xFFE2E4E8),
  accent: Color(0xFF6A7382),
  brandText: Color(0xFF2C323E),
  textPrimary: Color(0xFF1F242C),
  textSecondary: Color(0xFF838C98),
  bottomNavBg: Color(0xFFECEEF2),
  border: Color(0xFFDBDFE4),
  progressTrack: Color(0xFFEBEDF0),
  lightAccent: Color(0xFF959EA9),
);

const charcoalDark = ThemeColorFlavor(
  backgroundPolish: Color(0xFF181A1D),
  headerBg: Color(0xFF23272C),
  accent: Color(0xFF9BA4B0),
  brandText: Color(0xFFE1E5E9),
  textPrimary: Color(0xFFF1F4F6),
  textSecondary: Color(0xFF9199A3),
  bottomNavBg: Color(0xFF181A1D),
  border: Color(0xFF373D45),
  progressTrack: Color(0xFF23272C),
  lightAccent: Color(0xFFABF4F6),
);

const amberLight = ThemeColorFlavor(
  backgroundPolish: Color(0xFFFAF7EE),
  headerBg: Color(0xFFF6EAD1),
  accent: Color(0xFFC29B53),
  brandText: Color(0xFF5C471E),
  textPrimary: Color(0xFF342813),
  textSecondary: Color(0xFF9B8258),
  bottomNavBg: Color(0xFFF6EFE0),
  border: Color(0xFFECDDBB),
  progressTrack: Color(0xFFF8F3E5),
  lightAccent: Color(0xFFD1B781),
);

const amberDark = ThemeColorFlavor(
  backgroundPolish: Color(0xFF19140C),
  headerBg: Color(0xFF251F14),
  accent: Color(0xFFCBAB70),
  brandText: Color(0xFFEAD9BE),
  textPrimary: Color(0xFFFAF4EB),
  textSecondary: Color(0xFFB4A087),
  bottomNavBg: Color(0xFF19140C),
  border: Color(0xFF393022),
  progressTrack: Color(0xFF251F14),
  lightAccent: Color(0xFFDEB877),
);

const terracottaLight = ThemeColorFlavor(
  backgroundPolish: Color(0xFFFAF6F3),
  headerBg: Color(0xFFF1DDD0),
  accent: Color(0xFFBA7760),
  brandText: Color(0xFF6A3F33),
  textPrimary: Color(0xFF371E19),
  textSecondary: Color(0xFF966C5E),
  bottomNavBg: Color(0xFFF7EDE5),
  border: Color(0xFFE6CCBE),
  progressTrack: Color(0xFFF9F1EA),
  lightAccent: Color(0xFFCA8F7B),
);

const terracottaDark = ThemeColorFlavor(
  backgroundPolish: Color(0xFF1B1310),
  headerBg: Color(0xFF271B17),
  accent: Color(0xFFCD8D78),
  brandText: Color(0xFFEED0C5),
  textPrimary: Color(0xFFF8EFEA),
  textSecondary: Color(0xFFBA9C90),
  bottomNavBg: Color(0xFF1B1310),
  border: Color(0xFF3C2B25),
  progressTrack: Color(0xFF271B17),
  lightAccent: Color(0xFFDEAD9F),
);

const sakuraLight = ThemeColorFlavor(
  backgroundPolish: Color(0xFFFCF5F7),
  headerBg: Color(0xFFFCDDE7),
  accent: Color(0xFFD17C9B),
  brandText: Color(0xFF673646),
  textPrimary: Color(0xFF341721),
  textSecondary: Color(0xFF9B697A),
  bottomNavBg: Color(0xFFFAF0F3),
  border: Color(0xFFF5CBD6),
  progressTrack: Color(0xFFFDF0F4),
  lightAccent: Color(0xFFDC97AF),
);

const sakuraDark = ThemeColorFlavor(
  backgroundPolish: Color(0xFF201318),
  headerBg: Color(0xFF301C24),
  accent: Color(0xFFE092AD),
  brandText: Color(0xFFF9D6E1),
  textPrimary: Color(0xFFFAF3F5),
  textSecondary: Color(0xFFBFA2AC),
  bottomNavBg: Color(0xFF201318),
  border: Color(0xFF462D38),
  progressTrack: Color(0xFF301C24),
  lightAccent: Color(0xFFE789AA),
);

ThemeColorFlavor getThemeColorFlavor(String flavor, {bool isDark = false}) {
  switch (flavor) {
    case 'Matcha':
      return isDark ? matchaDark : matchaLight;
    case 'Ocean':
      return isDark ? oceanDark : oceanLight;
    case 'Lavender':
      return isDark ? lavenderDark : lavenderLight;
    case 'Charcoal':
      return isDark ? charcoalDark : charcoalLight;
    case 'Amber':
      return isDark ? amberDark : amberLight;
    case 'Terracotta':
      return isDark ? terracottaDark : terracottaLight;
    case 'Sakura':
      return isDark ? sakuraDark : sakuraLight;
    case 'Strawberry':
    default:
      return isDark ? strawberryDark : strawberryLight;
  }
}
