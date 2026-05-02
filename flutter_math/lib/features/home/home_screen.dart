import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/features/learning/provider/learning_provider.dart';
import 'package:flutter_math/features/learning/screen/material_detail_screen.dart';
import 'package:flutter_math/features/auth/provider/auth_provider.dart';
import 'package:flutter_math/features/exam/screen/assignment_list_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topicsAsync = ref.watch(topicsProvider);
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F6FF),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Collapsible Header ──────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFF1A5FD4),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1A40A8),
                      Color(0xFF2D6EE8),
                      Color(0xFF4B8EFF),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 16, 22, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Center(
                                child: Text(
                                  "∑",
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "ALIN",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 4,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text(
                          "Halo, ${user?.name ?? 'Mahasiswa'}! 👋",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Siap belajar Aljabar Linear hari ini?",
                          style: TextStyle(
                            fontSize: 13.5,
                            color: Colors.white.withOpacity(0.80),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  onPressed: () => _confirmLogout(context, ref),
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.logout_rounded,
                        color: Colors.white, size: 20),
                  ),
                  tooltip: "Keluar",
                ),
              ),
            ],
          ),

          // ── Body Content ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Assignment Banner ────────────────────────────
                  _AssignmentBanner(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AssignmentListScreen()),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Section Title ────────────────────────────────
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFF4B8EFF), Color(0xFF1A5FD4)],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Topik Materi",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F2D6B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 14),
                    child: Text(
                      "Pilih topik untuk mulai belajar",
                      style: TextStyle(
                          fontSize: 12.5, color: Colors.grey[500]),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),

          // ── Topics List ──────────────────────────────────────────────
          topicsAsync.when(
            data: (topics) => SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final topic = topics[index];
                    return _TopicCard(
                      index: index,
                      orderIndex: topic.orderIndex,
                      title: topic.title,
                      description: topic.description ?? "",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MaterialDetailScreen(
                            topicId: topic.id,
                            topicTitle: topic.title,
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: topics.length,
                ),
              ),
            ),
            loading: () => const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF2D6EE8),
                  strokeWidth: 3,
                ),
              ),
            ),
            error: (err, stack) => SliverFillRemaining(
              child: _ErrorState(message: err.toString()),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Keluar dari Akun?",
          style: TextStyle(
              fontWeight: FontWeight.w800, color: Color(0xFF0F2D6B)),
        ),
        content: Text(
          "Kamu akan keluar dari sesi belajarmu sekarang.",
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal",
                style: TextStyle(color: Color(0xFF4B8EFF))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A5FD4),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authProvider.notifier).logout();
            },
            child: const Text("Keluar",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── Assignment Banner ────────────────────────────────────────────────────────
class _AssignmentBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _AssignmentBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2D6EE8), Color(0xFF4B8EFF)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A5FD4).withOpacity(0.30),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.20),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.quiz_rounded,
                  color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Ada tugas untukmu!",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "Buka daftar ujian sekarang",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.80),
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Buka",
                style: TextStyle(
                  color: Color(0xFF1A5FD4),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Topic Card ───────────────────────────────────────────────────────────────
class _TopicCard extends StatefulWidget {
  final int index;
  final int orderIndex;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _TopicCard({
    required this.index,
    required this.orderIndex,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  State<_TopicCard> createState() => _TopicCardState();
}

class _TopicCardState extends State<_TopicCard> {
  bool _pressed = false;

  // Cycle through subtle blue shades for variety
  static const List<List<Color>> _iconGradients = [
    [Color(0xFF4B8EFF), Color(0xFF1A5FD4)],
    [Color(0xFF34B3F1), Color(0xFF1A7FC4)],
    [Color(0xFF7C9EFF), Color(0xFF3B5FD4)],
    [Color(0xFF50C4D4), Color(0xFF1A90A8)],
  ];

  @override
  Widget build(BuildContext context) {
    final gradient =
        _iconGradients[widget.index % _iconGradients.length];

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4B8EFF).withOpacity(0.09),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Order badge
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradient,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      "${widget.orderIndex}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Title & description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                          color: Color(0xFF0F2D6B),
                        ),
                      ),
                      if (widget.description.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          widget.description,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.grey[500],
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Arrow
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F6FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: Color(0xFF4B8EFF),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Error State ──────────────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.cloud_off_rounded,
                  color: Color(0xFFE53935), size: 36),
            ),
            const SizedBox(height: 16),
            const Text(
              "Gagal memuat data",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Color(0xFF0F2D6B),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}