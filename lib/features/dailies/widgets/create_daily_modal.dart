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
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.task != null ? 'Edit Daily Task' : 'Create Daily Task',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Enter task title',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Enter task description',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<DailyPriority>(
                    value: _priority,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _priority = value);
                      }
                    },
                    items: DailyPriority.values.map((priority) {
                      return DropdownMenuItem(
                        value: priority,
                        child: Text(priority.name),
                      );
                    }).toList(),
                    decoration: const InputDecoration(
                      labelText: 'Priority',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<DailyCategory>(
                    value: _category,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _category = value);
                      }
                    },
                    items: DailyCategory.values.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category.name),
                      );
                    }).toList(),
                    decoration: const InputDecoration(
                      labelText: 'Category',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Due Time',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              subtitle: Text(
                _dueTime.format(context),
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.access_time),
                onPressed: _selectTime,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveTask,
                child: Text(widget.task != null ? 'Update Task' : 'Create Task'),
              ),
            ),
          ],
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

    dev.log('Creating task with due time: $dueDateTime');

    final task = DailyTask(
      title: _titleController.text,
      description: _descriptionController.text,
      dueTime: dueDateTime,
      priority: _priority,
      category: _category,
    );

    dev.log('Task created: ${task.toJson()}');

    if (widget.task != null) {
      ref.read(dailyProvider.notifier).updateDaily(task);
    } else {
      ref.read(dailyProvider.notifier).createDaily(task);
    }

    Navigator.pop(context);
  }
} 