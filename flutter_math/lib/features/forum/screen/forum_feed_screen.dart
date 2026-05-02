import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/features/forum/service/forum_service.dart';

class ForumFeedScreen extends ConsumerWidget {
  const ForumFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threadsAsync = ref.watch(threadsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F6FF),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App Bar ─────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFF1A5FD4),
            expandedHeight: 120,
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
                    padding: const EdgeInsets.fromLTRB(22, 12, 22, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          "Forum Diskusi",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Tanya, diskusi, dan bantu sesama",
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.white.withOpacity(0.78),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Content ─────────────────────────────────────────────────
          threadsAsync.when(
            data: (threads) => _ThreadList(
              threads: threads,
              onRefresh: () => ref.refresh(threadsProvider.future),
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
      floatingActionButton: _ComposeFAB(
        onTap: () => _showCreatePostModal(context, ref),
      ),
    );
  }

  void _showCreatePostModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CreatePostSheet(ref: ref),
    );
  }
}

// ── Thread List ──────────────────────────────────────────────────────────────
class _ThreadList extends StatelessWidget {
  final List threads;
  final Future<void> Function() onRefresh;

  const _ThreadList({required this.threads, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    if (threads.isEmpty) {
      return const SliverFillRemaining(child: _EmptyState());
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == 0) {
              return _RefreshHint(onRefresh: onRefresh);
            }
            final post = threads[index - 1];
            return _ThreadCard(post: post);
          },
          childCount: threads.length + 1,
        ),
      ),
    );
  }
}

// ── Refresh Hint ─────────────────────────────────────────────────────────────
class _RefreshHint extends StatelessWidget {
  final Future<void> Function() onRefresh;
  const _RefreshHint({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Postingan Terbaru",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          GestureDetector(
            onTap: onRefresh,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFDCEAFF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.refresh_rounded,
                      size: 14, color: Color(0xFF1A5FD4)),
                  SizedBox(width: 4),
                  Text(
                    "Refresh",
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF1A5FD4),
                      fontWeight: FontWeight.w600,
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

// ── Thread Card ──────────────────────────────────────────────────────────────
class _ThreadCard extends StatefulWidget {
  final dynamic post;
  const _ThreadCard({required this.post});

  @override
  State<_ThreadCard> createState() => _ThreadCardState();
}

class _ThreadCardState extends State<_ThreadCard> {
  bool _pressed = false;

  // Deterministic avatar gradient from name initial
  static const List<List<Color>> _avatarGradients = [
    [Color(0xFF4B8EFF), Color(0xFF1A5FD4)],
    [Color(0xFF34B3F1), Color(0xFF1A7FC4)],
    [Color(0xFF7C9EFF), Color(0xFF3B5FD4)],
    [Color(0xFF50C4D4), Color(0xFF1A90A8)],
    [Color(0xFF74A8FF), Color(0xFF2D5EC4)],
  ];

  List<Color> _gradientForName(String name) {
    final idx = name.codeUnitAt(0) % _avatarGradients.length;
    return _avatarGradients[idx];
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final gradient = _gradientForName(post.user.name);
    final initial = post.user.name[0].toUpperCase();
    final subtitle = post.user.nim ?? post.user.role;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4B8EFF).withOpacity(0.08),
                blurRadius: 18,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Author row ─────────────────────────────────────
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: gradient,
                        ),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.user.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: Color(0xFF0F2D6B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F6FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "Forum",
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF2D6EE8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ── Body ───────────────────────────────────────────
                Text(
                  post.body,
                  style: const TextStyle(
                    fontSize: 14.5,
                    color: Color(0xFF1A2840),
                    height: 1.55,
                  ),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 14),

                // ── Footer ─────────────────────────────────────────
                Container(
                  height: 1,
                  color: const Color(0xFFEEF4FF),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _StatChip(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: "${post.repliesCount} Balasan",
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 13,
                      color: Color(0xFF4B8EFF),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Stat Chip ────────────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: const Color(0xFF4B8EFF)),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            color: Color(0xFF4B8EFF),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ── Compose FAB ──────────────────────────────────────────────────────────────
class _ComposeFAB extends StatelessWidget {
  final VoidCallback onTap;
  const _ComposeFAB({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4B8EFF), Color(0xFF1A5FD4)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A5FD4).withOpacity(0.38),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              "Buat Postingan",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Create Post Bottom Sheet ──────────────────────────────────────────────────
class _CreatePostSheet extends StatefulWidget {
  final WidgetRef ref;
  const _CreatePostSheet({required this.ref});

  @override
  State<_CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<_CreatePostSheet> {
  final _controller = TextEditingController();
  bool _isPosting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final body = _controller.text.trim();
    if (body.isEmpty) return;
    setState(() => _isPosting = true);
    try {
      await widget.ref.read(forumServiceProvider).postThread(body: body);
      widget.ref.invalidate(threadsProvider);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            "Buat Postingan Baru",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F2D6B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Tulis pertanyaan atau diskusimu di sini",
            style: TextStyle(fontSize: 12.5, color: Colors.grey[500]),
          ),
          const SizedBox(height: 18),

          // Text area
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF0F6FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD0E2FF), width: 1.2),
            ),
            child: TextField(
              controller: _controller,
              maxLines: 5,
              style: const TextStyle(
                fontSize: 14.5,
                color: Color(0xFF0F2D6B),
                height: 1.5,
              ),
              decoration: InputDecoration(
                hintText: "Apa yang ingin kamu tanyakan atau diskusikan?",
                hintStyle:
                    TextStyle(color: Colors.grey[400], fontSize: 13.5),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Submit button
          GestureDetector(
            onTap: _isPosting ? null : _submit,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isPosting
                      ? [const Color(0xFFB0C8FF), const Color(0xFF8AAEE0)]
                      : [const Color(0xFF4B8EFF), const Color(0xFF1A5FD4)],
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: _isPosting
                    ? []
                    : [
                        BoxShadow(
                          color: const Color(0xFF1A5FD4).withOpacity(0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
              ),
              alignment: Alignment.center,
              child: _isPosting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white),
                    )
                  : const Text(
                      "Posting Sekarang",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFDCEAFF),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.forum_outlined,
                  size: 40, color: Color(0xFF2D6EE8)),
            ),
            const SizedBox(height: 18),
            const Text(
              "Belum ada diskusi",
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: Color(0xFF0F2D6B),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Jadilah yang pertama memulai diskusi!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error State ───────────────────────────────────────────────────────────────
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
              "Gagal memuat forum",
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