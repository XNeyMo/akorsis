import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../bloc/goal_bloc.dart';
import '../bloc/goal_event.dart';
import '../bloc/goal_state.dart';
import '../../domain/entities/goal.dart';
import '../widgets/goal_card.dart';
import '../widgets/stats_summary.dart';
import 'create_goal_screen.dart';
import '../../core/l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoalType? _selectedFilter;

  @override
  void initState() {
    super.initState();
    context.read<GoalBloc>().add(const LoadGoals());
  }

  List<Goal> _filterGoals(List<Goal> goals) {
    if (_selectedFilter == null) return goals;
    return goals.where((goal) => goal.type == _selectedFilter).toList();
  }

  String _getGreeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.goodMorning;
    if (hour < 18) return l10n.goodAfternoon;
    return l10n.goodEvening;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF11131D) : const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1ABC9C), Color(0xFF7C3BED)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1ABC9C).withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getGreeting(l10n),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                ShaderMask(
                                  shaderCallback: (bounds) => const LinearGradient(
                                    colors: [Colors.white, Color(0xFFE0E0E0)],
                                  ).createShader(bounds),
                                  child: const Text(
                                    'AKORSIS',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.25),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'PRO',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.3),
                                Colors.white.withOpacity(0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            LucideIcons.sparkles,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const StatsSummary(),
                  ],
                ),
              ),
            ),

            // Filter tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(
                      label: l10n.allGoals,
                      icon: LucideIcons.layoutGrid,
                      isSelected: _selectedFilter == null,
                      onTap: () => setState(() => _selectedFilter = null),
                    ),
                    _FilterChip(
                      label: l10n.numeric,
                      icon: LucideIcons.hash,
                      isSelected: _selectedFilter == GoalType.numeric,
                      onTap: () => setState(() => _selectedFilter = GoalType.numeric),
                    ),
                    _FilterChip(
                      label: l10n.habits,
                      icon: LucideIcons.flame,
                      isSelected: _selectedFilter == GoalType.habit,
                      onTap: () => setState(() => _selectedFilter = GoalType.habit),
                    ),
                    _FilterChip(
                      label: l10n.milestones,
                      icon: LucideIcons.flag,
                      isSelected: _selectedFilter == GoalType.milestone,
                      onTap: () => setState(() => _selectedFilter = GoalType.milestone),
                    ),
                    _FilterChip(
                      label: l10n.levels,
                      icon: LucideIcons.layers,
                      isSelected: _selectedFilter == GoalType.levels,
                      onTap: () => setState(() => _selectedFilter = GoalType.levels),
                    ),
                  ],
                ),
              ),
            ),

            // Goals list
            Expanded(
              child: BlocBuilder<GoalBloc, GoalState>(
                builder: (context, state) {
                  if (state is GoalLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is GoalError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (state is GoalsLoaded) {
                    final filteredGoals = _filterGoals(state.goals);

                    if (filteredGoals.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF1ABC9C).withOpacity(0.15),
                                    const Color(0xFF7C3BED).withOpacity(0.1),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF1ABC9C).withOpacity(0.3),
                                ),
                              ),
                              child: Icon(
                                LucideIcons.target,
                                size: 48,
                                color: isDark ? const Color(0xFF1ABC9C) : const Color(0xFF1ABC9C),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              l10n.noGoals,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.createFirstGoal,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF1ABC9C), Color(0xFF7C3BED)],
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF1ABC9C).withOpacity(0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(LucideIcons.plus, color: Colors.white, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    l10n.createGoal,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<GoalBloc>().add(const LoadGoals());
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredGoals.length,
                        itemBuilder: (context, index) {
                          return GoalCard(goal: filteredGoals[index]);
                        },
                      ),
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1ABC9C).withOpacity(0.5),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: const Color(0xFF7C3BED).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateGoalScreen()),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(
                colors: [Color(0xFF1ABC9C), Color(0xFF7C3BED)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(
              LucideIcons.plus,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF1ABC9C), Color(0xFF26C6DA)],
                )
              : null,
          color: isSelected
              ? null
              : (isDark ? const Color(0xFF1E2235) : Colors.white),
          borderRadius: BorderRadius.circular(14),
          border: isSelected
              ? null
              : Border.all(
                  color: isDark 
                      ? const Color(0xFF2A2D3A) 
                      : Colors.grey.shade200,
                ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF1ABC9C).withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: const Color(0xFF222639).withOpacity(isDark ? 0.2 : 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : const Color(0xFF6C7993)),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
