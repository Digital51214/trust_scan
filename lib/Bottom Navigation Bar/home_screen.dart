// // import 'dart:io';
// //
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import 'package:image_picker/image_picker.dart';
// // import 'package:lottie/lottie.dart';
//
// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:lottie/lottie.dart';
// import 'package:social_saver/Services/loading_animate.dart';
// import 'package:social_saver/Services/notify_screen.dart';
// import 'package:social_saver/results_screen.dart';
//
// import 'package:social_saver/session/session_controller.dart';
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen>
//     with SingleTickerProviderStateMixin {
//   final inputCtrl = TextEditingController();
//   final session = SessionController.instance;
//   final ImagePicker _picker = ImagePicker();
//
//   late final AnimationController _btnCtrl;
//   late final Animation<double> _btnScale;
//
//   bool _isScanning = false;
//   bool _isFocused = false;
//
//   @override
//   void initState() {
//     super.initState();
//     inputCtrl.addListener(() => setState(() {}));
//     _btnCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 120),
//       lowerBound: 0.0,
//       upperBound: 0.15,
//     );
//     _btnScale = Tween<double>(begin: 1.0, end: 0.85).animate(
//       CurvedAnimation(parent: _btnCtrl, curve: Curves.easeOut),
//     );
//   }
//
//   @override
//   void dispose() {
//     inputCtrl.dispose();
//     _btnCtrl.dispose();
//     super.dispose();
//   }
//
//   // Future<void> _goToResult() async {
//   //   final text = inputCtrl.text.trim();
//   //   if (text.isEmpty) return;
//   //
//   //   await _btnCtrl.forward();
//   //   await _btnCtrl.reverse();
//   //
//   //   setState(() => _isScanning = true);
//   //   await Future.delayed(const Duration(milliseconds: 400));
//   //   setState(() => _isScanning = false);
//   //
//   //   Get.to(
//   //         () => ResultScreen(inputText: text),
//   //     transition: Transition.fadeIn,
//   //     duration: const Duration(milliseconds: 350),
//   //   );
//   // }
//   Future<void> _goToResult() async {
//     final text = inputCtrl.text.trim();
//     if (text.isEmpty) return;
//
//     await _btnCtrl.forward();
//     await _btnCtrl.reverse();
//
//     Get.to(
//           () => LoadingScreen(),
//       transition: Transition.noTransition,
//     );
//
//     await Future.delayed(const Duration(seconds: 2));
//
//     Get.back(); // loading screen close
//
//     Get.to(
//           () => ResultScreen(inputText: text),
//       transition: Transition.fadeIn,
//       duration: const Duration(milliseconds: 350),
//     );
//   }
//
//   Future<void> _pickMediaBottomSheet() async {
//     Get.bottomSheet(
//       Container(
//         padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
//         decoration: const BoxDecoration(
//           color: Color(0xFF0A2235),
//           borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
//         ),
//         child: SafeArea(
//           top: false,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 width: 55,
//                 height: 5,
//                 decoration: BoxDecoration(
//                   color: Colors.white24,
//                   borderRadius: BorderRadius.circular(999),
//                 ),
//               ),
//               const SizedBox(height: 18),
//               const Text(
//                 "Select Media",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 18,
//                   fontWeight: FontWeight.w800,
//                 ),
//               ),
//               const SizedBox(height: 18),
//               Row(
//                 children: [
//                   Expanded(
//                     child: _MediaPickTile(
//                       icon: Icons.image_rounded,
//                       title: "Image",
//                       onTap: () async {
//                         Get.back();
//                         await _pickImage();
//                       },
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: _MediaPickTile(
//                       icon: Icons.videocam_rounded,
//                       title: "Video",
//                       onTap: () async {
//                         Get.back();
//                         await _pickVideo();
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//     );
//   }
//
//   Future<void> _pickImage() async {
//     final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
//     if (picked == null) return;
//     Get.to(
//           () => ResultScreen(mediaFile: File(picked.path)),
//       transition: Transition.fadeIn,
//       duration: const Duration(milliseconds: 350),
//     );
//   }
//
//   Future<void> _pickVideo() async {
//     final XFile? picked = await _picker.pickVideo(source: ImageSource.gallery);
//     if (picked == null) return;
//     Get.to(
//           () => ResultScreen(mediaFile: File(picked.path)),
//       transition: Transition.fadeIn,
//       duration: const Duration(milliseconds: 350),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final m = MediaQuery.of(context);
//     final bottomPad = m.padding.bottom;
//     final hasText = inputCtrl.text.trim().isNotEmpty;
//
//     return Scaffold(
//       body: Stack(
//         fit: StackFit.expand,
//         children: [
//           // ── Background ───────────────────────────────────────────────
//           Positioned.fill(
//             child: Image.asset(
//               "assets/images/bg.png",
//               fit: BoxFit.cover,
//             ),
//           ),
//
//           SafeArea(
//             bottom: false,
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 18),
//               child: Stack(
//                 children: [
//                   // ── Top content ──────────────────────────────────────
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // CHANGE 1: top spacing thoda kam kiya (8 → 6)
//                       const SizedBox(height: 6),
//
//                       // ── Header ───────────────────────────────────────
//                       Row(
//                         children: [
//                           Container(
//                             width: 36, // CHANGE 2: thoda chhota (38 → 36)
//                             height: 36,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               border: Border.all(
//                                   color: Colors.white12, width: 1.5),
//                               image: const DecorationImage(
//                                 image: AssetImage("assets/images/logo.png"),
//                                 fit: BoxFit.cover,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 10),
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               // CHANGE 3: "Welcome!" → "Welcome back,"
//                               const Text(
//                                 "Welcome back,",
//                                 style: TextStyle(
//                                   color: Colors.white60,
//                                   fontSize: 12,
//                                 ),
//                               ),
//                               const SizedBox(height: 1),
//                               Obx(() {
//                                 final name = session.name.value.trim();
//                                 return Text(
//                                   name.isEmpty ? "User" : name,
//                                   style: const TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w700,
//                                   ),
//                                 );
//                               }),
//                             ],
//                           ),
//                           const Spacer(),
//                           // CHANGE 4: notification icon smaller (44 → 34)
//                           GestureDetector(
//     onTap: (){
//       Get.to(
//             () => NotificationScreen(),
//         transition: Transition.noTransition,
//         duration: Duration.zero,
//       );
//     },
//                             child: SizedBox(
//                               width: 50,
//                               height: 50,
//                               child: Center(
//                                 child: Lottie.asset(
//                                   "assets/images/notification_animation.json",
//                                   width: 50,
//                                   height: 50,
//                                   fit: BoxFit.contain,
//                                   repeat: true,
//                                   animate: true,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//
//                       // CHANGE 5: spacing thoda tight (15 → 10)
//                       const SizedBox(height: 10),
//
//                       // CHANGE 6: Headline updated + tighter spacing
//                       const Text(
//                         "Scan. Detect. Stay Safe.",
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 24,
//                           height: 1.2, // tighter (1.25 → 1.2)
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                       const SizedBox(height: 5),
//                       const Text(
//                         "Paste a link, message, or upload a screenshot to check for scams instantly.",
//                         style: TextStyle(
//                           color: Colors.white60,
//                           fontSize: 13, // slightly smaller (14 → 13)
//                           height: 1.35,
//                         ),
//                       ),
//
//                       const SizedBox(height: 10),
//
//                       // CHANGE 7: Features as compact chips (not big bullet list)
//                       _buildFeatures(),
//                     ],
//                   ),
//
//                   // ── Center Lottie swirl ──────────────────────────────
//                   // CHANGE 8: opacity kam kiya (0.55 → 0.12) — texture not focus
//                   Align(
//                     alignment: Alignment.center,
//                     child: Opacity(
//                       opacity: 0.50,
//                       child: SizedBox(
//                         width: 300,
//                         height: 250,
//                         child: Lottie.asset(
//                           "assets/images/Flow_5.json",
//                           fit: BoxFit.contain,
//                           repeat: true,
//                           animate: true,
//                         ),
//                       ),
//                     ),
//                   ),
// SizedBox(height: 10,),
//                   // ── Bottom input + trust indicator ───────────────────
//                   Align(
//                     alignment: Alignment.bottomCenter,
//                     child: Padding(
//                       padding: EdgeInsets.only(bottom: bottomPad + 30),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//
//
//                           AnimatedOpacity(
//                             opacity: _isScanning ? 1.0 : 0.0,
//                             duration: const Duration(milliseconds: 250),
//                             child: const Padding(
//                               padding: EdgeInsets.only(bottom: 8),
//                               child: _PulsingText("Analyzing..."),
//                             ),
//                           ),
//
//                           // ── Input bar ────────────────────────────────
//                           AnimatedContainer(
//                             duration: const Duration(milliseconds: 220),
//                             curve: Curves.easeOutCubic,
//                             padding: const EdgeInsets.symmetric(horizontal: 14),
//                             height: 50,
//                             decoration: BoxDecoration(
//                               color: const Color(0xFF081A2A),
//                               borderRadius: BorderRadius.circular(28),
//                               border: Border.all(
//                                 color: const Color(0xFF37C8FF).withOpacity(_isFocused ? 0.85 : 0.65),
//                                 width: _isFocused ? 1.4 : 1.1,
//                               ),
//                               gradient: LinearGradient(
//                                 begin: Alignment.topCenter,
//                                 end: Alignment.bottomCenter,
//                                 colors: [
//                                   const Color(0xFF0D2235).withOpacity(0.96),
//                                   const Color(0xFF081A2A).withOpacity(0.98),
//                                 ],
//                               ),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: const Color(0xFF37C8FF).withOpacity(_isFocused ? 0.30 : 0.18),
//                                   blurRadius: _isFocused ? 22 : 16,
//                                   spreadRadius: _isFocused ? 1.2 : 0.6,
//                                   offset: Offset.zero,
//                                 ),
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(0.35),
//                                   blurRadius: 10,
//                                   offset: const Offset(0, 4),
//                                 ),
//                               ],
//                             ),
//                             child: Row(
//                               children: [
//                                 Icon(
//                                   Icons.link_rounded,
//                                   color: const Color(0xFF37C8FF).withOpacity(0.95),
//                                   size: 18,
//                                 ),
//                                 const SizedBox(width: 10),
//
//                                 Expanded(
//                                   child: Focus(
//                                     onFocusChange: (hasFocus) =>
//                                         setState(() => _isFocused = hasFocus),
//                                     child: TextField(
//                                       controller: inputCtrl,
//                                       style: const TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 13,
//                                         fontWeight: FontWeight.w400,
//                                       ),
//                                       textInputAction: TextInputAction.search,
//                                       onSubmitted: (_) => _goToResult(),
//                                       cursorColor: const Color(0xFF37C8FF),
//                                       decoration: InputDecoration(
//                                         hintText: "Paste link or message to scan...",
//                                         hintStyle: TextStyle(
//                                           color: Colors.white.withOpacity(0.34),
//                                           fontSize: 13,
//                                           fontWeight: FontWeight.w400,
//                                         ),
//                                         border: InputBorder.none,
//                                         isDense: true,
//                                         contentPadding: EdgeInsets.zero,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//
//                                 const SizedBox(width: 8),
//
//                                 GestureDetector(
//                                   onTap: _pickMediaBottomSheet,
//                                   child: Container(
//                                     width: 28,
//                                     height: 28,
//                                     alignment: Alignment.center,
//                                     child: Icon(
//                                       Icons.camera_alt_rounded,
//                                       color: const Color(0xFF37C8FF).withOpacity(0.95),
//                                       size: 18,
//                                     ),
//                                   ),
//                                 ),
//
//                                 const SizedBox(width: 8),
//
//                                 GestureDetector(
//                                   onTap: _isScanning ? null : _goToResult,
//                                   child: Container(
//                                     width: 28,
//                                     height: 28,
//                                     alignment: Alignment.center,
//                                     child: Icon(
//                                       Icons.crop_free_rounded,
//                                       color: const Color(0xFF37C8FF).withOpacity(0.95),
//                                       size: 18,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//
//                           // CHANGE 10: Trust indicator — NEW widget under input
//                           const SizedBox(height: 10),
//                           _TrustIndicatorPlaceholder(hasText: hasText),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
//
// // ── Trust Indicator Placeholder ──────────────────────────────────────────────
// // CHANGE 10: Naya widget — input ke neeche trust score placeholder
// class _TrustIndicatorPlaceholder extends StatelessWidget {
//   const _TrustIndicatorPlaceholder({required this.hasText});
//   final bool hasText;
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeOut,
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.04),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: hasText
//               ? const Color(0xFF37C8FF).withOpacity(0.20)
//               : Colors.white.withOpacity(0.07),
//         ),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.start
//         ,
//         children: [
//           Icon(
//             Icons.shield_outlined,
//             size: 14,
//             color: hasText
//                 ? const Color(0xFF37C8FF).withOpacity(0.7)
//                 : Colors.white30,
//           ),
//           const SizedBox(width: 7),
//           Text(
//             hasText
//                 ? "Tap Scan to get your trust score"
//                 : "Your trust score will appear here",
//             style: TextStyle(
//               color: hasText
//                   ? const Color(0xFF37C8FF).withOpacity(0.75)
//                   : Colors.white30,
//               fontSize: 12,
//               fontWeight: FontWeight.w500,
//               letterSpacing: 0.2,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
//
// //── Beautiful Glowing Scan Button ────────────────────────────────────────────
// class _ScanButton extends StatefulWidget {
//   const _ScanButton({
//     required this.isScanning,
//     required this.scaleAnim,
//     required this.onTap,
//     required this.hasText,
//   });
//
//   final bool isScanning;
//   final Animation<double> scaleAnim;
//   final VoidCallback? onTap;
//   final bool hasText;
//
//   @override
//   State<_ScanButton> createState() => _ScanButtonState();
// }
//
// class _ScanButtonState extends State<_ScanButton>
//     with TickerProviderStateMixin {
//   late final AnimationController _ringCtrl;
//   late final Animation<double> _ringScale;
//   late final Animation<double> _ringOpacity;
//
//   late final AnimationController _rotCtrl;
//   late final Animation<double> _rotAnim;
//
//   late final AnimationController _glowCtrl;
//   late final Animation<double> _glowAnim;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _ringCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1600),
//     );
//     _ringScale = Tween<double>(begin: 1.0, end: 1.45).animate(
//       CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOut),
//     );
//     _ringOpacity = Tween<double>(begin: 0.4, end: 0.0).animate(
//       CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOut),
//     );
//
//     _rotCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 3000),
//     );
//     _rotAnim = Tween<double>(begin: 0, end: 1).animate(
//       CurvedAnimation(parent: _rotCtrl, curve: Curves.linear),
//     );
//
//     _glowCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1200),
//     );
//     _glowAnim = Tween<double>(begin: 0.4, end: 0.9).animate(
//       CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
//     );
//   }
//
//   @override
//   void didUpdateWidget(_ScanButton oldWidget) {
//     super.didUpdateWidget(oldWidget);
//
//     if (widget.hasText && !oldWidget.hasText) {
//       _ringCtrl.repeat();
//       _rotCtrl.repeat();
//       _glowCtrl.repeat(reverse: true);
//     } else if (!widget.hasText && oldWidget.hasText) {
//       _ringCtrl.stop();
//       _rotCtrl.stop();
//       _glowCtrl.stop();
//     }
//   }
//
//   @override
//   void dispose() {
//     _ringCtrl.dispose();
//     _rotCtrl.dispose();
//     _glowCtrl.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: widget.onTap,
//       child: AnimatedBuilder(
//         animation: Listenable.merge([
//           widget.scaleAnim,
//           _ringScale,
//           _ringOpacity,
//           _rotAnim,
//           _glowAnim,
//         ]),
//         builder: (context, _) {
//           return Transform.scale(
//             scale: widget.scaleAnim.value,
//             child: SizedBox(
//               width: 36,
//               height: 36,
//               child: Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   if (!widget.isScanning && widget.hasText)
//                     Transform.scale(
//                       scale: _ringScale.value,
//                       child: Container(
//                         width: 46,
//                         height: 46,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(14),
//                           border: Border.all(
//                             color: const Color(0xFF37C8FF)
//                                 .withOpacity(_ringOpacity.value),
//                             width: 1.5,
//                           ),
//                         ),
//                       ),
//                     ),
//
//                   Container(
//                     width: 46,
//                     height: 46,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(14),
//                       gradient: LinearGradient(
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                         colors: widget.isScanning
//                             ? [
//                           const Color(0xFF37C8FF).withOpacity(0.6),
//                           const Color(0xFF1A8FD1).withOpacity(0.6),
//                         ]
//                             : const [
//                           Color(0xFF37C8FF),
//                           Color(0xFF0E7FBF),
//                         ],
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: const Color(0xFF37C8FF).withOpacity(
//                             widget.isScanning
//                                 ? 0.15
//                                 : widget.hasText
//                                 ? _glowAnim.value * 0.7
//                                 : 0.1,
//                           ),
//                           blurRadius: 20,
//                           spreadRadius: 2,
//                           offset: const Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     child: widget.isScanning
//                         ? const Padding(
//                       padding: EdgeInsets.all(11),
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2.2,
//                         color: Colors.white,
//                       ),
//                     )
//                         : Stack(
//                       alignment: Alignment.center,
//                       children: [
//                         if (widget.hasText)
//                           ClipRRect(
//                             borderRadius: BorderRadius.circular(14),
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 gradient: LinearGradient(
//                                   begin: Alignment(
//                                       -1.5 + _glowAnim.value * 3, -1),
//                                   end: Alignment(
//                                       0.5 + _glowAnim.value * 3, 1),
//                                   colors: [
//                                     Colors.white.withOpacity(0.0),
//                                     Colors.white.withOpacity(0.22),
//                                     Colors.white.withOpacity(0.0),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         widget.hasText
//                             ? RotationTransition(
//                           turns: _rotAnim,
//                           child: const Icon(
//                             Icons.radar_rounded,
//                             color: Colors.white,
//                             size: 22,
//                           ),
//                         )
//                             : const Icon(
//                           Icons.radar_rounded,
//                           color: Colors.white,
//                           size: 22,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
//
//
// class _AppLoadingView extends StatelessWidget {
//   const _AppLoadingView();
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       height: double.infinity,
//       color: Colors.black,
//       alignment: Alignment.center,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: const [
//           CircularProgressIndicator(
//             strokeWidth: 2.5,
//             color: Color(0xFF37C8FF),
//           ),
//           SizedBox(height: 16),
//           Text(
//             'Loading...',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 15,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
//
// // ── Pulsing "Analyzing..." text ──────────────────────────────────────────────
// class _PulsingText extends StatefulWidget {
//   const _PulsingText(this.text);
//   final String text;
//
//   @override
//   State<_PulsingText> createState() => _PulsingTextState();
// }
//
// class _PulsingTextState extends State<_PulsingText>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _ctrl;
//   late final Animation<double> _opacity;
//
//   @override
//   void initState() {
//     super.initState();
//     _ctrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 700),
//     )..repeat(reverse: true);
//     _opacity = Tween<double>(begin: 0.4, end: 1.0).animate(_ctrl);
//   }
//
//   @override
//   void dispose() {
//     _ctrl.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return FadeTransition(
//       opacity: _opacity,
//       child: Text(
//         widget.text,
//         style: const TextStyle(
//           color: Color(0xFF37C8FF),
//           fontSize: 13,
//           fontWeight: FontWeight.w700,
//           letterSpacing: 0.4,
//         ),
//       ),
//     );
//   }
// }
//
//
// // ── Media pick tile ──────────────────────────────────────────────────────────
// class _MediaPickTile extends StatelessWidget {
//   const _MediaPickTile({
//     required this.icon,
//     required this.title,
//     required this.onTap,
//   });
//
//   final IconData icon;
//   final String title;
//   final VoidCallback onTap;
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         height: 110,
//         decoration: BoxDecoration(
//           color: Colors.white.withOpacity(.06),
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: Colors.white10),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, color: const Color(0xFF37C8FF), size: 30),
//             const SizedBox(height: 10),
//             Text(
//               title,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
//
// // ── Features section ─────────────────────────────────────────────────────────
// // CHANGE 11: Big bullet list → compact chip-style row
// Widget _buildFeatures() {
//   return Wrap(
//     spacing: 8,
//     runSpacing: 8,
//     children: const [
//       _FeatureChip(icon: Icons.lock_outline_rounded, label: "Secure & Private"),
//       _FeatureChip(icon: Icons.flash_on_rounded, label: "AI Detection"),
//       _FeatureChip(icon: Icons.verified_outlined, label: "Trust Score"),
//       _FeatureChip(icon: Icons.shield_outlined, label: "Scam Guard"),
//     ],
//   );
// }
//
// class _FeatureChip extends StatelessWidget {
//   const _FeatureChip({required this.icon, required this.label});
//   final IconData icon;
//   final String label;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.05),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Colors.white.withOpacity(0.10)),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 12, color: const Color(0xFF37C8FF)),
//           const SizedBox(width: 5),
//           Text(
//             label,
//             style: const TextStyle(
//               color: Colors.white60,
//               fontSize: 11.5,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:io';
import 'dart:math' as dartMath;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:social_saver/Services/loading_animate.dart';
import 'package:social_saver/Services/notify_screen.dart';
import 'package:social_saver/results_screen.dart';

