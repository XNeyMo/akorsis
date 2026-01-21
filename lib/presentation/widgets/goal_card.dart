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
    final goalColor = _getColorForGoalColor(goal.color);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark 
              ? [const Color(0xFF1A1D2E), const Color(0xFF15171F)]
              : [Colors.white, const Color(0xFFFCFDFE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark 
              ? const Color(0xFF252839)
              : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
          borderRadius: BorderRadius.circular(18),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border(
                left: BorderSide(
                  color: goalColor.withOpacity(isDark ? 0.8 : 0.6),
                  width: 3,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Icon container with goal color
                      Container(
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(
                          color: goalColor.withOpacity(isDark ? 0.18 : 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          goal.category.getIcon(),
                          color: goalColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              goal.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : const Color(0xFF222639),
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 3),
                            _buildSubtitle(isDark, goalColor),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      _buildPercentageCircle(percentage, isDark, goalColor),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildProgressBar(percentage, isDark, goalColor),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubtitle(bool isDark, Color goalColor) {
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
        color: isDark ? Colors.grey[400] : Colors.grey[500],
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildPercentageCircle(double percentage, bool isDark, Color goalColor) {
    return Container(
      width: 50,
      height: 50,
      child: Stack(
        children: [
          Center(
            child: SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                value: percentage / 100,
                strokeWidth: 3,
                strokeCap: StrokeCap.round,
                backgroundColor: isDark 
                    ? goalColor.withOpacity(0.15) 
                    : goalColor.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation(goalColor),
              ),
            ),
          ),
          Center(
            child: Text(
              '${percentage.toInt()}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: goalColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double percentage, bool isDark, Color goalColor) {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: goalColor.withOpacity(isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: (percentage / 100).clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: goalColor.withOpacity(isDark ? 0.85 : 0.75),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
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
        return const Color(0xFF8B5CF6);
      case GoalColor.blue:
        return const Color(0xFF3B82F6);
      case GoalColor.orange:
        return const Color(0xFFF59E0B);
    }
  }
}
