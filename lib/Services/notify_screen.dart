import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';



class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF061B2B);
    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            "assets/images/bg.png",
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 18),

                    // ✅ Top Row (Back JSON + Logo)
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Get.back(),
                          behavior: HitTestBehavior.opaque,
                          child: SizedBox(
                            width: 58,
                            height: 58,
                            child: Center(
                              child: Transform.scale(
                                scale: 1.5,
                                child: Lottie.asset(
                                  "assets/images/back_arrow.json",
                                  width: 42,
                                  height: 42,
                                  fit: BoxFit.contain,
                                  repeat: true,
                                  animate: true,
                                ),
                              ),
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


                    const Text(
                      "Notifications",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),



                    const SizedBox(height: 24),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(), // disables inner scroll
                      itemCount: 5,
                      separatorBuilder: (context, index) => const SizedBox(height: 15),
                      itemBuilder: (context, index) {
                        final time = index == 0 || index == 2 ? "Just now" : "2 min Ago";
                        return NotificationCard(time: time);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

  }
}

class NotificationCard extends StatelessWidget {
  final String time;

  const NotificationCard({super.key, required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF051325), // Slightly lighter card background
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Color(0xFF00CFFF), // Glowing blue border effect
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF00CFFF),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          // Alert Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Colors.redAccent, // Red alert color
              size: 24,
            ),
          ),

          const SizedBox(width: 15),

          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Scam Alert",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Lorem Ipsum Dolor Sit Amet",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Time Widget
          Text(
            time,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
