import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:social_saver/session/session_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _box = GetStorage();

  @override
  void initState() {
    super.initState();
    _decideNext();
  }

  Future<void> _decideNext() async {
    await Future.delayed(const Duration(seconds: 3));

    final session = SessionController.instance;

    // ✅ force refresh from storage
    session.loadSession();

    final bool onboardingSeen = _box.read("onboardingSeen") == true;

    // ✅ strongest check: storage-based + controller-based
    final bool loggedInStorage = _box.read("isLoggedIn") == true && (_box.read("userId") ?? 0) != 0;
    final bool loggedInController = session.isLoggedIn.value && session.userId.value != 0;

    final bool loggedIn = loggedInStorage || loggedInController;

    debugPrint("🚀 SPLASH -> onboardingSeen=$onboardingSeen | loggedIn=$loggedIn | userId=${session.userId.value}");

    if (loggedIn) {
      Get.offAllNamed('/home');
      return;
    }

    if (!onboardingSeen) {
      Get.offAllNamed('/onboarding');
      return;
    }

    Get.offAllNamed('/signin');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/Flow_1.gif',
              fit: BoxFit.cover,
              gaplessPlayback: true,
            ),
          ),
          Center(
            child: Image.asset(
              'assets/images/logo.png',
              width: 200,
              height: 200,
            ),
          ),
          const Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Text(
              "Version 1.1.1",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