import 'package:social_saver/session/session_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  final inputCtrl = TextEditingController();
  final session = SessionController.instance;
  final ImagePicker _picker = ImagePicker();

  late final AnimationController _btnCtrl;
  late final Animation<double> _btnScale;

  late final AnimationController _orbitCtrl;

  bool _isScanning = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    inputCtrl.addListener(() => setState(() {}));

    _btnCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 0.15,
    );

    _btnScale = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _btnCtrl, curve: Curves.easeOut),
    );

    _orbitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    )..repeat();
  }

  @override
  void dispose() {
    inputCtrl.dispose();
    _btnCtrl.dispose();
    _orbitCtrl.dispose();
    super.dispose();
  }

  Future<void> _goToResult() async {
    final text = inputCtrl.text.trim();
    if (text.isEmpty) return;

    await _btnCtrl.forward();
    await _btnCtrl.reverse();

    Get.to(
          () => LoadingScreen(),
      transition: Transition.noTransition,
    );

    await Future.delayed(const Duration(seconds: 2));

    Get.back();

    Get.to(
          () => ResultScreen(inputText: text),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 350),
    );
  }

  Future<void> _pickMediaBottomSheet() async {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
        decoration: BoxDecoration(
          color: const Color(0xFF081B2C),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          border: Border.all(
            color: const Color(0xFF37C8FF).withOpacity(0.10),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF37C8FF).withOpacity(0.08),
              blurRadius: 18,
              spreadRadius: 1,
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 55,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                "Select Media",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Feed visual content into the AI scanner",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _MediaPickTile(
                      icon: Icons.image_rounded,
                      title: "Image",
                      onTap: () async {
                        Get.back();
                        await _pickImage();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MediaPickTile(
                      icon: Icons.videocam_rounded,
                      title: "Video",
                      onTap: () async {
                        Get.back();
                        await _pickVideo();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    Get.to(
          () => ResultScreen(mediaFile: File(picked.path)),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 350),
    );
  }

  Future<void> _pickVideo() async {
    final XFile? picked = await _picker.pickVideo(source: ImageSource.gallery);
    if (picked == null) return;
    Get.to(
          () => ResultScreen(mediaFile: File(picked.path)),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 350),
    );
  }

  @override
  Widget build(BuildContext context) {
    final m = MediaQuery.of(context);
    final bottomPad = m.padding.bottom;
    final hasText = inputCtrl.text.trim().isNotEmpty;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/bg.png",
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.22),
                    Colors.transparent,
                    const Color(0xFF061B2B).withOpacity(0.22),
                    const Color(0xFF061B2B).withOpacity(0.82),
                  ],
                  stops: const [0.0, 0.28, 0.62, 1.0],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.15),
                  radius: 1.05,
                  colors: [
                    const Color(0xFF37C8FF).withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF37C8FF).withOpacity(0.18),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF37C8FF).withOpacity(0.10),
                                  blurRadius: 12,
                                  spreadRadius: 1,
                                ),
                              ],
                              image: const DecorationImage(
                                image: AssetImage("assets/images/logo.png"),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Welcome back,",
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Obx(() {
                                final name = session.name.value.trim();
                                return Text(
                                  name.isEmpty ? "User" : name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                );
                              }),
                            ],
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              Get.to(
                                    () => NotificationScreen(),
                                transition: Transition.noTransition,
                                duration: Duration.zero,
                              );
                            },
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: Center(
                                child: Lottie.asset(
                                  "assets/images/notification_animation.json",
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.contain,
                                  repeat: true,
                                  animate: true,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF37C8FF).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: const Color(0xFF37C8FF).withOpacity(0.18),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF37C8FF).withOpacity(0.06),
                              blurRadius: 14,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_awesome_rounded,
                              size: 13,
                              color: Color(0xFF37C8FF),
                            ),
                            SizedBox(width: 6),
                            Text(
                              "AI Threat Intelligence",
                              style: TextStyle(
                                color: Color(0xFFC7F7FF),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.25,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Scan. Detect. Outsmart AI Scams.",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          height: 1.18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "Paste a link, suspicious message, or upload media to let your AI safety layer inspect it instantly.",
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildFeatures(),
                    ],
                  ),

                  Align(
                    alignment: const Alignment(0, 0.10),

                      child: Opacity(
                        opacity: 0.55,
                        child:   Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: 250,
                            height: 250,
                            child: Lottie.asset(
                              "assets/images/Flow_5.json",
                              fit: BoxFit.contain,
                              repeat: true,
                              animate: true,
                            ),
                          ),
                        ),
                      ),
                    ),


                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: bottomPad + 30),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedOpacity(
                            opacity: _isScanning ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 250),
                            child: const Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: _PulsingText("Analyzing..."),
                            ),
                          ),
                          const SizedBox(height: 14),
                          AnimatedBuilder(
                            animation: _orbitCtrl,
                            builder: (context, child) {
                              final angle = _orbitCtrl.value * 6.28318530718;
                              const orbitRadius = 132.0;

                              return SizedBox(
                                width: double.infinity,
                                height: 68,
                                child: Stack(
                                  alignment: Alignment.center,
                                  clipBehavior: Clip.none,
                                  children: [
                                    Positioned(
                                      left: (MediaQuery.of(context).size.width - 36 - 18 - 18) / 2 +
                                          orbitRadius * (0.88 * MathHelper.cos(angle)),
                                      top: 34 +
                                          orbitRadius * (0.18 * MathHelper.sin(angle)) -
                                          5,
                                      child: _OrbitDot(
                                        opacity: _isFocused ? 1.0 : 0.72,
                                      ),
                                    ),
                                    Positioned(
                                      left: (MediaQuery.of(context).size.width - 36 - 18 - 18) / 2 +
                                          orbitRadius *
                                              (0.88 * MathHelper.cos(angle + 2.094)),
                                      top: 34 +
                                          orbitRadius *
                                              (0.18 * MathHelper.sin(angle + 2.094)) -
                                          4,
                                      child: _OrbitDot(
                                        size: 7,
                                        opacity: _isFocused ? 0.95 : 0.58,
                                      ),
                                    ),
                                    Positioned(
                                      left: (MediaQuery.of(context).size.width - 36 - 18 - 18) / 2 +
                                          orbitRadius *
                                              (0.88 * MathHelper.cos(angle + 4.188)),
                                      top: 34 +
                                          orbitRadius *
                                              (0.18 * MathHelper.sin(angle + 4.188)) -
                                          4,
                                      child: _OrbitDot(
                                        size: 5.5,
                                        opacity: _isFocused ? 0.85 : 0.42,
                                      ),
                                    ),
                                    child!,
                                  ],
                                ),
                              );
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOutCubic,
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              height: 52,
                              decoration: BoxDecoration(
                                color: const Color(0xFF081A2A),
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: const Color(0xFF37C8FF)
                                      .withOpacity(_isFocused ? 0.90 : 0.62),
                                  width: _isFocused ? 1.4 : 1.1,
                                ),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    const Color(0xFF0E2235).withOpacity(0.98),
                                    const Color(0xFF081A2A).withOpacity(0.99),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF37C8FF).withOpacity(
                                      _isFocused ? 0.32 : 0.16,
                                    ),
                                    blurRadius: _isFocused ? 24 : 16,
                                    spreadRadius: _isFocused ? 1.2 : 0.5,
                                    offset: Offset.zero,
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.link_rounded,
                                    color: const Color(0xFF37C8FF).withOpacity(0.95),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Focus(
                                      onFocusChange: (hasFocus) =>
                                          setState(() => _isFocused = hasFocus),
                                      child: TextField(
                                        controller: inputCtrl,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        textInputAction: TextInputAction.search,
                                        onSubmitted: (_) => _goToResult(),
                                        cursorColor: const Color(0xFF37C8FF),
                                        decoration: InputDecoration(
                                          hintText:
                                          "Paste link, deal, or message for AI scan...",
                                          hintStyle: TextStyle(
                                            color: Colors.white.withOpacity(0.34),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400,
                                          ),
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: _pickMediaBottomSheet,
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      alignment: Alignment.center,
                                      child: Icon(
                                        Icons.camera_alt_rounded,
                                        color: const Color(0xFF37C8FF)
                                            .withOpacity(0.95),
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: _isScanning ? null : _goToResult,
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      alignment: Alignment.center,
                                      child: Icon(
                                        Icons.crop_free_rounded,
                                        color: const Color(0xFF37C8FF)
                                            .withOpacity(0.95),
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          _TrustIndicatorPlaceholder(hasText: hasText),
                        ],
                      ),
                    ),
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

class _OrbitDot extends StatelessWidget {
  const _OrbitDot({
    this.size = 8,
    this.opacity = 0.72,
  });

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF37C8FF).withOpacity(opacity),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF37C8FF).withOpacity(opacity * 0.75),
              blurRadius: 10,
              spreadRadius: 1.2,
            ),
          ],
        ),
      ),
    );
  }
}

