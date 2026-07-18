import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import 'main_shell.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  bool loading = false;
  String? errorText;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  Future<void> _submit() async {
    setState(() {
      loading = true;
      errorText = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    String? error;
    if (isLogin) {
      error = await AuthService.signIn(email, password);
    } else {
      if (name.isEmpty) {
        error = 'Please enter your name.';
      } else {
        error = await AuthService.signUp(email, password, name);
      }
    }

    if (!mounted) return;

    if (error == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    } else {
      setState(() {
        loading = false;
        errorText = error;
      });
    }
  }

  static const _darkText = Color(0xFF1A1A2E);
  static const _mutedText = Color(0xFF6B7280);
  static const _indigo = Color(0xFF4338CA);

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    return Scaffold(
      backgroundColor: Colors.white,
      body: isWide ? _wideLayout() : _narrowLayout(),
    );
  }

  Widget _wideLayout() {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Container(
            height: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 64),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF312E81), Color(0xFF4338CA)],
              ),
            ),
            child: Center(child: _brandPanel()),
          ),
        ),
        Expanded(
          flex: 4,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: _formPanel(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _narrowLayout() {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF312E81), Color(0xFF4338CA)]),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.precision_manufacturing_outlined, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('One Robotics Ai', style: TextStyle(color: _darkText, fontSize: 20, fontWeight: FontWeight.w800)),
                      Text('Learn. Build. Automate.', style: TextStyle(color: _mutedText, fontSize: 12)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _formPanel(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _brandPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.precision_manufacturing_outlined, color: Colors.white, size: 40),
        const SizedBox(height: 20),
        const Text('One Robotics Ai', style: TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text('Learn. Build. Automate.', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 15)),
        const SizedBox(height: 32),
        _brandFeature(Icons.smart_toy_outlined, 'Robotics & AI courses'),
        const SizedBox(height: 14),
        _brandFeature(Icons.workspace_premium_outlined, 'Verified certificates'),
        const SizedBox(height: 14),
        _brandFeature(Icons.groups_outlined, 'Active learner community'),
      ],
    );
  }

  Widget _brandFeature(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(width: 10),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _formPanel() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isLogin ? 'Welcome back' : 'Create account',
          style: const TextStyle(color: _darkText, fontSize: 26, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          isLogin ? 'Log in to continue learning.' : 'Sign up to start your robotics journey.',
          style: const TextStyle(color: _mutedText, fontSize: 14),
        ),
        const SizedBox(height: 28),
        if (!isLogin) ...[
          _buildField(controller: _nameController, label: 'Full name', icon: Icons.person_outline),
          const SizedBox(height: 16),
        ],
        _buildField(controller: _emailController, label: 'Email', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 16),
        _buildField(controller: _passwordController, label: 'Password', icon: Icons.lock_outline, obscureText: true),
        if (errorText != null) ...[
          const SizedBox(height: 16),
          Text(errorText!, style: const TextStyle(color: Colors.red, fontSize: 13)),
        ],
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _indigo,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: loading ? null : _submit,
            child: loading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(isLogin ? 'Log In' : 'Sign Up', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: TextButton(
            onPressed: loading
                ? null
                : () => setState(() {
                    isLogin = !isLogin;
                    errorText = null;
                  }),
            child: Text(
              isLogin ? "Don't have an account? Sign up" : 'Already have an account? Log in',
              style: const TextStyle(color: _indigo, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: _darkText, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle(color: _darkText, fontSize: 15),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: _mutedText, size: 20),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _indigo, width: 1.5)),
          ),
        ),
      ],
    );
  }
}