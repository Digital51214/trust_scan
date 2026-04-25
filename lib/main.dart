import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:social_saver/Intro Screens/splash_screen.dart';
import 'package:social_saver/Intro Screens/onboarding_screen.dart';
import 'package:social_saver/Authentication Screens/signin_screen.dart';
import 'package:social_saver/Bottom Navigation Bar/bottom_nav_screen.dart';

import 'package:social_saver/session/session_controller.dart';

// 👇 ADD THIS
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();

  if (!Get.isRegistered<SessionController>()) {
    Get.put(SessionController(), permanent: true);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SocialSaver',
      debugShowCheckedModeBanner: false,

      // 👇 ADD THIS
      navigatorObservers: [routeObserver],

      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
      ),
      initialRoute: '/splash',
      getPages: [
        GetPage(name: '/splash', page: () => const SplashScreen()),
        GetPage(name: '/onboarding', page: () => const OnboardingScreen()),
        GetPage(name: '/signin', page: () => const SignInScreen()),
        GetPage(name: '/home', page: () => const BottomNavScreen()),
      ],
    );
  }
}