class _TrustIndicatorPlaceholder extends StatelessWidget {
  const _TrustIndicatorPlaceholder({required this.hasText});
  final bool hasText;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasText
              ? const Color(0xFF37C8FF).withOpacity(0.20)
              : Colors.white.withOpacity(0.07),
        ),
        boxShadow: hasText
            ? [
          BoxShadow(
            color: const Color(0xFF37C8FF).withOpacity(0.06),
            blurRadius: 12,
            spreadRadius: 0.8,
          ),
        ]
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            Icons.shield_outlined,
            size: 14,
            color: hasText
                ? const Color(0xFF37C8FF).withOpacity(0.75)
                : Colors.white30,
          ),
          const SizedBox(width: 7),
          Text(
            hasText
                ? "Tap Scan to generate your AI trust score"
                : "Your AI trust score will appear here",
            style: TextStyle(
              color: hasText
                  ? const Color(0xFF37C8FF).withOpacity(0.78)
                  : Colors.white30,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanButton extends StatefulWidget {
  const _ScanButton({
    required this.isScanning,
    required this.scaleAnim,
    required this.onTap,
    required this.hasText,
  });

  final bool isScanning;
  final Animation<double> scaleAnim;
  final VoidCallback? onTap;
  final bool hasText;

  @override
  State<_ScanButton> createState() => _ScanButtonState();
}

class _ScanButtonState extends State<_ScanButton>
    with TickerProviderStateMixin {
  late final AnimationController _ringCtrl;
  late final Animation<double> _ringScale;
  late final Animation<double> _ringOpacity;

  late final AnimationController _rotCtrl;
  late final Animation<double> _rotAnim;

  late final AnimationController _glowCtrl;
  late final Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();

    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _ringScale = Tween<double>(begin: 1.0, end: 1.45).animate(
      CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOut),
    );
    _ringOpacity = Tween<double>(begin: 0.4, end: 0.0).animate(
      CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOut),
    );

    _rotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _rotAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _rotCtrl, curve: Curves.linear),
    );

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _glowAnim = Tween<double>(begin: 0.4, end: 0.9).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(_ScanButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.hasText && !oldWidget.hasText) {
      _ringCtrl.repeat();
      _rotCtrl.repeat();
      _glowCtrl.repeat(reverse: true);
    } else if (!widget.hasText && oldWidget.hasText) {
      _ringCtrl.stop();
      _rotCtrl.stop();
      _glowCtrl.stop();
    }
  }

  @override
  void dispose() {
    _ringCtrl.dispose();
    _rotCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          widget.scaleAnim,
          _ringScale,
          _ringOpacity,
          _rotAnim,
          _glowAnim,
        ]),
        builder: (context, _) {
          return Transform.scale(
            scale: widget.scaleAnim.value,
            child: SizedBox(
              width: 36,
              height: 36,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (!widget.isScanning && widget.hasText)
                    Transform.scale(
                      scale: _ringScale.value,
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFF37C8FF)
                                .withOpacity(_ringOpacity.value),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: widget.isScanning
                            ? [
                          const Color(0xFF37C8FF).withOpacity(0.6),
                          const Color(0xFF1A8FD1).withOpacity(0.6),
                        ]
                            : const [
                          Color(0xFF37C8FF),
                          Color(0xFF0E7FBF),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF37C8FF).withOpacity(
                            widget.isScanning
                                ? 0.15
                                : widget.hasText
                                ? _glowAnim.value * 0.7
                                : 0.1,
                          ),
                          blurRadius: 20,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: widget.isScanning
                        ? const Padding(
                      padding: EdgeInsets.all(11),
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                        : Stack(
                      alignment: Alignment.center,
                      children: [
                        if (widget.hasText)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment(
                                      -1.5 + _glowAnim.value * 3, -1),
                                  end: Alignment(
                                      0.5 + _glowAnim.value * 3, 1),
                                  colors: [
                                    Colors.white.withOpacity(0.0),
                                    Colors.white.withOpacity(0.22),
                                    Colors.white.withOpacity(0.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        widget.hasText
                            ? RotationTransition(
                          turns: _rotAnim,
                          child: const Icon(
                            Icons.radar_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        )
                            : const Icon(
                          Icons.radar_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AppLoadingView extends StatelessWidget {
  const _AppLoadingView();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Color(0xFF37C8FF),
          ),
          SizedBox(height: 16),
          Text(
            'Loading...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingText extends StatefulWidget {
  const _PulsingText(this.text);
  final String text;

  @override
  State<_PulsingText> createState() => _PulsingTextState();
}

class _PulsingTextState extends State<_PulsingText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.4, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Text(
        widget.text,
        style: const TextStyle(
          color: Color(0xFF37C8FF),
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _MediaPickTile extends StatelessWidget {
  const _MediaPickTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF37C8FF).withOpacity(0.12),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF37C8FF).withOpacity(0.05),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF37C8FF), size: 30),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildFeatures() {
  return Wrap(
    spacing: 8,
    runSpacing: 8,
    children: const [
      _FeatureChip(icon: Icons.lock_outline_rounded, label: "Private Shield"),
      _FeatureChip(icon: Icons.flash_on_rounded, label: "AI Detection"),
      _FeatureChip(icon: Icons.verified_outlined, label: "Trust Score"),
      _FeatureChip(icon: Icons.shield_outlined, label: "Scam Guard"),
    ],
  );
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF37C8FF).withOpacity(0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF37C8FF).withOpacity(0.03),
            blurRadius: 8,
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFF37C8FF)),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class MathHelper {
  static double sin(double x) => _Trig.sin(x);
  static double cos(double x) => _Trig.cos(x);
}

class _Trig {
  static double sin(double x) => mathSin(x);
  static double cos(double x) => mathCos(x);
}

double mathSin(double x) => _math.sin(x);
double mathCos(double x) => _math.cos(x);

final _math = _MathProxy();

class _MathProxy {
  double sin(double x) => dartMath.sin(x);
  double cos(double x) => dartMath.cos(x);
}

