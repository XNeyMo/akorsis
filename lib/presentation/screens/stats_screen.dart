import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../bloc/goal_bloc.dart';
import '../bloc/goal_state.dart';
import '../../domain/entities/goal.dart';
import '../../core/l10n/app_localizations.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF11131D) : const Color(0xFFF5F7FA),
      body: SafeArea(
        child: BlocBuilder<GoalBloc, GoalState>(
          builder: (context, state) {
            if (state is GoalLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is GoalsLoaded) {
              final stats = _calculateStats(state.goals);

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.statistics,
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF222639),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.yourProgressOverview,
                        style: TextStyle(
                          fontSize: 17,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Overall progress card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark 
                                ? [const Color(0xFF1E2235), const Color(0xFF171A26)]
                                : [Colors.white, const Color(0xFFF8FAFE)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isDark 
                                ? const Color(0xFF2A2D3A) 
                                : Colors.grey.shade200,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1ABC9C).withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF1ABC9C), Color(0xFF26C6DA)],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    l10n.overallProgress,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),
                            SizedBox(
                              width: 160,
                              height: 160,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Outer glow effect
                                  Container(
                                    width: 160,
                                    height: 160,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF1ABC9C).withOpacity(0.3),
                                          blurRadius: 20,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Background circle
                                  Container(
                                    width: 160,
                                    height: 160,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isDark 
                                          ? const Color(0xFF252839)
                                          : const Color(0xFFF0F4F8),
                                    ),
                                  ),
                                  // Progress indicator
                                  SizedBox(
                                    width: 160,
                                    height: 160,
                                    child: CircularProgressIndicator(
                                      value: stats['overallProgress'] as double,
                                      strokeWidth: 8,
                                      strokeCap: StrokeCap.round,
                                      backgroundColor: Colors.transparent,
                                      valueColor: const AlwaysStoppedAnimation(
                                        Color(0xFF1ABC9C),
                                      ),
                                    ),
                                  ),
                                  // Inner circle with percentage
                                  Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: isDark 
                                            ? [const Color(0xFF1E2235), const Color(0xFF171A26)]
                                            : [Colors.white, const Color(0xFFF8FAFE)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        ShaderMask(
                                          shaderCallback: (bounds) => const LinearGradient(
                                            colors: [Color(0xFF1ABC9C), Color(0xFF7C3BED)],
                                          ).createShader(bounds),
                                          child: Text(
                                            '${((stats['overallProgress'] as double) * 100).toInt()}%',
                                            style: const TextStyle(
                                              fontSize: 36,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isDark 
                                    ? const Color(0xFF252839)
                                    : const Color(0xFFF0F4F8),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${stats['completedGoals']} ${l10n.ofWord} ${stats['totalGoals']} ${l10n.completed.toLowerCase()}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Stats grid
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              child: _StatItem(
                                icon: LucideIcons.target,
                                iconColor: const Color(0xFF26C6DA),
                                value: '${stats['totalGoals']}',
                                label: l10n.totalGoals,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _StatCard(
                              child: _StatItem(
                                icon: LucideIcons.checkCircle2,
                                iconColor: const Color(0xFF4CAF50),
                                value: '${stats['completedGoals']}',
                                label: l10n.completed,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              child: _StatItem(
                                icon: LucideIcons.flame,
                                iconColor: const Color(0xFFFF9800),
                                value: '${stats['activeStreaks']}',
                                label: l10n.activeStreaks,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _StatCard(
                              child: _StatItem(
                                icon: LucideIcons.trendingUp,
                                iconColor: const Color(0xFF7E57C2),
                                value: '${stats['bestStreak']}',
                                label: l10n.bestStreak,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Goals by type - redesigned as cards
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark 
                                ? [const Color(0xFF1E2235), const Color(0xFF171A26)]
                                : [Colors.white, const Color(0xFFF8FAFE)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark 
                                ? const Color(0xFF2A2D3A) 
                                : Colors.grey.shade200,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF1ABC9C), Color(0xFF26C6DA)],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(LucideIcons.pieChart, color: Colors.white, size: 18),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  l10n.goalsByType,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : const Color(0xFF222639),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _GoalTypeCard(
                              icon: LucideIcons.hash,
                              label: l10n.numericGoals,
                              value: stats['numericGoals'] as int,
                              total: stats['totalGoals'] as int,
                              color: const Color(0xFF26C6DA),
                              goalsLabel: l10n.goals,
                              completionPercentage: stats['numericProgress'] as double,
                            ),
                            const SizedBox(height: 12),
                            _GoalTypeCard(
                              icon: LucideIcons.flame,
                              label: l10n.habitStreaks,
                              value: stats['habitGoals'] as int,
                              total: stats['totalGoals'] as int,
                              color: const Color(0xFFFF9800),
                              goalsLabel: l10n.goals,
                              completionPercentage: stats['habitProgress'] as double,
                            ),
                            const SizedBox(height: 12),
                            _GoalTypeCard(
                              icon: LucideIcons.flag,
                              label: l10n.milestones,
                              value: stats['milestoneGoals'] as int,
                              total: stats['totalGoals'] as int,
                              color: const Color(0xFF7E57C2),
                              goalsLabel: l10n.goals,
                              completionPercentage: stats['milestoneProgress'] as double,
                            ),
                            const SizedBox(height: 12),
                            _GoalTypeCard(
                              icon: LucideIcons.layers,
                              label: l10n.levels,
                              value: stats['levelGoals'] as int,
                              total: stats['totalGoals'] as int,
                              color: const Color(0xFF1ABC9C),
                              goalsLabel: l10n.goals,
                              completionPercentage: stats['levelProgress'] as double,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Goals by category - redesigned with colorful chips
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark 
                                ? [const Color(0xFF1E2235), const Color(0xFF171A26)]
                                : [Colors.white, const Color(0xFFF8FAFE)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark 
                                ? const Color(0xFF2A2D3A) 
                                : Colors.grey.shade200,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF7E57C2), Color(0xFFE91E63)],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(LucideIcons.tags, color: Colors.white, size: 18),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  l10n.goalsByCategory,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : const Color(0xFF222639),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: (stats['categoryCounts'] as Map<GoalCategory, int>).isEmpty
                                  ? Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Column(
                                          children: [
                                            Icon(
                                              LucideIcons.folderOpen,
                                              size: 40,
                                              color: isDark ? Colors.grey[600] : Colors.grey[400],
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              l10n.noGoals,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Wrap(
                                      spacing: 10,
                                      runSpacing: 10,
                                      children: (stats['categoryCounts'] as Map<GoalCategory, int>)
                                          .entries
                                          .map((entry) => _CategoryChip(
                                                category: entry.key,
                                                count: entry.value,
                                                name: _getCategoryName(entry.key, l10n),
                                              ))
                                          .toList(),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Center(child: Text(l10n.noDataAvailable));
          },
        ),
      ),
    );
  }

  String _getCategoryName(GoalCategory category, AppLocalizations l10n) {
    switch (category) {
      case GoalCategory.health:
        return l10n.health;
      case GoalCategory.finance:
        return l10n.finance;
      case GoalCategory.learning:
        return l10n.learning;
      case GoalCategory.career:
        return l10n.career;
      case GoalCategory.personal:
        return l10n.personal;
      case GoalCategory.fitness:
        return l10n.fitness;
      case GoalCategory.creative:
        return l10n.creative;
      case GoalCategory.social:
        return l10n.social;
    }
  }

  Map<String, dynamic> _calculateStats(List<Goal> goals) {
    final totalGoals = goals.length;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Count completed goals including habits completed today
    final completedGoals = goals.where((g) {
      if (g.type == GoalType.habit) {
        // For habits, count as completed if done today
        return (g.completedDates ?? []).any((date) =>
          date.year == today.year &&
          date.month == today.month &&
          date.day == today.day);
      }
      return g.isCompleted;
    }).length;
    
    final overallProgress = totalGoals > 0 ? completedGoals / totalGoals : 0.0;

    final numericGoals = goals.where((g) => g.type == GoalType.numeric).length;
    final habitGoals = goals.where((g) => g.type == GoalType.habit).length;
    final milestoneGoals = goals.where((g) => g.type == GoalType.milestone).length;
    final levelGoals = goals.where((g) => g.type == GoalType.levels).length;

    // Calculate average completion percentage for each type
    double _calculateTypePercentage(GoalType type) {
      final typeGoals = goals.where((g) => g.type == type).toList();
      if (typeGoals.isEmpty) return 0.0;
      
      double totalPercentage = 0.0;
      for (final goal in typeGoals) {
        switch (goal.type) {
          case GoalType.numeric:
            final current = goal.currentValue ?? 0;
            final target = goal.targetValue ?? 1;
            if (target > 0) {
              totalPercentage += ((current / target) * 100).clamp(0.0, 100.0);
            }
            break;
          case GoalType.habit:
            final completedToday = (goal.completedDates ?? []).any((date) =>
                date.year == today.year &&
                date.month == today.month &&
                date.day == today.day);
            totalPercentage += completedToday ? 100.0 : 0.0;
            break;
          case GoalType.milestone:
            final milestones = goal.milestones ?? [];
            if (milestones.isNotEmpty) {
              final completed = milestones.where((m) => m.isCompleted).length;
              totalPercentage += ((completed / milestones.length) * 100).clamp(0.0, 100.0);
            }
            break;
          case GoalType.levels:
            final levels = goal.levels ?? [];
            if (levels.isNotEmpty) {
              final currentIndex = goal.currentLevelIndex ?? 0;
              totalPercentage += ((currentIndex / levels.length) * 100).clamp(0.0, 100.0);
            }
            break;
        }
      }
      return totalPercentage / typeGoals.length;
    }

    final numericProgress = _calculateTypePercentage(GoalType.numeric);
    final habitProgress = _calculateTypePercentage(GoalType.habit);
    final milestoneProgress = _calculateTypePercentage(GoalType.milestone);
    final levelProgress = _calculateTypePercentage(GoalType.levels);

    final activeStreaks = goals.where((g) => g.type == GoalType.habit && (g.streak ?? 0) > 0).length;
    final bestStreak = goals.fold<int>(0, (max, g) => g.bestStreak != null && g.bestStreak! > max ? g.bestStreak! : max);

    final categoryCounts = <GoalCategory, int>{};
    for (final goal in goals) {
      categoryCounts[goal.category] = (categoryCounts[goal.category] ?? 0) + 1;
    }

    return {
      'totalGoals': totalGoals,
      'completedGoals': completedGoals,
      'overallProgress': overallProgress,
      'numericGoals': numericGoals,
      'habitGoals': habitGoals,
      'milestoneGoals': milestoneGoals,
      'levelGoals': levelGoals,
      'numericProgress': numericProgress,
      'habitProgress': habitProgress,
      'milestoneProgress': milestoneProgress,
      'levelProgress': levelProgress,
      'activeStreaks': activeStreaks,
      'bestStreak': bestStreak,
      'categoryCounts': categoryCounts,
    };
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF171A26) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF222639).withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Create gradient colors based on iconColor
    final gradientColors = [
      iconColor,
      Color.lerp(iconColor, const Color(0xFF7C3BED), 0.5)!,
    ];
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                iconColor.withOpacity(0.2),
                iconColor.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: iconColor.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: iconColor.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: gradientColors,
            ).createShader(bounds),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ),
        const SizedBox(height: 14),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: isDark 
                ? [Colors.white, Colors.grey.shade300]
                : [const Color(0xFF222639), const Color(0xFF4A5568)],
          ).createShader(bounds),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.label,
    required this.value,
    required this.total,
    required this.color,
    required this.goalsLabel,
  });

  final String label;
  final int value;
  final int total;
  final Color color;
  final String goalsLabel;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final percentage = total > 0 ? (value / total * 100).toInt() : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : const Color(0xFF222639),
              ),
            ),
            Text(
              '$value $goalsLabel • $percentage%',
              style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: total > 0 ? value / total : 0,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

// New widget for goal type cards
class _GoalTypeCard extends StatelessWidget {
  const _GoalTypeCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.total,
    required this.color,
    required this.goalsLabel,
    this.completionPercentage,
  });

  final IconData icon;
  final String label;
  final int value;
  final int total;
  final Color color;
  final String goalsLabel;
  final double? completionPercentage;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final percentage = total > 0 ? (value / total * 100).toInt() : 0;
    final progress = completionPercentage ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252839) : const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color,
                  Color.lerp(color, const Color(0xFF7C3BED), 0.4)!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF222639),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$value $goalsLabel',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ),
                        if (value > 0) ...[
                          const SizedBox(width: 6),
                          Text(
                            '• ${progress.toInt()}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Stack(
                  children: [
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: (progress / 100).clamp(0.0, 1.0),
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              color,
                              Color.lerp(color, Colors.white, 0.3)!,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.5),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$percentage% del total',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// New widget for category chips
class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.category,
    required this.count,
    required this.name,
  });

  final GoalCategory category;
  final int count;
  final String name;

  Color _getCategoryColor() {
    switch (category) {
      case GoalCategory.health:
        return const Color(0xFF4CAF50);
      case GoalCategory.finance:
        return const Color(0xFF2196F3);
      case GoalCategory.learning:
        return const Color(0xFFFF9800);
      case GoalCategory.career:
        return const Color(0xFF9C27B0);
      case GoalCategory.personal:
        return const Color(0xFFE91E63);
      case GoalCategory.fitness:
        return const Color(0xFFFF5722);
      case GoalCategory.creative:
        return const Color(0xFF00BCD4);
      case GoalCategory.social:
        return const Color(0xFF8BC34A);
    }
  }

  IconData _getCategoryIcon() {
    switch (category) {
      case GoalCategory.health:
        return LucideIcons.heart;
      case GoalCategory.finance:
        return LucideIcons.wallet;
      case GoalCategory.learning:
        return LucideIcons.bookOpen;
      case GoalCategory.career:
        return LucideIcons.briefcase;
      case GoalCategory.personal:
        return LucideIcons.user;
      case GoalCategory.fitness:
        return LucideIcons.dumbbell;
      case GoalCategory.creative:
        return LucideIcons.palette;
      case GoalCategory.social:
        return LucideIcons.users;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _getCategoryColor();
    final icon = _getCategoryIcon();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(isDark ? 0.25 : 0.15),
            color.withOpacity(isDark ? 0.1 : 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(
            name,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF222639),
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
