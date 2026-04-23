// import 'package:flutter/material.dart';
// import 'package:social_saver/services/history_service.dart';
// import 'package:social_saver/session/session_controller.dart';
//
// class HistoryScreen extends StatefulWidget {
//   const HistoryScreen({super.key});
//
//   @override
//   State<HistoryScreen> createState() => _HistoryScreenState();
// }
//
// class _HistoryScreenState extends State<HistoryScreen> {
//   bool isLoading = true;
//   String errorMsg = "";
//   List<Map<String, dynamic>> items = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _loadHistory();
//   }
//
//   Future<void> _loadHistory() async {
//     setState(() {
//       isLoading = true;
//       errorMsg = "";
//       items = [];
//     });
//
//     final session = SessionController.instance;
//
//     // ✅ MUST: refresh session from storage
//     session.loadSession();
//
//     final int userId = session.userId.value;
//
//     print("🟦 HISTORY -> userId=$userId | loggedIn=${session.isLoggedIn.value}");
//
//     if (userId <= 0) {
//       setState(() {
//         isLoading = false;
//         errorMsg = "User not logged in";
//       });
//       return;
//     }
//
//     final result = await HistoryService.fetchHistory(userId: userId);
//
//     final ok = result["status"] == true;
//     final msg = (result["message"] ?? "").toString();
//
//     if (!ok) {
//       setState(() {
//         isLoading = false;
//         errorMsg = msg.isEmpty ? "Failed to fetch history" : msg;
//       });
//       return;
//     }
//
//     final data = result["data"];
//     if (data is List) {
//       setState(() {
//         items = data
//             .whereType<Map>()
//             .map((e) => Map<String, dynamic>.from(e))
//             .toList();
//         isLoading = false;
//       });
//     } else {
//       setState(() {
//         isLoading = false;
//         errorMsg = "Invalid history response";
//       });
//     }
//   }
//
//   int _extractRiskScore(String s) {
//     final m = RegExp(r'Risk Score:\s*(\d+)').firstMatch(s);
//     return int.tryParse(m?.group(1) ?? "0") ?? 0;
//   }
//
//   bool _isHighRisk(String scanResult) {
//     final sr = scanResult.toLowerCase();
//     final score = _extractRiskScore(scanResult);
//     if (sr.contains("phishing: 1") || sr.contains("suspicious: 1")) return true;
//     if (score >= 50) return true;
//     return false;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     const bg = Color(0xFF061B2B);
//     const cyan = Color(0xFF2CC7FF);
//
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       body: Stack(
//         fit: StackFit.expand,
//         children: [
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
//           SafeArea(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 6),
//                   const Text(
//                     "History",
//                     style: TextStyle(
//                       fontSize: 28,
//                       fontWeight: FontWeight.w900,
//                       color: Colors.white,
//                     ),
//                   ),
//                   const SizedBox(height: 18),
//
//                   // ✅ Search Bar (UI same)
//                   Container(
//                     height: 50,
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.06),
//                       borderRadius: BorderRadius.circular(26),
//                       border: Border.all(
//                         color: Colors.white.withOpacity(0.10),
//                         width: 1,
//                       ),
//                     ),
//                     child: Row(
//                       children: [
//                         const Icon(Icons.search_rounded,
//                             color: Colors.white70, size: 22),
//                         const SizedBox(width: 10),
//                         Text(
//                           "Search...",
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.white.withOpacity(0.65),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   const SizedBox(height: 36),
//
//                   if (isLoading)
//                     Center(
//                       child: Padding(
//                         padding: const EdgeInsets.only(top: 40),
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2.5,
//                           valueColor: AlwaysStoppedAnimation<Color>(
//                             Colors.white.withOpacity(0.9),
//                           ),
//                         ),
//                       ),
//                     )
//                   else if (errorMsg.isNotEmpty)
//                     Center(
//                       child: Padding(
//                         padding: const EdgeInsets.only(top: 40),
//                         child: Column(
//                           children: [
//                             Text(
//                               errorMsg,
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                 color: Colors.white.withOpacity(0.85),
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                             const SizedBox(height: 14),
//                             GestureDetector(
//                               onTap: _loadHistory,
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 18, vertical: 10),
//                                 decoration: BoxDecoration(
//                                   color: Colors.white.withOpacity(0.10),
//                                   borderRadius: BorderRadius.circular(12),
//                                   border: Border.all(
//                                     color: Colors.white.withOpacity(0.18),
//                                   ),
//                                 ),
//                                 child: const Text(
//                                   "Retry",
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.w800,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     )
//                   else if (items.isEmpty)
//                       Center(
//                         child: Padding(
//                           padding: const EdgeInsets.only(top: 40),
//                           child: Text(
//                             "No history found",
//                             style: TextStyle(
//                               color: Colors.white.withOpacity(0.75),
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       )
//                     else
//                       Column(
//                         children: [
//                           for (int i = 0; i < items.length; i++) ...[
//                             _buildCard(items[i], cyan),
//                             if (i != items.length - 1) const SizedBox(height: 14),
//                           ],
//                         ],
//                       ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCard(Map<String, dynamic> it, Color cyan) {
//     final url = (it["url"] ?? "").toString();
//     final scanResult = (it["scan_result"] ?? "").toString();
//     final createdAt = (it["created_at"] ?? "").toString();
//
//     final highRisk = _isHighRisk(scanResult);
//
//     final iconBg = highRisk ? const Color(0xFF1B2F47) : const Color(0xFF102E45);
//     final icon = highRisk ? Icons.warning_rounded : Icons.verified_user_rounded;
//     final iconColor =
//     highRisk ? const Color(0xFFE85B5B) : const Color(0xFF2CC7FF);
//
//     final tagText = highRisk ? "High Risk" : "Safe";
//     final tagBg = highRisk ? const Color(0xFF3A2A3A) : const Color(0xFF10344B);
//     final tagTextColor =
//     highRisk ? const Color(0xFFE85B5B) : const Color(0xFF2CC7FF);
//
//     return _HistoryCard(
//       iconBg: iconBg,
//       icon: icon,
//       iconColor: iconColor,
//       title: "Account verification",
//       subtitle: url,
//       time: createdAt,
//       action: "Link Check",
//       tagText: tagText,
//       tagBg: tagBg,
//       tagTextColor: tagTextColor,
//       borderColor: cyan,
//     );
//   }
// }
//
// /* ======================= CARD (same UI) ======================= */
//
// class _HistoryCard extends StatelessWidget {
//   const _HistoryCard({
//     required this.iconBg,
//     required this.icon,
//     required this.iconColor,
//     required this.title,
//     required this.subtitle,
//     required this.time,
//     required this.action,
//     required this.tagText,
//     required this.tagBg,
//     required this.tagTextColor,
//     required this.borderColor,
//   });
//
//   final Color iconBg;
//   final IconData icon;
//   final Color iconColor;
//
//   final String title;
//   final String subtitle;
//   final String time;
//   final String action;
//
//   final String tagText;
//   final Color tagBg;
//   final Color tagTextColor;
//
//   final Color borderColor;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(14),
//         color: const Color(0xFF0A2235).withOpacity(0.55),
//         border: Border.all(
//           color: borderColor.withOpacity(0.7),
//           width: 1.2,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.25),
//             blurRadius: 12,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 44,
//             height: 44,
//             decoration: BoxDecoration(
//               color: iconBg,
//               shape: BoxShape.circle,
//             ),
//             child: Icon(icon, color: iconColor, size: 22),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Text(
//                         title,
//                         style: const TextStyle(
//                           fontSize: 14.5,
//                           fontWeight: FontWeight.w800,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                       decoration: BoxDecoration(
//                         color: tagBg,
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Text(
//                         tagText,
//                         style: TextStyle(
//                           fontSize: 11.5,
//                           fontWeight: FontWeight.w800,
//                           color: tagTextColor,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 5),
//                 Text(
//                   subtitle,
//                   style: TextStyle(
//                     fontSize: 12.5,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.white.withOpacity(0.65),
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Row(
//                   children: [
//                     Text(
//                       time,
//                       style: TextStyle(
//                         fontSize: 11.5,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.white.withOpacity(0.55),
//                       ),
//                     ),
//                     const SizedBox(width: 6),
//                     Text(
//                       action,
//                       style: TextStyle(
//                         fontSize: 11.5,
//                         fontWeight: FontWeight.w800,
//                         color: Colors.white.withOpacity(0.70),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:social_saver/services/history_service.dart';
import 'package:social_saver/session/session_controller.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool isLoading = true;
  String errorMsg = "";
  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      isLoading = true;
      errorMsg = "";
      items = [];
    });

    final session = SessionController.instance;

    session.loadSession();

    final int userId = session.userId.value;

    print("HISTORY -> userId=$userId | loggedIn=${session.isLoggedIn.value}");

    if (userId <= 0) {
      setState(() {
        isLoading = false;
        errorMsg = "User not logged in";
      });
      return;
    }

    final result = await HistoryService.fetchHistory(userId: userId);

    final ok = result["status"] == true;
    final msg = (result["message"] ?? "").toString();

    if (!ok) {
      setState(() {
        isLoading = false;
        errorMsg = msg.isEmpty ? "Failed to fetch history" : msg;
      });
      return;
    }

    final data = result["data"];
    if (data is List) {
      setState(() {
        items = data
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
        errorMsg = "Invalid history response";
      });
    }
  }

  int _extractRiskScore(String s) {
    final m = RegExp(r'Risk Score:\s*(\d+)').firstMatch(s);
    return int.tryParse(m?.group(1) ?? "0") ?? 0;
  }

  bool _isHighRisk(String scanResult) {
    final sr = scanResult.toLowerCase();
    final score = _extractRiskScore(scanResult);
    if (sr.contains("phishing: 1") || sr.contains("suspicious: 1")) return true;
    if (score >= 50) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF061B2B);
    const cyan = Color(0xFF2CC7FF);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0D5E7D),
                  bg,
                  Color(0xFF020A14),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.2),
                radius: 1.2,
                colors: [
                  const Color(0xFF2CC7FF).withOpacity(0.10),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  const Text(
                    "History Scan Intelligence",
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 18),

                  Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color: const Color(0xFF2CC7FF).withOpacity(0.20),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2CC7FF).withOpacity(0.08),
                          blurRadius: 14,
                          spreadRadius: 0.5,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search_rounded,
                          color: Color(0xFF2CC7FF),
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Search scanned activity...",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.55),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),

                  if (isLoading)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF2CC7FF),
                          ),
                        ),
                      ),
                    )
                  else if (errorMsg.isNotEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Column(
                          children: [
                            Text(
                              errorMsg,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 14),
                            GestureDetector(
                              onTap: _loadHistory,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF2CC7FF),
                                      Color(0xFF0E7FBF),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF2CC7FF)
                                          .withOpacity(0.30),
                                      blurRadius: 12,
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  "Retry Scan",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (items.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Text(
                            "No AI scans found",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.75),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                    else
                      Column(
                        children: [
                          for (int i = 0; i < items.length; i++) ...[
                            _buildCard(items[i], cyan),
                            if (i != items.length - 1)
                              const SizedBox(height: 14),
                          ],
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

  Widget _buildCard(Map<String, dynamic> it, Color cyan) {
    final url = (it["url"] ?? "").toString();
    final scanResult = (it["scan_result"] ?? "").toString();
    final createdAt = (it["created_at"] ?? "").toString();

    final highRisk = _isHighRisk(scanResult);

    final iconBg = highRisk ? const Color(0xFF1B2F47) : const Color(0xFF102E45);
    final icon = highRisk ? Icons.warning_rounded : Icons.verified_user_rounded;
    final iconColor =
    highRisk ? const Color(0xFFE85B5B) : const Color(0xFF2CC7FF);

    final tagText = highRisk ? "High Risk" : "Safe";
    final tagBg = highRisk ? const Color(0xFF3A2A3A) : const Color(0xFF10344B);
    final tagTextColor =
    highRisk ? const Color(0xFFE85B5B) : const Color(0xFF2CC7FF);

    return _HistoryCard(
      iconBg: iconBg,
      icon: icon,
      iconColor: iconColor,
      title: "AI Account Verification",
      subtitle: url,
      time: createdAt,
      action: "Link Scan",
      tagText: tagText,
      tagBg: tagBg,
      tagTextColor: tagTextColor,
      borderColor: cyan,
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.iconBg,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.action,
    required this.tagText,
    required this.tagBg,
    required this.tagTextColor,
    required this.borderColor,
  });

  final Color iconBg;
  final IconData icon;
  final Color iconColor;

  final String title;
  final String subtitle;
  final String time;
  final String action;

  final String tagText;
  final Color tagBg;
  final Color tagTextColor;

  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0xFF0A2235).withOpacity(0.55),
        border: Border.all(
          color: borderColor.withOpacity(0.7),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2CC7FF).withOpacity(0.08),
            blurRadius: 18,
            spreadRadius: 0.5,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: iconColor.withOpacity(0.18),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.15,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: tagBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: tagTextColor.withOpacity(0.18),
                        ),
                      ),
                      child: Text(
                        tagText,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: tagTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.65),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.55),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      action,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white.withOpacity(0.70),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}