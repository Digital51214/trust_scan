import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:social_saver/services/notification_service.dart';
import 'package:social_saver/session/session_controller.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool notificationsEnabled = true;
  bool isLoading = true;
  String errorMsg = "";
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _loadNotificationSetting();
    if (notificationsEnabled) {
      await _loadNotifications();
    }
  }

  Future<void> _loadNotificationSetting() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    });
  }

  // ── Fetch notifications from API ──────────────────────────────
  Future<void> _loadNotifications() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMsg = "";
    });

    final session = SessionController.instance;
    session.loadSession();
    final int userId = session.userId.value;

    if (userId <= 0) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMsg = "User not logged in";
      });
      return;
    }

    final result = await NotificationService.fetchNotifications(userId: userId);
    if (!mounted) return;

    final ok = result["status"] == true;
    final data = result["data"];

    if (!ok) {
      setState(() {
        isLoading = false;
        errorMsg = (result["message"] ?? "Failed to fetch notifications").toString();
        notifications = [];
      });
      return;
    }

    setState(() {
      notifications = data is List
          ? List<Map<String, dynamic>>.from(data)
          : [];
      isLoading = false;
    });
  }

  // ── Helpers ──────────────────────────────────────────────────
  String _timeAgo(String? dateAdded) {
    if (dateAdded == null || dateAdded.trim().isEmpty) return "";
    final parsed = DateTime.tryParse(dateAdded);
    if (parsed == null) return dateAdded;

    final diff = DateTime.now().difference(parsed);
    if (diff.inSeconds < 60) return "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes} min Ago";
    if (diff.inHours < 24) return "${diff.inHours} hr Ago";
    return "${diff.inDays} day${diff.inDays == 1 ? '' : 's'} Ago";
  }

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

                    if (isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 80),
                          child: CircularProgressIndicator(
                            color: Color(0xFF00CFFF),
                          ),
                        ),
                      )
                    else if (!notificationsEnabled)
                      const _NotificationsOffView()
                    else if (errorMsg.isNotEmpty)
                        _ErrorView(
                          message: errorMsg,
                          onRetry: _loadNotifications,
                        )
                      else if (notifications.isEmpty)
                          const _EmptyView()
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: notifications.length,
                            separatorBuilder: (context, index) =>
                            const SizedBox(height: 15),
                            itemBuilder: (context, index) {
                              final item = notifications[index];
                              final title =
                              (item["title"] ?? "Notification").toString();
                              final description =
                              (item["description"] ?? "").toString();
                              final status =
                              (item["status"] ?? "").toString();
                              final time = _timeAgo(
                                  item["date_added"]?.toString());

                              return NotificationCard(
                                title: title,
                                description: description,
                                time: time,
                                isUnread: status.toLowerCase() == "unread",
                              );
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

/* ===================== NOTIFICATIONS OFF VIEW ===================== */

class _NotificationsOffView extends StatelessWidget {
  const _NotificationsOffView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 90),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
          decoration: BoxDecoration(
            color: const Color(0xFF051325).withOpacity(0.88),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFF00CFFF).withOpacity(0.45),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00CFFF).withOpacity(0.25),
                blurRadius: 16,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                  border: Border.all(
                    color: const Color(0xFF00CFFF).withOpacity(0.35),
                  ),
                ),
                child: const Icon(
                  Icons.notifications_off_rounded,
                  color: Color(0xFF00CFFF),
                  size: 34,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                "Notifications are turned off",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "Turn them on from Settings to see new alerts here.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.65),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ===================== EMPTY VIEW ===================== */

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 90),
        child: Column(
          children: [
            Icon(
              Icons.notifications_none_rounded,
              color: Colors.white.withOpacity(0.4),
              size: 42,
            ),
            const SizedBox(height: 14),
            Text(
              "No notifications yet",
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ===================== ERROR VIEW ===================== */

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 90),
        child: Column(
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Colors.redAccent, size: 36),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.75),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFF2CC7FF).withOpacity(0.25)),
                ),
                child: const Text(
                  "Retry",
                  style: TextStyle(
                    color: Color(0xFF2CC7FF),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ===================== NOTIFICATION CARD ===================== */

class NotificationCard extends StatelessWidget {
  final String title;
  final String description;
  final String time;
  final bool isUnread;

  const NotificationCard({
    super.key,
    required this.title,
    required this.description,
    required this.time,
    this.isUnread = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF051325),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFF00CFFF),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF00CFFF),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
            ),
            child: Icon(
              isUnread
                  ? Icons.warning_amber_rounded
                  : Icons.check_circle_outline_rounded,
              color: isUnread ? Colors.redAccent : Colors.white70,
              size: 24,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                if (description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 8),

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