import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/colors.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_layout.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
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
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(authStateProvider.notifier)
        .register(
          _usernameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text,
        );
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
          icon: Icons.person_add_alt_1_rounded,
          kicker: 'Start strong',
          title: 'LockedIn',
          subtitle:
              'Create your account and turn every focused session into visible proof.',
          formTitle: 'Create account',
          formSubtitle: 'Set up your workspace in a few seconds.',
          footer: AuthFooter(
            text: 'Already have an account? ',
            action: 'Sign in',
            onTap: () => context.go('/login'),
          ),
          children: [
            AuthTextField(
              controller: _usernameController,
              label: 'Username',
              hint: 'Choose a username',
              icon: Icons.person_outline_rounded,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Choose a username' : null,
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: _emailController,
              label: 'Email',
              hint: 'you@example.com',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter your email';
                if (!v.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: _passwordController,
              label: 'Password',
              hint: 'Create a password',
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
                  v == null || v.isEmpty ? 'Create a password' : null,
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
                      onPressed: _register,
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: const Text('Create account'),
                    ),
            ),
            if (authState.hasError) ...[
              const SizedBox(height: 14),
              const AuthError(
                message: 'Registration failed. Try another username or email.',
              ),
            ],
          ],
        ),
      ),
    );
  }
}
