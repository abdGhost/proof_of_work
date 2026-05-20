import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/colors.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../providers/timer_provider.dart';

class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({super.key});

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen> {
  final _taskController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedCategory = 'Coding';

  final _categories = [
    'Coding',
    'Study',
    'Reading',
    'Gym',
    'Freelance',
    'Deep Work',
  ];

  @override
  void dispose() {
    _taskController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveSession() async {
    if (_taskController.text.trim().isEmpty) return;

    final timer = ref.read(timerProvider.notifier);
    final duration = timer.durationInMinutes;
    if (duration == 0) return;

    try {
      await ref
          .read(sessionServiceProvider)
          .createSession(
            category: _selectedCategory,
            taskName: _taskController.text.trim(),
            duration: duration,
            notes: _notesController.text.trim(),
          );
      timer.stop();
      ref.invalidate(dashboardProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Session saved! ${_formattedDuration(duration)}',
              style: GoogleFonts.inter(color: AppColors.textPrimary),
            ),
            backgroundColor: AppColors.accent.withAlpha(30),
          ),
        );
        context.go('/shell');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: AppColors.accentRed.withAlpha(30),
          ),
        );
      }
    }
  }

  String _formattedDuration(int minutes) {
    if (minutes >= 60) {
      return '${minutes ~/ 60}h ${minutes % 60}m';
    }
    return '${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerProvider);
    final isRunning = timerState.isRunning;
    final isPaused = timerState.isPaused;
    final hasTime = timerState.elapsedSeconds >= 60;
    final accent =
        AppColors.categoryColors[_selectedCategory] ?? AppColors.accent;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            _Header(isRunning: isRunning, isPaused: isPaused, accent: accent),
            const SizedBox(height: 18),
            _CategoryStrip(
              categories: _categories,
              selectedCategory: _selectedCategory,
              onChanged: (value) => setState(() => _selectedCategory = value),
            ),
            const SizedBox(height: 14),
            _TaskInput(controller: _taskController, accent: accent),
            const SizedBox(height: 18),
            _TimerStage(
              timerState: timerState,
              accent: accent,
              category: _selectedCategory,
            ),
            const SizedBox(height: 18),
            _ControlDock(
              isRunning: isRunning,
              isPaused: isPaused,
              onStart: () => ref.read(timerProvider.notifier).start(),
              onPause: () => ref.read(timerProvider.notifier).pause(),
              onResume: () => ref.read(timerProvider.notifier).resume(),
              onStop: () => ref.read(timerProvider.notifier).stop(),
              accent: accent,
            ),
            const SizedBox(height: 22),
            _CaptureArea(
              notesController: _notesController,
              hasTime: hasTime,
              hasTask: _taskController.text.trim().isNotEmpty,
              onSave: _saveSession,
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.isRunning,
    required this.isPaused,
    required this.accent,
  });

  final bool isRunning;
  final bool isPaused;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Focus session',
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                _statusText(),
                style: GoogleFonts.inter(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accent.withAlpha(isRunning ? 34 : 16),
            border: Border.all(color: accent.withAlpha(isRunning ? 100 : 45)),
          ),
          child: Icon(
            isRunning
                ? Icons.bolt_rounded
                : isPaused
                ? Icons.pause_rounded
                : Icons.timer_outlined,
            color: accent,
            size: 18,
          ),
        ),
      ],
    );
  }

  String _statusText() {
    if (isRunning) return 'In the zone';
    if (isPaused) return 'Paused and ready';
    return 'Choose a lane and begin';
  }
}

class _CategoryStrip extends StatelessWidget {
  const _CategoryStrip({
    required this.categories,
    required this.selectedCategory,
    required this.onChanged,
  });

  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final color = AppColors.categoryColors[category] ?? AppColors.accent;
          final selected = category == selectedCategory;

          return GestureDetector(
            onTap: () => onChanged(category),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 11),
              decoration: BoxDecoration(
                color: selected ? color.withAlpha(24) : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected
                      ? color.withAlpha(120)
                      : AppColors.borderHairline,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    category,
                    style: GoogleFonts.inter(
                      color: selected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TaskInput extends StatelessWidget {
  const _TaskInput({required this.controller, required this.accent});

  final TextEditingController controller;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.inter(
        color: AppColors.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      cursorColor: accent,
      decoration: InputDecoration(
        filled: false,
        hintText: 'What are you proving right now?',
        hintStyle: GoogleFonts.inter(
          color: AppColors.textMuted,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Icon(Icons.edit_outlined, color: accent, size: 18),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 34,
          minHeight: 40,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 11),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.borderHairline),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: accent, width: 1.2),
        ),
      ),
    );
  }
}

