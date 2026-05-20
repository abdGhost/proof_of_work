import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/colors.dart';
import '../../dashboard/providers/dashboard_provider.dart';

class ShareScreen extends ConsumerWidget {
  const ShareScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Share your progress'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/shell'),
        ),
      ),
      body: Center(
        child: dashboardAsync.when(
          loading: () => const Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.accent,
              ),
            ),
          ),
          error: (_, __) => Center(
            child: Text(
              'Failed to load data',
              style: GoogleFonts.inter(color: AppColors.textSecondary),
            ),
          ),
          data: (data) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ShareCard(data: data),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => _share(data),
                    icon: const Icon(Icons.share_rounded, size: 20),
                    label: const Text('Share'),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () => _share(data),
                  icon: Icon(
                    Icons.copy_rounded,
                    color: AppColors.textMuted,
                    size: 18,
                  ),
                  label: Text(
                    'Copy to clipboard',
                    style: GoogleFonts.inter(color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _share(dynamic data) {
    final text = _buildText(data);
    Share.share(text);
  }

  String _buildText(dynamic data) {
    return '''
━━━━━━━━━━━━━━━━━━━━━━
🔥 ${data.currentStreak} Day Streak
💻 ${data.weeklyHours}h This Week
📊 Proof Score: ${data.proofScore}
━━━━━━━━━━━━━━━━━━━━━━

Track the grind. Share the proof.
#LockedIn #ProofOfWork
''';
  }
}

class _ShareCard extends StatelessWidget {
  final dynamic data;

  const _ShareCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.surface, AppColors.surfaceElevated.withAlpha(150)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderHairline),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'LOCKEDIN',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: 3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _ShareLine(emoji: '🔥', text: '${data.currentStreak} Day Streak'),
          const SizedBox(height: 14),
          _ShareLine(emoji: '💻', text: '${data.weeklyHours}h This Week'),
          const SizedBox(height: 14),
          _ShareLine(emoji: '📊', text: 'Proof Score: ${data.proofScore}'),
          const SizedBox(height: 14),
          _ShareLine(
            emoji: '📅',
            text: '${data.monthlyHours}h Total This Month',
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.accent.withAlpha(15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Proof > Motivation',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.accent,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareLine extends StatelessWidget {
  final String emoji;
  final String text;

  const _ShareLine({required this.emoji, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 10),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
