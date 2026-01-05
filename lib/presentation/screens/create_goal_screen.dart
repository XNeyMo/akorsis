import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/goal.dart';
import '../../domain/entities/milestone.dart';
import '../../domain/entities/level.dart';
import '../bloc/goal_bloc.dart';
import '../bloc/goal_event.dart';
import '../bloc/goal_state.dart';

class CreateGoalScreen extends StatefulWidget {
  const CreateGoalScreen({super.key});

  @override
  State<CreateGoalScreen> createState() => _CreateGoalScreenState();
}

class _CreateGoalScreenState extends State<CreateGoalScreen> {
  int _currentStep = 1;
  GoalType? _selectedGoalType = GoalType.numeric;
  GoalCategory? _selectedCategory = GoalCategory.personal;
  String _goalTitle = '';
  String _goalDescription = '';
  Color _selectedColor = const Color(0xFF1ABC9C);
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  // Step 3 - Numeric Goal
  final TextEditingController _targetValueController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  
  // Step 3 - Habit Goal
  String _frequency = 'daily'; // 'daily' or 'weekly'
  
  // Step 3 - Milestone Goal
  List<String> _milestones = [];
  final TextEditingController _milestoneController = TextEditingController();
  
  // Step 3 - Levels Goal
  String? _selectedLevelPreset;
  List<String> _customLevels = [];
  final TextEditingController _levelController = TextEditingController();
  
  final List<Color> _availableColors = [
    const Color(0xFF1ABC9C), // Teal
    const Color(0xFF7C3BED), // Purple
    const Color(0xFF3B82F6), // Blue
    const Color(0xFFFF9800), // Orange
  ];

  final List<GoalCategory> _categories = GoalCategory.values;
  
