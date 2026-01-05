import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../bloc/goal_bloc.dart';
import '../bloc/goal_event.dart';
import '../bloc/goal_state.dart';
import '../cubit/theme_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BlocListener<GoalBloc, GoalState>(
      listener: (context, state) async {
        if (state is GoalExported) {
          await _saveExportFile(context, state.jsonData);
        } else if (state is GoalsLoaded && state.goals.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('All data cleared')),
          );
        } else if (state is GoalError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF11131D) : const Color(0xFFF5F7FA),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF222639),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Customize your experience',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Appearance section
                  _SectionHeader(title: 'APPEARANCE'),
                  BlocBuilder<ThemeCubit, ThemeMode>(
                    builder: (context, themeMode) {
                      final isDarkMode = themeMode == ThemeMode.dark;
                      return _SettingsCard(
                        child: _SettingsTile(
                          icon: isDarkMode ? LucideIcons.moon : LucideIcons.sun,
                          iconColor: isDarkMode ? const Color(0xFF7E57C2) : const Color(0xFFFF9800),
                          title: 'Dark Mode',
                          subtitle: isDarkMode ? 'Currently using dark theme' : 'Currently using light theme',
                          trailing: Switch(
                            value: isDarkMode,
                            onChanged: (value) {
                              context.read<ThemeCubit>().toggleTheme();
                            },
                            activeColor: const Color(0xFF1ABC9C),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // Data section
                  _SectionHeader(title: 'DATA'),
                  _SettingsCard(
                    child: Column(
                      children: [
                        _SettingsTile(
                          icon: LucideIcons.arrowBigDownDash,
                          iconColor: const Color(0xFF26C6DA),
                          title: 'Export Data',
                          subtitle: 'Download all your goals',
                          onTap: () => _exportData(context),
                        ),
                        const Divider(height: 1),
                        _SettingsTile(
                          icon: LucideIcons.arrowBigUpDash,
                          iconColor: const Color(0xFF7E57C2),
                          title: 'Import Data',
                          subtitle: 'Import goals',
                          onTap: () => _importData(context),
                        ),
                        const Divider(height: 1),
                        _SettingsTile(
                          icon: LucideIcons.trash,
                          iconColor: Colors.red,
                          title: 'Clear All Data',
                          subtitle: 'Delete all goals and progress',
                          onTap: () => _confirmClearData(context),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                    // About section
                    _SectionHeader(title: 'ABOUT'),
                    _SettingsCard(
                      child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF26C6DA), Color(0xFF7E57C2)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text(
                                'A',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AKORSIS',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xFF222639),
                                ),
                              ),
                              Text(
                                'Version 1.0.0',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Your personal growth companion. Track goals, build habits, and achieve milestones with a beautiful, motivating experience.',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Made with ❤️ by ZENOEX',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Your journey stats
                _SectionHeader(title: 'JOURNEY'),
                BlocBuilder<GoalBloc, GoalState>(
                  builder: (context, state) {
                    if (state is GoalsLoaded) {
                      final totalGoals = state.goals.length;
                      final completedGoals = state.goals.where((g) => g.isCompleted).length;
                      final bestStreak = state.goals.fold<int>(
                        0,
                        (max, g) => g.bestStreak != null && g.bestStreak! > max ? g.bestStreak! : max,
                      );

                      return _SettingsCard(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _JourneyStat(
                                  value: '$totalGoals',
                                  label: 'Goals Created',
                                ),
                                _JourneyStat(
                                  value: '$completedGoals',
                                  label: 'Completed',
                                ),
                                _JourneyStat(
                                  value: '$bestStreak',
                                  label: 'Best Streaks',
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }

  void _exportData(BuildContext context) {
    context.read<GoalBloc>().add(const ExportGoalsEvent());
  }

  Future<void> _saveExportFile(BuildContext context, String jsonData) async {
    final directoryPath = await FilePicker.platform.getDirectoryPath();
    if (directoryPath == null) return;

    final timestamp = DateTime.now();
    final fileName = 'akorsis_backup_${timestamp.year}${timestamp.month.toString().padLeft(2, '0')}${timestamp.day.toString().padLeft(2, '0')}_${timestamp.hour.toString().padLeft(2, '0')}${timestamp.minute.toString().padLeft(2, '0')}${timestamp.second.toString().padLeft(2, '0')}.json';
    final filePath = '$directoryPath${Platform.pathSeparator}$fileName';

    final file = File(filePath);
    await file.writeAsString(jsonData);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Backup saved to $filePath')),
      );
    }
  }

  Future<void> _importData(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final jsonData = await file.readAsString();

      if (!context.mounted) return;

      final bloc = context.read<GoalBloc>();
      bloc.add(ImportGoalsEvent(jsonData));

      final importResult = await bloc.stream.firstWhere(
        (state) => state is GoalError || state is GoalsLoaded,
      );

      if (!context.mounted) return;

      if (importResult is GoalError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: ${importResult.message}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data imported successfully')),
        );
      }
    }
  }

  void _confirmClearData(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'Are you sure you want to delete all your goals and progress? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<GoalBloc>().add(const ClearAllDataEvent());
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.grey[500] : Colors.grey[600],
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF222639) : Colors.white,
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

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF222639),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class _JourneyStat extends StatelessWidget {
  const _JourneyStat({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
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