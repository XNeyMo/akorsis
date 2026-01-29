import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../domain/entities/goal.dart';
import '../bloc/goal_bloc.dart';
import '../bloc/goal_state.dart';

class StatsSummary extends StatelessWidget {
  const StatsSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GoalBloc, GoalState>(
      builder: (context, state) {
        if (state is GoalsLoaded) {
          final totalGoals = state.goals.length;
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          
          // Count completed goals including habits completed today
          final completedGoals = state.goals.where((g) {
            if (g.type == GoalType.habit) {
              // For habits, count as completed if done today
              return (g.completedDates ?? []).any((date) =>
                date.year == today.year &&
                date.month == today.month &&
                date.day == today.day);
            }
            return g.isCompleted;
          }).length;
          
          final progress = totalGoals > 0 ? (completedGoals / totalGoals * 100).toInt() : 0;
          final activeStreaks = state.goals.where((g) => g.type == GoalType.habit && (g.streak ?? 0) > 0).length;

          return Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  icon: LucideIcons.goal,
                  value: '$totalGoals',
                  label: 'Goals',
                ),
                _VerticalDivider(),
                _StatItem(
                  icon: LucideIcons.trendingUp,
                  value: '$progress%',
                  label: 'Progress',
                ),
                _VerticalDivider(),
                _StatItem(
                  icon: LucideIcons.flame,
                  value: '$activeStreaks',
                  label: 'Streaks',
                ),
              ],
            ),
          );
        }

        return const Center(
          child: SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
          ),
        );
      },
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      width: 1,
      color: Colors.white.withOpacity(0.2),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white.withOpacity(0.9), size: 16),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
