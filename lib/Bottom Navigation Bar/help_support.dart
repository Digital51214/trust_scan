import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:social_saver/Bottom%20Navigation%20Bar/video_background.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

import '../Authentication Screens/privacy_policy_screen.dart';
import '../Authentication Screens/terms_conditions_screen.dart';

class HelpAndSupportScreens extends StatelessWidget {
  const HelpAndSupportScreens({super.key});

  static const Color black = Color(0xFF050505);
  static const Color greyText = Color(0xFF5F6368);
  static const Color cardWhite = Color(0xDDFBFCFF);

  // ── App ke links yahan update karo ──
  static const String _playStoreUrl =
      'https://play.google.com/store/apps/details?id=YOUR_PACKAGE_NAME';
  static const String _appStoreUrl =
      'https://apps.apple.com/app/idYOUR_APP_ID';
  static const String _contactEmail = 'support@yourapp.com';
  static const String _appName = 'Trust Scan';
  static const String _appShareUrl = 'https://play.google.com/store/apps/details?id=YOUR_PACKAGE_NAME';

  // ── Rate Us ──
  Future<void> _rateUs() async {
    // Pehle Play Store try karo, agar na chale to App Store
    final Uri playUri = Uri.parse(_playStoreUrl);
    final Uri appStoreUri = Uri.parse(_appStoreUrl);

    if (await canLaunchUrl(playUri)) {
      await launchUrl(playUri, mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(appStoreUri)) {
      await launchUrl(appStoreUri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'Error',
        'Store open nahi ho saka.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ── Share App ──
  Future<void> _shareApp() async {
    await Share.share(
      '$_appName download karo aur videos/photos asaani se save karo!\n\n$_appShareUrl',
      subject: '$_appName – Video & Photo Saver',
    );
  }

  // ── Contact Us ──
  Future<void> _contactUs() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: _contactEmail,
      queryParameters: {
        'subject': '',
        'body': '',
      },
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      Get.snackbar(
        'Error',
        'Email app nahi mili. $_contactEmail par manually email karein.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      body: Stack(
        children: [
          const VideoBackground(),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(17, 14, 17, 34),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _TopBar(),

                  const SizedBox(height: 28),

                  Container(
                    height: MediaQuery.of(context).size.height * 0.15,
                    width: MediaQuery.of(context).size.width * 1.0,
                    child: Image.asset("assets/images/logo1.png"),
                  ),

                  const _SectionTitle("General"),

                  const SizedBox(height: 15),

                  _SettingsCard(
                    children: [
                      _SettingsRow(
                        icon: Icons.thumb_up_alt_outlined,
                        title: "Rate Us",
                        onTap: _rateUs,
                      ),
                      _SettingsRow(
                        icon: Icons.share_outlined,
                        title: "Share App",
                        onTap: _shareApp,
                      ),
                      _SettingsRow(
                        icon: Icons.mail_outline_rounded,
                        title: "Contact Us",
                        showDivider: false,
                        onTap: _contactUs,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  const _SectionTitle("Privacy"),

                  const SizedBox(height: 15),

                  _SettingsCard(
                    children: [
                      _SettingsRow(
                        icon: Icons.privacy_tip_outlined,
                        title: "Privacy Policy",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PrivacyPolicyScreen(),
                            ),
                          );
                        },
                      ),
                      _SettingsRow(
                        icon: Icons.assignment_outlined,
                        title: "Terms of Use",
                        showDivider: false,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TermsConditionsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Baaki sab classes same rehti hain ──

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 25,
              ),
            ),
          ),
          const Text(
            "Help And Support",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: Colors.white,
        height: 1,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xEEFAFCFF).withOpacity(.1),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white, width: 1.5),
          ),
          child: Column(children: children),
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.showDivider = true,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.black.withOpacity(.03),
        highlightColor: Colors.black.withOpacity(.02),
        child: Padding(
          padding: const EdgeInsets.only(left: 27, right: 24),
          child: Column(
            children: [
              SizedBox(
                height: 84,
                child: Row(
                  children: [
                    Icon(icon, color: Colors.white, size: 25),
                    const SizedBox(width: 35),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 0.5,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white.withOpacity(.43),
                      size: 20,
                    ),
                  ],
                ),
              ),
              if (showDivider)
                Container(
                  height: 0.5,
                  margin: const EdgeInsets.only(left: 25),
                  color: Colors.white.withOpacity(.95),
                ),
            ],
          ),
        ),
      ),
    );
  }
}