class _TimerStage extends StatelessWidget {
  const _TimerStage({
    required this.timerState,
    required this.accent,
    required this.category,
  });

  final TimerState timerState;
  final Color accent;
  final String category;

  @override
  Widget build(BuildContext context) {
    final progress = (timerState.elapsedSeconds % 3600) / 3600;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth * 0.68, 260.0);
        final timerFontSize = size * 0.2;

        return Center(
          child: SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _TimerRingPainter(
                progress: progress,
                accent: accent,
                isRunning: timerState.isRunning,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    category.toUpperCase(),
                    style: GoogleFonts.inter(
                      color: accent,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.6,
                    ),
                  ),
                  const SizedBox(height: 10),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      timerState.formattedTime,
                      style: GoogleFonts.inter(
                        color: timerState.isRunning
                            ? accent
                            : AppColors.textPrimary,
                        fontSize: timerFontSize,
                        fontWeight: FontWeight.w300,
                        height: 0.95,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    _helperText(timerState),
                    style: GoogleFonts.inter(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _helperText(TimerState state) {
    if (state.isRunning) return 'Stay with the task';
    if (state.isPaused) return 'Resume when ready';
    return 'Tap start when your mind is clear';
  }
}

class _TimerRingPainter extends CustomPainter {
  const _TimerRingPainter({
    required this.progress,
    required this.accent,
    required this.isRunning,
  });

  final double progress;
  final Color accent;
  final bool isRunning;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 7;

    final outer = Paint()
      ..color = AppColors.borderHairline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius, outer);

    final halo = Paint()
      ..color = accent.withAlpha(isRunning ? 16 : 6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - 14, halo);

    final progressPaint = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _TimerRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.accent != accent ||
        oldDelegate.isRunning != isRunning;
  }
}

class _ControlDock extends StatelessWidget {
  const _ControlDock({
    required this.isRunning,
    required this.isPaused,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onStop,
    required this.accent,
  });

  final bool isRunning;
  final bool isPaused;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 10,
      children: [
        if (isRunning || isPaused)
          _SmallActionButton(
            icon: Icons.stop_rounded,
            label: 'Reset',
            color: AppColors.accentRed,
            onTap: onStop,
          ),
        _PrimaryActionButton(
          icon: isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
          label: isRunning
              ? 'Pause'
              : isPaused
              ? 'Resume'
              : 'Start',
          color: isRunning ? AppColors.accentOrange : accent,
          onTap: isRunning
              ? onPause
              : isPaused
              ? onResume
              : onStart,
        ),
      ],
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        constraints: const BoxConstraints(minWidth: 112),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.background, size: 20),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                color: AppColors.background,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallActionButton extends StatelessWidget {
  const _SmallActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color.withAlpha(90)),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _CaptureArea extends StatelessWidget {
  const _CaptureArea({
    required this.notesController,
    required this.hasTime,
    required this.hasTask,
    required this.onSave,
  });

  final TextEditingController notesController;
  final bool hasTime;
  final bool hasTask;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final canSave = hasTime && hasTask;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(height: 1, color: AppColors.borderHairline),
        const SizedBox(height: 12),
        TextFormField(
          controller: notesController,
          maxLines: 2,
          style: GoogleFonts.inter(color: AppColors.textPrimary),
          decoration: InputDecoration(
            filled: false,
            hintText: 'Add a quick note after the session...',
            hintStyle: GoogleFonts.inter(
              color: AppColors.textMuted,
              fontSize: 13,
            ),
            prefixIcon: const Icon(
              Icons.notes_rounded,
              color: AppColors.textMuted,
              size: 18,
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 34,
              minHeight: 40,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 46,
          child: ElevatedButton.icon(
            onPressed: canSave ? onSave : null,
            icon: Icon(
              canSave ? Icons.check_rounded : Icons.lock_clock_rounded,
            ),
            label: Text(_saveLabel()),
            style: ElevatedButton.styleFrom(
              backgroundColor: canSave
                  ? AppColors.accent
                  : AppColors.surfaceElevated,
              foregroundColor: canSave
                  ? AppColors.background
                  : AppColors.textMuted,
              disabledBackgroundColor: AppColors.surfaceElevated,
              disabledForegroundColor: AppColors.textMuted,
              textStyle: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _saveLabel() {
    if (!hasTask) return 'Name the task to save';
    if (!hasTime) return 'Work at least 1 min';
    return 'Save session';
  }
}
