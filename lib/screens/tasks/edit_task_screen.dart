import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class EditTaskScreen extends StatefulWidget {
  const EditTaskScreen({Key? key}) : super(key: key);

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dueDateController = TextEditingController();
  
  late TaskModel _task;
  bool _isInit = false;
  String _priority = 'low';
  String _status = 'pending';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      // Parse task argument passed from navigation route
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is TaskModel) {
        _task = args;
        _titleController.text = _task.title;
        _descriptionController.text = _task.description;
        _priority = _task.priority;
        _status = _task.status;
        _selectedDate = _task.dueDate ?? DateTime.now();
        _dueDateController.text = _task.dueDate != null 
            ? DateFormat.yMMMd().format(_task.dueDate!) 
            : '';
      }
      _isInit = true;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppConstants.primary,
              onPrimary: AppConstants.surface,
              onSurface: AppConstants.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dueDateController.text = DateFormat.yMMMd().format(_selectedDate);
      });
    }
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      
      final updatedTask = _task.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        priority: _priority,
        status: _status,
        dueDate: _selectedDate,
      );

      await taskProvider.updateTask(updatedTask);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task updated successfully!'),
            backgroundColor: AppConstants.success,
          ),
        );
        Navigator.pop(context); // Go back to dashboard
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppConstants.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isWebOrDesktop = size.width > AppConstants.mobileBreakPoint;

    return Scaffold(
      backgroundColor: AppConstants.background,
      appBar: AppBar(
        title: const Text('Edit Task'),
        elevation: 0,
        backgroundColor: AppConstants.surface,
        foregroundColor: AppConstants.textPrimary,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppConstants.border, height: 1.0),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              padding: isWebOrDesktop 
                  ? const EdgeInsets.all(AppConstants.paddingExtraLarge)
                  : EdgeInsets.zero,
              decoration: isWebOrDesktop
                  ? BoxDecoration(
                      color: AppConstants.surface,
                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                      border: Border.all(color: AppConstants.border, width: 1.0),
                    )
                  : null,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Task Details',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingLarge),

                    // Task Title
                    CustomTextField(
                      controller: _titleController,
                      labelText: 'Task Title',
                      hintText: 'Enter task title',
                      prefixIcon: Icons.title_outlined,
                      validator: Validators.validateTaskTitle,
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),

                    // Task Description
                    CustomTextField(
                      controller: _descriptionController,
                      labelText: 'Description',
                      hintText: 'Enter task description',
                      prefixIcon: Icons.description_outlined,
                      maxLines: 4,
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),

                    // Status Selector
                    DropdownButtonFormField<String>(
                      value: _status,
                      decoration: InputDecoration(
                        labelText: 'Task Status',
                        prefixIcon: const Icon(Icons.check_circle_outline, color: AppConstants.textSecondary, size: 20),
                        filled: true,
                        fillColor: AppConstants.surface,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: AppConstants.paddingMedium,
                          horizontal: AppConstants.paddingMedium,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                          borderSide: const BorderSide(color: AppConstants.border, width: 1.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                          borderSide: const BorderSide(color: AppConstants.border, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                          borderSide: const BorderSide(color: AppConstants.primary, width: 1.5),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'pending',
                          child: Text('Pending', style: TextStyle(color: AppConstants.warning, fontWeight: FontWeight.w600)),
                        ),
                        DropdownMenuItem(
                          value: 'in_progress',
                          child: Text('In Progress', style: TextStyle(color: AppConstants.accentDark, fontWeight: FontWeight.w600)),
                        ),
                        DropdownMenuItem(
                          value: 'completed',
                          child: Text('Completed', style: TextStyle(color: AppConstants.success, fontWeight: FontWeight.w600)),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _status = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),

                    // Priority Selector
                    DropdownButtonFormField<String>(
                      value: _priority,
                      decoration: InputDecoration(
                        labelText: 'Priority Level',
                        prefixIcon: const Icon(Icons.priority_high_outlined, color: AppConstants.textSecondary, size: 20),
                        filled: true,
                        fillColor: AppConstants.surface,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: AppConstants.paddingMedium,
                          horizontal: AppConstants.paddingMedium,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                          borderSide: const BorderSide(color: AppConstants.border, width: 1.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                          borderSide: const BorderSide(color: AppConstants.border, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                          borderSide: const BorderSide(color: AppConstants.primary, width: 1.5),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'low',
                          child: Text('Low Priority', style: TextStyle(color: AppConstants.priorityLow, fontWeight: FontWeight.w600)),
                        ),
                        DropdownMenuItem(
                          value: 'medium',
                          child: Text('Medium Priority', style: TextStyle(color: AppConstants.priorityMedium, fontWeight: FontWeight.w600)),
                        ),
                        DropdownMenuItem(
                          value: 'high',
                          child: Text('High Priority', style: TextStyle(color: AppConstants.priorityHigh, fontWeight: FontWeight.w600)),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _priority = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),

                    // Due Date Selector
                    CustomTextField(
                      controller: _dueDateController,
                      labelText: 'Due Date',
                      readOnly: true,
                      prefixIcon: Icons.calendar_today_outlined,
                      onTap: () => _selectDate(context),
                    ),
                    const SizedBox(height: AppConstants.paddingLarge),

                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'Cancel',
                            isSecondary: true,
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: AppConstants.paddingMedium),
                        Expanded(
                          child: CustomButton(
                            text: 'Save Changes',
                            isLoading: _isLoading,
                            onPressed: _handleSubmit,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
