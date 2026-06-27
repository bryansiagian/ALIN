import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/features/exam/service/exam_service.dart';
import 'package:flutter_math/models/assignment_model.dart';
import 'package:flutter_math/features/exam/screen/exam_screen.dart';

// ─────────────────────────────────────────────
//  Design Tokens
// ─────────────────────────────────────────────
const _kBlue900 = Color(0xFF0D2B6B);
const _kBlue700 = Color(0xFF1A56DB);
const _kBlue500 = Color(0xFF3B82F6);
const _kBlue200 = Color(0xFFBFDBFE);
const _kBlue50 = Color(0xFFEFF6FF);
const _kSurface = Color(0xFFF8FAFF);

// ─────────────────────────────────────────────
//  Main Screen
// ─────────────────────────────────────────────
class AssignmentListScreen extends ConsumerStatefulWidget {
  const AssignmentListScreen({super.key});

  @override
  ConsumerState<AssignmentListScreen> createState() =>
      _AssignmentListScreenState();
}

class _AssignmentListScreenState extends ConsumerState<AssignmentListScreen>
    with SingleTickerProviderStateMixin {
  late Future<List<AssignmentModel>> _future;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _refresh();
  }

  void _refresh() {
    _future = ref.read(examServiceProvider).getAssignments();
    _fadeCtrl.forward(from: 0);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _kSurface,
        body: FutureBuilder<List<AssignmentModel>>(
          future: _future,
          builder: (context, snapshot) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSliverAppBar(snapshot),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const SliverFillRemaining(child: _LoadingState())
                else if (snapshot.hasError)
                  SliverFillRemaining(
                    child: _ErrorState(
                      error: snapshot.error.toString(),
                      onRetry: () => setState(_refresh),
                    ),
                  )
                else if ((snapshot.data ?? []).isEmpty)
                  const SliverFillRemaining(child: _EmptyState())
                else
                  _buildList(snapshot.data!),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(AsyncSnapshot<List<AssignmentModel>> snapshot) {
    final total = snapshot.data?.length ?? 0;
    final canDo =
        snapshot.data?.where((AssignmentModel a) {
          final isLocked =
              a.startTime != null &&
              DateTime.now().isBefore(a.startTime!.toLocal());
          return (a.attemptLimit - a.examSessionsCount) > 0 && !isLocked;
        }).length ??
        0;

    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      stretch: true,
      backgroundColor: _kBlue700,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 16,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.refresh_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          onPressed: () => setState(_refresh),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: _AppBarBackground(total: total, canDo: canDo),
      ),
    );
  }

  Widget _buildList(List<AssignmentModel> assignments) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: Offset(0, 0.08 + index * 0.04),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _fadeCtrl,
                      curve: Interval(index * 0.08, 1.0, curve: Curves.easeOut),
                    ),
                  ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _AssignmentCard(
                  item: assignments[index],
                  index: index,
                  onStart: () => _startExam(context, ref, assignments[index]),
                ),
              ),
            ),
          );
        }, childCount: assignments.length),
      ),
    );
  }

  Future<void> _startExam(
    BuildContext context,
    WidgetRef ref,
    AssignmentModel assignment,
  ) async {
    try {
      final response = await ref
          .read(examServiceProvider)
          .startExam(assignment.id);
      final int sessionId = response['session']['id'];
      final List questions = response['questions'];
      final bool showResults =
          response['assignment']['show_results'] == 1 ||
          response['assignment']['show_results'] == true;

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ExamScreen(
              sessionId: sessionId,
              questions: questions,
              duration: assignment.durationMinutes,
              showResults: showResults,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF1A1A2E),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: Color(0xFFFF6B6B),
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Gagal memulai kuis: $e",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
  }
}

