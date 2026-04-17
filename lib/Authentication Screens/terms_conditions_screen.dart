import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const cyan = Color(0xFF2CC7FF);

    return Scaffold(
      backgroundColor: const Color(0xFF061B2B),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ✅ Background Image
          Image.asset(
            "assets/images/bg.png",
            fit: BoxFit.cover,
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 18),

                // ✅ Top Row: Back + Logo
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Center(
                          child: Image.asset(
                            "assets/images/back_icon.png",
                            width: 42,
                            height: 42,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Image.asset(
                        "assets/images/logo.png",
                        width: 85,
                        height: 85,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // ✅ FIXED Heading (Static)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      "Terms & Conditions",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: cyan,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ✅ ONLY Body Scroll
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
                    child: const Text(
                      "Lorem ipsum dolor sit amet, consectetur\n"
                          "adipiscing elit. Proin eros libero, vulputate et felis\n"
                          "pretium, feugiat ornare massa. Maecenas auctor\n"
                          "massa in scelerisque molestie. Suspendisse\n"
                          "potenti. Morbi mollis tincidunt risus. Nulla\n"
                          "sagittis mauris quis est accumsan vulputate.\n"
                          "Curabitur imperdiet dictum enim, sit amet\n"
                          "lobortis turpis vulputate non. Praesent placerat\n"
                          "lectus sit amet diam ultrices, ut pulvinar nisi\n"
                          "molestie. Integer nec felis ut justo congue\n"
                          "lobortis at vel ligula.Lorem ipsum dolor sit amet,\n"
                          "consectetur adipiscing elit. Proin eros libero,\n"
                          "vulputate et felis pretium, feugiat ornare massa.\n"
                          "Maecenas auctor massa in scelerisque molestie.\n\n"
                          "Suspendisse potenti. Morbi mollis tincidunt risus.\n"
                          "Nulla sagittis mauris quis est accumsan\n"
                          "vulputate. Curabitur imperdiet dictum enim, sit\n"
                          "amet lobortis turpis vulputate non. Praesent\n"
                          "placerat lectus sit amet diam ultrices, ut pulvinar\n"
                          "nisi molestie. Integer nec felis ut justo congue\n"
                          "lobortis at vel ligula.Lorem ipsum dolor sit amet,\n"
                          "consectetur adipiscing elit. Proin eros libero,\n"
                          "vulputate et felis pretium, feugiat ornare massa.\n"
                          "Maecenas auctor massa in scelerisque molestie.\n"
                          "Suspendisse potenti.\n\n"
                          "Morbi mollis tincidunt risus. Nulla sagittis mauris\n"
                          "quis est accumsan vulputate. Curabitur imperdiet\n"
                          "dictum enim, sit amet lobortis turpis vulputate non.\n"
                          "Praesent placerat lectus sit amet diam ultrices, ut\n"
                          "pulvinar nisi molestie. Integer nec felis ut justo\n"
                          "congue lobortis at vel ligula.Lorem ipsum dolor sit\n"
                          "amet, consectetur adipiscing elit. Proin eros libero,\n"
                          "vulputate et felis pretium, feugiat ornare massa.\n"
                          "Maecenas auctor massa in scelerisque molestie.\n"
                          "Suspendisse potenti.\n",
                      style: TextStyle(
                        fontSize: 14.2,
                        height: 1.55,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
