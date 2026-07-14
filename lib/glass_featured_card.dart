import 'dart:ui';
import 'package:flutter/material.dart';

/// ============================================================
/// UNIVERSAL GLASSY CARD WIDGET (FIXED-SCREEN VERSION)
///
/// Ab width aur height dono NULLABLE hain — jab tum ise Expanded
/// ke andar (row ya column dono taraf se) rakhoge, card khud
/// available space le lega. Isse pura screen fixed rehta hai,
/// scroll ki zaroorat nahi parti.
///
/// Grid ke liye:
/// Expanded(
///   child: Row(
///     children: [
///       Expanded(child: GlassCard(image: "...", title: "...", subtitle: "...")),
///       SizedBox(width: 12),
///       Expanded(child: GlassCard(image: "...", title: "...", subtitle: "...")),
///     ],
///   ),
/// )
/// ============================================================
class GlassCard extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final double? width;   // null = parent width le lega
  final double? height;  // null = parent height le lega

  const GlassCard({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: width ?? double.infinity,
          height: height ?? double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 24,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: const Color(0xFF3B9EFF).withOpacity(0.08),
                blurRadius: 30,
                spreadRadius: -8,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- Image: jitni jagah bache utni le le ----
              Expanded(
                flex: 3,
                child: Center(
                  child: Image.asset(image, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 6),

              // ---- Title ----
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),


              // ---- Subtitle + Arrow button ----
              Expanded(

                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 10.5,
                          height: 1.25,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: onTap,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFF3B9EFF), width: 1.3),
                        ),
                        child: const Icon(Icons.arrow_forward,
                            color: Color(0xFF3B9EFF), size: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}