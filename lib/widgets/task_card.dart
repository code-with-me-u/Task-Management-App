import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../utils/constants.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final Function(String)? onStatusChanged;

  const TaskCard({
    Key? key,
    required this.task,
    required this.onTap,
    this.onDelete,
    this.onStatusChanged,
  }) : super(key: key);

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppConstants.priorityHigh;
      case 'medium':
        return AppConstants.priorityMedium;
      case 'low':
      default:
        return AppConstants.priorityLow;
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppConstants.success.withOpacity(0.12);
      case 'in_progress':
        return AppConstants.warning.withOpacity(0.12);
      case 'pending':
      default:
        return AppConstants.info.withOpacity(0.12);
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppConstants.success;
      case 'in_progress':
        return AppConstants.warning;
      case 'pending':
      default:
        return AppConstants.info;
    }
  }

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Completed';
      case 'in_progress':
        return 'In Progress';
      case 'pending':
      default:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = task.status.toLowerCase() == 'completed';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isOverdue = task.dueDate != null &&
        !isCompleted &&
        task.dueDate!.isBefore(today);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      color: AppConstants.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        side: BorderSide(
          color: isOverdue ? AppConstants.error.withOpacity(0.5) : AppConstants.border,
          width: isOverdue ? 1.5 : 1.0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Priority Dot, Overdue Badge, and Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Priority indicator
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _getPriorityColor(task.priority),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppConstants.paddingSmall),
                      Text(
                        '${task.priority.toUpperCase()} PRIORITY',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _getPriorityColor(task.priority),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          fontSize: 10.0,
                        ),
                      ),
                      if (isOverdue) ...[
                        const SizedBox(width: AppConstants.paddingSmall),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppConstants.error.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'OVERDUE',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppConstants.error,
                              fontWeight: FontWeight.bold,
                              fontSize: 9.0,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusBgColor(task.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _formatStatus(task.status),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _getStatusTextColor(task.status),
                        fontWeight: FontWeight.bold,
                        fontSize: 11.0,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.paddingMedium),

              // Title
              Text(
                task.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppConstants.textPrimary,
                  fontWeight: FontWeight.bold,
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                  decorationColor: AppConstants.textSecondary.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 6),

              // Description
              Text(
                task.description.isEmpty ? 'No description provided.' : task.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppConstants.textSecondary,
                  fontSize: 13.5,
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                  decorationColor: AppConstants.textSecondary.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: AppConstants.paddingMedium),

              // Footer: Due Date and Actions
              const Divider(color: AppConstants.border, height: 1),
              const SizedBox(height: AppConstants.paddingSmall),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Due date
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: AppConstants.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        task.dueDate != null 
                            ? 'Due: ${DateFormat.yMMMd().format(task.dueDate!)}'
                            : 'No due date',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppConstants.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  // Actions: Toggle Complete, Edit (handled by tap), Delete
                  Row(
                    children: [
                      // Quick Toggle Checkbox
                      IconButton(
                        icon: Icon(
                          isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: isCompleted ? AppConstants.success : AppConstants.textSecondary,
                          size: 20,
                        ),
                        tooltip: isCompleted ? 'Mark Pending' : 'Mark Completed',
                        onPressed: () async {
                          final newStatus = isCompleted ? 'pending' : 'completed';
                          if (onStatusChanged != null) {
                            onStatusChanged!(newStatus);
                          } else {
                            await Provider.of<TaskProvider>(context, listen: false)
                                .updateTask(task.copyWith(status: newStatus));
                          }
                        },
                      ),
                      
                      // Delete button
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: AppConstants.error,
                          size: 20,
                        ),
                        tooltip: 'Delete Task',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              title: const Text('Delete Task'),
                              content: const Text('Are you sure you want to delete this task?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(dialogContext),
                                  child: const Text('Cancel', style: TextStyle(color: AppConstants.textSecondary)),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.pop(dialogContext);
                                    if (onDelete != null) {
                                      onDelete!();
                                    } else {
                                      await Provider.of<TaskProvider>(context, listen: false)
                                          .deleteTask(task.id);
                                    }
                                  },
                                  child: const Text('Delete', style: TextStyle(color: AppConstants.error)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
