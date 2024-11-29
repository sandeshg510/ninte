import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ninte/presentation/theme/app_colors.dart';
import 'package:ninte/features/dailies/models/daily_task.dart';
import 'package:ninte/features/dailies/providers/daily_provider.dart';
import 'dart:developer' as dev;

class CreateDailyModal extends ConsumerStatefulWidget {
  final DailyTask? task;

  const CreateDailyModal({
    super.key,
    this.task,
  });

  @override
  ConsumerState<CreateDailyModal> createState() => _CreateDailyModalState();
}

class _CreateDailyModalState extends ConsumerState<CreateDailyModal> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late DailyPriority _priority;
  late DailyCategory _category;
  late TimeOfDay _dueTime;
  bool _hasReminder = false;
  int _reminderMinutes = 15;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title);
    _descriptionController = TextEditingController(text: widget.task?.description);
    _priority = widget.task?.priority ?? DailyPriority.medium;
    _category = widget.task?.category ?? DailyCategory.personal;
    _dueTime = widget.task?.dueTime != null 
        ? TimeOfDay.fromDateTime(widget.task!.dueTime)
        : TimeOfDay.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.9,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.surfaceLight.withOpacity(0.1),
                ),
              ),
            ),
            child: Row(
              children: [
                Text(
                  widget.task != null ? 'Edit Daily Task' : 'Create Daily Task',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
          
          // Main Content - Wrap in Expanded
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Field
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        hintText: 'Enter task title',
                      ),
                      autofocus: true,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    
                    // Description Field
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description (optional)',
                        hintText: 'Enter task description',
                      ),
                      maxLines: 2,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 24),
                    
                    // Time and Priority Row
                    Row(
                      children: [
                        // Due Time
                        Expanded(
                          child: InkWell(
                            onTap: _selectTime,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceLight.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    color: AppColors.accent,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _dueTime.format(context),
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Priority Dropdown
                        Expanded(
                          child: _buildDropdown<DailyPriority>(
                            label: 'Priority',
                            value: _priority,
                            items: DailyPriority.values,
                            onChanged: (value) {
                              if (value != null) setState(() => _priority = value);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Category Dropdown
                    _buildDropdown<DailyCategory>(
                      label: 'Category',
                      value: _category,
                      items: DailyCategory.values,
                      onChanged: (value) {
                        if (value != null) setState(() => _category = value);
                      },
                    ),
                    const SizedBox(height: 24),
                    // Reminder Settings
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Reminder',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            const Spacer(),
                            Switch(
                              value: _hasReminder,
                              onChanged: (value) => setState(() => _hasReminder = value),
                              activeColor: AppColors.accent,
                            ),
                          ],
                        ),
                        if (_hasReminder) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: _reminderMinutes,
                                onChanged: (value) {
                                  if (value != null) setState(() => _reminderMinutes = value);
                                },
                                items: [5, 10, 15, 30, 60].map((minutes) {
                                  return DropdownMenuItem(
                                    value: minutes,
                                    child: Text(
                                      '$minutes minutes before',
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                dropdownColor: AppColors.surface,
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  color: AppColors.textSecondary,
                                ),
                                isExpanded: true,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Save Button
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: bottomPadding + 16,
              top: 16,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(
                  color: AppColors.surfaceLight.withOpacity(0.1),
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.surface,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  widget.task != null ? 'Update Task' : 'Create Task',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          onChanged: onChanged,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(
                item.toString().split('.').last,
                style: TextStyle(
                  color: AppColors.textPrimary,
                ),
              ),
            );
          }).toList(),
          dropdownColor: AppColors.surface,
          icon: Icon(
            Icons.arrow_drop_down,
            color: AppColors.textSecondary,
          ),
          isExpanded: true,
        ),
      ),
    );
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _dueTime,
    );
    if (picked != null && picked != _dueTime) {
      setState(() {
        _dueTime = picked;
      });
    }
  }

  void _saveTask() {
    if (_titleController.text.isEmpty) return;

    final now = DateTime.now();
    final dueDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      _dueTime.hour,
      _dueTime.minute,
    );

    final task = DailyTask(
      id: widget.task?.id,
      title: _titleController.text,
      description: _descriptionController.text,
      dueTime: dueDateTime,
      priority: _priority,
      category: _category,
      hasReminder: _hasReminder,
      reminderMinutes: _reminderMinutes,
    );

    if (widget.task != null) {
      ref.read(dailyProvider.notifier).updateDaily(task);
    } else {
      ref.read(dailyProvider.notifier).createDaily(task);
    }

    Navigator.pop(context);
  }
} 