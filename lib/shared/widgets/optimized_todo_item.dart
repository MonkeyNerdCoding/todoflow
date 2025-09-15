import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/models.dart';
import '../../core/providers/individual_todo_provider.dart';
import '../constants/app_constants.dart';

/// Optimized todo item widget that only rebuilds when this specific todo changes
class OptimizedTodoItem extends ConsumerWidget {
  final String todoId;
  final VoidCallback? onTap;

  const OptimizedTodoItem({
    super.key,
    required this.todoId,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only watch this specific todo's display data - prevents cascade rebuilds
    final todoDisplayData = ref.watch(todoDisplayProvider(todoId));

    return todoDisplayData.when(
      loading: () => _buildLoadingSkeleton(context),
      error: (error, stack) => _buildErrorWidget(context, error),
      data: (displayData) => _buildTodoItem(context, ref, displayData),
    );
  }

  Widget _buildTodoItem(BuildContext context, WidgetRef ref, TodoDisplayData displayData) {
    final theme = Theme.of(context);
    final isCompleted = displayData.isCompleted;
    
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingM,
        vertical: AppConstants.spacingS,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingM),
          child: Row(
            children: [
              // Completion checkbox - only triggers completion state change
              _buildCompletionCheckbox(context, ref, displayData),
              const SizedBox(width: AppConstants.spacingM),
              
              // Todo content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title with completion styling
                    Text(
                      displayData.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                        color: isCompleted 
                          ? theme.colorScheme.onSurfaceVariant 
                          : theme.colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    if (displayData.description != null && displayData.description!.isNotEmpty) ...[
                      const SizedBox(height: AppConstants.spacingS),
                      Text(
                        displayData.description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isCompleted 
                            ? theme.colorScheme.onSurfaceVariant 
                            : theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    
                    // Metadata row
                    const SizedBox(height: AppConstants.spacingS),
                    _buildMetadataRow(context, displayData),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionCheckbox(BuildContext context, WidgetRef ref, TodoDisplayData displayData) {
    return Checkbox(
      value: displayData.isCompleted,
      onChanged: (value) {
        if (value != null) {
          // Trigger completion toggle using the function provider
          final toggleFn = ref.read(toggleTodoCompletionProvider(todoId));
          toggleFn();
        }
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusS),
      ),
    );
  }

  Widget _buildMetadataRow(BuildContext context, TodoDisplayData displayData) {
    final theme = Theme.of(context);
    final isCompleted = displayData.isCompleted;
    
    return Row(
      children: [
        // Category indicator
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: displayData.categoryColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppConstants.spacingS),
        
        // Category name
        Text(
          displayData.categoryName,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isCompleted 
              ? theme.colorScheme.onSurfaceVariant 
              : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        
        const Spacer(),
        
  // Priority pill (always visible for clarity)
  _buildPriorityPill(context, displayData.priority),
  const SizedBox(width: AppConstants.spacingS),
        
        // Due date
        if (displayData.dueDate != null) ...[
          Icon(
            Icons.schedule,
            size: 16,
            color: _getDueDateColor(context, displayData.dueDate!, isCompleted),
          ),
          const SizedBox(width: AppConstants.spacingXs),
          Text(
            _formatDueDate(displayData.dueDate!),
            style: theme.textTheme.bodySmall?.copyWith(
              color: _getDueDateColor(context, displayData.dueDate!, isCompleted),
            ),
          ),
        ],
      ],
    );
  }

  // Small, color-coded priority pill (dot + label)
  Widget _buildPriorityPill(BuildContext context, Priority priority) {
  final color = _getPriorityColor(context, priority);
  final theme = Theme.of(context);
  final bg = color.withValues(alpha: 0.14);

    return Semantics(
      label: 'Priority ${priority.displayName}',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingS,
          vertical: 2,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppConstants.radiusS),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: AppConstants.spacingXs),
            Text(
              priority.displayName,
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton(BuildContext context) {
    final theme = Theme.of(context);
    final placeholder = theme.colorScheme.surfaceContainerHighest;
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingM,
        vertical: AppConstants.spacingS,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: placeholder,
                borderRadius: BorderRadius.circular(AppConstants.radiusS),
              ),
            ),
            const SizedBox(width: AppConstants.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    decoration: BoxDecoration(
                      color: placeholder,
                      borderRadius: BorderRadius.circular(AppConstants.radiusS),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingS),
                  Container(
                    height: 12,
                    width: 200,
                    decoration: BoxDecoration(
                      color: placeholder,
                      borderRadius: BorderRadius.circular(AppConstants.radiusS),
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

  Widget _buildErrorWidget(BuildContext context, Object error) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingM,
        vertical: AppConstants.spacingS,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Row(
          children: [
            Icon(Icons.error, color: cs.error),
            const SizedBox(width: AppConstants.spacingM),
            Expanded(
              child: Text(
                'Error loading todo: $error',
                style: TextStyle(color: cs.error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(BuildContext context, Priority priority) {
    final cs = Theme.of(context).colorScheme;
    switch (priority) {
      case Priority.high:
        return cs.error;
      case Priority.medium:
        return cs.warning;
      case Priority.low:
        return cs.onSurfaceVariant;
    }
  }

  Color _getDueDateColor(BuildContext context, DateTime dueDate, bool isCompleted) {
    if (isCompleted) return Theme.of(context).colorScheme.onSurfaceVariant;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    
    if (due.isBefore(today)) {
      return Theme.of(context).colorScheme.error; // Overdue
    } else if (due.isAtSameMomentAs(today)) {
  return Theme.of(context).colorScheme.warning; // Due today
    } else {
      return Theme.of(context).colorScheme.onSurfaceVariant; // Future
    }
  }

  String _formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    
    if (due.isAtSameMomentAs(today)) {
      return 'Today';
    } else if (due.isAtSameMomentAs(today.add(const Duration(days: 1)))) {
      return 'Tomorrow';
    } else if (due.isBefore(today)) {
      final days = today.difference(due).inDays;
      return '$days day${days > 1 ? 's' : ''} ago';
    } else {
      final days = due.difference(today).inDays;
      return 'In $days day${days > 1 ? 's' : ''}';
    }
  }
}

