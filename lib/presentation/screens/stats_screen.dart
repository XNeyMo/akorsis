import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../bloc/goal_bloc.dart';
import '../bloc/goal_state.dart';
import '../../domain/entities/goal.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                        'Statistics',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF222639),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your progress overview',
                        style: TextStyle(
                          fontSize: 17,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Overall progress card
                      _StatCard(
                        child: Column(
                          children: [
                            Text(
                              'OVERALL PROGRESS',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF8a94a8),
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 150,
                              child: Stack(
                                children: [
                                  CircularProgressIndicator(
                                    value: stats['overallProgress'] as double,
                                    strokeWidth: 12,
                                    backgroundColor: const Color(0xFFE0F7FA),
                                    valueColor: const AlwaysStoppedAnimation(Color(0xFF26C6DA)),
                                  ),
                                  Center(
                                    child: Builder(
                                      builder: (context) {
                                        final isDark = Theme.of(context).brightness == Brightness.dark;
                                        return Text(
                                          '${((stats['overallProgress'] as double) * 100).toInt()}%',
                                          style: TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            color: isDark ? Colors.white : const Color(0xFF222639),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              '${stats['completedGoals']} of ${stats['totalGoals']} goals completed',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
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
                                label: 'Total Goals',
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
                                label: 'Completed',
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
                                label: 'Active Streaks',
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
                                label: 'Best Streak',
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Goals by type
                      _StatCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Goals by Type',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF222639),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _ProgressBar(
                              label: 'Numeric Goals',
                              value: stats['numericGoals'] as int,
                              total: stats['totalGoals'] as int,
                              color: const Color(0xFF26C6DA),
                            ),
                            const SizedBox(height: 12),
                            _ProgressBar(
                              label: 'Habit Streaks',
                              value: stats['habitGoals'] as int,
                              total: stats['totalGoals'] as int,
                              color: const Color(0xFFFF9800),
                            ),
                            const SizedBox(height: 12),
                            _ProgressBar(
                              label: 'Milestones',
                              value: stats['milestoneGoals'] as int,
                              total: stats['totalGoals'] as int,
                              color: const Color(0xFF7E57C2),
                            ),
                            const SizedBox(height: 12),
                            _ProgressBar(
                              label: 'Levels',
                              value: stats['levelGoals'] as int,
                              total: stats['totalGoals'] as int,
                              color: const Color(0xFF1ABC9C),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Goals by category
                      _StatCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Goals by Category',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF222639),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: (stats['categoryCounts'] as Map<GoalCategory, int>).isEmpty
                                  ? Center(
                                      child: Text(
                                        'No goals yet',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                                        ),
                                      ),
                                    )
                                  : Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: (stats['categoryCounts'] as Map<GoalCategory, int>)
                                          .entries
                                          .map((entry) => Chip(
                                                label: Text(
                                                  '${entry.key.name}: ${entry.value}',
                                                  style: const TextStyle(fontSize: 12),
                                                ),
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

            return const Center(child: Text('No data available'));
          },
        ),
      ),
    );
  }

  Map<String, dynamic> _calculateStats(List<Goal> goals) {
    final totalGoals = goals.length;
    final completedGoals = goals.where((g) => g.isCompleted).length;
    final overallProgress = totalGoals > 0 ? completedGoals / totalGoals : 0.0;

    final numericGoals = goals.where((g) => g.type == GoalType.numeric).length;
    final habitGoals = goals.where((g) => g.type == GoalType.habit).length;
    final milestoneGoals = goals.where((g) => g.type == GoalType.milestone).length;
    final levelGoals = goals.where((g) => g.type == GoalType.levels).length;

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
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 28),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF222639),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
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
  });

  final String label;
  final int value;
  final int total;
  final Color color;

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
              '$value goals • $percentage%',
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
