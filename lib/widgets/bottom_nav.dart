import 'package:flutter/material.dart';
import 'theme_colors.dart';

class ElegantBottomNav extends StatelessWidget {
  final String activeScreen;
  final ThemeColorFlavor colors;
  final ValueChanged<String> onTabSelect;

  const ElegantBottomNav({
    Key? key,
    required this.activeScreen,
    required this.colors,
    required this.onTabSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.bottomNavBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                icon: Icons.home_rounded,
                label: "Beranda",
                screenId: "home",
              ),
              _buildNavItem(
                icon: Icons.add_circle_rounded,
                label: "Catat",
                screenId: "catat",
              ),
              _buildNavItem(
                icon: Icons.format_list_bulleted_rounded,
                label: "Riwayat",
                screenId: "riwayat",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required String screenId,
  }) {
    final isSelected = activeScreen == screenId;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTabSelect(screenId),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? colors.headerBg : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: isSelected ? colors.brandText : colors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                color: isSelected ? colors.brandText : colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
