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
          final completedGoals = state.goals.where((g) => g.isCompleted).length;
          final progress = totalGoals > 0 ? (completedGoals / totalGoals * 100).toInt() : 0;
          final activeStreaks = state.goals.where((g) => g.type == GoalType.habit && (g.streak ?? 0) > 0).length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                totalGoals > 0
                    ? 'Keep doing your best!'
                    : 'Ready to start your journey?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: LucideIcons.goal,
                      value: '$totalGoals',
                      label: 'Goals',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: LucideIcons.trendingUp,
                      value: '$progress%',
                      label: 'Progress',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: LucideIcons.flame,
                      value: '$activeStreaks',
                      label: 'Streaks',
                    ),
                  ),
                ],
              ),
            ],
          );
        }

        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      },
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(12),
      ),
      child: _StatItem(
        icon: icon,
        value: value,
        label: label,
      ),
    );
  }
}
