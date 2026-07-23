import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({Key? key}) : super(key: key);

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dueDateController = TextEditingController();
  
  String _priority = 'low'; // Default priority
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1)); // Default due date
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _dueDateController.text = DateFormat.yMMMd().format(_selectedDate);
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
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
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
      
      await taskProvider.addTask(
        _titleController.text.trim(),
        _descriptionController.text.trim(),
        _priority,
        _selectedDate,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task created successfully!'),
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
        title: const Text('Add New Task'),
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
                            text: 'Create Task',
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
