import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../domain/entities/goal.dart';
import '../../domain/entities/milestone.dart';
import '../../domain/entities/level.dart';
import '../../domain/entities/progress_entry.dart';
import '../../injection_container.dart';
import '../cubit/goal_detail_cubit.dart';

class GoalDetailScreen extends StatelessWidget {
  const GoalDetailScreen({super.key, required this.goalId});

  final String goalId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<GoalDetailCubit>()..load(goalId),
      child: BlocBuilder<GoalDetailCubit, GoalDetailState>(
        builder: (context, state) {
          if (state is GoalDetailDeleted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (Navigator.canPop(context)) {
                Navigator.pop(context, true);
              }
            });
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          if (state is GoalDetailLoading || state is GoalDetailInitial) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state is GoalDetailError) {
            return Scaffold(
              body: Center(
                child: Text(
                  state.message,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            );
          }

          final loaded = state as GoalDetailLoaded;
          return WillPopScope(
            onWillPop: () async {
              Navigator.pop(context, true);
              return false;
            },
            child: _GoalDetailView(
              goal: loaded.goal,
              entries: loaded.entries,
              isSubmitting: loaded.isSubmitting,
              onDelete: () => context.read<GoalDetailCubit>().deleteGoal(goalId),
            ),
          );
        },
      ),
    );
  }
}

class _GoalDetailView extends StatelessWidget {
  const _GoalDetailView({required this.goal, required this.entries, required this.isSubmitting, required this.onDelete});

