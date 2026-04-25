import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../main.dart'; // routeObserver ka correct path lagao

class VideoBackground extends StatefulWidget {
  const VideoBackground({super.key});

  @override
  State<VideoBackground> createState() => _VideoBackgroundState();
}

class _VideoBackgroundState extends State<VideoBackground>
    with RouteAware, WidgetsBindingObserver {
  static VideoPlayerController? _fwdCtrl;
  static VideoPlayerController? _revCtrl;
  static Future<void>? _initFuture;

  bool _showForward = true;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initVideos();
  }

  Future<void> _initVideos() async {
    _initFuture ??= _createControllers();

    await _initFuture;
    if (!mounted) return;

    setState(() => _initialized = true);
    _restartLoop();
  }

  static Future<void> _createControllers() async {
    final fwd = VideoPlayerController.asset("assets/vedio/vedio1.mp4");
    await fwd.initialize();
    await fwd.setVolume(0);
    await fwd.setLooping(false);

    _fwdCtrl = fwd;

    try {
      final rev = VideoPlayerController.asset("assets/vedio/reverseV1.mp4");
      await rev.initialize();
      await rev.setVolume(0);
      await rev.setLooping(false);
      _revCtrl = rev;
    } catch (e) {
      debugPrint("Reverse video error: $e");
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  void _restartLoop() async {
    final fwd = _fwdCtrl;
    final rev = _revCtrl;

    if (fwd == null || !mounted) return;

    fwd.removeListener(_onForwardEnd);
    rev?.removeListener(_onReverseEnd);

    await fwd.pause();
    await rev?.pause();

    await fwd.seekTo(Duration.zero);
    await rev?.seekTo(Duration.zero);

    if (!mounted) return;

    setState(() => _showForward = true);

    fwd.addListener(_onForwardEnd);
    await fwd.play();
  }

  void _onForwardEnd() {
    final ctrl = _fwdCtrl;
    if (ctrl == null || !mounted) return;

    final pos = ctrl.value.position;
    final dur = ctrl.value.duration;

    if (dur.inMilliseconds > 0 &&
        pos.inMilliseconds >= dur.inMilliseconds - 150) {
      ctrl.removeListener(_onForwardEnd);
      ctrl.pause();

      if (_revCtrl != null) {
        _playReverse();
      } else {
        _restartLoop();
      }
    }
  }

  void _playReverse() async {
    final rev = _revCtrl;
    if (rev == null || !mounted) return;

    rev.removeListener(_onReverseEnd);

    await rev.seekTo(Duration.zero);
    if (!mounted) return;

    setState(() => _showForward = false);

    rev.addListener(_onReverseEnd);
    await rev.play();
    await _fwdCtrl?.seekTo(Duration.zero);
  }

  void _onReverseEnd() {
    final ctrl = _revCtrl;
    if (ctrl == null || !mounted) return;

    final pos = ctrl.value.position;
    final dur = ctrl.value.duration;

    if (dur.inMilliseconds > 0 &&
        pos.inMilliseconds >= dur.inMilliseconds - 150) {
      ctrl.removeListener(_onReverseEnd);
      ctrl.pause();
      _restartLoop();
    }
  }

  @override
  void didPopNext() {
    // EditProfile se back aane ke baad Profile wali video dobara play hogi
    _restartLoop();
  }

  @override
  void didPush() {
    _restartLoop();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _restartLoop();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _fwdCtrl?.pause();
      _revCtrl?.pause();
    }
  }

  Widget _buildVideo(VideoPlayerController ctrl) {
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: ctrl.value.size.width,
          height: ctrl.value.size.height,
          child: VideoPlayer(ctrl),
        ),
      ),
    );
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);

    _fwdCtrl?.removeListener(_onForwardEnd);
    _revCtrl?.removeListener(_onReverseEnd);

    // Static controllers dispose nahi kar rahe,
    // taake Profile/Edit ke darmiyan video reload na ho.

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const cyan = Color(0xFF2CC7FF);

    final fwd = _fwdCtrl;
    final rev = _revCtrl;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (_initialized && fwd != null) ...[
          Positioned.fill(
            child: Opacity(
              opacity: _showForward ? 1.0 : 0.0,
              child: _buildVideo(fwd),
            ),
          ),
          if (rev != null)
            Positioned.fill(
              child: Opacity(
                opacity: _showForward ? 0.0 : 1.0,
                child: _buildVideo(rev),
              ),
            ),
        ] else
          Positioned.fill(child: Container(color: Colors.black)),

        Positioned.fill(
          child: Container(color: Colors.black.withOpacity(0.45)),
        ),

        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.3),
                radius: 1.2,
                colors: [
                  cyan.withOpacity(0.10),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}