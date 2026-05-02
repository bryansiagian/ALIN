import 'package:flutter_math/features/auth/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFEEF4FF), // very light blue-white
              Color(0xFFDCEAFF), // soft sky
              Color(0xFFB8D4FF), // medium periwinkle
              Color(0xFF8AB8FF), // vibrant cornflower
            ],
            stops: [0.0, 0.35, 0.70, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: SizedBox(
              height: size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Spacer(flex: 2),

                        // ── Logo / Brand ──────────────────────────────────
                        Center(
                          child: Column(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF4B8EFF),
                                      Color(0xFF1A5FD4),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF1A5FD4)
                                          .withOpacity(0.35),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Text(
                                    "∑",
                                    style: TextStyle(
                                      fontSize: 40,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              ShaderMask(
                                shaderCallback: (bounds) =>
                                    const LinearGradient(
                                  colors: [
                                    Color(0xFF1A40A8),
                                    Color(0xFF2D6EE8),
                                  ],
                                ).createShader(bounds),
                                child: const Text(
                                  "ALIN",
                                  style: TextStyle(
                                    fontSize: 42,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 6,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Aplikasi Belajar Aljabar Linear",
                                style: TextStyle(
                                  fontSize: 13.5,
                                  color: const Color(0xFF1A5FD4)
                                      .withOpacity(0.75),
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(flex: 2),

                        // ── Card ──────────────────────────────────────────
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.88),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    const Color(0xFF4B8EFF).withOpacity(0.18),
                                blurRadius: 32,
                                spreadRadius: 0,
                                offset: const Offset(0, 12),
                              ),
                              BoxShadow(
                                color: Colors.white.withOpacity(0.9),
                                blurRadius: 8,
                                spreadRadius: 0,
                                offset: const Offset(0, -2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                "Selamat Datang 👋",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F2D6B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Masuk untuk melanjutkan belajar",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[500],
                                ),
                              ),
                              const SizedBox(height: 28),

                              // Email field
                              _buildLabel("Email"),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: emailController,
                                hint: "contoh@email.com",
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 18),

                              // Password field
                              _buildLabel("Password"),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: passwordController,
                                hint: "Masukkan password",
                                icon: Icons.lock_outline_rounded,
                                obscureText: _obscurePassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: const Color(0xFF4B8EFF),
                                    size: 20,
                                  ),
                                  onPressed: () => setState(
                                      () => _obscurePassword = !_obscurePassword),
                                ),
                              ),

                              // Error message
                              if (auth.error != null) ...[
                                const SizedBox(height: 14),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFEBEE),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: const Color(0xFFFFCDD2)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.error_outline,
                                          color: Color(0xFFE53935), size: 18),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          auth.error!,
                                          style: const TextStyle(
                                            color: Color(0xFFB71C1C),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              const SizedBox(height: 28),

                              // Login button
                              auth.isLoading
                                  ? Center(
                                      child: SizedBox(
                                        width: 44,
                                        height: 44,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                          color: const Color(0xFF2D6EE8),
                                        ),
                                      ),
                                    )
                                  : GestureDetector(
                                      onTap: () {
                                        ref.read(authProvider.notifier).login(
                                              emailController.text,
                                              passwordController.text,
                                            );
                                      },
                                      child: Container(
                                        height: 54,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                            colors: [
                                              Color(0xFF4B8EFF),
                                              Color(0xFF1A5FD4),
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF1A5FD4)
                                                  .withOpacity(0.40),
                                              blurRadius: 16,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        alignment: Alignment.center,
                                        child: const Text(
                                          "Masuk",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        ),

                        const Spacer(flex: 1),

                        // Footer
                        Center(
                          child: Text(
                            "© 2025 ALIN — Aljabar Linear",
                            style: TextStyle(
                              fontSize: 12,
                              color: const Color(0xFF1A5FD4).withOpacity(0.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF0F2D6B),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontSize: 14.5,
        color: Color(0xFF0F2D6B),
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF4B8EFF), size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF0F6FF),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD0E2FF), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF4B8EFF), width: 1.8),
        ),
      ),
    );
  }
}