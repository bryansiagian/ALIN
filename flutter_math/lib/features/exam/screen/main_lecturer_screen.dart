import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_math/features/auth/provider/auth_provider.dart';
import 'package:flutter_math/features/exam/screen/lecturer_dashboard_screen.dart';
import 'package:flutter_math/features/exam/screen/student_list_screen.dart';
import 'package:flutter_math/features/exam/screen/upload_material_screen.dart';

class MainLecturerScreen extends ConsumerStatefulWidget {
  const MainLecturerScreen({super.key});

  @override
  ConsumerState<MainLecturerScreen> createState() =>
      _MainLecturerScreenState();
}

class _MainLecturerScreenState extends ConsumerState<MainLecturerScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _navAnim;

  final List<Widget> _pages = [
    const LecturerDashboardScreen(),
    const StudentListScreen(),
    const Center(child: Text("Halaman Manajemen Materi")),
  ];

  static const _tabs = [
    _TabMeta(
      icon: Icons.quiz_rounded,
      activeIcon: Icons.quiz_rounded,
      label: "Kuis",
    ),
    _TabMeta(
      icon: Icons.people_outline_rounded,
      activeIcon: Icons.people_rounded,
      label: "Mahasiswa",
    ),
    _TabMeta(
      icon: Icons.menu_book_outlined,
      activeIcon: Icons.menu_book_rounded,
      label: "Materi",
    ),
  ];

  static const _titles = ["Manajemen Kuis", "Daftar Mahasiswa", "Manajemen Materi"];

  @override
  void initState() {
    super.initState();
    _navAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _navAnim.dispose();
    super.dispose();
  }

  void _onTabTap(int index) {
    if (index == _currentIndex) return;
    _navAnim.forward(from: 0);
    setState(() => _currentIndex = index);
  }

  void _confirmLogout() {
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
          "Sesi mengajarmu akan diakhiri.",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F6FF),
      body: Column(
        children: [
          // ── Gradient Header ──────────────────────────────────────
          Container(
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
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x331A5FD4),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(20, 12, 12, 18),
                child: Row(
                  children: [
                    // Logo + title
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Center(
                        child: Text("∑",
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: Text(
                              _titles[_currentIndex],
                              key: ValueKey(_currentIndex),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Text(
                            "Panel Dosen — ALIN",
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Colors.white.withOpacity(0.72),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Upload button (tab Materi only)
                    if (_currentIndex == 2)
                      _HeaderIconBtn(
                        icon: Icons.add_rounded,
                        tooltip: "Upload Materi",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const UploadMaterialScreen()),
                        ),
                      ),
                    const SizedBox(width: 6),
                    // Logout
                    _HeaderIconBtn(
                      icon: Icons.logout_rounded,
                      tooltip: "Keluar",
                      onTap: _confirmLogout,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Page Body ────────────────────────────────────────────
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: child,
              ),
              child: KeyedSubtree(
                key: ValueKey(_currentIndex),
                child: _pages[_currentIndex],
              ),
            ),
          ),
        ],
      ),

      // ── Bottom Nav ───────────────────────────────────────────────
      bottomNavigationBar: _ModernBottomNav(
        currentIndex: _currentIndex,
        tabs: _tabs,
        onTap: _onTabTap,
      ),
    );
  }
}

// ── Header Icon Button ────────────────────────────────────────────────────────
class _HeaderIconBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _HeaderIconBtn({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

// ── Tab Metadata ──────────────────────────────────────────────────────────────
class _TabMeta {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _TabMeta(
      {required this.icon,
      required this.activeIcon,
      required this.label});
}

// ── Modern Bottom Nav ─────────────────────────────────────────────────────────
class _ModernBottomNav extends StatelessWidget {
  final int currentIndex;
  final List<_TabMeta> tabs;
  final ValueChanged<int> onTap;

  const _ModernBottomNav({
    required this.currentIndex,
    required this.tabs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x1A4B8EFF),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: List.generate(tabs.length, (i) {
              final tab = tabs[i];
              final active = i == currentIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: active
                          ? const Color(0xFFDCEAFF)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: Icon(
                            active ? tab.activeIcon : tab.icon,
                            key: ValueKey(active),
                            size: 24,
                            color: active
                                ? const Color(0xFF1A5FD4)
                                : Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 180),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: active
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: active
                                ? const Color(0xFF1A5FD4)
                                : Colors.grey[400],
                          ),
                          child: Text(tab.label),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}