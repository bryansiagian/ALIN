import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/features/exam/service/lecturer_service.dart';
import 'package:flutter_math/core/api/api_client.dart';
import 'package:flutter_math/models/user_model.dart';

class StudentListScreen extends ConsumerStatefulWidget {
  const StudentListScreen({super.key});

  @override
  ConsumerState<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends ConsumerState<StudentListScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late LecturerService _service;
  late Future<List<UserModel>> _studentsFuture;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearchFocused = false;
  final ScrollController _scrollController = ScrollController();

  // Design system
  static const Color _primaryDark = Color(0xFF0D2B6B);
  static const Color _primaryMid = Color(0xFF1A56DB);
  static const Color _primaryLight = Color(0xFF3B82F6);
  static const Color _bgPage = Color(0xFFF0F4FF);
  static const Color _cardBg = Colors.white;
  static const Color _textPrimary = Color(0xFF0F172A);
  static const Color _textSecondary = Color(0xFF475569);
  static const Color _accentGreen = Color(0xFF10B981);
  static const Color _accentAmber = Color(0xFFF59E0B);

  // Avatar colors untuk variasi visual
  static const List<List<Color>> _avatarGradients = [
    [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    [Color(0xFF3B82F6), Color(0xFF06B6D4)],
    [Color(0xFF10B981), Color(0xFF059669)],
    [Color(0xFFF59E0B), Color(0xFFEF4444)],
    [Color(0xFFEC4899), Color(0xFF8B5CF6)],
    [Color(0xFF1A56DB), Color(0xFF3B82F6)],
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _scrollController.addListener(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _service = LecturerService(ref.read(apiClientProvider).dio);
    _studentsFuture = _service.getAllStudents();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _refresh() {
    HapticFeedback.lightImpact();
    setState(() {
      _studentsFuture = _service.getAllStudents();
    });
    _fadeController.reset();
    _fadeController.forward();
  }

  List<UserModel> _filterStudents(List<UserModel> students) {
    if (_searchQuery.isEmpty) return students;
    final q = _searchQuery.toLowerCase();
    return students.where((s) {
      return (s.name.toLowerCase().contains(q)) ||
          (s.nim?.toLowerCase().contains(q) ?? false) ||
          (s.prodi?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  List<Color> _getAvatarGradient(int index) {
    return _avatarGradients[index % _avatarGradients.length];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UserModel>>(
      future: _studentsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }
        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error!);
        }
        final allStudents = snapshot.data ?? [];
        return _buildContent(allStudents);
      },
    );
  }

  Widget _buildContent(List<UserModel> allStudents) {
    final filtered = _filterStudents(allStudents);

    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Search bar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: _buildSearchBar(),
          ),
        ),
        // Result label
        if (_searchQuery.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                "${filtered.length} hasil untuk \"$_searchQuery\"",
                style: const TextStyle(
                    color: _textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
        // List atau empty
        filtered.isEmpty && _searchQuery.isNotEmpty
            ? SliverFillRemaining(child: _buildSearchEmptyState())
            : allStudents.isEmpty
                ? SliverFillRemaining(child: _buildEmptyState())
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final student = filtered[index];
                          final delay = index * 60;
                          return FadeTransition(
                            opacity: Tween<double>(begin: 0, end: 1).animate(
                              CurvedAnimation(
                                parent: _fadeController,
                                curve: Interval(
                                  (delay / 900).clamp(0.0, 1.0),
                                  ((delay + 300) / 900).clamp(0.0, 1.0),
                                  curve: Curves.easeOut,
                                ),
                              ),
                            ),
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.15),
                                end: Offset.zero,
                              ).animate(
                                CurvedAnimation(
                                  parent: _fadeController,
                                  curve: Interval(
                                    (delay / 900).clamp(0.0, 1.0),
                                    ((delay + 300) / 900).clamp(0.0, 1.0),
                                    curve: Curves.easeOut,
                                  ),
                                ),
                              ),
                              child: _buildStudentCard(student, index),
                            ),
                          );
                        },
                        childCount: filtered.length,
                      ),
                    ),
                  ),
      ],
    );
  }


  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: _primaryLight.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 3)),
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 1)),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        style: const TextStyle(fontSize: 14, color: _textPrimary),
        decoration: InputDecoration(
          hintText: "Cari nama, NIM, atau prodi...",
          hintStyle:
              const TextStyle(color: _textSecondary, fontSize: 14),
          prefixIcon:
              const Icon(Icons.search_rounded, color: _primaryLight, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                  child: const Icon(Icons.close_rounded,
                      color: _textSecondary, size: 18),
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildStudentCard(UserModel student, int index) {
    final gradientColors = _getAvatarGradient(index);
    final initials = _getInitials(student.name);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showStudentDetail(context, student.id, _service);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Avatar gradasi dengan inisial
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors[0].withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Info mahasiswa
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (student.nim != null) ...[
                          _infoChip(
                              Icons.badge_rounded, student.nim!, _primaryLight),
                          const SizedBox(width: 6),
                        ],
                        if (student.prodi != null)
                          Expanded(
                            child: _infoChipText(student.prodi!),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Analytics button
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_primaryMid, _primaryLight],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: _primaryMid.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.analytics_rounded,
                    color: Colors.white, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 10),
          const SizedBox(width: 3),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _infoChipText(String label) {
    return Text(
      label,
      style: const TextStyle(
          color: _textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  // ── Bottom Sheet Detail Mahasiswa ─────────────────────────────────────────

  void _showStudentDetail(
      BuildContext context, int id, LecturerService service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: _bgPage,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: FutureBuilder<Map<String, dynamic>>(
            future: service.getStudentDetail(id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildSheetLoading();
              }
              if (snapshot.hasError) {
                return _buildSheetError(snapshot.error!);
              }
              final data = snapshot.data!;
              return _buildSheetContent(data, scrollController);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSheetLoading() {
    return Column(
      children: [
        _buildSheetHandle(),
        const Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: _primaryLight,
                  strokeWidth: 2.5,
                ),
                SizedBox(height: 14),
                Text("Memuat data mahasiswa...",
                    style:
                        TextStyle(color: _textSecondary, fontSize: 14)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSheetError(Object err) {
    return Column(
      children: [
        _buildSheetHandle(),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline_rounded,
                    color: Colors.red.withOpacity(0.6), size: 48),
                const SizedBox(height: 12),
                const Text("Gagal memuat detail",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: _textPrimary)),
                const SizedBox(height: 6),
                Text(err.toString(),
                    style: const TextStyle(
                        color: _textSecondary, fontSize: 12),
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSheetContent(
      Map<String, dynamic> data, ScrollController scrollController) {
    final String name = data['name'] ?? '-';
    final String nim = data['nim'] ?? '-';
    final String prodi = data['prodi'] ?? '-';
    final List topics = data['topics'] ?? data['progress'] ?? [];

    return ListView(
      controller: scrollController,
      padding: EdgeInsets.zero,
      children: [
        // Handle bar
        _buildSheetHandle(),

        // Header mahasiswa
        Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_primaryDark, _primaryMid],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _primaryMid.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    _getInitials(name),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _sheetInfoBadge(Icons.badge_rounded, nim),
                        const SizedBox(width: 8),
                        Expanded(child: _sheetInfoBadge(Icons.school_rounded, prodi)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Progress section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_primaryMid, _primaryLight],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                "Progres Belajar",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _textPrimary),
              ),
              const Spacer(),
              if (topics.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _primaryLight.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${topics.length} topik",
                    style: const TextStyle(
                        color: _primaryMid,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        if (topics.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.bar_chart_rounded,
                      color: _primaryLight.withOpacity(0.4), size: 48),
                  const SizedBox(height: 10),
                  const Text("Belum ada data progres",
                      style: TextStyle(color: _textSecondary, fontSize: 14)),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            itemCount: topics.length,
            itemBuilder: (context, i) {
              final topic = topics[i];
              final String topicName =
                  topic['title'] ?? topic['name'] ?? 'Topik ${i + 1}';
              final double progress =
                  ((topic['progress'] ?? topic['score'] ?? 0) as num)
                      .toDouble()
                      .clamp(0.0, 100.0);
              final bool done = progress >= 100;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _cardBg,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: done
                                ? _accentGreen.withOpacity(0.12)
                                : _primaryLight.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            done
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            color: done ? _accentGreen : _primaryLight,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            topicName,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          "${progress.toInt()}%",
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: done
                                  ? _accentGreen
                                  : progress > 50
                                      ? _primaryMid
                                      : _accentAmber),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress / 100,
                        minHeight: 5,
                        backgroundColor: const Color(0xFFE2E8F0),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          done
                              ? _accentGreen
                              : progress > 50
                                  ? _primaryMid
                                  : _accentAmber,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildSheetHandle() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _sheetInfoBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 11),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ── State Screens ────────────────────────────────────────────────────────

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: _primaryLight, strokeWidth: 2.5),
          SizedBox(height: 14),
          Text("Memuat daftar mahasiswa...",
              style: TextStyle(color: _textSecondary, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _primaryLight.withOpacity(0.2),
                  _primaryMid.withOpacity(0.1)
                ],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(Icons.people_outline_rounded,
                color: _primaryLight.withOpacity(0.6), size: 40),
          ),
          const SizedBox(height: 20),
          const Text("Belum Ada Mahasiswa",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary)),
          const SizedBox(height: 8),
          const Text("Data mahasiswa belum tersedia.",
              style:
                  TextStyle(fontSize: 14, color: _textSecondary)),
        ],
      ),
    );
  }

  Widget _buildSearchEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded,
              color: _primaryLight.withOpacity(0.5), size: 56),
          const SizedBox(height: 14),
          Text("Tidak ditemukan hasil untuk\n\"$_searchQuery\"",
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 15, color: _textSecondary, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object err) {
    return Center(
      child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.red.withOpacity(0.15),
                      Colors.red.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(Icons.wifi_off_rounded,
                    color: Colors.red.withOpacity(0.7), size: 40),
              ),
              const SizedBox(height: 20),
              const Text("Gagal Memuat Data",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _textPrimary)),
              const SizedBox(height: 8),
              Text(err.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 13, color: _textSecondary, height: 1.5),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _refresh,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 13),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [_primaryDark, _primaryMid]),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                          color: _primaryMid.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4)),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text("Coba Lagi",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14)),
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