  final Map<String, Map<String, String>> _levelPresets = {
    'Language (CEFR)': {
      'description': 'A1 → A2 → B1 → B2 → C1 → C2',
      'example': 'A1, A2, B1, B2, C1, C2'
    },
    'Developer': {
      'description': 'Junior → Semi-Mid → Mid → Senior',
      'example': 'Junior, Semi-Mid, Mid, Senior'
    },
    'Skill': {
      'description': 'Beginner → Elementary → Intermediate → Advanced → Proficient',
      'example': 'Beginner, Elementary, Intermediate, Advanced'
    },
    'Mastery': {
      'description': 'Novice → Apprentice → Practitioner → Expert → Master',
      'example': 'Novice, Apprentice, Practitioner, Expert, Master'
    },
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return BlocListener<GoalBloc, GoalState>(
      listener: (context, state) {
        if (state is GoalError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF11131D) : const Color(0xFFF5F7FA),
        appBar: AppBar(
          backgroundColor: isDark ? const Color(0xFF171A26) : Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              LucideIcons.arrowLeft,
              color: isDark ? Colors.white : const Color(0xFF222639),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'New Goal',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF222639),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Step $_currentStep of 3',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              if (_currentStep == 1)
                _buildStep1(isDark)
              else if (_currentStep == 2)
                _buildStep2(isDark)
              else if (_currentStep == 3)
                _buildStep3(isDark),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildStep1(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What type of goal?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF222639),
          ),
        ),
        const SizedBox(height: 24),
        _buildGoalTypeCard(
          type: GoalType.numeric,
          icon: LucideIcons.trendingUp,
          title: 'Numeric Goal',
          description: 'Track progress towards a number',
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildGoalTypeCard(
          type: GoalType.habit,
          icon: LucideIcons.flame,
          title: 'Daily Habit',
          description: 'Build streaks with daily actions',
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildGoalTypeCard(
          type: GoalType.milestone,
          icon: LucideIcons.flag,
          title: 'Milestone',
          description: 'Complete phases step by step',
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildGoalTypeCard(
          type: GoalType.levels,
          icon: LucideIcons.layers,
          title: 'Levels',
          description: 'Progress through skill levels',
          isDark: isDark,
        ),
        const SizedBox(height: 40),
        _buildContinueButton(isDark, onPressed: () {
          if (_selectedGoalType != null) {
            setState(() => _currentStep = 2);
          }
        }),
      ],
    );
  }

  Widget _buildStep2(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Goal Title
        Text(
          'Goal Title',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF222639),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _titleController,
          onChanged: (value) => _goalTitle = value,
          decoration: InputDecoration(
            hintText: 'e.g., Read 12 books this year',
            hintStyle: TextStyle(
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            filled: true,
            fillColor: isDark ? const Color(0xFF171A26) : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              ),
            ),
          ),
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF222639),
          ),
        ),
        const SizedBox(height: 24),
        
        // Description
        Text(
          'Description (optional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF222639),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _descriptionController,
          onChanged: (value) => _goalDescription = value,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Why is this goal important to you?',
            hintStyle: TextStyle(
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            filled: true,
            fillColor: isDark ? const Color(0xFF171A26) : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              ),
            ),
          ),
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF222639),
          ),
        ),
        const SizedBox(height: 24),
        
        // Category
        Text(
          'Category',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF222639),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _categories.map((category) {
            final isSelected = _selectedCategory == category;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = category),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF1ABC9C).withOpacity(0.1)
                      : (isDark ? const Color(0xFF171A26) : Colors.white),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF1ABC9C)
                        : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(
                  category.name[0].toUpperCase() + category.name.substring(1),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? const Color(0xFF1ABC9C)
                        : (isDark ? Colors.grey[300] : const Color(0xFF222639)),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        
        // Color Theme
        Text(
          'Color Theme',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF222639),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: _availableColors.map((color) {
            final isSelected = _selectedColor == color;
            return GestureDetector(
              onTap: () => setState(() => _selectedColor = color),
              child: Container(
                width: 60,
                height: 60,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border.all(
                          color: Colors.white,
                          width: 3,
                        )
                      : null,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 40),
        
        // Back and Continue buttons
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 56,
                child: OutlinedButton(
                  onPressed: () => setState(() => _currentStep = 1),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Back',
                    style: TextStyle(
                      color: isDark ? Colors.grey[300] : const Color(0xFF222639),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildContinueButton(isDark, onPressed: () {
                if (_goalTitle.isNotEmpty && _selectedCategory != null) {
                  setState(() => _currentStep = 3);
                }
              }),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContinueButton(bool isDark, {required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1ABC9C), Color(0xFF7C3BED)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(12),
            child: const Center(
              child: Text(
                'Continue',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoalTypeCard({
    required GoalType type,
    required IconData icon,
    required String title,
    required String description,
    required bool isDark,
  }) {
    final isSelected = _selectedGoalType == type;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedGoalType = type),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF171A26) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1ABC9C)
                : (isDark ? Colors.grey[700]! : Colors.grey[200]!),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF1ABC9C).withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
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
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF1ABC9C).withOpacity(0.1)
                    : (isDark ? Colors.grey[800] : Colors.grey[100]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: isSelected ? const Color(0xFF1ABC9C) : (isDark ? Colors.grey[400] : Colors.grey[600]),
                  size: 28,
                ),
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
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
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

  Widget _buildStep3(bool isDark) {
    if (_selectedGoalType == GoalType.numeric) {
      return _buildStep3Numeric(isDark);
    } else if (_selectedGoalType == GoalType.habit) {
      return _buildStep3Habit(isDark);
    } else if (_selectedGoalType == GoalType.milestone) {
      return _buildStep3Milestone(isDark);
    } else if (_selectedGoalType == GoalType.levels) {
      return _buildStep3Levels(isDark);
    }
    return const SizedBox.shrink();
  }

  Widget _buildStep3Numeric(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Target Value',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF222639),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _targetValueController,
          onChanged: (_) => setState(() {}),
          keyboardType: TextInputType.numberWithOptions(
            decimal: true,
            signed: false,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(
              RegExp(r'^\d+\.?\d*'),
            ),
          ],
          decoration: InputDecoration(
            hintText: 'e.g., 12',
            hintStyle: TextStyle(
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            filled: true,
            fillColor: isDark ? const Color(0xFF171A26) : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              ),
            ),
          ),
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF222639),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Unit',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF222639),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _unitController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'e.g., books, miles, dollars',
            hintStyle: TextStyle(
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            filled: true,
            fillColor: isDark ? const Color(0xFF171A26) : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              ),
            ),
          ),
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF222639),
          ),
        ),
        const SizedBox(height: 40),
        _buildStep3Navigation(isDark),
      ],
    );
  }

  Widget _buildStep3Habit(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frequency',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF222639),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _frequency = 'daily'),
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: _frequency == 'daily'
                        ? const Color(0xFF1ABC9C)
                        : (isDark ? const Color(0xFF171A26) : Colors.white),
                    borderRadius: BorderRadius.circular(12),
                    border: _frequency == 'daily'
                        ? null
                        : Border.all(
                            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                          ),
                  ),
                  child: Center(
                    child: Text(
                      'Daily',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _frequency == 'daily'
                            ? Colors.white
                            : (isDark ? Colors.grey[300] : const Color(0xFF222639)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _frequency = 'weekly'),
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: _frequency == 'weekly'
                        ? const Color(0xFF1ABC9C)
                        : (isDark ? const Color(0xFF171A26) : Colors.white),
                    borderRadius: BorderRadius.circular(12),
                    border: _frequency == 'weekly'
                        ? null
                        : Border.all(
                            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                          ),
                  ),
                  child: Center(
                    child: Text(
                      'Weekly',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _frequency == 'weekly'
                            ? Colors.white
                            : (isDark ? Colors.grey[300] : const Color(0xFF222639)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Build a streak by completing this every day!',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 40),
        _buildStep3Navigation(isDark),
      ],
    );
  }

  Widget _buildStep3Milestone(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Milestones',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF222639),
          ),
        ),
        const SizedBox(height: 12),
        if (_milestones.isNotEmpty) ...[
          Column(
            children: _milestones.asMap().entries.map((entry) {
              int index = entry.key;
              String milestone = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF171A26) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1ABC9C),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          milestone,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.grey[300] : const Color(0xFF222639),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _milestones.removeAt(index)),
                        child: Icon(
                          LucideIcons.trash2,
                          size: 18,
                          color: isDark ? Colors.grey[500] : Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _milestoneController,
                decoration: InputDecoration(
                  hintText: 'Add a milestone...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey[600] : Colors.grey[400],
                  ),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF171A26) : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                    ),
                  ),
                ),
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF222639),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF1ABC9C),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (_milestoneController.text.isNotEmpty) {
                      setState(() {
                        _milestones.add(_milestoneController.text);
                        _milestoneController.clear();
                      });
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: const Center(
                    child: Icon(LucideIcons.plus, color: Colors.white, size: 24),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Add at least one milestone to track your progress step by step.',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 40),
        _buildStep3Navigation(isDark),
      ],
    );
  }

  Widget _buildStep3Levels(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Level Preset',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF222639),
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: [
            ..._levelPresets.entries.map((entry) {
              String presetName = entry.key;
              Map<String, String> presetData = entry.value;
              bool isSelected = _selectedLevelPreset == presetName;
              
              return GestureDetector(
                onTap: () => setState(() => _selectedLevelPreset = presetName),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF1ABC9C).withOpacity(0.1)
                        : (isDark ? const Color(0xFF171A26) : Colors.white),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF1ABC9C)
                          : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        presetName,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF222639),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        presetData['description']!,
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            GestureDetector(
              onTap: () => setState(() => _selectedLevelPreset = 'custom'),
              child: Container(
                decoration: BoxDecoration(
                  color: _selectedLevelPreset == 'custom'
                      ? const Color(0xFF1ABC9C).withOpacity(0.1)
                      : (isDark ? const Color(0xFF171A26) : Colors.white),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedLevelPreset == 'custom'
                        ? const Color(0xFF1ABC9C)
                        : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
                    width: _selectedLevelPreset == 'custom' ? 2 : 1,
                  ),
                ),
                padding: const EdgeInsets.all(12),
                child: Center(
                  child: Text(
                    'Custom',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _selectedLevelPreset == 'custom'
                          ? const Color(0xFF1ABC9C)
                          : (isDark ? Colors.grey[300] : const Color(0xFF222639)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_selectedLevelPreset != null && _selectedLevelPreset != 'custom') ...[
          const SizedBox(height: 24),
          Text(
            'Levels will be:',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          ..._levelPresets[_selectedLevelPreset]!['example']!.split(', ').asMap().entries.map((entry) {
            int index = entry.key;
            String level = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1ABC9C).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1ABC9C),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      level,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white : const Color(0xFF222639),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ] else if (_selectedLevelPreset == 'custom') ...[
          const SizedBox(height: 24),
          if (_customLevels.isNotEmpty) ...[
            Column(
              children: _customLevels.asMap().entries.map((entry) {
                int index = entry.key;
                String level = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1ABC9C).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: Color(0xFF1ABC9C),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            level,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white : const Color(0xFF222639),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _customLevels.removeAt(index)),
                          child: Icon(
                            LucideIcons.trash2,
                            size: 18,
                            color: isDark ? Colors.grey[500] : Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _levelController,
                  decoration: InputDecoration(
                    hintText: 'Add a custom level...',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.grey[600] : Colors.grey[400],
                    ),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF171A26) : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                      ),
                    ),
                  ),
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF222639),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF1ABC9C),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      if (_levelController.text.isNotEmpty) {
                        setState(() {
                          _customLevels.add(_levelController.text);
                          _levelController.clear();
                        });
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: const Center(
                      child: Icon(LucideIcons.plus, color: Colors.white, size: 24),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 40),
        _buildStep3Navigation(isDark),
      ],
    );
  }

  Widget _buildStep3Navigation(bool isDark) {
    bool canCreate = true;
    if (_selectedGoalType == GoalType.numeric) {
      canCreate = _targetValueController.text.isNotEmpty && _unitController.text.isNotEmpty;
    } else if (_selectedGoalType == GoalType.milestone) {
      canCreate = _milestones.isNotEmpty;
    } else if (_selectedGoalType == GoalType.levels) {
      canCreate = _selectedLevelPreset != null;
      if (_selectedLevelPreset == 'custom') {
        canCreate = _customLevels.isNotEmpty;
      }
    }
    
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 56,
            child: OutlinedButton(
              onPressed: () => setState(() => _currentStep = 2),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Back',
                style: TextStyle(
                  color: isDark ? Colors.grey[300] : const Color(0xFF222639),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildCreateGoalButton(isDark, canCreate: canCreate),
        ),
      ],
    );
  }

  void _createGoal(BuildContext context) {
    // Validate inputs
    if (_selectedGoalType == GoalType.numeric) {
      if (_targetValueController.text.isEmpty || _unitController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill in target value and unit'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    } else if (_selectedGoalType == GoalType.milestone) {
      if (_milestones.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add at least one milestone'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    } else if (_selectedGoalType == GoalType.levels) {
      if (_selectedLevelPreset == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a level preset'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (_selectedLevelPreset == 'custom' && _customLevels.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add at least one custom level'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }
    
    const uuid = Uuid();
    final now = DateTime.now();
    
    // Map color to GoalColor enum
    GoalColor goalColor = GoalColor.teal;
    if (_selectedColor == const Color(0xFF7C3BED)) {
      goalColor = GoalColor.purple;
    } else if (_selectedColor == const Color(0xFF3B82F6)) {
      goalColor = GoalColor.blue;
    } else if (_selectedColor == const Color(0xFFFF9800)) {
      goalColor = GoalColor.orange;
    }
    
    Goal goal = Goal(
      id: uuid.v4(),
      title: _goalTitle,
      description: _goalDescription.isEmpty ? null : _goalDescription,
      type: _selectedGoalType!,
      category: _selectedCategory!,
      color: goalColor,
      createdAt: now,
      updatedAt: now,
      isCompleted: false,
    );
    
    // Add type-specific data
    if (_selectedGoalType == GoalType.numeric) {
      goal = goal.copyWith(
        targetValue: double.tryParse(_targetValueController.text),
        currentValue: 0.0,
        unit: _unitController.text,
      );
    } else if (_selectedGoalType == GoalType.habit) {
      goal = goal.copyWith(
        frequency: _frequency,
        streak: 0,
        bestStreak: 0,
        completedDates: [],
      );
    } else if (_selectedGoalType == GoalType.milestone) {
      // Convert String list to Milestone objects
      final milestones = _milestones.asMap().entries.map((entry) {
        return Milestone(
          id: uuid.v4(),
          title: entry.value,
          isCompleted: false,
          order: entry.key,
        );
      }).toList();
      
      goal = goal.copyWith(
        milestones: milestones,
      );
    } else if (_selectedGoalType == GoalType.levels) {
      // Get level titles
      List<String> levelTitles = [];
      if (_selectedLevelPreset == 'custom') {
        levelTitles = _customLevels;
      } else if (_selectedLevelPreset != null) {
        levelTitles = _levelPresets[_selectedLevelPreset]!['example']!.split(', ');
      }
      
      // Convert to Level objects
      final levels = levelTitles.asMap().entries.map((entry) {
        return Level(
          id: uuid.v4(),
          title: entry.value,
          isCompleted: false,
          order: entry.key,
        );
      }).toList();
      
      goal = goal.copyWith(
        levels: levels,
        currentLevelIndex: 0,
      );
    }
    
    // Save goal via BLoC
    context.read<GoalBloc>().add(CreateGoalEvent(goal));
    
    // Show success message and navigate back
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Goal created successfully!'),
        backgroundColor: Color(0xFF1ABC9C),
        duration: Duration(seconds: 2),
      ),
    );
    
    // Wait a moment before navigating to ensure the snackbar is visible
    Future.delayed(const Duration(milliseconds: 300), () {
      if (context.mounted) {
        Navigator.pop(context);
      }
    });
  }

  Widget _buildCreateGoalButton(bool isDark, {required bool canCreate}) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1ABC9C), Color(0xFF7C3BED)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: canCreate ? () => _createGoal(context) : null,
            borderRadius: BorderRadius.circular(12),
            child: const Center(
              child: Text(
                'Create Goal',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}