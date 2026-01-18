import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../bloc/goal_bloc.dart';
import '../bloc/goal_event.dart';
import '../bloc/goal_state.dart';
import '../cubit/theme_cubit.dart';
import '../cubit/locale_cubit.dart';
import '../../core/l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    
    return BlocListener<GoalBloc, GoalState>(
      listener: (context, state) async {
        if (state is GoalExported) {
          await _saveExportFile(context, state.jsonData);
        } else if (state is GoalsLoaded && state.goals.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.allDataCleared)),
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
                    l10n.settings,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF222639),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.customizeExperience,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Appearance section
                  _SectionHeader(
                    title: l10n.appearance,
                    icon: LucideIcons.palette,
                    gradientColors: const [Color(0xFF7E57C2), Color(0xFFE91E63)],
                  ),
                  BlocBuilder<ThemeCubit, ThemeMode>(
                    builder: (context, themeMode) {
                      final isDarkMode = themeMode == ThemeMode.dark;
                      return _SettingsCard(
                        child: _SettingsTile(
                          icon: isDarkMode ? LucideIcons.moon : LucideIcons.sun,
                          iconColor: isDarkMode ? const Color(0xFF7E57C2) : const Color(0xFFFF9800),
                          title: l10n.darkMode,
                          subtitle: isDarkMode ? l10n.darkThemeActive : l10n.lightThemeActive,
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

                  // Language section
                  _SectionHeader(
                    title: l10n.language,
                    icon: LucideIcons.globe,
                    gradientColors: const [Color(0xFF42A5F5), Color(0xFF26C6DA)],
                  ),
                  BlocBuilder<LocaleCubit, Locale>(
                    builder: (context, locale) {
                      final localeCubit = context.read<LocaleCubit>();
                      return _SettingsCard(
                        child: _SettingsTile(
                          icon: LucideIcons.globe,
                          iconColor: const Color(0xFF42A5F5),
                          title: l10n.changeLanguage,
                          subtitle: '${l10n.currentLanguage}: ${localeCubit.currentLanguageName}',
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1ABC9C).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF1ABC9C).withOpacity(0.3),
                              ),
                            ),
                            child: DropdownButton<String>(
                              value: locale.languageCode,
                              underline: const SizedBox(),
                              isDense: true,
                              icon: Icon(
                                LucideIcons.chevronDown,
                                size: 16,
                                color: isDark ? Colors.white : const Color(0xFF222639),
                              ),
                              dropdownColor: isDark ? const Color(0xFF222639) : Colors.white,
                              items: [
                                DropdownMenuItem(
                                  value: 'es',
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text('🇪🇸', style: TextStyle(fontSize: 16)),
                                      const SizedBox(width: 8),
                                      Text(
                                        l10n.spanish,
                                        style: TextStyle(
                                          color: isDark ? Colors.white : const Color(0xFF222639),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'en',
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text('🇺🇸', style: TextStyle(fontSize: 16)),
                                      const SizedBox(width: 8),
                                      Text(
                                        l10n.english,
                                        style: TextStyle(
                                          color: isDark ? Colors.white : const Color(0xFF222639),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  localeCubit.setLocale(Locale(value));
                                }
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // Data section
                  _SectionHeader(
                    title: l10n.data,
                    icon: LucideIcons.database,
                    gradientColors: const [Color(0xFF26C6DA), Color(0xFF1ABC9C)],
                  ),
                  _SettingsCard(
                    child: Column(
                      children: [
                        _SettingsTile(
                          icon: LucideIcons.arrowBigDownDash,
                          iconColor: const Color(0xFF26C6DA),
                          title: l10n.exportData,
                          subtitle: l10n.downloadGoals,
                          onTap: () => _exportData(context),
                        ),
                        const Divider(height: 1),
                        _SettingsTile(
                          icon: LucideIcons.arrowBigUpDash,
                          iconColor: const Color(0xFF7E57C2),
                          title: l10n.importData,
                          subtitle: l10n.importGoals,
                          onTap: () => _importData(context),
                        ),
                        const Divider(height: 1),
                        _SettingsTile(
                          icon: LucideIcons.trash,
                          iconColor: Colors.red,
                          title: l10n.clearAllData,
                          subtitle: l10n.deleteGoalsProgress,
                          onTap: () => _confirmClearData(context),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                    // About section
                    _SectionHeader(
                      title: l10n.about,
                      icon: LucideIcons.info,
                      gradientColors: const [Color(0xFFFF9800), Color(0xFFFF5722)],
                    ),
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
                                '${l10n.version} 1.0.0',
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
                        l10n.appDescription,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.madeWithLove,
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
                _SectionHeader(
                  title: l10n.journey,
                  icon: LucideIcons.rocket,
                  gradientColors: const [Color(0xFF1ABC9C), Color(0xFF7E57C2)],
                ),
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
                        child: Row(
                          children: [
                            Expanded(
                              child: _JourneyStat(
                                value: '$totalGoals',
                                label: l10n.goalsCreated,
                                icon: LucideIcons.target,
                                color: const Color(0xFF26C6DA),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _JourneyStat(
                                value: '$completedGoals',
                                label: l10n.completed,
                                icon: LucideIcons.checkCircle,
                                color: const Color(0xFF4CAF50),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _JourneyStat(
                                value: '$bestStreak',
                                label: l10n.bestStreaks,
                                icon: LucideIcons.flame,
                                color: const Color(0xFFFF9800),
                              ),
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
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.backupSaved} $filePath')),
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
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.importFailed}: ${importResult.message}')),
        );
      } else {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.dataImported)),
        );
      }
    }
  }

  void _confirmClearData(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.clearDataTitle),
        content: Text(l10n.clearDataMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<GoalBloc>().add(const ClearAllDataEvent());
              Navigator.pop(dialogContext);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.icon, this.gradientColors});

  final String title;
  final IconData? icon;
  final List<Color>? gradientColors;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = gradientColors ?? [const Color(0xFF1ABC9C), const Color(0xFF26C6DA)];
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: colors),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: colors.first.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 12),
          ],
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
              letterSpacing: 0.5,
            ),
          ),
        ],
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
            color: isDark 
                ? Colors.black.withOpacity(0.3)
                : const Color(0xFF222639).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
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
    
    // Create gradient colors based on iconColor
    final gradientColors = [
      iconColor,
      Color.lerp(iconColor, const Color(0xFF7C3BED), 0.4)!,
    ];
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    iconColor.withOpacity(0.2),
                    iconColor.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: iconColor.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: gradientColors,
                ).createShader(bounds),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
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
    this.icon,
    this.color,
  });

  final String value;
  final String label;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statColor = color ?? const Color(0xFF1ABC9C);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252839) : const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: statColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    statColor.withOpacity(0.2),
                    statColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: statColor, size: 20),
            ),
            const SizedBox(height: 10),
          ],
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                statColor,
                Color.lerp(statColor, const Color(0xFF7C3BED), 0.5)!,
              ],
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
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}