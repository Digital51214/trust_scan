import 'package:flutter/services.dart';
import 'package:social_saver/Bottom%20Navigation%20Bar/history_screen.dart';
import 'package:social_saver/Bottom%20Navigation%20Bar/home_screen.dart';
import 'package:social_saver/Bottom%20Navigation%20Bar/profile_screen.dart';
import 'package:social_saver/Bottom%20Navigation%20Bar/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// ─────────────────────────────────────────────
//  CONTROLLER
// ─────────────────────────────────────────────
class BottomNavController extends GetxController {
  var currentIndex = 0.obs;

  final List<Widget> screens = const [
    HomeScreen(),
    HistoryScreen(),
    SettingsScreen(),
    ProfileScreen(),
  ];

  void changeTab(int index) {
    if (currentIndex.value == index) return;
    HapticFeedback.lightImpact();
    currentIndex.value = index;
  }
}

// ─────────────────────────────────────────────
//  MAIN SCREEN
// ─────────────────────────────────────────────
class BottomNavScreen extends StatelessWidget {
  const BottomNavScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BottomNavController c = Get.put(BottomNavController());

    return Scaffold(
      backgroundColor: const Color(0xFF06131D),
      extendBody: true,
      body: Obx(
            () => IndexedStack(
          index: c.currentIndex.value,
          children: c.screens,
        ),
      ),
      bottomNavigationBar: const _SocialSaverNav(),
    );
  }
}

// ─────────────────────────────────────────────
//  BOTTOM NAV BAR
// ─────────────────────────────────────────────
class _SocialSaverNav extends StatelessWidget {
  const _SocialSaverNav();

  @override
  Widget build(BuildContext context) {
    final BottomNavController c = Get.find<BottomNavController>();

    return Container(
      height: 76,
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1F2E),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(60),
          bottomLeft: Radius.circular(15),
          topRight: Radius.circular(15),
          bottomRight: Radius.circular(60),
        ),
        border: Border.all(
          color: const Color(0xFF2FAAD9).withOpacity(0.5),
          width: 2.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Obx(() {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildTile(0, Icons.home_filled, Icons.home_outlined, "Home", c),
            _buildTile(1, Icons.history, Icons.history, "History", c),
            _buildTile(2, Icons.settings, Icons.settings_outlined, "Settings", c),
            _buildTile(3, Icons.person, Icons.person_outline, "Profile", c),
          ],
        );
      }),
    );
  }

  Widget _buildTile(
      int index,
      IconData selectedIcon,
      IconData unselectedIcon,
      String label,
      BottomNavController c,
      ) {
    bool isSelected = c.currentIndex.value == index;
    const accentColor = Color(0xFF37C8FF);

    return GestureDetector(
      onTap: () => c.changeTab(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Spacer(),

            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? Colors.transparent
                    : Colors.white.withOpacity(0.08),
              ),
              child: Icon(
                isSelected ? unselectedIcon : selectedIcon,
                color: isSelected
                    ? accentColor
                    : Colors.white.withOpacity(0.6),
                size: 24,
              ),
            ),

            if (isSelected) ...[
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: const TextStyle(
                    color: accentColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    height: 1.0,
                  ),
                ),
              ),
            ],

            const Spacer(),

            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: isSelected ? 7 : 0,
              width: isSelected ? 35 : 0,
              decoration: const BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                boxShadow: [
                  BoxShadow(color: accentColor, blurRadius: 8, spreadRadius: -2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}