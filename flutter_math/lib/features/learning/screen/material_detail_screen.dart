import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/features/learning/provider/learning_provider.dart';
import 'package:flutter_math/features/learning/widget/latex_renderer.dart';
import 'package:flutter_math/features/learning/screen/pdf_view_screen.dart';
import 'package:url_launcher/url_launcher.dart';

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
  late Animation<double> _headerAnimation;
  final ScrollController _scrollController = ScrollController();
  bool _isCollapsed = false;

  // Design system - konsisten dengan screen lain
  static const Color _primaryDark = Color(0xFF0D2B6B);
  static const Color _primaryMid = Color(0xFF1A56DB);
  static const Color _primaryLight = Color(0xFF3B82F6);
  static const Color _bgPage = Color(0xFFF0F4FF);
  static const Color _cardBg = Colors.white;
  static const Color _textPrimary = Color(0xFF0F172A);
  static const Color _textSecondary = Color(0xFF475569);
  static const Color _pdfRed = Color(0xFFEF4444);
  static const Color _formulaGreen = Color(0xFF10B981);
  static const Color _textBlue = Color(0xFF2563EB);

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _headerAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOut,
    );

    _scrollController.addListener(() {
      final collapsed = _scrollController.offset > 100;
      if (collapsed != _isCollapsed) {
        setState(() => _isCollapsed = collapsed);
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _headerController.dispose();
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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final delay = index * 80;
                  return FadeTransition(
                    opacity: Tween<double>(begin: 0, end: 1).animate(
                      CurvedAnimation(
                        parent: _fadeController,
                        curve: Interval(
                          (delay / 800).clamp(0.0, 1.0),
                          ((delay + 300) / 800).clamp(0.0, 1.0),
                          curve: Curves.easeOut,
                        ),
                      ),
                    ),
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.2),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _fadeController,
                          curve: Interval(
                            (delay / 800).clamp(0.0, 1.0),
                            ((delay + 300) / 800).clamp(0.0, 1.0),
                            curve: Curves.easeOut,
                          ),
                        ),
                      ),
                      child: _buildMaterialCard(context, materials[index], index),
                    ),
                  );
                },
                childCount: materials.length,
              ),
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
    final int textCount = totalMaterials - pdfCount - formulaCount;

    return SliverAppBar(
      expandedHeight:
          200, // 1. Tingkatkan dari 180 ke 200 agar lebih lega untuk judul panjang
      pinned: true,
      stretch: true,
      backgroundColor: _primaryDark,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_primaryDark, _primaryMid, _primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          // 2. CABUT WIDGET 'SafeArea' dan atur padding atas secara rasional (60)
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Breadcrumb
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.menu_book_rounded,
                            color: Colors.white70,
                            size: 12,
                          ),
                          SizedBox(width: 4),
                          Text(
                            "Materi",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.topicTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  // Menghilangkan LaTeX dari regular prose
                ),
                const SizedBox(height: 12),
                // Stats pills
                if (totalMaterials > 0)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _statPill(
                          Icons.layers_rounded,
                          "$totalMaterials Materi",
                          Colors.white,
                        ),
                        if (pdfCount > 0) ...[
                          const SizedBox(width: 8),
                          _statPill(
                            Icons.picture_as_pdf_rounded,
                            "$pdfCount PDF",
                            const Color(0xFFFFB3B3),
                          ),
                        ],
                        if (formulaCount > 0) ...[
                          const SizedBox(width: 8),
                          _statPill(
                            Icons.functions_rounded,
                            "$formulaCount Formula",
                            const Color(0xFFB3F0D8),
                          ),
                        ],
                        if (textCount > 0) ...[
                          const SizedBox(width: 8),
                          _statPill(
                            Icons.text_snippet_rounded,
                            "$textCount Teks",
                            const Color(0xFFBFD7FF),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        title: _isCollapsed
            ? Text(
                widget.topicTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
      ),
    );
  }

  Widget _statPill(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialCard(BuildContext context, dynamic material, int index) {
    final bool isPdf = material.fileUrl != null;
    final bool isFormula = material.contentType == 'formula';

    // Warna aksen per tipe konten
    Color accentColor;
    IconData typeIcon;
    String typeLabel;
    Color typeBg;

    if (isPdf) {
      accentColor = _pdfRed;
      typeIcon = Icons.picture_as_pdf_rounded;
      typeLabel = "PDF";
      typeBg = const Color(0xFFFFF1F1);
    } else if (isFormula) {
      accentColor = _formulaGreen;
      typeIcon = Icons.functions_rounded;
      typeLabel = "Formula";
      typeBg = const Color(0xFFF0FFF8);
    } else {
      accentColor = _textBlue;
      typeIcon = Icons.text_snippet_rounded;
      typeLabel = "Teks";
      typeBg = const Color(0xFFF0F6FF);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card dengan accent kiri
          Container(
            decoration: BoxDecoration(
              color: typeBg,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(
              children: [
                // Nomor urut
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accentColor, accentColor.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      "${index + 1}",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        material.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: _textPrimary,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Type badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(typeIcon, color: accentColor, size: 11),
                            const SizedBox(width: 4),
                            Text(
                              typeLabel,
                              style: TextStyle(
                                  color: accentColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider gradasi
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accentColor.withOpacity(0.3),
                  accentColor.withOpacity(0.05),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Konten body
          Padding(
            padding: const EdgeInsets.all(16),
            child: isPdf
                ? _buildPdfContent(context, material)
                : isFormula
                    ? _buildFormulaContent(material)
                    : _buildTextContent(material),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfContent(BuildContext context, dynamic material) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Preview info
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8F8),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _pdfRed.withOpacity(0.15)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: _pdfRed.withOpacity(0.7),
                size: 14,
              ),
              const SizedBox(width: 8),

              // --- SUNTIKKAN EXPANDED DI SINI AGAR TEKS OTOMATIS ME-WRAP ---
              Expanded(
                child: const Text(
                  "Dokumen PDF tersedia untuk dibaca atau diunduh",
                  style: TextStyle(
                    color: _textSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
              // -------------------------------------------------------------
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Tombol aksi
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _buildGradientButton(
                label: "Baca PDF",
                icon: Icons.menu_book_rounded,
                gradient: const LinearGradient(
                  colors: [_primaryDark, _primaryMid],
                ),
                shadowColor: _primaryMid,
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
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: _buildOutlineButton(
                label: "Unduh",
                icon: Icons.download_rounded,
                color: _pdfRed,
                onTap: () => _downloadPDF(context, material.fileUrl!),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormulaContent(dynamic material) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _formulaGreen.withOpacity(0.08),
                _primaryLight.withOpacity(0.06),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _formulaGreen.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.functions_rounded,
                      color: _formulaGreen.withOpacity(0.6), size: 14),
                  const SizedBox(width: 6),
                  Text(
                    "Formula LaTeX",
                    style: TextStyle(
                        color: _formulaGreen.withOpacity(0.8),
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: LatexRenderer(
                  latex: material.content ?? "",
                  fontSize: 22,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextContent(dynamic material) {
    final String content = material.content ?? "Tidak ada isi materi.";
    return Text(
      content,
      style: const TextStyle(
        fontSize: 15,
        color: _textPrimary,
        height: 1.65,
        letterSpacing: 0.1,
      ),
    );
  }

  Widget _buildGradientButton({
    required String label,
    required IconData icon,
    required Gradient gradient,
    required Color shadowColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 44,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withOpacity(0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutlineButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.4), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 17),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                  color: color, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  // ── State Screens ────────────────────────────────────────────────────────

  Widget _buildLoadingState() {
    return Scaffold(
      backgroundColor: _bgPage,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: _primaryDark,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 18),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_primaryDark, _primaryMid, _primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            expandedHeight: 180,
          ),
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_primaryMid, _primaryLight],
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
                    child: const Center(
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Memuat materi...",
                    style: TextStyle(
                        color: _textSecondary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
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
                    _primaryLight.withOpacity(0.2),
                    _primaryMid.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(Icons.library_books_outlined,
                  color: _primaryLight.withOpacity(0.6), size: 40),
            ),
            const SizedBox(height: 20),
            const Text(
              "Belum Ada Materi",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              "Materi untuk topik ini belum tersedia.\nCek kembali nanti.",
              textAlign: TextAlign.center,
              style:
                  TextStyle(fontSize: 14, color: _textSecondary, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object err) {
    return Scaffold(
      backgroundColor: _bgPage,
      body: Center(
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
                      _pdfRed.withOpacity(0.15),
                      _pdfRed.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(Icons.wifi_off_rounded,
                    color: _pdfRed.withOpacity(0.7), size: 40),
              ),
              const SizedBox(height: 20),
              const Text(
                "Gagal Memuat Materi",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                err.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13, color: _textSecondary, height: 1.5),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref.invalidate(materialsProvider(widget.topicId));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 13),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_primaryDark, _primaryMid],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: _primaryMid.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh_rounded,
                          color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        "Coba Lagi",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14),
                      ),
                    ],
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