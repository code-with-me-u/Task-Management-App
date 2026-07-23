import 'package:flutter/material.dart';
import '../utils/constants.dart';

class StatusSummaryCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color color;

  const StatusSummaryCard({
    Key? key,
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppConstants.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(color: AppConstants.border, width: 1.0),
      ),
      child: Row(
        children: [
          // Icon Container
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: AppConstants.paddingMedium),
          
          // Labels
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppConstants.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  count,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppConstants.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 22.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
