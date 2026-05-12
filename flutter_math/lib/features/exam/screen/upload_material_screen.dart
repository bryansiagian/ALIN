import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/features/exam/service/lecturer_service.dart';
import 'package:flutter_math/core/api/api_client.dart';
import 'package:flutter_math/features/exam/screen/create_topic_screen.dart';

// ─────────────────────────────────────────────
//  Design Tokens
// ─────────────────────────────────────────────
const _kBlue900 = Color(0xFF0D2B6B);
const _kBlue700 = Color(0xFF1A56DB);
const _kBlue500 = Color(0xFF3B82F6);
const _kBlue200 = Color(0xFFBFDBFE);
const _kBlue50  = Color(0xFFEFF6FF);
const _kSurface = Color(0xFFF8FAFF);

class UploadMaterialScreen extends ConsumerStatefulWidget {
  const UploadMaterialScreen({super.key});

  @override
  ConsumerState<UploadMaterialScreen> createState() => _UploadMaterialScreenState();
}

class _UploadMaterialScreenState extends ConsumerState<UploadMaterialScreen> {
  final _titleController = TextEditingController();
  int? _selectedTopicId;
  File? _selectedFile;
  List<dynamic> _topics = [];
  bool _isLoadingTopics = true;
  bool _isUploading = false;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTopics());
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _loadTopics() async {
    setState(() => _isLoadingTopics = true);
    try {
      final service = LecturerService(ref.read(apiClientProvider).dio);
      final data = await service.getTopicsList();
      setState(() {
        _topics = data;
        _isLoadingTopics = false;
      });
      } catch (e) {
      setState(() => _isLoadingTopics = false);
    }
  }

  Future<void> _pickPDF() async {
    HapticFeedback.lightImpact();
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _selectedFile = File(result.files.single.path!));
    }
  }

  bool get _isFormValid =>
      _titleController.text.trim().isNotEmpty &&
      _selectedTopicId != null &&
      _selectedFile != null;

  Future<void> _submit() async {
    if (!_isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF1A1A2E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFFBBF24), size: 18),
              SizedBox(width: 10),
              Text("Harap lengkapi semua field!", style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final service = LecturerService(ref.read(apiClientProvider).dio);
      await service.uploadMaterial(
        topicId: _selectedTopicId!,
        title: _titleController.text.trim(),
        filePath: _selectedFile!.path,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF1A1A2E),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: const Row(
              children: [
                Icon(Icons.check_circle_outline_rounded, color: Color(0xFF6EE7B7), size: 18),
                SizedBox(width: 10),
                Text("Materi PDF berhasil diunggah!", style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF1A1A2E),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Color(0xFFFF6B6B), size: 18),
                const SizedBox(width: 10),
                Expanded(child: Text("Gagal mengunggah: $e", style: const TextStyle(color: Colors.white))),
              ],
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _kSurface,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverAppBar(),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Step 1: Judul
                        _StepCard(
                          step: 1,
                          title: "Judul Materi",
                          child: _TitleField(controller: _titleController, onChanged: (_) => setState(() {})),
                        ),
                        const SizedBox(height: 16),

                        // Step 2: Topik
                        _StepCard(
                          step: 2,
                          title: "Pilih Topik",
                          action: _AddTopicButton(onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const CreateTopicScreen()),
                            );
                            if (result == true) _loadTopics();
                          }),
                          child: _isLoadingTopics
                              ? const _TopicLoadingIndicator()
                              : _TopicDropdown(
                                  topics: _topics,
                                  selectedId: _selectedTopicId,
                                  onChanged: (v) => setState(() => _selectedTopicId = v),
                                ),
                        ),
                        const SizedBox(height: 16),

                        // Step 3: File PDF
                        _StepCard(
                          step: 3,
                          title: "File PDF",
                          child: _FilePickerZone(
                            selectedFile: _selectedFile,
                            onTap: _pickPDF,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Upload Button
                        _UploadButton(
                          isValid: _isFormValid,
                          isUploading: _isUploading,
                          onTap: _submit,
                        ),
                      ],
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 160,
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
          child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Container(
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
                        child: const Icon(Icons.upload_file_rounded, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Tambah Materi",
                            style: TextStyle(
                              color: Colors.white, fontSize: 20,
                              fontWeight: FontWeight.w700, letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            "Unggah file PDF untuk mahasiswa",
                            style: TextStyle(color: Color(0xFFBFDBFE), fontSize: 12),
                          ),
                        ],
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
//  Step Card Container
// ─────────────────────────────────────────────
class _StepCard extends StatelessWidget {
  const _StepCard({required this.step, required this.title, required this.child, this.action});
  final int step;
  final String title;
  final Widget child;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kBlue200, width: 1.2),
        boxShadow: [
          BoxShadow(color: _kBlue500.withOpacity(0.07), blurRadius: 14, offset: const Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_kBlue700, _kBlue500]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    "$step",
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
              ),
              if (action != null) ...[const Spacer(), action!],
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Title Field
// ─────────────────────────────────────────────
class _TitleField extends StatelessWidget {
  const _TitleField({required this.controller, required this.onChanged});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kBlue50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBlue200),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
        decoration: const InputDecoration(
          hintText: "Contoh: Determinan Matriks Invers",
          hintStyle: TextStyle(color: Color(0xFFCBD5E1), fontSize: 14),
          prefixIcon: Icon(Icons.title_rounded, color: _kBlue500, size: 20),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Add Topic Button
// ─────────────────────────────────────────────
class _AddTopicButton extends StatelessWidget {
  const _AddTopicButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF86EFAC)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, color: Color(0xFF059669), size: 16),
            SizedBox(width: 4),
            Text("Topik Baru", style: TextStyle(color: Color(0xFF059669), fontSize: 12, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Topic Loading
// ─────────────────────────────────────────────
class _TopicLoadingIndicator extends StatelessWidget {
  const _TopicLoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 18, height: 18,
            child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation(_kBlue500)),
          ),
          SizedBox(width: 12),
          Text("Memuat daftar topik...", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Topic Dropdown
// ─────────────────────────────────────────────
class _TopicDropdown extends StatelessWidget {
  const _TopicDropdown({required this.topics, required this.selectedId, required this.onChanged});
  final List<dynamic> topics;
  final int? selectedId;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    if (topics.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFDE68A)),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline_rounded, color: Color(0xFFD97706), size: 16),
            SizedBox(width: 8),
            Text("Belum ada topik. Buat topik baru dulu.", style: TextStyle(color: Color(0xFFD97706), fontSize: 13)),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: _kBlue50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBlue200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selectedId,
          isExpanded: true,
          hint: const Text("Pilih Bab / Topik", style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 14)),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _kBlue500),
          style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
          items: topics.map((t) => DropdownMenuItem<int>(
            value: t['id'] as int,
            child: Text(t['title'] as String),
          )).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  File Picker Zone
// ─────────────────────────────────────────────
class _FilePickerZone extends StatefulWidget {
  const _FilePickerZone({required this.selectedFile, required this.onTap});
  final File? selectedFile;
  final VoidCallback onTap;

  @override
  State<_FilePickerZone> createState() => _FilePickerZoneState();
}

class _FilePickerZoneState extends State<_FilePickerZone> with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 100), lowerBound: 0.97, upperBound: 1.0, value: 1.0);
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasFile = widget.selectedFile != null;
    final fileName = hasFile ? widget.selectedFile!.path.split('/').last : null;
    final fileSize = hasFile ? widget.selectedFile!.lengthSync() : 0;
    final fileSizeKb = (fileSize / 1024).toStringAsFixed(1);

    return GestureDetector(
      onTapDown: (_) => _pressCtrl.reverse(),
      onTapUp: (_) { _pressCtrl.forward(); widget.onTap(); },
      onTapCancel: () => _pressCtrl.forward(),
      child: AnimatedBuilder(
        animation: _pressCtrl,
        builder: (_, child) => Transform.scale(scale: _pressCtrl.value, child: child),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
          decoration: BoxDecoration(
            color: hasFile ? const Color(0xFFF0FDF4) : _kBlue50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasFile ? const Color(0xFF86EFAC) : _kBlue200,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: hasFile
                      ? const LinearGradient(colors: [Color(0xFF059669), Color(0xFF10B981)])
                      : const LinearGradient(colors: [_kBlue700, _kBlue500]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (hasFile ? const Color(0xFF059669) : _kBlue500).withOpacity(0.30),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  hasFile ? Icons.check_circle_outline_rounded : Icons.upload_file_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                hasFile ? "File Terpilih" : "Ketuk untuk pilih file PDF",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: hasFile ? const Color(0xFF059669) : _kBlue700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                hasFile
                    ? "$fileName  •  $fileSizeKb KB"
                    : "Format: PDF  •  Ukuran bebas",
                style: TextStyle(
                  fontSize: 12,
                  color: hasFile ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (hasFile) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF86EFAC)),
                  ),
                  child: const Text(
                    "Ketuk untuk ganti file",
                    style: TextStyle(fontSize: 11, color: Color(0xFF059669), fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Upload Button
// ─────────────────────────────────────────────
class _UploadButton extends StatelessWidget {
  const _UploadButton({required this.isValid, required this.isUploading, required this.onTap});
  final bool isValid;
  final bool isUploading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (!isValid || isUploading) ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: isValid && !isUploading
              ? const LinearGradient(colors: [_kBlue700, _kBlue500])
              : null,
          color: isValid && !isUploading ? null : const Color(0xFFCBD5E1),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isValid && !isUploading
              ? [BoxShadow(color: _kBlue500.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 4))]
              : null,
        ),
        child: Center(
          child: isUploading
              ? const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                    ),
                    SizedBox(width: 12),
                    Text("Mengunggah...", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                  ],
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.cloud_upload_rounded,
                      color: isValid ? Colors.white : const Color(0xFF94A3B8),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Upload Sekarang",
                      style: TextStyle(
                        color: isValid ? Colors.white : const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}