import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/features/auth/provider/auth_provider.dart';
import 'package:go_router/go_router.dart';

class PlacementResultScreen extends ConsumerStatefulWidget {
  final double score;
  final String grade;

  const PlacementResultScreen({
    super.key,
    required this.score,
    required this.grade,
  });

  @override
  ConsumerState<PlacementResultScreen> createState() =>
      _PlacementResultScreenState();
}

class _PlacementResultScreenState extends ConsumerState<PlacementResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleCtrl;
  late AnimationController _countCtrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _countAnim;

  bool _isLoading = false;

  static const _grad = LinearGradient(
    colors: [Color(0xFF0D2B6B), Color(0xFF1A56DB), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();
    HapticFeedback.mediumImpact();

    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _countCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scaleAnim = CurvedAnimation(parent: _scaleCtrl, curve: Curves.elasticOut);
    _countAnim = CurvedAnimation(parent: _countCtrl, curve: Curves.easeOut);

    Future.delayed(const Duration(milliseconds: 200), () {
      _scaleCtrl.forward();
      _countCtrl.forward();
    });
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    _countCtrl.dispose();
    super.dispose();
  }

  Future<void> _mulai() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();

    await ref.read(authProvider.notifier).refreshUser();

    if (mounted) context.go('/student'); // langsung go, bukan pop
  }

  _GradeInfo _getGradeInfo(String grade) {
    switch (grade) {
      case 'A':
        return _GradeInfo(
          icon: Icons.emoji_events_rounded,
          color: const Color(0xFFF59E0B),
          label: 'Sangat Memuaskan',
          description:
              'Luar biasa! Pemahaman Anda sangat kuat. Anda siap menghadapi materi paling menantang.',
          bgColor: const Color(0xFFFFFBEB),
        );
      case 'AB':
        return _GradeInfo(
          icon: Icons.star_rounded,
          color: const Color(0xFF10B981),
          label: 'Memuaskan',
          description:
              'Hasil yang sangat baik! Anda memiliki fondasi yang kuat untuk berkembang lebih jauh.',
          bgColor: const Color(0xFFECFDF5),
        );
      case 'B':
        return _GradeInfo(
          icon: Icons.thumb_up_rounded,
          color: const Color(0xFF1A56DB),
          label: 'Baik',
          description:
              'Pemahaman Anda baik. Terus berlatih untuk mencapai hasil yang lebih optimal.',
          bgColor: const Color(0xFFEFF6FF),
        );
      case 'BC':
        return _GradeInfo(
          icon: Icons.trending_up_rounded,
          color: const Color(0xFF6366F1),
          label: 'Cukup Baik',
          description:
              'Anda berada di jalur yang tepat. Sedikit latihan lagi akan membawa perubahan besar.',
          bgColor: const Color(0xFFEEF2FF),
        );
      case 'C':
        return _GradeInfo(
          icon: Icons.school_rounded,
          color: const Color(0xFF8B5CF6),
          label: 'Cukup',
          description:
              'Fondasi sudah ada. Fokus pada konsep dasar untuk meningkatkan pemahaman Anda.',
          bgColor: const Color(0xFFF5F3FF),
        );
      case 'D':
        return _GradeInfo(
          icon: Icons.auto_graph_rounded,
          color: const Color(0xFFF97316),
          label: 'Kurang',
          description:
              'Jangan menyerah! Mulai dari konsep dasar dan bangun pemahamanmu secara bertahap.',
          bgColor: const Color(0xFFFFF7ED),
        );
      default: // E
        return _GradeInfo(
          icon: Icons.refresh_rounded,
          color: const Color(0xFFEF4444),
          label: 'Perlu Bimbingan',
          description:
              'Setiap ahli pernah menjadi pemula. Manfaatkan semua materi yang tersedia dan jangan ragu bertanya.',
          bgColor: const Color(0xFFFEF2F2),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = _getGradeInfo(widget.grade);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: Column(
        children: [
          // Header gradient
          Container(
            decoration: const BoxDecoration(gradient: _grad),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Row(
                  children: [
                    const Icon(Icons.school_rounded,
                        color: Colors.white70, size: 18),
                    const SizedBox(width: 8),
                    const Text(
                      'Hasil Placement Test',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Grade Badge animated
                  ScaleTransition(
                    scale: _scaleAnim,
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: info.bgColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: info.color.withOpacity(0.2),
                            blurRadius: 32,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                      child: Icon(info.icon, color: info.color, size: 64),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Level Anda',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    info.label,
                    style: const TextStyle(
                      color: Color(0xFF0D2B6B),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Score & Grade row
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Nilai',
                          child: AnimatedBuilder(
                            animation: _countAnim,
                            builder: (_, __) {
                              final displayed =
                                  widget.score * _countAnim.value;
                              return Text(
                                displayed.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: info.color,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: 'Grade',
                          child: ScaleTransition(
                            scale: _scaleAnim,
                            child: Text(
                              widget.grade,
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: info.color,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _GradeScaleCard(currentGrade: widget.grade),

                  const SizedBox(height: 16),

                  // Motivasi card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: info.bgColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: info.color.withOpacity(0.2), width: 1.5),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.format_quote_rounded,
                            color: info.color, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            info.description,
                            style: const TextStyle(
                              color: Color(0xFF1E3A5F),
                              fontSize: 14,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // CTA Button
                  GestureDetector(
                    onTap: _isLoading ? null : _mulai,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: _grad,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1A56DB).withOpacity(0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Mulai Belajar →',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GradeInfo {
  final IconData icon;
  final Color color;
  final String label;
  final String description;
  final Color bgColor;

  const _GradeInfo({
    required this.icon,
    required this.color,
    required this.label,
    required this.description,
    required this.bgColor,
  });
}

class _StatCard extends StatelessWidget {
  final String label;
  final Widget child;

  const _StatCard({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A56DB).withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          child,
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _GradeScaleCard extends StatelessWidget {
  final String currentGrade;

  const _GradeScaleCard({required this.currentGrade});

  static const _grades = [
    ('A', '≥ 79.5', Color(0xFFF59E0B)),
    ('AB', '72–79.4', Color(0xFF10B981)),
    ('B', '64.5–71.9', Color(0xFF1A56DB)),
    ('BC', '57–64.4', Color(0xFF6366F1)),
    ('C', '49.5–56.9', Color(0xFF8B5CF6)),
    ('D', '34–49.4', Color(0xFFF97316)),
    ('E', '< 34', Color(0xFFEF4444)),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Skala Penilaian',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Color(0xFF0D2B6B),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _grades.map((g) {
              final isMe = g.$1 == currentGrade;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isMe ? g.$3 : g.$3.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      isMe ? null : Border.all(color: g.$3.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      g.$1,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isMe ? Colors.white : g.$3,
                      ),
                    ),
                    Text(
                      g.$2,
                      style: TextStyle(
                        fontSize: 10,
                        color:
                            isMe ? Colors.white70 : g.$3.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}