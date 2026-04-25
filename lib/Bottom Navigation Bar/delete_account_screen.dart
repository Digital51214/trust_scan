// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:lottie/lottie.dart';
//
// import 'package:social_saver/Authentication Screens/signin_screen.dart';
// import 'package:social_saver/session/session_controller.dart';
//
// class DeleteAccountScreen extends StatelessWidget {
//   const DeleteAccountScreen({super.key});
//
//   static const bg = Color(0xFF061B2B);
//   static const cyan = Color(0xFF2CC7FF);
//   static const red = Color(0xFFFF3B3B);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       body: Stack(
//         fit: StackFit.expand,
//         children: [
//           // ✅ Background Gradient (same theme)
//           Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   Color(0xFF0D5E7D),
//                   bg,
//                   Color(0xFF040F1D),
//                 ],
//               ),
//             ),
//           ),
//
//           SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // ✅ Top row: back + shield
//                   Row(
//                     children: [
//                       GestureDetector(
//                         onTap: () => Get.back(),
//                         behavior: HitTestBehavior.opaque,
//                         child: SizedBox(
//                           width: 58,
//                           height: 58,
//                           child: Center(
//                             child: Transform.scale(
//                               scale: 1.5,
//                               child: Lottie.asset(
//                                 "assets/images/back_arrow.json",
//                                 width: 42,
//                                 height: 42,
//                                 fit: BoxFit.contain,
//                                 repeat: true,
//                                 animate: true,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       const Spacer(),
//                       Image.asset(
//                         "assets/images/logo.png",
//                         width: 85,
//                         height: 85,
//                         fit: BoxFit.contain,
//                       ),
//                     ],
//                   ),
//
//                   const SizedBox(height: 34),
//
//                   // ✅ Dustbin icon (delete.png)
//                   Center(
//                     child: Image.asset(
//                       "assets/images/delete.png",
//                       width: 140,
//                       height: 140,
//                       fit: BoxFit.contain,
//                     ),
//                   ),
//
//                   const SizedBox(height: 22),
//
//                   // ✅ Title
//                   const Text(
//                     "Delete Your Account",
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.w900,
//                       color: Colors.white,
//                     ),
//                   ),
//
//                   const SizedBox(height: 10),
//
//                   // ✅ Description
//                   Text(
//                     "Deleting your account is permanent. All your data will be removed and you won’t be able to recover it.\nAre you sure you want to delete your account?",
//                     style: TextStyle(
//                       fontSize: 13.5,
//                       height: 1.5,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.white.withOpacity(0.72),
//                     ),
//                   ),
//
//                   const SizedBox(height: 22),
//
//                   // ✅ SAME Delete Animation Button (moved from Settings)
//                   SizedBox(
//                     width: double.infinity,
//                     height: 70,
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(999),
//                       child: Material(
//                         color: Colors.transparent,
//                         child: InkWell(
//                           onTap: () => _confirmDelete(context),
//                           child: Center(
//                             child: Lottie.asset(
//                               "assets/images/Delete_Buttons.json",
//                               fit: BoxFit.contain,
//                               repeat: true,
//                               animate: true,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//
//                   const Spacer(),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _confirmDelete(BuildContext context) {
//     showDialog(
//       context: context,
//       barrierDismissible: true,
//       barrierColor: Colors.black.withOpacity(0.70),
//       builder: (_) {
//         return Dialog(
//           backgroundColor: Colors.transparent,
//           insetPadding: const EdgeInsets.symmetric(horizontal: 22),
//           child: Container(
//             padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
//             decoration: BoxDecoration(
//               color: const Color(0xFF0A2235),
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(
//                 color: red.withOpacity(.35),
//                 width: 1.2,
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.40),
//                   blurRadius: 18,
//                   offset: const Offset(0, 12),
//                 ),
//               ],
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   width: 54,
//                   height: 54,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: red.withOpacity(0.12),
//                     border: Border.all(color: red.withOpacity(.40)),
//                   ),
//                   child: const Icon(
//                     Icons.delete_forever_rounded,
//                     color: red,
//                     size: 28,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 const Text(
//                   "Delete Account",
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w900,
//                     color: Colors.white,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   "This action will permanently delete your account. Do you want to continue?",
//                   style: TextStyle(
//                     fontSize: 13.2,
//                     height: 1.45,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.white.withOpacity(.70),
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: OutlinedButton(
//                         style: OutlinedButton.styleFrom(
//                           shape: const StadiumBorder(),
//                           side: BorderSide(
//                             color: Colors.white.withOpacity(.18),
//                             width: 1,
//                           ),
//                           foregroundColor: Colors.white70,
//                           padding: const EdgeInsets.symmetric(vertical: 13),
//                         ),
//                         onPressed: () => Get.back(),
//                         child: const Text(
//                           "No",
//                           style: TextStyle(
//                             fontWeight: FontWeight.w800,
//                             fontSize: 14,
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     Expanded(
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: red,
//                           shape: const StadiumBorder(),
//                           elevation: 0,
//                           padding: const EdgeInsets.symmetric(vertical: 13),
//                         ),
//                         onPressed: () {
//                           Get.back(); // close dialog
//
//                           // TODO: delete account API call here
//                           if (Get.isRegistered<SessionController>()) {
//                             SessionController.instance.clearSession();
//                           }
//
//                           Get.offAll(() => const SignInScreen());
//                         },
//                         child: const Text(
//                           "Yes",
//                           style: TextStyle(
//                             fontWeight: FontWeight.w900,
//                             fontSize: 14,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
//
// class _CircleIconButton extends StatelessWidget {
//   const _CircleIconButton({
//     required this.icon,
//     required this.onTap,
//   });
//
//   final IconData icon;
//   final VoidCallback onTap;
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       borderRadius: BorderRadius.circular(999),
//       onTap: onTap,
//       child: Container(
//         width: 44,
//         height: 44,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           color: Colors.white.withOpacity(0.10),
//           border: Border.all(color: Colors.white.withOpacity(0.14)),
//         ),
//         child: Icon(icon, color: Colors.white.withOpacity(0.9), size: 20),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import 'package:social_saver/Authentication Screens/signin_screen.dart';
import 'package:social_saver/session/session_controller.dart';

class DeleteAccountScreen extends StatelessWidget {
  const DeleteAccountScreen({super.key});

  static const bg = Color(0xFF061B2B);
  static const cyan = Color(0xFF2CC7FF);
  static const red = Color(0xFFFF3B3B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 🌌 Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0D5E7D),
                  bg,
                  Color(0xFF040F1D),
                ],
              ),
            ),
          ),

          // ✨ AI Glow Layer
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.2),
                radius: 1.2,
                colors: [
                  red.withOpacity(0.10),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
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
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // 🧠 AI Warning Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: red.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: red.withOpacity(0.25),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            size: 13, color: red),
                        SizedBox(width: 6),
                        Text(
                          "Critical Action",
                          style: TextStyle(
                            color: Color(0xFFFFB3B3),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // 🗑️ Icon
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: red.withOpacity(0.35),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: red.withOpacity(0.18),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        "assets/images/delete.png",
                        width: 120,
                        height: 120,
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  const Text(
                    "Delete Your Account",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "This action will permanently erase your identity, activity, and AI trust history. This cannot be reversed.",
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.72),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 🔥 Animated Button (same Lottie)
                  SizedBox(
                    width: double.infinity,
                    height: 70,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _confirmDelete(context),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Lottie.asset(
                                "assets/images/Delete_Buttons.json",
                                fit: BoxFit.contain,
                              ),

                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 22),
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            decoration: BoxDecoration(
              color: const Color(0xFF0A2235),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: red.withOpacity(.40),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: red.withOpacity(0.25),
                  blurRadius: 18,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.delete_forever_rounded,
                    color: red, size: 40),
                const SizedBox(height: 10),

                const Text(
                  "Confirm Deletion",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "Your account will be permanently removed from the AI system.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(.70),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: red,
                        ),
                        onPressed: () {
                          Get.back();

                          if (Get.isRegistered<SessionController>()) {
                            SessionController.instance.clearSession();
                          }

                          Get.offAll(() => const SignInScreen());
                        },
                        child: const Text("Delete"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}