  final Goal goal;
  final List<ProgressEntry> entries;
  final bool isSubmitting;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final percent = _progressPercent(goal);
    final accent = _colorForGoal(goal.color);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF11131D) : const Color(0xFFF0F2F7),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _Header(goal: goal, percent: percent, accent: accent, onDelete: onDelete, isSubmitting: isSubmitting, isDark: isDark),
              Transform.translate(
                offset: const Offset(0, -32),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      if (goal.type == GoalType.habit) ...[
                        _HabitCard(
                          goal: goal,
                          accent: accent,
                          isDark: isDark,
                          onComplete: () => context.read<GoalDetailCubit>().completeHabitToday(goal.id),
                        ),
                      ] else if (goal.type == GoalType.levels) ...[
                        _LevelsCard(
                          goal: goal,
                          accent: accent,
                          isDark: isDark,
                          isSubmitting: isSubmitting,
                          onAdvance: () {
                            final levels = goal.levels ?? [];
                            final currentIndex = goal.currentLevelIndex ?? 0;
                            if (currentIndex < levels.length) {
                              context.read<GoalDetailCubit>().completeLevel(
                                    goalId: goal.id,
                                    levelId: levels[currentIndex].id,
                                  );
                            }
                          },
                        ),
                      ] else if (goal.type == GoalType.milestone) ...[
                        _MilestonesCard(
                          goal: goal,
                          accent: accent,
                          isDark: isDark,
                          isSubmitting: isSubmitting,
                          onComplete: (milestoneId) =>
                              context.read<GoalDetailCubit>().completeMilestone(goalId: goal.id, milestoneId: milestoneId),
                        ),
                      ] else ...[
                        _CurrentProgressCard(
                          goal: goal,
                          percent: percent,
                          accent: accent,
                          isDark: isDark,
                          onAddProgress: () => _showAddProgressSheet(context, accent, isDark),
                        ),
                      ],
                      const SizedBox(height: 16),
                      _DetailsCard(goal: goal, accent: accent, isDark: isDark),
                      const SizedBox(height: 16),
                      _HistoryCard(goal: goal, entries: entries, accent: accent, isDark: isDark),
                      if (isSubmitting) ...[
                        const SizedBox(height: 12),
                        const LinearProgressIndicator(minHeight: 2),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _progressPercent(Goal goal) {
    if (goal.type == GoalType.habit) {
      final completedToday = (goal.completedDates ?? []).any((date) =>
          date.year == DateTime.now().year &&
          date.month == DateTime.now().month &&
          date.day == DateTime.now().day);
      return completedToday ? 100 : 0;
    }

    if (goal.type == GoalType.milestone) {
      final milestones = goal.milestones ?? [];
      if (milestones.isEmpty) return 0;
      final completed = milestones.where((m) => m.isCompleted).length;
      return ((completed / milestones.length) * 100).clamp(0, 100);
    }

    if (goal.type == GoalType.levels) {
      final levels = goal.levels ?? [];
      if (levels.isEmpty) return 0;
      final currentIndex = goal.currentLevelIndex ?? 0;
      return ((currentIndex / levels.length) * 100).clamp(0, 100);
    }

    final current = goal.currentValue ?? 0;
    final target = goal.targetValue ?? 1;
    if (target <= 0) return 0;
    return ((current / target) * 100).clamp(0, 100);
  }

  Color _colorForGoal(GoalColor color) {
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

  void _showAddProgressSheet(BuildContext context, Color accent, bool isDark) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add Progress',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x),
                    onPressed: () => Navigator.pop(ctx),
                  )
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Amount (${goal.unit ?? ''})',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.grey[400] : const Color(0xFF6B7280)),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                ],
                decoration: InputDecoration(
                  hintText: 'How many ${goal.unit ?? ''}?',
                  hintStyle: TextStyle(color: isDark ? Colors.grey[500] : null),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF374151) : const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB)),
                  ),
                ),
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
              ),
              const SizedBox(height: 12),
              Text(
                'Note (optional)',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.grey[400] : const Color(0xFF6B7280)),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: noteController,
                decoration: InputDecoration(
                  hintText: 'Add a note...',
                  hintStyle: TextStyle(color: isDark ? Colors.grey[500] : null),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF374151) : const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB)),
                  ),
                ),
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final text = amountController.text.trim();
                    if (text.isEmpty) return;
                    final amount = double.tryParse(text) ?? 0;
                    if (amount <= 0) return;

                    context.read<GoalDetailCubit>().addProgress(
                          goalId: goal.id,
                          amount: amount,
                          note: noteController.text.trim().isEmpty ? null : noteController.text.trim(),
                        );

                    Navigator.pop(ctx);
                  },
                  child: const Text(
                    'Save Progress',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.goal, required this.percent, required this.accent, required this.onDelete, required this.isSubmitting, required this.isDark});

  final Goal goal;
  final double percent;
  final Color accent;
  final VoidCallback onDelete;
  final bool isSubmitting;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final gradient = _gradientForGoal(goal.color);
    final isDark = false;

    return Container(
      constraints: const BoxConstraints(minHeight: 350),
      decoration: BoxDecoration(
        gradient: gradient,
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _RoundIconButton(
                icon: LucideIcons.arrowLeft,
                onTap: () => Navigator.pop(context),
              ),
              _RoundIconButton(
                icon: LucideIcons.trash2,
                onTap: isSubmitting
                    ? null
                    : () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete goal'),
                            content: const Text('Are you sure you want to delete this goal? This cannot be undone.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  onDelete();
                                },
                                style: TextButton.styleFrom(foregroundColor: Colors.red),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Icon(
                  goal.category.getIcon(),
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              goal.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              goal.description ?? 'Meta numérica para este año',
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: _BigProgressCircle(percent: percent, accent: accent),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  LinearGradient _gradientForGoal(GoalColor color) {
    switch (color) {
      case GoalColor.teal:
        return const LinearGradient(
          colors: [Color(0xFF16C2A3), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case GoalColor.purple:
        return const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case GoalColor.blue:
        return const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case GoalColor.orange:
        return const LinearGradient(
          colors: [Color(0xFFFFA726), Color(0xFFFF7043)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }
}

class _BigProgressCircle extends StatelessWidget {
  const _BigProgressCircle({required this.percent, required this.accent});

  final double percent;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.15),
                  blurRadius: 16,
                  spreadRadius: 3,
                ),
              ],
            ),
          ),
          // Background circle
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.12),
            ),
          ),
          // Progress arc
          SizedBox(
            width: 150,
            height: 150,
            child: CircularProgressIndicator(
              value: percent / 100,
              strokeWidth: 10,
              strokeCap: StrokeCap.round,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          // Inner circle with content
          Container(
            width: 105,
            height: 105,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${percent.toInt()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
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

class _CurrentProgressCard extends StatelessWidget {
  const _CurrentProgressCard({required this.goal, required this.percent, required this.accent, required this.isDark, required this.onAddProgress});

  final Goal goal;
  final double percent;
  final Color accent;
  final bool isDark;
  final VoidCallback onAddProgress;

  @override
  Widget build(BuildContext context) {
    final current = goal.currentValue ?? 0;
    final target = goal.targetValue ?? 0;
    final unit = goal.unit ?? '';

    return Container(
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
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accent, Color.lerp(accent, const Color(0xFF7C3BED), 0.5)!],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(LucideIcons.trendingUp, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Progress',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${(percent).toInt()}% completed',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF252839) : const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: accent.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [accent, Color.lerp(accent, const Color(0xFF7C3BED), 0.5)!],
                  ).createShader(bounds),
                  child: Text(
                    '${current.toStringAsFixed(current.truncateToDouble() == current ? 0 : 1)}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  ' / ${target.toStringAsFixed(target.truncateToDouble() == target ? 0 : 1)} $unit',
                  style: TextStyle(
                    fontSize: 18,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accent, Color.lerp(accent, const Color(0xFF7C3BED), 0.4)!],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: accent.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onAddProgress,
                borderRadius: BorderRadius.circular(14),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.plus, size: 20, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      'Add Progress',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.goal, required this.accent, required this.isDark});

  final Goal goal;
  final Color accent;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accent.withOpacity(0.2), accent.withOpacity(0.05)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: accent.withOpacity(0.3),
                  ),
                ),
                child: Icon(LucideIcons.info, color: accent, size: 20),
              ),
              const SizedBox(width: 14),
              Text(
                'Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _DetailRow(
            icon: LucideIcons.target,
            label: 'Target',
            value: '${goal.targetValue?.toStringAsFixed(goal.targetValue?.truncateToDouble() == goal.targetValue ? 0 : 1) ?? '-'} ${goal.unit ?? ''}',
            accent: accent,
            isDark: isDark,
          ),
          const SizedBox(height: 14),
          _DetailRow(
            icon: LucideIcons.bookOpen,
            label: 'Category',
            value: goal.category.name[0].toUpperCase() + goal.category.name.substring(1),
            accent: accent,
            isDark: isDark,
          ),
          const SizedBox(height: 14),
          _DetailRow(
            icon: LucideIcons.calendar,
            label: 'Created',
            value: _formatDate(goal.createdAt),
            accent: accent,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${_monthName(date.month)} ${date.day}, ${date.year}';
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.label, required this.value, required this.accent, required this.isDark});

  final IconData icon;
  final String label;
  final String value;
  final Color accent;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: accent.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: accent, size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : const Color(0xFF111827),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.goal, required this.entries, required this.accent, required this.isDark});

  final Goal goal;
  final List<ProgressEntry> entries;
  final Color accent;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progress History',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No progress yet. Start by adding your first update!',
                style: TextStyle(color: isDark ? Colors.grey[400] : const Color(0xFF6B7280), fontSize: 12),
              ),
            )
          else
            ...entries.map((entry) => _HistoryRow(
                  entry: entry,
                  unit: goal.unit ?? '',
                  accent: accent,
                  isDark: isDark,
                )),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.entry, required this.unit, required this.accent, required this.isDark});

  final ProgressEntry entry;
  final String unit;
  final Color accent;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final hasUnit = unit.trim().isNotEmpty;
    final amountLabel = '+ ${entry.value.toStringAsFixed(entry.value.truncateToDouble() == entry.value ? 0 : 1)}${hasUnit ? ' $unit' : ''}';
    final title = hasUnit
        ? amountLabel
        : (entry.note != null && entry.note!.isNotEmpty ? entry.note! : amountLabel);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(LucideIcons.trendingUp, color: accent, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF111827),
                  ),
                ),
                if (hasUnit && entry.note != null && entry.note!.isNotEmpty)
                  Text(
                    entry.note!,
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : const Color(0xFF4B5563)),
                  )
                else if (!hasUnit)
                  Text(
                    amountLabel,
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : const Color(0xFF4B5563)),
                  ),
              ],
            ),
          ),
          Text(
            _formatEntryDate(entry.createdAt),
            style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[500] : const Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  String _formatEntryDate(DateTime date) {
    return '${_monthName(date.month)} ${date.day}, ${_twoDigits(date.hour)}:${_twoDigits(date.minute)}';
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');
}

class _MilestonesCard extends StatelessWidget {
  const _MilestonesCard({
    required this.goal,
    required this.accent,
    required this.isDark,
    required this.isSubmitting,
    required this.onComplete,
  });

  final Goal goal;
  final Color accent;
  final bool isDark;
  final bool isSubmitting;
  final ValueChanged<String> onComplete;

  @override
  Widget build(BuildContext context) {
    final milestones = List<Milestone>.from(goal.milestones ?? [])
      ..sort((a, b) => a.order.compareTo(b.order));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Milestones',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          if (milestones.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No milestones added yet.',
                style: TextStyle(color: isDark ? Colors.grey[400] : const Color(0xFF6B7280), fontSize: 12),
              ),
            )
          else
            ...milestones.map(
              (m) => _MilestoneRow(
                milestone: m,
                accent: accent,
                isDark: isDark,
                isSubmitting: isSubmitting,
                onComplete: () => onComplete(m.id),
              ),
            ),
        ],
      ),
    );
  }
}

