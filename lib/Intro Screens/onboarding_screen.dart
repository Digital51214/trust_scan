import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lottie/lottie.dart';

import 'package:social_saver/Authentication Screens/signin_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final OnboardingController c;
  bool _assetsReady = false;

  @override
  void initState() {
    super.initState();
    c = Get.put(OnboardingController());

    // ✅ Preload all onboarding images to avoid lag/flash
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await Future.wait(
          c.pages.map((p) => precacheImage(AssetImage(p["bg"]!), context)),
        );
      } catch (_) {}

      if (mounted) setState(() => _assetsReady = true);
    });
  }

  @override
  void dispose() {
    if (Get.isRegistered<OnboardingController>()) {
      Get.delete<OnboardingController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double gifW = 333;
    const double gifH = 60;
    const double gifRatio = gifW / gifH;

    // ✅ decode image near device resolution (smooth + fast)
    final screenWpx =
    (MediaQuery.of(context).size.width * MediaQuery.of(context).devicePixelRatio)
        .round();

    // ✅ Professional loader while images precache
    if (!_assetsReady) {
      return const Scaffold(
        backgroundColor: Color(0xFF061B2B),
        body: Center(
          child: SizedBox(
            width: 34,
            height: 34,
            child: CircularProgressIndicator(strokeWidth: 2.8),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF061B2B),
      body: PageView.builder(
        controller: c.pageController,
        onPageChanged: c.onPageChanged,
        itemCount: c.pages.length,
        itemBuilder: (context, index) {
          final item = c.pages[index];

          return Stack(
            fit: StackFit.expand,
            children: [
              // ✅ Keep bottom curve visible + no flicker + faster decode
              Image.asset(
                item['bg']!,
                fit: BoxFit.cover,
                alignment: Alignment.bottomCenter, // ✅ curve fix
                gaplessPlayback: true, // ✅ no flash while switching
                filterQuality: FilterQuality.low,
                cacheWidth: screenWpx,
              ),

              SafeArea(
                child: Column(
                  children: [
                    const Spacer(flex: 6),
                    const SizedBox(height: 180),
                    const SizedBox(height: 30),
                    Obx(() {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          c.pages.length,
                              (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 7,
                            width: c.currentPage.value == i ? 20 : 7,
                            decoration: BoxDecoration(
                              color: c.currentPage.value == i
                                  ? const Color(0xFF35D3FF)
                                  : Colors.white38,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 30),

                    Text(
                      item['title']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        item['subtitle']!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14.5,
                          height: 1.4,
                          color: Colors.white70,
                        ),
                      ),
                    ),

                    const Spacer(),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 26),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final w = constraints.maxWidth;
                          final h = w / gifRatio;
                          final r = h / 2;

                          return SizedBox(
                            width: w,
                            height: h,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(r),
                              child: InkWell(
                                onTap: c.next,
                                child: Lottie.asset(
                                  "assets/images/Flow_2.json",
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ---------------- CONTROLLER ----------------

class OnboardingController extends GetxController {
  final pageController = PageController();
  final currentPage = 0.obs;
  final _box = GetStorage();

  final pages = [
    {
      "bg": "assets/images/bg1.png",
      "title": "Welcome to Trust Scan",
      "subtitle": "Your AI-powered tool to spot scams before they hurt you.",
    },
    {
      "bg": "assets/images/bg2.png",
      "title": "Check Any Seller or Deal",
      "subtitle": "Upload a screenshot or paste a link — we’ll give a trust score.",
    },
    {
      "bg": "assets/images/bg3.png",
      "title": "Stay Ahead of Fake AI Ads",
      "subtitle": "Detect AI-generated images and reviews instantly.",
    },
  ];

  void onPageChanged(int index) => currentPage.value = index;

  void next() {
    if (currentPage.value < pages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _box.write("onboardingSeen", true);
      Get.offAll(() => const SignInScreen());
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
