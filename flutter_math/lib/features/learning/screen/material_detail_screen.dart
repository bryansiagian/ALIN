import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/features/learning/provider/learning_provider.dart';
import 'package:flutter_math/features/learning/widget/latex_renderer.dart';
import 'package:flutter_math/features/learning/screen/pdf_view_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;

class MaterialDetailScreen extends ConsumerStatefulWidget {
  final int topicId;
  final String topicTitle;

  const MaterialDetailScreen({
    super.key,
    required this.topicId,
    required this.topicTitle,
  });

  @override
  ConsumerState<MaterialDetailScreen> createState() =>
      _MaterialDetailScreenState();
}

class _MaterialDetailScreenState extends ConsumerState<MaterialDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _headerController;
  late AnimationController _waveController; // Controller baru untuk ombak
  late Animation<double> _headerAnimation;
  final ScrollController _scrollController = ScrollController();
  bool _isCollapsed = false;

  // Design system diperbarui untuk kesan Classic Aesthetic
  static const Color _primaryDark = Color(0xFF0D2B6B);
  static const Color _primaryMid = Color(0xFF1A56DB);
  static const Color _primaryLight = Color(0xFF3B82F6);
  static const Color _bgPage = Color(0xFFF8FAFC); // Lebih bersih
  static const Color _cardBg = Colors.white;
  static const Color _textPrimary = Color(0xFF1E293B);
  static const Color _textSecondary = Color(0xFF64748B);
  static const Color _pdfRed = Color(0xFFE11D48);
  static const Color _formulaGreen = Color(0xFF059669);
  static const Color _textBlue = Color(0xFF2563EB);

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Inisialisasi controller ombak
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _headerAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOut,
    );

    _scrollController.addListener(() {
      final collapsed = _scrollController.offset > 120;
      if (collapsed != _isCollapsed) {
        setState(() => _isCollapsed = collapsed);
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _headerController.dispose();
    _waveController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _downloadPDF(BuildContext context, String url) async {
    HapticFeedback.lightImpact();
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        _showErrorSnackBar(context, "Gagal membuka link download");
      }
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: const Color(0xFF1E293B),
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: _pdfRed, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final materialsAsync = ref.watch(materialsProvider(widget.topicId));

    return Scaffold(
      backgroundColor: _bgPage,
      body: materialsAsync.when(
        data: (materials) => _buildContent(context, materials),
        loading: () => _buildLoadingState(),
        error: (err, stack) => _buildErrorState(context, err),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List materials) {
    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildSliverAppBar(context, materials),
        if (materials.isEmpty)
          SliverFillRemaining(child: _buildEmptyState())
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final delay = index * 100;
                return FadeTransition(
                  opacity: Tween<double>(begin: 0, end: 1).animate(
                    CurvedAnimation(
                      parent: _fadeController,
                      curve: Interval(
                        (delay / 1000).clamp(0.0, 1.0),
                        1.0,
                        curve: Curves.easeOut,
                      ),
                    ),
                  ),
                  child: SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(0, 0.1),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: _fadeController,
                            curve: Interval(
                              (delay / 1000).clamp(0.0, 1.0),
                              1.0,
                              curve: Curves.easeOut,
                            ),
                          ),
                        ),
                    child: _buildMaterialCard(context, materials[index], index),
                  ),
                );
              }, childCount: materials.length),
            ),
          ),
      ],
    );
  }

  Widget _buildSliverAppBar(BuildContext context, List materials) {
    final int totalMaterials = materials.length;
    final int pdfCount = materials.where((m) => m.fileUrl != null).length;
    final int formulaCount = materials
        .where((m) => m.contentType == 'formula')
        .length;

    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      stretch: true,
      elevation: 0,
      backgroundColor: _primaryDark,
      leading: _buildAppBarLeading(context),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Background Gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primaryDark, _primaryMid],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            // Animasi Ombak Laut
            AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                return Stack(
                  children: [
                    _buildWave(
                      0.4,
                      0.6,
                      _waveController.value,
                      Colors.white.withOpacity(0.1),
                    ),
                    _buildWave(
                      0.5,
                      0.4,
                      _waveController.value + 0.5,
                      Colors.white.withOpacity(0.15),
                    ),
                  ],
                );
              },
            ),

            // Konten Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderBreadcrumb(),
                  const SizedBox(height: 12),
                  Text(
                    widget.topicTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  _buildStatsRow(totalMaterials, pdfCount, formulaCount),
                ],
              ),
            ),
          ],
        ),
        title: _isCollapsed
            ? Text(
                widget.topicTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
        centerTitle: true,
      ),
    );
  }

  Widget _buildWave(
    double heightFactor,
    double speed,
    double offset,
    Color color,
  ) {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SizedBox(
          height: 100,
          child: CustomPaint(
            painter: WavePainter(waveAnimation: offset, color: color),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarLeading(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          Navigator.pop(context);
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(_isCollapsed ? 0 : 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderBreadcrumb() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_stories, color: Colors.white, size: 14),
          SizedBox(width: 6),
          Text(
            "Learning Material",
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(int total, int pdf, int formula) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _statPill(
            Icons.collections_bookmark_rounded,
            "$total Materi",
            Colors.white,
          ),
          if (pdf > 0) ...[
            const SizedBox(width: 8),
            _statPill(
              Icons.picture_as_pdf_rounded,
              "$pdf PDF",
              Colors.red.shade100,
            ),
          ],
          if (formula > 0) ...[
            const SizedBox(width: 8),
            _statPill(
              Icons.functions_rounded,
              "Formula",
              Colors.green.shade100,
            ),
          ],
        ],
      ),
    );
  }

  Widget _statPill(IconData icon, String label, Color color) {
    return ClipRRect(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- MODIFIKASI CARD: CLASSIC AESTHETIC ---
  Widget _buildMaterialCard(BuildContext context, dynamic material, int index) {
    final bool isPdf = material.fileUrl != null;
    final bool isFormula = material.contentType == 'formula';

    Color accentColor = isPdf
        ? _pdfRed
        : (isFormula ? _formulaGreen : _textBlue);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D2B6B).withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Decorative Side Bar & Content Header
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(width: 6, color: accentColor),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              "${index + 1}",
                              style: TextStyle(
                                color: accentColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  material.title,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: _textPrimary,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isPdf
                                      ? "Dokumen Referensi"
                                      : (isFormula
                                            ? "Rumus Matematika"
                                            : "Materi Tekstual"),
                                  style: TextStyle(
                                    color: accentColor.withOpacity(0.7),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(height: 1, thickness: 0.5),
            ),

            // Konten body
            Padding(
              padding: const EdgeInsets.all(20),
              child: isPdf
                  ? _buildPdfContent(context, material)
                  : isFormula
                  ? _buildFormulaContent(material)
                  : _buildTextContent(material),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfContent(BuildContext context, dynamic material) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _pdfRed.withOpacity(0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _pdfRed.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              const Icon(Icons.description_outlined, color: _pdfRed, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "File PDF siap dipelajari secara offline maupun online.",
                  style: TextStyle(
                    color: _textSecondary.withOpacity(0.8),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _buildClassicButton(
                label: "Buka Materi",
                icon: Icons.auto_stories_rounded,
                color: _primaryMid,
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PdfViewScreen(
                        title: material.title,
                        url: material.fileUrl!,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: _buildClassicButton(
                label: "Simpan",
                icon: Icons.download_for_offline_rounded,
                color: _pdfRed,
                isOutline: true,
                onTap: () => _downloadPDF(context, material.fileUrl!),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormulaContent(dynamic material) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.functions_rounded,
            color: _formulaGreen.withOpacity(0.4),
            size: 20,
          ),
          const SizedBox(height: 12),
          LatexRenderer(latex: material.content ?? "", fontSize: 22),
        ],
      ),
    );
  }

  Widget _buildTextContent(dynamic material) {
    return Text(
      material.content ?? "Tidak ada isi materi.",
      style: const TextStyle(
        fontSize: 15,
        color: _textPrimary,
        height: 1.7,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildClassicButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isOutline = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 48,
        decoration: BoxDecoration(
          color: isOutline ? Colors.transparent : color,
          borderRadius: BorderRadius.circular(14),
          border: isOutline ? Border.all(color: color, width: 1.5) : null,
          boxShadow: isOutline
              ? null
              : [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isOutline ? color : Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isOutline ? color : Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- STATE SCREENS ---

  Widget _buildLoadingState() {
    return Center(child: CircularProgressIndicator(color: _primaryMid));
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            "Belum ada materi tersedia",
            style: TextStyle(color: _textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object err) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: _pdfRed),
          const SizedBox(height: 16),
          Text(
            "Terjadi kesalahan sistem",
            style: TextStyle(color: _textPrimary, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _buildClassicButton(
            label: "Coba Lagi",
            icon: Icons.refresh,
            color: _primaryMid,
            onTap: () => ref.invalidate(materialsProvider(widget.topicId)),
          ),
        ],
      ),
    );
  }
}

// PAINTER UNTUK ANIMASI OMBAK
class WavePainter extends CustomPainter {
  final double waveAnimation;
  final Color color;

  WavePainter({required this.waveAnimation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();

    path.moveTo(0, size.height);
    for (double i = 0; i <= size.width; i++) {
      path.lineTo(
        i,
        size.height * 0.5 +
            math.sin(
                  (i / size.width * 2 * math.pi) +
                      (waveAnimation * 2 * math.pi),
                ) *
                15,
      );
    }
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) =>
      oldDelegate.waveAnimation != waveAnimation;
}