class _MilestoneRow extends StatelessWidget {
  const _MilestoneRow({
    required this.milestone,
    required this.accent,
    required this.isDark,
    required this.isSubmitting,
    required this.onComplete,
  });

  final Milestone milestone;
  final Color accent;
  final bool isDark;
  final bool isSubmitting;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final isDone = milestone.isCompleted;
    final canComplete = !isDone && !isSubmitting;

    return InkWell(
      onTap: canComplete ? onComplete : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isDone ? accent.withOpacity(0.12) : (isDark ? const Color(0xFF374151) : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDone ? accent.withOpacity(0.25) : (isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB))),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDone ? accent : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                isDone ? LucideIcons.check : LucideIcons.circle,
                color: isDone ? Colors.white : accent,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    milestone.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDone ? accent : (isDark ? Colors.white : const Color(0xFF111827)),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isDone
                        ? 'Completed ${_formatDate(milestone.completedAt ?? DateTime.now())}'
                        : 'Pending',
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : const Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),
            if (isDone)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
              )
            else
              SizedBox(
                height: 36,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: accent,
                    side: BorderSide(color: accent.withOpacity(0.4)),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: canComplete ? onComplete : null,
                  icon: const Icon(LucideIcons.check, size: 16),
                  label: const Text(
                    'Mark done',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _LevelsCard extends StatelessWidget {
  const _LevelsCard({
    required this.goal,
    required this.accent,
    required this.isDark,
    required this.isSubmitting,
    required this.onAdvance,
  });

  final Goal goal;
  final Color accent;
  final bool isDark;
  final bool isSubmitting;
  final VoidCallback onAdvance;

  @override
  Widget build(BuildContext context) {
    final levels = List<Level>.from(goal.levels ?? [])
      ..sort((a, b) => a.order.compareTo(b.order));
    final currentIndex = goal.currentLevelIndex ?? 0;
    final allDone = currentIndex >= levels.length && levels.isNotEmpty;
    final hasNext = levels.isNotEmpty && currentIndex < levels.length;

    return Container(
      width: double.infinity,
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
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accent, Color.lerp(accent, const Color(0xFF7C3BED), 0.5)!],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(LucideIcons.layers, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Level Progression',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF111827),
                      ),
                    ),
                    Text(
                      '${currentIndex} of ${levels.length} completed',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${((currentIndex / levels.length) * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (levels.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Column(
                  children: [
                    Icon(LucideIcons.layers, size: 40, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text(
                      'No levels added yet.',
                      style: TextStyle(color: isDark ? Colors.grey[400] : const Color(0xFF6B7280), fontSize: 12),
                    ),
                  ],
                ),
              ),
            )
          else
            ...levels.map(
              (level) {
                final index = levels.indexOf(level);
                final isDone = level.isCompleted;
                final isCurrent = !isDone && index == currentIndex;
                return _LevelRow(
                  level: level,
                  accent: accent,
                  isDark: isDark,
                  position: index + 1,
                  totalLevels: levels.length,
                  state: isDone
                      ? _LevelState.done
                      : (isCurrent ? _LevelState.current : _LevelState.locked),
                );
              },
            ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              gradient: hasNext 
                  ? LinearGradient(
                      colors: [accent, Color.lerp(accent, const Color(0xFF7C3BED), 0.4)!],
                    )
                  : null,
              color: hasNext ? null : (isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(14),
              boxShadow: hasNext ? [
                BoxShadow(
                  color: accent.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ] : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: hasNext && !isSubmitting ? onAdvance : null,
                borderRadius: BorderRadius.circular(14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      allDone ? LucideIcons.trophy : LucideIcons.arrowUpRight, 
                      size: 20, 
                      color: hasNext ? Colors.white : (isDark ? Colors.grey[500] : const Color(0xFF9CA3AF)),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      allDone ? 'All levels completed! 🎉' : 'Advance to Next Level',
                      style: TextStyle(
                        color: hasNext ? Colors.white : (isDark ? Colors.grey[500] : const Color(0xFF9CA3AF)),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _LevelState { done, current, locked }

class _LevelRow extends StatelessWidget {
  const _LevelRow({
    required this.level,
    required this.accent,
    required this.isDark,
    required this.position,
    required this.state,
    this.totalLevels = 1,
  });

  final Level level;
  final Color accent;
  final bool isDark;
  final int position;
  final _LevelState state;
  final int totalLevels;

  @override
  Widget build(BuildContext context) {
    final isDone = state == _LevelState.done;
    final isCurrent = state == _LevelState.current;
    final isLocked = state == _LevelState.locked;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: isCurrent 
            ? LinearGradient(
                colors: [
                  accent.withOpacity(0.15),
                  accent.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isCurrent 
            ? null 
            : (isDone 
                ? accent.withOpacity(0.08)
                : (isDark ? const Color(0xFF252839) : const Color(0xFFF5F7FA))),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent 
              ? accent.withOpacity(0.5)
              : (isDone 
                  ? accent.withOpacity(0.2) 
                  : (isDark ? const Color(0xFF3A3D4A) : const Color(0xFFE5E7EB))),
          width: isCurrent ? 2 : 1,
        ),
        boxShadow: isCurrent ? [
          BoxShadow(
            color: accent.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ] : null,
      ),
      child: Row(
        children: [
          // Position badge
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: isDone || isCurrent
                  ? LinearGradient(
                      colors: [
                        accent,
                        Color.lerp(accent, const Color(0xFF7C3BED), 0.4)!,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isDone || isCurrent ? null : (isDark ? const Color(0xFF3A3D4A) : const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(12),
              boxShadow: isDone || isCurrent ? [
                BoxShadow(
                  color: accent.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ] : null,
            ),
            child: Center(
              child: Text(
                '$position',
                style: TextStyle(
                  color: isDone || isCurrent ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[600]),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        level.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDone 
                              ? accent 
                              : (isDark ? Colors.white : const Color(0xFF111827)),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isCurrent)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [accent, Color.lerp(accent, const Color(0xFF7C3BED), 0.5)!],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Current',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      )
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isDone
                      ? 'Completed ✓'
                      : (isCurrent ? 'In progress' : 'Locked'),
                  style: TextStyle(
                    fontSize: 12, 
                    color: isDone 
                        ? accent 
                        : (isDark ? Colors.grey[400] : const Color(0xFF6B7280)),
                    fontWeight: isDone ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          // Status icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDone 
                  ? accent.withOpacity(0.15)
                  : (isCurrent 
                      ? accent.withOpacity(0.15)
                      : (isDark ? const Color(0xFF3A3D4A) : const Color(0xFFF0F0F0))),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDone 
                  ? LucideIcons.checkCircle2 
                  : (isCurrent 
                      ? LucideIcons.circleDot 
                      : LucideIcons.lock),
              color: isDone || isCurrent 
                  ? accent 
                  : (isDark ? Colors.grey[500] : const Color(0xFF9CA3AF)),
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  const _LevelBadge({required this.number, required this.accent, required this.isDark, required this.state});

  final int number;
  final Color accent;
  final bool isDark;
  final _LevelState state;

  @override
  Widget build(BuildContext context) {
    final isDone = state == _LevelState.done;
    final isCurrent = state == _LevelState.current;

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isDone
            ? accent
            : isCurrent
                ? accent.withOpacity(0.15)
                : (isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          number.toString(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isDone ? Colors.white : (isCurrent ? accent : (isDark ? Colors.grey[400] : const Color(0xFF6B7280))),
          ),
        ),
      ),
    );
  }
}

class _HabitCard extends StatelessWidget {
  const _HabitCard({required this.goal, required this.accent, required this.isDark, required this.onComplete});

  final Goal goal;
  final Color accent;
  final bool isDark;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final streak = goal.streak ?? 0;
    final best = goal.bestStreak ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.flame, color: accent, size: 18),
              const SizedBox(width: 8),
              Text(
                '$streak day streak',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Best: $best days',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: onComplete,
              icon: const Icon(LucideIcons.check, size: 18, color: Colors.white),
              label: const Text(
                'Mark Complete',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddProgressButton extends StatelessWidget {
  const _AddProgressButton({required this.goal, required this.accent});

  final Goal goal;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 4,
      ),
      onPressed: () => _showAddProgressSheet(context),
      child: const Text(
        'Add Progress',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
      ),
    );
  }

  void _showAddProgressSheet(BuildContext context) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add Progress',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x),
                    onPressed: () => Navigator.pop(ctx),
                  )
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Amount (${goal.unit ?? ''})',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.grey[400] : const Color(0xFF6B7280)),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                ],
                decoration: InputDecoration(
                  hintText: 'How many ${goal.unit ?? ''}?',
                  hintStyle: TextStyle(color: isDark ? Colors.grey[500] : null),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF374151) : const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB)),
                  ),
                ),
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
              ),
              const SizedBox(height: 12),
              Text(
                'Note (optional)',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.grey[400] : const Color(0xFF6B7280)),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: noteController,
                decoration: InputDecoration(
                  hintText: 'Add a note...',
                  hintStyle: TextStyle(color: isDark ? Colors.grey[500] : null),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF374151) : const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB)),
                  ),
                ),
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final text = amountController.text.trim();
                    if (text.isEmpty) return;
                    final amount = double.tryParse(text) ?? 0;
                    if (amount <= 0) return;

                    context.read<GoalDetailCubit>().addProgress(
                          goalId: goal.id,
                          amount: amount,
                          note: noteController.text.trim().isEmpty ? null : noteController.text.trim(),
                        );

                    Navigator.pop(ctx);
                  },
                  child: const Text(
                    'Save Progress',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.25),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
