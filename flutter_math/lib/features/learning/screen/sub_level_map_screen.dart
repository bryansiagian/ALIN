import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/features/learning/provider/learning_provider.dart';
import 'package:flutter_math/features/learning/screen/level_play_screen.dart';

class SubLevelMapScreen extends ConsumerWidget {
  final String topicTitle;
  final int topicOrderIndex;

  const SubLevelMapScreen({
    Key? key,
    required this.topicTitle,
    required this.topicOrderIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int actualUserLevel = ref.watch(unlockedLevelProvider);

    int startLevel = (topicOrderIndex - 1) * 100;
    int completedInThisTopic = (actualUserLevel - startLevel).clamp(0, 100);
    double progressPercent = completedInThisTopic / 100;

    return Scaffold(
      // Latar belakang Biru Muda Tipis yang Segar
      backgroundColor: const Color(0xFFF5FAFF),
      body: Stack(
        children: [
          // 1. AREA MAP (SCROLLABLE)
          _buildMapContent(context, actualUserLevel),

          // 2. STICKY HEADER
          _buildStickyHeader(context, progressPercent, completedInThisTopic),
        ],
      ),
    );
  }

  Widget _buildMapContent(BuildContext context, int actualUserLevel) {
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.only(top: 230, bottom: 100),
      itemCount: 100,
      itemBuilder: (context, index) {
        final int localLevel = index + 1;
        final int globalLevelOfButton =
            ((topicOrderIndex - 1) * 100) + localLevel;

        final bool isLocked = globalLevelOfButton > actualUserLevel;
        final bool isActive = globalLevelOfButton == actualUserLevel;
        final bool isPassed = globalLevelOfButton < actualUserLevel;

        Alignment alignment;
        int pos = index % 4;
        if (pos == 0)
          alignment = Alignment.centerLeft;
        else if (pos == 1 || pos == 3)
          alignment = Alignment.center;
        else
          alignment = Alignment.centerRight;

        return Container(
          height: 160,
          child: Stack(
            children: [
              if (index < 99)
                CustomPaint(
                  size: const Size(double.infinity, 160),
                  painter: DashedLinePainter(
                    currentIndex: index,
                    isPassed: isPassed || isActive,
                  ),
                ),
              Align(
                alignment: alignment,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: _LevelNodeWrapper(
                    levelNumber: globalLevelOfButton,
                    isLocked: isLocked,
                    isActive: isActive,
                    isPassed: isPassed,
                    onTap: () {
                      if (!isLocked) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                LevelPlayScreen(level: globalLevelOfButton),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStickyHeader(BuildContext context, double progress, int count) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.only(bottom: 25),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF1E88E5), Color(0xFF42A5F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(35),
            bottomRight: Radius.circular(35),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 18,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            topicTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            "Level Progress: $count/100",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF00E5FF),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelNodeWrapper extends StatefulWidget {
  final int levelNumber;
  final bool isLocked;
  final bool isActive;
  final bool isPassed;
  final VoidCallback onTap;

  const _LevelNodeWrapper({
    required this.levelNumber,
    required this.isLocked,
    required this.isActive,
    required this.isPassed,
    required this.onTap,
  });

  @override
  State<_LevelNodeWrapper> createState() => _LevelNodeWrapperState();
}

class _LevelNodeWrapperState extends State<_LevelNodeWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.isActive
        ? ScaleTransition(scale: _animation, child: _buildNode())
        : _buildNode();
  }

  Widget _buildNode() {
    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 75,
            height: 75,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.isActive
                      ? const Color(0xFF00E5FF).withOpacity(0.4)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: widget.isLocked
                      ? [
                          Colors.grey[300]!,
                          Colors.grey[500]!,
                        ] // Locked: Abu-abu solid tapi tidak terlalu gelap
                      : (widget.isActive
                            ? [
                                const Color(0xFF00E5FF),
                                const Color(0xFF007BFF),
                              ] // Active: Biru Elektrik
                            : [
                                const Color(0xFF64B5F6),
                                const Color(0xFF1E88E5),
                              ]), // Passed: Biru Cerah
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: Colors.white,
                  width: widget.isActive ? 4 : 3,
                ),
              ),
              child: Center(
                child: widget.isLocked
                    ? const Icon(
                        Icons.lock_rounded,
                        color: Colors.white70,
                        size: 24,
                      )
                    : (widget.isPassed
                          ? const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 35,
                            )
                          : Text(
                              "${widget.levelNumber}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            )),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Level ${widget.levelNumber}",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: widget.isLocked
                  ? Colors.grey[600]
                  : const Color(0xFF1565C0),
            ),
          ),
        ],
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final int currentIndex;
  final bool isPassed;

  DashedLinePainter({required this.currentIndex, required this.isPassed});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      // Jika sudah dilewati: Biru Transparan. Jika belum: Abu-abu redup (Opacity 0.2)
      ..color = isPassed
          ? const Color(0xFF2196F3).withOpacity(0.4)
          : Colors.blueGrey.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    double startX = _getXPos(currentIndex, size.width);
    double endX = _getXPos(currentIndex + 1, size.width);

    Offset start = Offset(startX, size.height / 2);
    Offset end = Offset(endX, -size.height / 2);

    Path path = Path();
    path.moveTo(start.dx, start.dy);
    path.cubicTo(start.dx, start.dy - 70, end.dx, end.dy + 70, end.dx, end.dy);

    const double dashWidth = 10.0;
    const double dashSpace = 10.0;
    double distance = 0.0;

    for (PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        canvas.drawPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  double _getXPos(int index, double width) {
    int pos = index % 4;
    if (pos == 0) return 85;
    if (pos == 1 || pos == 3) return width / 2;
    return width - 85;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
