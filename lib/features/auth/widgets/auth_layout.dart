import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/colors.dart';

class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.icon,
    required this.kicker,
    required this.title,
    required this.subtitle,
    required this.formTitle,
    required this.formSubtitle,
    required this.children,
    required this.footer,
  });

  final IconData icon;
  final String kicker;
  final String title;
  final String subtitle;
  final String formTitle;
  final String formSubtitle;
  final List<Widget> children;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 760;
            final contentWidth = math
                .min(constraints.maxWidth - 40, 1040)
                .toDouble();

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 32 : 20,
                vertical: isWide ? 34 : 22,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: contentWidth),
                  child: isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: _BrandPanel(
                                icon: icon,
                                kicker: kicker,
                                title: title,
                                subtitle: subtitle,
                              ),
                            ),
                            const SizedBox(width: 36),
                            SizedBox(
                              width: 420,
                              child: _AuthForm(
                                title: formTitle,
                                subtitle: formSubtitle,
                                footer: footer,
                                children: children,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _BrandPanel(
                              icon: icon,
                              kicker: kicker,
                              title: title,
                              subtitle: subtitle,
                              compact: true,
                            ),
                            const SizedBox(height: 28),
                            _AuthForm(
                              title: formTitle,
                              subtitle: formSubtitle,
                              footer: footer,
                              children: children,
                            ),
                          ],
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: GoogleFonts.inter(color: AppColors.textPrimary),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}

class AuthError extends StatelessWidget {
  const AuthError({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.accentRed.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accentRed.withAlpha(50)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.accentRed,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(
                color: AppColors.accentRed,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthFooter extends StatelessWidget {
  const AuthFooter({
    super.key,
    required this.text,
    required this.action,
    required this.onTap,
  });

  final String text;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          text,
          style: GoogleFonts.inter(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        TextButton(onPressed: onTap, child: Text(action)),
      ],
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel({
    required this.icon,
    required this.kicker,
    required this.title,
    required this.subtitle,
    this.compact = false,
  });

  final IconData icon;
  final String kicker;
  final String title;
  final String subtitle;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: compact ? null : 560,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.accent.withAlpha(28),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.accent.withAlpha(80)),
                ),
                child: Icon(icon, color: AppColors.accent, size: 24),
              ),
              const SizedBox(width: 14),
              Text(
                kicker,
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 34 : 90),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontSize: compact ? 40 : 56,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              const SizedBox(height: 16),
              Container(width: 72, height: 2, color: AppColors.accent),
              const SizedBox(height: 18),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ],
          ),
          if (!compact) ...[
            const SizedBox(height: 44),
            const Row(
              children: [
                _MetricPill(label: 'Focus', value: '90m'),
                SizedBox(width: 10),
                _MetricPill(label: 'Streak', value: '12d'),
                SizedBox(width: 10),
                _MetricPill(label: 'Proof', value: 'live'),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _AuthForm extends StatelessWidget {
  const _AuthForm({
    required this.title,
    required this.subtitle,
    required this.children,
    required this.footer,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 22),
          Container(height: 1, color: AppColors.borderHairline),
          const SizedBox(height: 26),
          ...children,
          const SizedBox(height: 18),
          footer,
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(left: BorderSide(color: AppColors.borderHairline)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                color: AppColors.textMuted,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
