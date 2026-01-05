import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/goal_bloc.dart';
import '../bloc/goal_event.dart';
import '../screens/goal_detail_screen.dart';
import '../../domain/entities/goal.dart';

class GoalCard extends StatelessWidget {
  const GoalCard({super.key, required this.goal});

  final Goal goal;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final percentage = _calculatePercentage();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF171A26) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          top: BorderSide(
            color: _getColorForGoalColor(goal.color),
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final updated = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GoalDetailScreen(goalId: goal.id),
              ),
            );

            if (updated == true && context.mounted) {
              context.read<GoalBloc>().add(const LoadGoals());
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getColorForGoalColor(goal.color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        goal.category.getIcon(),
                        color: _getColorForGoalColor(goal.color),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Builder(
                            builder: (context) {
                              final isDark = Theme.of(context).brightness == Brightness.dark;
                              return Text(
                                goal.title,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xFF222639),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 4),
                          _buildSubtitle(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildPercentageCircle(percentage, isDark),
                  ],
                ),
                const SizedBox(height: 16),
                _buildProgressBar(percentage),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        String subtitle = '';
        
        switch (goal.type) {
          case GoalType.numeric:
            final current = goal.currentValue ?? 0;
            final target = goal.targetValue ?? 1;
            subtitle = '${current.toStringAsFixed(current.truncateToDouble() == current ? 0 : 1)} / ${target.toStringAsFixed(target.truncateToDouble() == target ? 0 : 1)} ${goal.unit ?? ''}';
            break;
          case GoalType.habit:
            final streak = goal.streak ?? 0;
            subtitle = '$streak day streak';
            break;
          case GoalType.milestone:
            final milestones = goal.milestones ?? [];
            final completed = milestones.where((m) => m.isCompleted).length;
            subtitle = '$completed of ${milestones.length} milestones';
            break;
          case GoalType.levels:
            final levels = goal.levels ?? [];
            final currentIndex = goal.currentLevelIndex ?? 0;
            subtitle = currentIndex < levels.length ? 'Level: ${levels[currentIndex].title}' : 'Completed';
            break;
        }
        
        return Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        );
      },
    );
  }

  Widget _buildPercentageCircle(double percentage, bool isDark) {
    return Container(
      width: 60,
      height: 60,
      child: Stack(
        children: [
          Center(
            child: SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                value: percentage / 100,
                strokeWidth: 4,
                backgroundColor: _getColorForGoalColor(goal.color).withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation(_getColorForGoalColor(goal.color)),
              ),
            ),
          ),
          Center(
            child: Text(
              '${percentage.toInt()}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF222639),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double percentage) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: (percentage / 100).clamp(0.0, 1.0),
        backgroundColor: _getColorForGoalColor(goal.color).withOpacity(0.1),
        valueColor: AlwaysStoppedAnimation(_getColorForGoalColor(goal.color)),
        minHeight: 6,
      ),
    );
  }

  double _calculatePercentage() {
    switch (goal.type) {
      case GoalType.numeric:
        final current = goal.currentValue ?? 0;
        final target = goal.targetValue ?? 1;
        if (target == 0) return 0;
        return ((current / target) * 100).clamp(0.0, 100.0);
        
      case GoalType.habit:
        // 100% if completed today, 0% otherwise
        final completedToday = (goal.completedDates ?? []).any((date) =>
            date.year == DateTime.now().year &&
            date.month == DateTime.now().month &&
            date.day == DateTime.now().day);
        return completedToday ? 100.0 : 0.0;
        
      case GoalType.milestone:
        final milestones = goal.milestones ?? [];
        if (milestones.isEmpty) return 0;
        final completed = milestones.where((m) => m.isCompleted).length;
        return ((completed / milestones.length) * 100).clamp(0.0, 100.0);
        
      case GoalType.levels:
        final levels = goal.levels ?? [];
        if (levels.isEmpty) return 0;
        final currentIndex = goal.currentLevelIndex ?? 0;
        return ((currentIndex / levels.length) * 100).clamp(0.0, 100.0);
    }
  }

  Color _getColorForGoalColor(GoalColor color) {
    switch (color) {
      case GoalColor.teal:
        return const Color(0xFF1ABC9C);
      case GoalColor.purple:
        return const Color(0xFF7C3BED);
      case GoalColor.blue:
        return const Color(0xFF3B82F6);
      case GoalColor.orange:
        return const Color(0xFFFF9800);
    }
  }
}
