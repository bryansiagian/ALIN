// lib/features/exam/screen/create_assignment_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/features/exam/service/lecturer_service.dart';
import 'package:flutter_math/core/api/api_client.dart';
import 'package:image_picker/image_picker.dart';

class CreateAssignmentScreen extends ConsumerStatefulWidget {
  const CreateAssignmentScreen({super.key});

  @override
  ConsumerState<CreateAssignmentScreen> createState() =>
      _CreateAssignmentScreenState();
}

class _CreateAssignmentScreenState extends ConsumerState<CreateAssignmentScreen>
    with TickerProviderStateMixin {
  // ── Controllers ──────────────────────────────────────────────────────────
  final _titleController = TextEditingController();
  final _startTimeController = TextEditingController(
    text: DateTime.now().toUtc().toIso8601String(),
  );
  final _deadlineController = TextEditingController(
    text: DateTime.now().add(const Duration(days: 1)).toUtc().toIso8601String(),
  );
  final _passwordController = TextEditingController();
  final _scrollController = ScrollController();
  final _imagePicker = ImagePicker();

  // ── State ─────────────────────────────────────────────────────────────────
  bool _isSafeExam = true;
  bool _allowReattempt = false;
  int _attemptLimit = 1;
  bool _showResults = true;
  bool _isSubmitting = false;
  bool _obscurePassword = true;
  int _currentStep = 0;

  // Setiap soal punya:
  // 'text', 'a', 'b', 'c', 'd' → TextEditingController (teks)
  // 'question_image' → File? (gambar soal)
  // 'question_image_url' → String? (URL setelah upload)
  // 'option_images' → List<File?> [a, b, c, d]
  // 'option_image_urls' → List<String?> [a, b, c, d]
  // 'key' → String (kunci jawaban)
  // 'expanded' → bool
  List<Map<String, dynamic>> _questions = [
    {
      'text': TextEditingController(),
      'a': TextEditingController(),
      'b': TextEditingController(),
      'c': TextEditingController(),
      'd': TextEditingController(),
      'question_image': null,
      'question_image_url': null,
      'option_images': [null, null, null, null],
      'option_image_urls': [null, null, null, null],
      'key': 'A',
      'expanded': true,
    },
  ];

  // ── Design System ─────────────────────────────────────────────────────────
  static const Color _primaryDark = Color(0xFF0D2B6B);
  static const Color _primaryMid = Color(0xFF1A56DB);
  static const Color _primaryLight = Color(0xFF3B82F6);
  static const Color _bgPage = Color(0xFFF0F4FF);
  static const Color _cardBg = Colors.white;
  static const Color _textPrimary = Color(0xFF0F172A);
  static const Color _textSecondary = Color(0xFF475569);
  static const Color _accentGreen = Color(0xFF10B981);
  static const Color _accentAmber = Color(0xFFF59E0B);
  static const Color _accentRed = Color(0xFFEF4444);

  static const List<Color> _optionColors = [
    Color(0xFF3B82F6),
    Color(0xFF8B5CF6),
    Color(0xFF06B6D4),
    Color(0xFFF59E0B),
  ];

  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _startTimeController.dispose();
    _deadlineController.dispose();
    _passwordController.dispose();
    _scrollController.dispose();
    _fadeController.dispose();
    for (final q in _questions) {
      (q['text'] as TextEditingController).dispose();
      (q['a'] as TextEditingController).dispose();
      (q['b'] as TextEditingController).dispose();
      (q['c'] as TextEditingController).dispose();
      (q['d'] as TextEditingController).dispose();
    }
    super.dispose();
  }

  void _addQuestion() {
    HapticFeedback.lightImpact();
    setState(() {
      for (final q in _questions) q['expanded'] = false;
      _questions.add({
        'text': TextEditingController(),
        'a': TextEditingController(),
        'b': TextEditingController(),
        'c': TextEditingController(),
        'd': TextEditingController(),
        'question_image': null,
        'question_image_url': null,
        'option_images': [null, null, null, null],
        'option_image_urls': [null, null, null, null],
        'key': 'A',
        'expanded': true,
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    });
  }

  void _removeQuestion(int index) {
    if (_questions.length <= 1) return;
    HapticFeedback.mediumImpact();
    setState(() => _questions.removeAt(index));
  }

  // ── Upload gambar ke server ───────────────────────────────────────────────

  Future<String?> _uploadImage(File imageFile) async {
    try {
      final service = LecturerService(ref.read(apiClientProvider).dio);
      final url = await service.uploadQuestionImage(imageFile);
      return url;
    } catch (e) {
      if (mounted) _showToast("Gagal upload gambar: $e", isError: true);
      return null;
    }
  }

  Future<void> _pickQuestionImage(int qIdx) async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;
    setState(() {
      _questions[qIdx]['question_image'] = File(picked.path);
      _questions[qIdx]['question_image_url'] =
          null; // reset, akan di-upload saat submit
    });
  }

  Future<void> _pickOptionImage(int qIdx, int optIdx) async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;
    setState(() {
      final images = List<dynamic>.from(
        _questions[qIdx]['option_images'] as List,
      );
      images[optIdx] = File(picked.path);
      _questions[qIdx]['option_images'] = images;

      final urls = List<dynamic>.from(
        _questions[qIdx]['option_image_urls'] as List,
      );
      urls[optIdx] = null;
      _questions[qIdx]['option_image_urls'] = urls;
    });
  }

  void _removeQuestionImage(int qIdx) {
    setState(() {
      _questions[qIdx]['question_image'] = null;
      _questions[qIdx]['question_image_url'] = null;
    });
  }

  void _removeOptionImage(int qIdx, int optIdx) {
    setState(() {
      final images = List<dynamic>.from(
        _questions[qIdx]['option_images'] as List,
      );
      images[optIdx] = null;
      _questions[qIdx]['option_images'] = images;

      final urls = List<dynamic>.from(
        _questions[qIdx]['option_image_urls'] as List,
      );
      urls[optIdx] = null;
      _questions[qIdx]['option_image_urls'] = urls;
    });
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  void _submitAll() async {
    if (_titleController.text.trim().isEmpty) {
      _showToast("Judul kuis tidak boleh kosong", isError: true);
      setState(() => _currentStep = 0);
      return;
    }
    for (int i = 0; i < _questions.length; i++) {
      final q = _questions[i];
      if ((q['text'] as TextEditingController).text.trim().isEmpty) {
        _showToast("Pertanyaan soal ${i + 1} kosong", isError: true);
        return;
      }
    }

    setState(() => _isSubmitting = true);
    HapticFeedback.lightImpact();

    // Upload semua gambar dulu
    for (int i = 0; i < _questions.length; i++) {
      final q = _questions[i];

      // Upload gambar soal
      if (q['question_image'] != null && q['question_image_url'] == null) {
        final url = await _uploadImage(q['question_image'] as File);
        if (url == null) {
          setState(() => _isSubmitting = false);
          return;
        }
        _questions[i]['question_image_url'] = url;
      }

      // Upload gambar tiap opsi
      final optImages = List<dynamic>.from(q['option_images'] as List);
      final optUrls = List<dynamic>.from(q['option_image_urls'] as List);
      for (int j = 0; j < 4; j++) {
        if (optImages[j] != null && optUrls[j] == null) {
          final url = await _uploadImage(optImages[j] as File);
          if (url == null) {
            setState(() => _isSubmitting = false);
            return;
          }
          optUrls[j] = url;
        }
      }
      _questions[i]['option_image_urls'] = optUrls;
    }

    final service = LecturerService(ref.read(apiClientProvider).dio);

    final List<String> optionKeys = ['a', 'b', 'c', 'd'];
    final List<String> optionLabels = ['A', 'B', 'C', 'D'];

    List<Map<String, dynamic>> finalQuestions = _questions.map((q) {
      final optUrls = List<dynamic>.from(q['option_image_urls'] as List);
      return {
        'question_text': (q['text'] as TextEditingController).text,
        'question_image': q['question_image_url'],
        'options': List.generate(
          4,
          (i) => {
            'key': optionLabels[i],
            'text': (q[optionKeys[i]] as TextEditingController).text,
            'image': optUrls[i],
          },
        ),
        'correct_answer': q['key'],
      };
    }).toList();

    try {
      await service.createAssignment({
        'topic_id': 1,
        'title': _titleController.text,
        'start_time': DateTime.parse(
          _startTimeController.text,
        ).toUtc().toIso8601String(),
        'password': _passwordController.text.trim().isEmpty
            ? null
            : _passwordController.text.trim(),
        'deadline': DateTime.parse(
          _deadlineController.text,
        ).toUtc().toIso8601String(),
        'duration_minutes': 60,
        'is_safe_exam': _isSafeExam,
        'questions': finalQuestions,
        'allow_reattempt': _allowReattempt,
        'attempt_limit': _attemptLimit,
        'show_results': _showResults,
      });

      ref.invalidate(myAssignmentsProvider);

      if (mounted) {
        setState(() => _isSubmitting = false);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: _accentGreen,
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                SizedBox(width: 10),
                Text(
                  "Kuis Berhasil Diterbitkan!",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        _showToast("Gagal: $e", isError: true);
      }
    }
  }

  void _showToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: isError ? _accentRed : _accentGreen,
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgPage,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _buildStepTabs(),
            ),
          ),
          SliverToBoxAdapter(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.05, 0),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
              child: _currentStep == 0
                  ? KeyedSubtree(
                      key: const ValueKey('info'),
                      child: _buildInfoSection(),
                    )
                  : KeyedSubtree(
                      key: const ValueKey('soal'),
                      child: _buildQuestionsSection(),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
              child: _buildSubmitButton(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 140,
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
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 48, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    "Buat Kuis Baru",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _headerPill(
                        Icons.quiz_rounded,
                        "${_questions.length} soal",
                        const Color(0xFFBFD7FF),
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

  Widget _headerPill(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepTabs() {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: _primaryLight.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _stepTab(0, Icons.info_outline_rounded, "Info Kuis"),
          _stepTab(1, Icons.quiz_rounded, "Soal (${_questions.length})"),
        ],
      ),
    );
  }

  Widget _stepTab(int index, IconData icon, String label) {
    final active = _currentStep == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _currentStep = index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: active
                ? const LinearGradient(colors: [_primaryMid, _primaryLight])
                : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: active ? Colors.white : _textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: active ? Colors.white : _textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Info Section ──────────────────────────────────────────────────────────

  Widget _buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(Icons.edit_note_rounded, "Detail Kuis"),
          const SizedBox(height: 12),
          _buildCard(
            child: Column(
              children: [
                _buildTextField(
                  controller: _titleController,
                  label: "Judul Kuis",
                  hint: "Contoh: Kuis Bab 3 — Matriks",
                  icon: Icons.title_rounded,
                ),
                const SizedBox(height: 12),
                _buildDateTimeField(
                  controller: _startTimeController,
                  label: "Waktu Mulai",
                  icon: Icons.play_circle_outline_rounded,
                ),
                const SizedBox(height: 12),
                _buildDateTimeField(
                  controller: _deadlineController,
                  label: "Deadline",
                  icon: Icons.calendar_today_rounded,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _sectionHeader(Icons.tune_rounded, "Pengaturan"),
          const SizedBox(height: 12),
          _buildCard(
            child: Column(
              children: [
                _buildToggleTile(
                  icon: Icons.lock_rounded,
                  iconColor: _accentRed,
                  title: "Mode SEB Aktif",
                  subtitle: "Safe Exam Browser diperlukan",
                  value: _isSafeExam,
                  onChanged: (v) => setState(() => _isSafeExam = v),
                ),
                _divider(),
                _buildToggleTile(
                  icon: Icons.bar_chart_rounded,
                  iconColor: _accentGreen,
                  title: "Tampilkan Skor & Kunci",
                  subtitle: "Mahasiswa lihat hasil setelah submit",
                  value: _showResults,
                  onChanged: (v) => setState(() => _showResults = v),
                ),
                _divider(),
                _buildToggleTile(
                  icon: Icons.replay_rounded,
                  iconColor: _accentAmber,
                  title: "Izinkan Mengulang",
                  subtitle: "Mahasiswa bisa mengerjakan ulang",
                  value: _allowReattempt,
                  onChanged: (v) => setState(() => _allowReattempt = v),
                ),
                if (_allowReattempt) ...[
                  _divider(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: _buildTextField(
                      label: "Batas Percobaan",
                      hint: "Masukkan angka",
                      icon: Icons.repeat_rounded,
                      keyboardType: TextInputType.number,
                      onChanged: (v) => _attemptLimit = int.tryParse(v) ?? 1,
                    ),
                  ),
                ],
                _divider(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(fontSize: 14, color: _textPrimary),
                    decoration: InputDecoration(
                      labelText: "Password Kuis (Opsional)",
                      hintText: "Kosongkan jika tanpa password",
                      labelStyle: const TextStyle(
                        color: _textSecondary,
                        fontSize: 13,
                      ),
                      hintStyle: const TextStyle(
                        color: _textSecondary,
                        fontSize: 13,
                      ),
                      prefixIcon: const Icon(
                        Icons.vpn_key_rounded,
                        color: _primaryLight,
                        size: 18,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: _textSecondary,
                          size: 18,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFF),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: _primaryLight.withOpacity(0.2),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: _primaryLight.withOpacity(0.2),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: _primaryMid,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _currentStep = 1);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_primaryMid, _primaryLight],
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Lanjut ke Soal",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── Questions Section ──────────────────────────────────────────────────────

  Widget _buildQuestionsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _sectionHeader(Icons.quiz_rounded, "Daftar Soal"),
              const Spacer(),
              GestureDetector(
                onTap: _addQuestion,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
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
                  child: const Row(
                    children: [
                      Icon(Icons.add_rounded, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        "Tambah",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._questions.asMap().entries.map((entry) {
            final idx = entry.key;
            final q = entry.value;
            return _buildQuestionCard(idx, q);
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(int idx, Map<String, dynamic> q) {
    final bool expanded = q['expanded'] as bool;
    final String currentKey = q['key'] as String;
    final List<String> optionKeys = ['a', 'b', 'c', 'd'];
    final List<String> optionLabels = ['A', 'B', 'C', 'D'];
    final File? questionImage = q['question_image'] as File?;
    final List<dynamic> optionImages = q['option_images'] as List<dynamic>;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _primaryLight.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header soal
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => q['expanded'] = !expanded);
            },
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _primaryMid.withOpacity(0.08),
                    _primaryLight.withOpacity(0.04),
                  ],
                ),
                borderRadius: expanded
                    ? const BorderRadius.vertical(top: Radius.circular(18))
                    : BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_primaryMid, _primaryLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
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
                    child: Center(
                      child: Text(
                        "${idx + 1}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
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
                          "Soal ${idx + 1}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _textPrimary,
                          ),
                        ),
                        if (!expanded) ...[
                          const SizedBox(height: 2),
                          Text(
                            (q['text'] as TextEditingController).text.isEmpty
                                ? "Ketuk untuk mengisi soal"
                                : (q['text'] as TextEditingController).text,
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  (q['text'] as TextEditingController)
                                      .text
                                      .isEmpty
                                  ? _textSecondary
                                  : _textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (_questions.length > 1)
                    GestureDetector(
                      onTap: () => _removeQuestion(idx),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: _accentRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          color: _accentRed.withOpacity(0.8),
                          size: 16,
                        ),
                      ),
                    ),
                  const SizedBox(width: 6),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: _textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          // Body soal
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: SizedBox(
              width: double.infinity,
              child: expanded
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Pertanyaan (teks)
                          _buildTextField(
                            controller: q['text'] as TextEditingController,
                            label: "Pertanyaan",
                            hint: "Ketik soal di sini...",
                            icon: Icons.help_outline_rounded,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 10),

                          // ── Gambar soal ──────────────────────────────────
                          _buildImagePicker(
                            label: "Gambar Soal (opsional)",
                            imageFile: questionImage,
                            onPick: () => _pickQuestionImage(idx),
                            onRemove: () => _removeQuestionImage(idx),
                          ),
                          const SizedBox(height: 14),

                          // Pilihan jawaban
                          const Text(
                            "Pilihan Jawaban",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...List.generate(4, (i) {
                            final color = _optionColors[i];
                            final optImage = optionImages[i] as File?;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      // Label opsi (A/B/C/D)
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: color.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: color.withOpacity(0.3),
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            optionLabels[i],
                                            style: TextStyle(
                                              color: color,
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      // Field teks opsi
                                      Expanded(
                                        child: TextField(
                                          controller:
                                              q[optionKeys[i]]
                                                  as TextEditingController,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: _textPrimary,
                                          ),
                                          decoration: InputDecoration(
                                            hintText:
                                                "Pilihan ${optionLabels[i]}...",
                                            hintStyle: const TextStyle(
                                              color: _textSecondary,
                                              fontSize: 13,
                                            ),
                                            filled: true,
                                            fillColor: color.withOpacity(0.04),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 10,
                                                ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                color: color.withOpacity(0.2),
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                color: color.withOpacity(0.2),
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                color: color,
                                                width: 1.5,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  // ── Gambar opsi ──────────────────────────
                                  Padding(
                                    padding: const EdgeInsets.only(left: 38),
                                    child: _buildImagePicker(
                                      label:
                                          "Gambar opsi ${optionLabels[i]} (opsional)",
                                      imageFile: optImage,
                                      onPick: () => _pickOptionImage(idx, i),
                                      onRemove: () =>
                                          _removeOptionImage(idx, i),
                                      compact: true,
                                      accentColor: color,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),

                          const SizedBox(height: 12),
                          // Kunci jawaban
                          const Text(
                            "Kunci Jawaban",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: List.generate(4, (i) {
                              final label = optionLabels[i];
                              final selected = currentKey == label;
                              final color = _optionColors[i];
                              return Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    right: i < 3 ? 8 : 0,
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      setState(() => q['key'] = label);
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 180,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: selected
                                            ? color
                                            : color.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: selected
                                              ? color
                                              : color.withOpacity(0.25),
                                          width: selected ? 0 : 1,
                                        ),
                                        boxShadow: selected
                                            ? [
                                                BoxShadow(
                                                  color: color.withOpacity(
                                                    0.35,
                                                  ),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ]
                                            : [],
                                      ),
                                      child: Center(
                                        child: Text(
                                          label,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: selected
                                                ? Colors.white
                                                : color,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Image Picker Widget ───────────────────────────────────────────────────

  Widget _buildImagePicker({
    required String label,
    required File? imageFile,
    required VoidCallback onPick,
    required VoidCallback onRemove,
    bool compact = false,
    Color accentColor = _primaryLight,
  }) {
    if (imageFile != null) {
      // Tampilkan preview gambar
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(
              imageFile,
              width: double.infinity,
              height: compact ? 80 : 140,
              fit: BoxFit.cover,
            ),
          ),
          // Tombol hapus gambar
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ),
          // Tombol ganti gambar
          Positioned(
            bottom: 6,
            right: 6,
            child: GestureDetector(
              onTap: onPick,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit_rounded, color: Colors.white, size: 12),
                    SizedBox(width: 4),
                    Text(
                      "Ganti",
                      style: TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Belum ada gambar — tampilkan tombol pilih
    return GestureDetector(
      onTap: onPick,
      child: Container(
        width: double.infinity,
        height: compact ? 44 : 60,
        decoration: BoxDecoration(
          color: accentColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: accentColor.withOpacity(0.25),
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_rounded,
              color: accentColor,
              size: compact ? 16 : 18,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: compact ? 11 : 12,
                color: accentColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Submit Button ─────────────────────────────────────────────────────────

  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: _isSubmitting ? null : _submitAll,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: _isSubmitting
              ? LinearGradient(
                  colors: [
                    _primaryMid.withOpacity(0.5),
                    _primaryLight.withOpacity(0.5),
                  ],
                )
              : const LinearGradient(colors: [_primaryDark, _primaryMid]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: _isSubmitting
              ? []
              : [
                  BoxShadow(
                    color: _primaryMid.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isSubmitting)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            else
              const Icon(
                Icons.rocket_launch_rounded,
                color: Colors.white,
                size: 20,
              ),
            const SizedBox(width: 10),
            Text(
              _isSubmitting ? "Menerbitkan..." : "Terbitkan Kuis Sekarang",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _sectionHeader(IconData icon, String title) {
    return Row(
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
        Icon(icon, color: _primaryMid, size: 18),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: _textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _primaryLight.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }

  Widget _buildTextField({
    TextEditingController? controller,
    required String label,
    String? hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14, color: _textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: _textSecondary, fontSize: 13),
        hintStyle: const TextStyle(color: _textSecondary, fontSize: 13),
        prefixIcon: Icon(icon, color: _primaryLight, size: 18),
        filled: true,
        fillColor: const Color(0xFFF8FAFF),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryLight.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryLight.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryMid, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: _textSecondary),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (v) {
              HapticFeedback.lightImpact();
              onChanged(v);
            },
            activeColor: _primaryMid,
            activeTrackColor: _primaryLight.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    String displayText = '';
    try {
      final dt = DateTime.parse(controller.text).toLocal();
      displayText =
          '${dt.day.toString().padLeft(2, '0')}-'
          '${dt.month.toString().padLeft(2, '0')}-'
          '${dt.year}  '
          '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {}

    return GestureDetector(
      onTap: () async {
        DateTime initial;
        try {
          initial = DateTime.parse(controller.text).toLocal();
        } catch (_) {
          initial = DateTime.now();
        }

        final date = await showDatePicker(
          context: context,
          initialDate: initial,
          firstDate: DateTime.now().subtract(const Duration(days: 1)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date == null || !mounted) return;

        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(initial),
        );
        if (time == null || !mounted) return;

        final localDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        controller.text = localDateTime.toUtc().toIso8601String();
        setState(() {});
      },
      child: AbsorbPointer(
        child: TextField(
          controller: TextEditingController(text: displayText),
          style: const TextStyle(fontSize: 14, color: _textPrimary),
          decoration: InputDecoration(
            labelText: label,
            hintText: "Ketuk untuk memilih waktu",
            labelStyle: const TextStyle(color: _textSecondary, fontSize: 13),
            hintStyle: const TextStyle(color: _textSecondary, fontSize: 13),
            prefixIcon: Icon(icon, color: _primaryLight, size: 18),
            suffixIcon: const Icon(
              Icons.edit_calendar_rounded,
              color: _primaryLight,
              size: 18,
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFF),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _primaryLight.withOpacity(0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _primaryLight.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _primaryMid, width: 1.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: _primaryLight.withOpacity(0.08),
      indent: 16,
      endIndent: 16,
    );
  }
}
