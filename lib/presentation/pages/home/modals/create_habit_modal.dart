import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ninte/presentation/theme/app_colors.dart';
import 'package:ninte/presentation/widgets/custom_text_field.dart';
import 'package:ninte/presentation/widgets/gradient_button.dart';
import 'package:ninte/features/habit_tracking/models/habit.dart';
import 'package:ninte/features/habit_tracking/providers/habit_provider.dart';

class CreateHabitModal extends ConsumerStatefulWidget {
  const CreateHabitModal({super.key});

  @override
  ConsumerState<CreateHabitModal> createState() => _CreateHabitModalState();
}

class _CreateHabitModalState extends ConsumerState<CreateHabitModal> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();
  HabitCategory _selectedCategory = HabitCategory.productivity;
  HabitFrequency _selectedFrequency = HabitFrequency.daily;
  bool _isReminderEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Create New Habit',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close_rounded,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            CustomTextField(
              controller: _nameController,
              label: 'Habit Name',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _descriptionController,
              label: 'Description (Optional)',
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            _buildCategorySelector(),
            const SizedBox(height: 24),
            _buildFrequencySelector(),
            const SizedBox(height: 24),
            _buildReminderSection(),
            const SizedBox(height: 32),
            GradientButton(
              text: 'Create Habit',
              onPressed: _createHabit,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: HabitCategory.values.map((category) {
            final isSelected = category == _selectedCategory;
            return FilterChip(
              selected: isSelected,
              label: Text(category.name),
              onSelected: (selected) {
                setState(() => _selectedCategory = category);
              },
              backgroundColor: AppColors.surface,
              selectedColor: AppColors.accent.withOpacity(0.2),
              checkmarkColor: AppColors.accent,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.accent : AppColors.textSecondary,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFrequencySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frequency',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: HabitFrequency.values.where((f) => f != HabitFrequency.custom).map((frequency) {
            final isSelected = frequency == _selectedFrequency;
            return FilterChip(
              selected: isSelected,
              label: Text(frequency.name),
              onSelected: (selected) {
                setState(() => _selectedFrequency = frequency);
              },
              backgroundColor: AppColors.surface,
              selectedColor: AppColors.accent.withOpacity(0.2),
              checkmarkColor: AppColors.accent,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.accent : AppColors.textSecondary,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildReminderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Reminder',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Switch(
              value: _isReminderEnabled,
              onChanged: (value) {
                setState(() => _isReminderEnabled = value);
              },
              activeColor: AppColors.accent,
            ),
          ],
        ),
        if (_isReminderEnabled) ...[
          const SizedBox(height: 16),
          InkWell(
            onTap: () async {
              final TimeOfDay? time = await showTimePicker(
                context: context,
                initialTime: _selectedTime,
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      timePickerTheme: TimePickerThemeData(
                        backgroundColor: AppColors.surface,
                        hourMinuteTextColor: AppColors.textPrimary,
                        dayPeriodTextColor: AppColors.textPrimary,
                        dialHandColor: AppColors.accent,
                        dialBackgroundColor: AppColors.background,
                        dialTextColor: AppColors.textPrimary,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (time != null) {
                setState(() => _selectedTime = time);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    _selectedTime.format(context),
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _createHabit() async {
    if (_nameController.text.trim().isEmpty) {
      // Show error
      return;
    }

    final now = DateTime.now();
    final reminderTime = _isReminderEnabled
        ? DateTime(
            now.year,
            now.month,
            now.day,
            _selectedTime.hour,
            _selectedTime.minute,
          )
        : null;

    final habit = Habit(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      frequency: _selectedFrequency,
      reminderTime: reminderTime,
    );

    await ref.read(habitProvider.notifier).createHabit(habit);
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
} 