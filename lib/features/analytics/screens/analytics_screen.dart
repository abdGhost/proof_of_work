import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/colors.dart';
import '../../../models/stats.dart';
import '../providers/analytics_provider.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyAsync = ref.watch(weeklyStatsProvider);
    final monthlyAsync = ref.watch(monthlyStatsProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.accent,
          backgroundColor: AppColors.surface,
          onRefresh: () async {
            ref.invalidate(weeklyStatsProvider);
            ref.invalidate(monthlyStatsProvider);
            await Future.wait([
              ref.read(weeklyStatsProvider.future),
              ref.read(monthlyStatsProvider.future),
            ]);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              const _AnalyticsHeader(),
              const SizedBox(height: 22),
              _SummaryHero(
                weeklyAsync: weeklyAsync,
                monthlyAsync: monthlyAsync,
              ),
              const SizedBox(height: 28),
              _WeeklySection(weeklyAsync: weeklyAsync),
              const SizedBox(height: 28),
              _CategorySection(monthlyAsync: monthlyAsync),
              const SizedBox(height: 28),
              _BreakdownSection(monthlyAsync: monthlyAsync),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnalyticsHeader extends StatelessWidget {
  const _AnalyticsHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analytics',
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 26,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          'Patterns, not pressure.',
          style: GoogleFonts.inter(
            color: AppColors.textMuted,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SummaryHero extends StatelessWidget {
  const _SummaryHero({required this.weeklyAsync, required this.monthlyAsync});

  final AsyncValue<WeeklyStats> weeklyAsync;
  final AsyncValue<MonthlyStats> monthlyAsync;

  @override
  Widget build(BuildContext context) {
    return monthlyAsync.when(
      loading: () => const _LoadingBlock(height: 118),
      error: (_, __) => const _EmptyMessage(
        title: 'Summary unavailable',
        subtitle: 'Pull down to try again.',
      ),
      data: (monthly) {
        final weekly = weeklyAsync.valueOrNull;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatHours(monthly.totalHours),
              style: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontSize: 64,
                fontWeight: FontWeight.w800,
                height: 0.9,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'tracked this month across ${monthly.totalSessions} sessions',
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: _TinyKpi(
                    label: 'This week',
                    value: weekly == null
                        ? '--'
                        : _formatHours(weekly.totalHours),
                    color: AppColors.accent,
                  ),
                ),
                const _VerticalRule(),
                Expanded(
                  child: _TinyKpi(
                    label: 'Weekly logs',
                    value: weekly == null ? '--' : '${weekly.totalSessions}',
                    color: AppColors.accentBlue,
                  ),
                ),
                const _VerticalRule(),
                Expanded(
                  child: _TinyKpi(
                    label: 'Avg/session',
                    value: _averageSession(monthly),
                    color: AppColors.accentOrange,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  String _averageSession(MonthlyStats stats) {
    if (stats.totalSessions == 0) return '0m';
    final minutes = (stats.totalHours * 60 / stats.totalSessions).round();
    if (minutes >= 60) return '${minutes ~/ 60}h ${minutes % 60}m';
    return '${minutes}m';
  }
}

class _TinyKpi extends StatelessWidget {
  const _TinyKpi({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: GoogleFonts.inter(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
      ],
    );
  }
}

class _WeeklySection extends StatelessWidget {
  const _WeeklySection({required this.weeklyAsync});

  final AsyncValue<WeeklyStats> weeklyAsync;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Weekly rhythm',
      subtitle: 'Which days carried the work.',
      child: SizedBox(
        height: 210,
        child: weeklyAsync.when(
          loading: () => const _LoadingBlock(height: 210),
          error: (_, __) => const _EmptyMessage(
            title: 'Weekly chart unavailable',
            subtitle: 'Pull down to refresh analytics.',
          ),
          data: (stats) => _WeeklyBarChart(data: stats.dailyBreakdown),
        ),
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({required this.monthlyAsync});

  final AsyncValue<MonthlyStats> monthlyAsync;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Category mix',
      subtitle: 'Where your hours are going.',
      child: SizedBox(
        height: 210,
        child: monthlyAsync.when(
          loading: () => const _LoadingBlock(height: 210),
          error: (_, __) => const _EmptyMessage(
            title: 'Category chart unavailable',
            subtitle: 'Pull down to refresh analytics.',
          ),
          data: (stats) => _CategoryDonut(data: stats.categoryBreakdown),
        ),
      ),
    );
  }
}

class _BreakdownSection extends StatelessWidget {
  const _BreakdownSection({required this.monthlyAsync});

  final AsyncValue<MonthlyStats> monthlyAsync;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Breakdown',
      subtitle: 'Month-to-date detail.',
      child: monthlyAsync.when(
        loading: () => const _LoadingBlock(height: 110),
        error: (_, __) => const _EmptyMessage(
          title: 'Breakdown unavailable',
          subtitle: 'Pull down to try again.',
        ),
        data: (stats) {
          final entries = stats.categoryBreakdown.entries.toList()
            ..sort((a, b) => _asDouble(b.value).compareTo(_asDouble(a.value)));

          if (entries.isEmpty) {
            return const _EmptyMessage(
              title: 'No analytics yet',
              subtitle: 'Save a focus session to build your first report.',
            );
          }

          final total = entries.fold<double>(
            0,
            (sum, entry) => sum + _asDouble(entry.value),
          );

          return Column(
            children: [
              _SummaryRow(
                label: 'Total hours',
                value: _formatHours(stats.totalHours),
              ),
              const SizedBox(height: 12),
              _SummaryRow(
                label: 'Total sessions',
                value: '${stats.totalSessions}',
              ),
              const SizedBox(height: 18),
              Container(height: 1, color: AppColors.borderHairline),
              const SizedBox(height: 16),
              ...entries.map(
                (entry) => _CategoryRow(
                  label: entry.key,
                  hours: _asDouble(entry.value),
                  total: math.max(total, 1),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }
}

class _WeeklyBarChart extends StatelessWidget {
  const _WeeklyBarChart({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final days = const [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    final hasData = days.any((day) => _asDouble(data[day]) > 0);
    if (!hasData) {
      return const _EmptyMessage(
        title: 'No weekly rhythm yet',
        subtitle: 'Your saved sessions will appear as daily bars.',
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        gridData: FlGridData(
          show: true,
          horizontalInterval: 1,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: AppColors.borderHairline, strokeWidth: 0.5),
        ),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= days.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    days[idx].substring(0, 1),
                    style: GoogleFonts.inter(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: days.asMap().entries.map((entry) {
          final value = _asDouble(data[entry.value]);
          final active = value > 0;
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: value,
                color: active ? AppColors.accent : AppColors.surfaceElevated,
                width: 18,
                borderRadius: BorderRadius.circular(9),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: _maxY(data, days),
                  color: AppColors.surfaceElevated.withAlpha(90),
                ),
              ),
            ],
          );
        }).toList(),
        maxY: _maxY(data, days),
        barTouchData: BarTouchData(enabled: false),
      ),
    );
  }

  double _maxY(Map<String, dynamic> data, List<String> days) {
    var maxValue = 0.0;
    for (final day in days) {
      maxValue = math.max(maxValue, _asDouble(data[day]));
    }
    return maxValue < 1 ? 1 : maxValue * 1.25;
  }
}

class _CategoryDonut extends StatelessWidget {
  const _CategoryDonut({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final entries = data.entries.toList()
      ..sort((a, b) => _asDouble(b.value).compareTo(_asDouble(a.value)));

    if (entries.isEmpty) {
      return const _EmptyMessage(
        title: 'No category mix yet',
        subtitle: 'Save sessions in categories to reveal your split.',
      );
    }

    final colors = [
      AppColors.accent,
      AppColors.accentOrange,
      AppColors.accentBlue,
      AppColors.accentPurple,
      AppColors.accentYellow,
      AppColors.accentRed,
    ];
    final total = entries.fold<double>(0, (sum, e) => sum + _asDouble(e.value));

    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: 48,
              sections: entries.asMap().entries.map((entry) {
                final idx = entry.key;
                final item = entry.value;
                final value = _asDouble(item.value);
                return PieChartSectionData(
                  value: value,
                  color: colors[idx % colors.length],
                  title: '',
                  radius: 28,
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: entries.take(5).toList().asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              final value = _asDouble(item.value);
              final percent = total == 0 ? 0 : (value / total * 100).round();
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _LegendLine(
                  color: colors[idx % colors.length],
                  label: item.key,
                  value: '$percent%',
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _LegendLine extends StatelessWidget {
  const _LegendLine({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.label,
    required this.hours,
    required this.total,
  });

  final String label;
  final double hours;
  final double total;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.categoryColors[label] ?? AppColors.accent;
    final progress = (hours / total).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                _formatHours(hours),
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              color: color,
              backgroundColor: AppColors.surfaceElevated,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _VerticalRule extends StatelessWidget {
  const _VerticalRule();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 13),
      color: AppColors.borderHairline,
    );
  }
}

class _LoadingBlock extends StatelessWidget {
  const _LoadingBlock({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.accent,
          ),
        ),
      ),
    );
  }
}

class _EmptyMessage extends StatelessWidget {
  const _EmptyMessage({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 54, height: 2, color: AppColors.accent),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: AppColors.textMuted,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

double _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

String _formatHours(double hours) {
  if (hours == 0) return '0h';
  if (hours < 1) return '${(hours * 60).round()}m';
  if (hours == hours.roundToDouble()) return '${hours.toInt()}h';
  return '${hours.toStringAsFixed(1)}h';
}
