import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/colors.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_layout.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(authStateProvider.notifier)
        .login(_usernameController.text.trim(), _passwordController.text);
    final authState = ref.read(authStateProvider);
    if (authState.hasValue && authState.value != null) {
      if (mounted) context.go('/shell');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Form(
        key: _formKey,
        child: AuthLayout(
          icon: Icons.lock_outline_rounded,
          kicker: 'Proof of Work',
          title: 'LockedIn',
          subtitle:
              'Return to your dashboard, keep your streak alive, and make today count.',
          formTitle: 'Welcome back',
          formSubtitle: 'Sign in to continue tracking focused work.',
          footer: AuthFooter(
            text: "Don't have an account? ",
            action: 'Create one',
            onTap: () => context.go('/register'),
          ),
          children: [
            AuthTextField(
              controller: _usernameController,
              label: 'Username',
              hint: 'Enter your username',
              icon: Icons.person_outline_rounded,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Enter your username' : null,
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: _passwordController,
              label: 'Password',
              hint: 'Enter your password',
              icon: Icons.lock_outline_rounded,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: AppColors.textMuted,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Enter your password' : null,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 54,
              child: authState.isLoading
                  ? const Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.accent,
                        ),
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: _login,
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                      label: const Text('Sign in'),
                    ),
            ),
            if (authState.hasError) ...[
              const SizedBox(height: 14),
              const AuthError(message: 'Invalid username or password'),
            ],
          ],
        ),
      ),
    );
  }
}
