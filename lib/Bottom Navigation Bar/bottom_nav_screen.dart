import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:get/get.dart';
import 'package:social_saver/Bottom%20Navigation%20Bar/history_screen.dart';
import 'package:social_saver/Bottom%20Navigation%20Bar/home_screen.dart';
import 'package:social_saver/Bottom%20Navigation%20Bar/profile_screen.dart';
import 'package:social_saver/Bottom%20Navigation%20Bar/settings_screen.dart';

// ─────────────────────────────────────────────
//  CONTROLLER
// ─────────────────────────────────────────────
class BottomNavController extends GetxController {
  RxInt currentIndex = 0.obs;

  final screens = const [
    HomeScreen(),
    HistoryScreen(),
    SettingsScreen(),
    ProfileScreen(),
  ];

  void changeTab(int index) {
    if (currentIndex.value == index) return;
    HapticFeedback.selectionClick(); // iOS-style haptic
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
    final c = Get.put(BottomNavController());

    return Scaffold(
      backgroundColor: const Color(0xFF061B2B),
      extendBody: true, // body goes behind nav bar
      body: Obx(() => c.screens[c.currentIndex.value]),
      bottomNavigationBar: const _SocialSaverNav(),
    );
  }
}

// ─────────────────────────────────────────────
//  BOTTOM NAV BAR
// ─────────────────────────────────────────────
class _SocialSaverNav extends StatelessWidget {
  const _SocialSaverNav();

  static const _items = [
    _NavItem(icon: Icons.home_rounded,    label: 'Home'),
    _NavItem(icon: Icons.history_rounded, label: 'History'),
    _NavItem(icon: Icons.settings_rounded,    label: 'Settings'),
    _NavItem(icon: Icons.person_rounded,  label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final c = Get.find<BottomNavController>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            // ── Frosted glass blur ──
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                // Very subtle, light frosted tint
                color: const Color(0xFF0D2235).withOpacity(0.72),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                  width: 1,
                ),
              ),
              child: Obx(() {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(
                    _items.length,
                        (i) => _NavTile(
                      item: _items[i],
                      isSelected: c.currentIndex.value == i,
                      onTap: () => c.changeTab(i),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SINGLE TILE
// ─────────────────────────────────────────────
class _NavTile extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  // Accent colour — sky-blue from your theme
  static const _accent = Color(0xFF37C8FF);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Icon with subtle glow when active ──
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              width: 38,
              height: 34,
              decoration: isSelected
                  ? BoxDecoration(
                borderRadius: BorderRadius.circular(11),
                color: _accent.withOpacity(0.13),
                boxShadow: [
                  BoxShadow(
                    color: _accent.withOpacity(0.28),
                    blurRadius: 10,
                    spreadRadius: 0,
                  ),
                ],
              )
                  : const BoxDecoration(),
              child: Icon(
                item.icon,
                size: 20,
                color: isSelected ? _accent : Colors.white.withOpacity(0.40),
              ),
            ),

            const SizedBox(height: 3),

            // ── Tiny label ──
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? _accent
                    : Colors.white.withOpacity(0.35),
                letterSpacing: 0.2,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  DATA
// ─────────────────────────────────────────────
class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}