// ─────────────────────────────────────────────
//  AppBar Background Widget
// ─────────────────────────────────────────────
class _AppBarBackground extends StatelessWidget {
  const _AppBarBackground({required this.total, required this.canDo});
  final int total;
  final int canDo;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_kBlue900, _kBlue700, _kBlue500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.quiz_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Tugas & Kuis",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        "Kerjakan sebelum batas waktu",
                        style: TextStyle(
                          color: Color(0xFFBFDBFE),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              if (total > 0)
                Row(
                  children: [
                    _StatPill(
                      icon: Icons.list_alt_rounded,
                      label: "$total Kuis",
                      color: Colors.white,
                    ),
                    const SizedBox(width: 10),
                    _StatPill(
                      icon: Icons.play_circle_outline_rounded,
                      label: "$canDo Bisa Dikerjakan",
                      color: canDo > 0
                          ? const Color(0xFF6EE7B7)
                          : const Color(0xFFFCA5A5),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Assignment Card
// ─────────────────────────────────────────────
class _AssignmentCard extends StatefulWidget {
  const _AssignmentCard({
    required this.item,
    required this.index,
    required this.onStart,
  });
  final AssignmentModel item;
  final int index;
  final VoidCallback onStart;

  @override
  State<_AssignmentCard> createState() => _AssignmentCardState();
}

class _AssignmentCardState extends State<_AssignmentCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _scaleAnim;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = _pressCtrl;
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  // ── Getters ──
  bool get _isLocked {
    final start = widget.item.startTime;
    if (start == null) return false;
    return DateTime.now().isBefore(start.toLocal());
  }

  int get _sisa => widget.item.attemptLimit - widget.item.examSessionsCount;
  bool get _canAttempt => _sisa > 0 && !_isLocked;

  String _formatTime(DateTime? dt) {
    if (dt == null) return '-';
    final local = dt.toLocal();
    return '${local.day.toString().padLeft(2, '0')}-'
        '${local.month.toString().padLeft(2, '0')}-'
        '${local.year} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isSafe = widget.item.isSafeExam;

    return GestureDetector(
      onTapDown: _canAttempt ? (_) => _pressCtrl.reverse() : null,
      onTapUp: _canAttempt ? (_) => _pressCtrl.forward() : null,
      onTapCancel: _canAttempt ? () => _pressCtrl.forward() : null,
      onTap: _canAttempt && !_isLoading
          ? () async {
              HapticFeedback.lightImpact();
              setState(() => _isLoading = true);
              await Future.delayed(const Duration(milliseconds: 150));
              widget.onStart();
              if (mounted) setState(() => _isLoading = false);
            }
          : null,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) =>
            Transform.scale(scale: _scaleAnim.value, child: child),
        child: Opacity(
          opacity: _isLocked ? 0.6 : 1.0,
          child: Container(
            decoration: BoxDecoration(
              color: _isLocked ? const Color(0xFFF8FAFC) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isLocked
                    ? const Color(0xFFE2E8F0)
                    : (_canAttempt ? _kBlue200 : const Color(0xFFE2E8F0)),
                width: 1.5,
              ),
              boxShadow: _isLocked
                  ? []
                  : [
                      BoxShadow(
                        color: _canAttempt
                            ? _kBlue500.withOpacity(0.08)
                            : Colors.black.withOpacity(0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header Row ──
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _isLocked
                                ? [
                                    const Color(0xFF94A3B8),
                                    const Color(0xFFCBD5E1),
                                  ]
                                : (isSafe
                                      ? [
                                          const Color(0xFFEF4444),
                                          const Color(0xFFF97316),
                                        ]
                                      : [_kBlue700, _kBlue500]),
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: _isLocked
                              ? []
                              : [
                                  BoxShadow(
                                    color:
                                        (isSafe
                                                ? const Color(0xFFEF4444)
                                                : _kBlue500)
                                            .withOpacity(0.30),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                        ),
                        child: Icon(
                          _isLocked
                              ? Icons.lock_clock_rounded
                              : (isSafe
                                    ? Icons.lock_rounded
                                    : Icons.assignment_rounded),
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.item.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: (_canAttempt && !_isLocked)
                                    ? const Color(0xFF0F172A)
                                    : const Color(0xFF94A3B8),
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                if (!_isLocked) _TypeBadge(isSafe: isSafe),
                                if (!_isLocked) const SizedBox(width: 8),
                                if (widget.item.durationMinutes > 0)
                                  _InfoChip(
                                    icon: Icons.timer_outlined,
                                    label:
                                        "${widget.item.durationMinutes} menit",
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 14),

                  // ── Footer Row ──
                  Row(
                    children: [
                      if (_isLocked) ...[
                        const Icon(
                          Icons.lock_clock_rounded,
                          size: 14,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "Buka ${_formatTime(widget.item.startTime)}",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF94A3B8),
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ] else
                        _AttemptIndicator(
                          sisa: _sisa,
                          limit: widget.item.attemptLimit,
                        ),
                      const SizedBox(width: 12),
                      _ActionButton(
                        canAttempt: _canAttempt,
                        isLoading: _isLoading,
                        isLocked: _isLocked,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Sub-Widgets
// ─────────────────────────────────────────────
class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.isSafe});
  final bool isSafe;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isSafe ? const Color(0xFFFEF2F2) : _kBlue50,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isSafe ? "Safe Exam" : "Reguler",
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: isSafe ? const Color(0xFFEF4444) : _kBlue700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 3),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
        ),
      ],
    );
  }
}

class _AttemptIndicator extends StatelessWidget {
  const _AttemptIndicator({required this.sisa, required this.limit});
  final int sisa;
  final int limit;

  @override
  Widget build(BuildContext context) {
    final pct = limit > 0 ? sisa / limit : 0.0;
    final color = pct > 0.5
        ? _kBlue500
        : pct > 0
        ? const Color(0xFFF59E0B)
        : const Color(0xFFEF4444);

    return Row(
      children: [
        SizedBox(
          width: 48,
          height: 6,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          sisa > 0 ? "Sisa $sisa percobaan" : "Selesai",
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.canAttempt,
    required this.isLoading,
    required this.isLocked,
  });
  final bool canAttempt;
  final bool isLoading;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    // Belum waktunya
    if (isLocked) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3CD),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFFDE68A)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_clock_rounded, size: 13, color: Color(0xFF92610A)),
            SizedBox(width: 5),
            Text(
              "Belum Dibuka",
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF92610A),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    // Sudah selesai / habis percobaan
    if (!canAttempt) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          "Selesai",
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    // Bisa dikerjakan
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [_kBlue700, _kBlue500]),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: _kBlue500.withOpacity(0.35),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Kerjakan",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 6),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 12,
                ),
              ],
            ),
    );
  }
}

// ─────────────────────────────────────────────
//  State Screens
// ─────────────────────────────────────────────
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _kBlue50,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _kBlue200.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(_kBlue500),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          "Memuat kuis...",
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

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
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _kBlue50,
                shape: BoxShape.circle,
                border: Border.all(color: _kBlue200, width: 2),
              ),
              child: const Icon(
                Icons.inbox_rounded,
                size: 48,
                color: _kBlue500,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Belum Ada Kuis Aktif",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Kuis dari dosen akan muncul di sini.\nPantau terus halaman ini ya!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error, required this.onRetry});
  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFECACA), width: 2),
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 48,
                color: Color(0xFFEF4444),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Gagal Memuat Data",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_kBlue700, _kBlue500],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: _kBlue500.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      "Coba Lagi",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
