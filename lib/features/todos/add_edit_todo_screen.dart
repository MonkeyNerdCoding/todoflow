import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/providers.dart';
import '../../core/models/models.dart';
import '../../shared/utils/color_utils.dart';
import '../../shared/constants/app_constants.dart';

class AddEditTodoScreen extends ConsumerStatefulWidget {
  final String? todoId;
  
  const AddEditTodoScreen({super.key, this.todoId});

  @override
  ConsumerState<AddEditTodoScreen> createState() => _AddEditTodoScreenState();
}

class _AddEditTodoScreenState extends ConsumerState<AddEditTodoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<TextEditingController> _subtaskControllers = [];
  
  String? _selectedCategoryId;
  Priority _selectedPriority = Priority.medium;
  DateTime? _selectedDueDate;
  TimeOfDay? _selectedDueTime;
  bool _isLoading = false;
  bool _hasUnsavedChanges = false;
  Todo? _originalTodo;
  
  // Subtasks management
  final List<Subtask> _subtasks = [];
  final List<String> _subtaskTexts = [];

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_onFormChanged);
    _descriptionController.addListener(_onFormChanged);
    
    if (widget.todoId != null) {
      _loadExistingTodo();
    }
  }

  void _onFormChanged() {
    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
    }
  }

  void _loadExistingTodo() async {
    final todosAsync = ref.read(todoNotifierProvider);
    todosAsync.whenData((todos) {
      final todo = todos.where((t) => t.id == widget.todoId).firstOrNull;
      if (todo != null) {
        setState(() {
          _originalTodo = todo;
          _titleController.text = todo.title;
          _descriptionController.text = todo.description ?? '';
          _selectedCategoryId = todo.categoryId;
          _selectedPriority = todo.priority;
          _selectedDueDate = todo.dueDate;
          _selectedDueTime = todo.dueTime != null 
              ? TimeOfDay.fromDateTime(todo.dueTime!) 
              : null;
          
          // Load subtasks
          _subtasks.clear();
          _subtasks.addAll(todo.subtasks);
          _subtaskTexts.clear();
          _subtaskControllers.clear();
          
          for (final subtask in todo.subtasks) {
            _subtaskTexts.add(subtask.title);
            final controller = TextEditingController(text: subtask.title);
            controller.addListener(_onFormChanged);
            _subtaskControllers.add(controller);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (final controller in _subtaskControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryNotifierProvider);
    final isMobile = AppSizing.isMobile(context);
    final isTablet = AppSizing.isTablet(context);
    
    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _hasUnsavedChanges) {
          _showUnsavedChangesDialog();
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: _buildAppBar(context),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: _buildResponsiveLayout(context, categoriesAsync, isMobile, isTablet),
              ),
            ],
          ),
        ),
        bottomSheet: _buildBottomActions(context),
      ),
    );
  }

  Widget _buildResponsiveLayout(
    BuildContext context, 
    AsyncValue<List<Category>> categoriesAsync,
    bool isMobile,
    bool isTablet,
  ) {
    final maxWidth = isMobile ? double.infinity : (isTablet ? 600.0 : 800.0);
    
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? AppConstants.spacingL : AppConstants.spacingXl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBasicInformationSection(context, categoriesAsync),
              SizedBox(height: AppConstants.spacingXl),
              _buildSchedulingSection(context),
              SizedBox(height: AppConstants.spacingXl),
              _buildDetailsSection(context),
              SizedBox(height: AppConstants.spacingXl),
              _buildSubtasksSection(context),
              const SizedBox(height: AppConstants.spacingXxxl * 2), // Space for bottom buttons
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final isEditing = widget.todoId != null;
    
    return AppBar(
      title: Text(isEditing ? 'Edit Todo' : 'Add Todo'),
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () {
          if (_hasUnsavedChanges) {
            _showUnsavedChangesDialog();
          } else {
            _exitScreen();
          }
        },
      ),
      actions: [
        Consumer(
          builder: (context, ref, child) {
            final themeMode = ref.watch(themeNotifierProvider);
            final isDarkMode = themeMode == ThemeMode.dark;
            
            return IconButton(
              icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: () {
                ref.read(themeNotifierProvider.notifier).toggleTheme();
              },
              tooltip: isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            );
          },
        ),
        if (isEditing)
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              HapticFeedback.mediumImpact();
              _showDeleteConfirmation();
            },
          ),
        const SizedBox(width: AppConstants.spacingS),
        FilledButton(
          onPressed: _canSave() ? () {
            HapticFeedback.lightImpact();
            _saveTodo();
          } : null,
          child: const Text('Save'),
        ),
        const SizedBox(width: AppConstants.spacingL),
      ],
    );
  }

  Widget _buildBasicInformationSection(BuildContext context, AsyncValue<List<Category>> categoriesAsync) {
    final isMobile = AppSizing.isMobile(context);
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? AppConstants.spacingL : AppConstants.spacingXl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: colorScheme.primary,
                  size: isMobile ? AppConstants.iconM : AppConstants.iconL,
                ),
                SizedBox(width: AppConstants.spacingM),
                Text(
                  'Basic Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: isMobile ? 18 : 20,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppConstants.spacingL),
            
            // Title Field
            Semantics(
              label: 'Todo title input field',
              child: TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Todo title',
                  hintText: 'What needs to be done?',
                  prefixIcon: Icon(Icons.title, size: isMobile ? AppConstants.iconM : AppConstants.iconL),
                  suffixText: '${_titleController.text.length}/100',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    borderSide: BorderSide(color: colorScheme.primary, width: 2),
                  ),
                  errorText: _titleController.text.isEmpty && _hasUnsavedChanges 
                      ? 'Title is required' 
                      : null,
                ),
                maxLength: 100,
                style: TextStyle(fontSize: isMobile ? 16 : 18),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
                onChanged: (value) => setState(() {}),
              ),
            ),
            SizedBox(height: AppConstants.spacingL),
            
            // Category Selection
            categoriesAsync.when(
              data: (categories) => _buildCategoryDropdown(context, categories, isMobile),
              loading: () => _buildCategoryLoadingSkeleton(context, isMobile),
              error: (error, stack) => _buildCategoryErrorState(context, isMobile),
            ),
            
            // Priority Selection
            SizedBox(height: AppConstants.spacingL),
            _buildPrioritySelector(context, isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(BuildContext context, List<Category> categories, bool isMobile) {
    final colorScheme = Theme.of(context).colorScheme;
    
    if (_selectedCategoryId == null && categories.isNotEmpty) {
      _selectedCategoryId = categories.first.id;
    }
    
    return Semantics(
      label: 'Category selection dropdown',
      child: DropdownButtonFormField<String>(
        initialValue: _selectedCategoryId,
        decoration: InputDecoration(
          labelText: 'Category',
          prefixIcon: Icon(Icons.category, size: isMobile ? AppConstants.iconM : AppConstants.iconL),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
            borderSide: BorderSide(color: colorScheme.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
        ),
        style: TextStyle(
          fontSize: isMobile ? 16 : 18,
          color: colorScheme.onSurface,
        ),
        items: categories.map((category) {
          return DropdownMenuItem(
            value: category.id,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: isMobile ? 16 : 20,
                  height: isMobile ? 16 : 20,
                  decoration: AppDecorations.categoryIndicatorDecoration(
                    parseHexColor(category.colorCode, fallback: Theme.of(context).colorScheme.primary),
                  ),
                ),
                SizedBox(width: AppConstants.spacingM),
                Flexible(
                  child: Text(
                    category.name,
                    style: TextStyle(fontSize: isMobile ? 16 : 18),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedCategoryId = value;
            _onFormChanged();
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a category';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildCategoryLoadingSkeleton(BuildContext context, bool isMobile) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      height: isMobile ? 56 : 64,
      decoration: AppDecorations.formFieldSkeletonDecoration(colorScheme),
      child: Row(
        children: [
          SizedBox(width: AppConstants.spacingM),
          Icon(Icons.category, color: colorScheme.onSurfaceVariant),
          SizedBox(width: AppConstants.spacingL),
          Expanded(
            child: Container(
              height: 16,
              decoration: AppDecorations.loadingContentDecoration(colorScheme),
            ),
          ),
          SizedBox(width: AppConstants.spacingM),
        ],
      ),
    );
  }

  Widget _buildCategoryErrorState(BuildContext context, bool isMobile) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      height: isMobile ? 56 : 64,
      decoration: AppDecorations.formFieldErrorDecoration(colorScheme),
      child: Center(
        child: Text(
          'Failed to load categories',
          style: TextStyle(
            color: colorScheme.error,
            fontSize: isMobile ? 14 : 16,
          ),
        ),
      ),
    );
  }

  Widget _buildPrioritySelector(BuildContext context, bool isMobile) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.flag_outlined,
              color: colorScheme.onSurfaceVariant,
              size: isMobile ? AppConstants.iconM : AppConstants.iconL,
            ),
            SizedBox(width: AppConstants.spacingM),
            Text(
              'Priority',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: isMobile ? 16 : 18,
              ),
            ),
          ],
        ),
        SizedBox(height: AppConstants.spacingM),
        Wrap(
          spacing: AppConstants.spacingM,
          runSpacing: AppConstants.spacingS,
          children: Priority.values.map((priority) {
            final isSelected = _selectedPriority == priority;
            final priorityColor = _getPriorityColor(priority, colorScheme);
            
            return Semantics(
              label: '${priority.name} priority',
              selected: isSelected,
              button: true,
              child: FilterChip(
                selected: isSelected,
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getPriorityIcon(priority),
                      size: isMobile ? 16 : 18,
                      color: isSelected ? colorScheme.onPrimary : priorityColor,
                    ),
                    SizedBox(width: AppConstants.spacingS),
                    Text(
                      priority.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? colorScheme.onPrimary : priorityColor,
                      ),
                    ),
                  ],
                ),
                backgroundColor: colorScheme.surface,
                selectedColor: priorityColor,
                side: BorderSide(
                  color: isSelected ? priorityColor : colorScheme.outline,
                  width: isSelected ? 2 : 1,
                ),
                onSelected: (selected) {
                  if (selected) {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selectedPriority = priority;
                      _onFormChanged();
                    });
                  }
                },
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getPriorityColor(Priority priority, ColorScheme colorScheme) {
    switch (priority) {
      case Priority.low:
  return colorScheme.success;
      case Priority.medium:
  return colorScheme.warning;
      case Priority.high:
  return colorScheme.error;
    }
  }

  IconData _getPriorityIcon(Priority priority) {
    switch (priority) {
      case Priority.low:
        return Icons.flag_outlined;
      case Priority.medium:
        return Icons.flag;
      case Priority.high:
        return Icons.priority_high;
    }
  }

  Widget _buildSchedulingSection(BuildContext context) {
    final isMobile = AppSizing.isMobile(context);
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? AppConstants.spacingL : AppConstants.spacingXl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: colorScheme.primary,
                  size: isMobile ? AppConstants.iconM : AppConstants.iconL,
                ),
                SizedBox(width: AppConstants.spacingM),
                Text(
                  'Schedule',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: isMobile ? 18 : 20,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppConstants.spacingL),
            
            // Due Date
            Semantics(
              label: 'Due date selection',
              button: true,
              child: InkWell(
                onTap: () => _selectDueDate(context),
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Due date (optional)',
                    prefixIcon: Icon(Icons.calendar_today, size: isMobile ? AppConstants.iconM : AppConstants.iconL),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      borderSide: BorderSide(color: colorScheme.outline),
                    ),
                  ),
                  child: Text(
                    _selectedDueDate != null 
                        ? '${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}'
                        : 'No date set',
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      color: _selectedDueDate != null 
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: AppConstants.spacingM),
            
            // Quick Date Options
            Wrap(
              spacing: AppConstants.spacingS,
              runSpacing: AppConstants.spacingS,
              children: [
                _buildQuickDateChip('Today', DateTime.now()),
                _buildQuickDateChip('Tomorrow', DateTime.now().add(const Duration(days: 1))),
                _buildQuickDateChip('This Weekend', _getNextWeekend()),
                _buildQuickDateChip('Next Week', DateTime.now().add(const Duration(days: 7))),
              ],
            ),
            SizedBox(height: AppConstants.spacingL),
            
            // Due Time
            Semantics(
              label: 'Due time selection',
              button: true,
              enabled: _selectedDueDate != null,
              child: InkWell(
                onTap: _selectedDueDate != null ? () => _selectDueTime(context) : null,
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Due time (optional)',
                    prefixIcon: Icon(Icons.access_time, size: isMobile ? AppConstants.iconM : AppConstants.iconL),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      borderSide: BorderSide(
                        color: _selectedDueDate != null ? colorScheme.outline : colorScheme.outline.withValues(alpha: 0.5),
                      ),
                    ),
                    enabled: _selectedDueDate != null,
                  ),
                  child: Text(
                    _selectedDueTime != null 
                        ? _selectedDueTime!.format(context)
                        : _selectedDueDate != null 
                            ? 'No time set' 
                            : 'Select a date first',
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      color: _selectedDueTime != null 
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
            
            if (_selectedDueDate != null) ...[
              SizedBox(height: AppConstants.spacingM),
              Row(
                children: [
                  Icon(
                    Icons.clear,
                    size: AppConstants.iconS,
                    color: colorScheme.error,
                  ),
                  SizedBox(width: AppConstants.spacingS),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedDueDate = null;
                        _selectedDueTime = null;
                        _onFormChanged();
                      });
                    },
                    child: Text(
                      'Clear date and time',
                      style: TextStyle(
                        color: colorScheme.error,
                        fontSize: isMobile ? 14 : 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: AppConstants.spacingS),
            Expanded(child: Divider(color: Theme.of(context).colorScheme.outline)),
          ],
        ),
        const SizedBox(height: AppConstants.spacingL),
        
        TextFormField(
          controller: _descriptionController,
          decoration: InputDecoration(
            labelText: 'Description (optional)',
            hintText: 'Add more details about this todo...',
            prefixIcon: const Icon(Icons.description),
            suffixText: '${_descriptionController.text.length}/300',
            border: const OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          maxLines: 4,
          maxLength: 300,
          onChanged: (value) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildSubtasksSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Subtasks',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: AppConstants.spacingS),
            Expanded(child: Divider(color: Theme.of(context).colorScheme.outline)),
            OutlinedButton.icon(
              onPressed: _addSubtask,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Subtask'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingS,
                  vertical: AppConstants.spacingXs,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingL),
        
        if (_subtaskTexts.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingXl),
            decoration: AppDecorations.emptyStateDecoration(Theme.of(context).colorScheme),
            child: Column(
              children: [
                Icon(Icons.checklist, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(height: AppConstants.spacingS),
                Text(
                  'No subtasks added',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                ),
                const SizedBox(height: AppConstants.spacingXs),
                Text(
                  'Break down your todo into smaller steps',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12),
                ),
              ],
            ),
          )
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _subtaskTexts.length,
            onReorder: _reorderSubtasks,
            buildDefaultDragHandles: false,
            itemBuilder: (context, index) {
              return Card(
                key: ValueKey(index),
                margin: const EdgeInsets.only(bottom: AppConstants.spacingS),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingM,
                    vertical: AppConstants.spacingS,
                  ),
                  child: Row(
                    children: [
                      ReorderableDragStartListener(
                        index: index,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingL),
                          child: Icon(
                            Icons.drag_handle,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingXxxl),
                      Expanded(
                        child: TextFormField(
                          controller: _subtaskControllers[index],
                          decoration: const InputDecoration(
                            hintText: 'Subtask description',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          maxLength: 50,
                          onChanged: (value) {
                            _subtaskTexts[index] = value;
                            _onFormChanged();
                          },
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingXxxl),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          _removeSubtask(index);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    final isEditing = widget.todoId != null;
    
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      decoration: AppDecorations.bottomActionBarDecoration(Theme.of(context).colorScheme),
      child: SafeArea(
        child: Row(
          children: [
            if (isEditing) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    _showDeleteConfirmation();
                  },
                  icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                  label: Text('Delete Todo', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Theme.of(context).colorScheme.error),
                    padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingM),
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.spacingM),
            ],
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: _canSave()
                    ? () {
                        HapticFeedback.mediumImpact();
                        _saveTodo();
                      }
                    : null,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingM),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : Text(isEditing ? 'Update Todo' : 'Save Todo'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickDateChip(String label, DateTime date) {
    final isSelected = _selectedDueDate != null &&
        _selectedDueDate!.year == date.year &&
        _selectedDueDate!.month == date.month &&
        _selectedDueDate!.day == date.day;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedDueDate = selected ? date : null;
          if (!selected) _selectedDueTime = null;
          _onFormChanged();
        });
      },
    );
  }

  // Helper Methods
  // removed duplicate _parseColor; using parseHexColor from color_utils.dart

  DateTime _getNextWeekend() {
    final now = DateTime.now();
    final daysUntilSaturday = 6 - now.weekday;
    return now.add(Duration(days: daysUntilSaturday));
  }

  bool _canSave() {
    return _titleController.text.trim().isNotEmpty && 
           _selectedCategoryId != null && 
           !_isLoading;
  }

  void _addSubtask() {
    setState(() {
      _subtaskTexts.add('');
      final controller = TextEditingController();
      controller.addListener(_onFormChanged);
      _subtaskControllers.add(controller);
      _onFormChanged();
    });
  }

  void _removeSubtask(int index) {
    setState(() {
      _subtaskTexts.removeAt(index);
      _subtaskControllers[index].dispose();
      _subtaskControllers.removeAt(index);
      _onFormChanged();
    });
  }

  void _reorderSubtasks(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      
      final text = _subtaskTexts.removeAt(oldIndex);
      _subtaskTexts.insert(newIndex, text);
      
      final controller = _subtaskControllers.removeAt(oldIndex);
      _subtaskControllers.insert(newIndex, controller);
      
      _onFormChanged();
    });
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      setState(() {
        _selectedDueDate = date;
        _onFormChanged();
      });
    }
  }

  Future<void> _selectDueTime(BuildContext context) async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedDueTime ?? TimeOfDay.now(),
    );
    
    if (time != null) {
      setState(() {
        _selectedDueTime = time;
        _onFormChanged();
      });
    }
  }

  Future<void> _saveTodo() async {
    if (!_formKey.currentState!.validate() || !_canSave()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Combine date and time
      DateTime? combinedDateTime;
      if (_selectedDueDate != null) {
        if (_selectedDueTime != null) {
          combinedDateTime = DateTime(
            _selectedDueDate!.year,
            _selectedDueDate!.month,
            _selectedDueDate!.day,
            _selectedDueTime!.hour,
            _selectedDueTime!.minute,
          );
        } else {
          combinedDateTime = _selectedDueDate;
        }
      }

      // Create subtasks
      final subtasks = _subtaskTexts
          .where((text) => text.trim().isNotEmpty)
          .map((text) => Subtask.create(
                title: text.trim(),
                parentTodoId: widget.todoId ?? '',
              ))
          .toList();

      if (widget.todoId != null && _originalTodo != null) {
        // Update existing todo
        final updatedTodo = _originalTodo!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty 
              ? null 
              : _descriptionController.text.trim(),
          categoryId: _selectedCategoryId!,
          priority: _selectedPriority,
          dueDate: _selectedDueDate,
          dueTime: combinedDateTime,
          subtasks: subtasks,
        );

        await ref.read(todoNotifierProvider.notifier).updateTodo(updatedTodo);
      } else {
        // Create new todo
        final newTodo = Todo.create(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty 
              ? null 
              : _descriptionController.text.trim(),
          categoryId: _selectedCategoryId!,
          priority: _selectedPriority,
          dueDate: _selectedDueDate,
          dueTime: combinedDateTime,
        );

        // Add subtasks to the new todo
        final todoWithSubtasks = subtasks.fold(
          newTodo,
          (todo, subtask) => todo.addSubtask(subtask.copyWith(parentTodoId: todo.id)),
        );

        await ref.read(todoNotifierProvider.notifier).addTodo(todoWithSubtasks);
      }

      setState(() {
        _hasUnsavedChanges = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.todoId != null 
                ? 'Todo updated successfully!' 
                : 'Todo created successfully!'),
          ),
        );
        _exitScreen();
      }
    } catch (e) {
      if (mounted) {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving todo: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
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

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Todo'),
        content: const Text('Are you sure you want to delete this todo? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.of(context).pop();
              await ref.read(todoNotifierProvider.notifier).deleteTodo(widget.todoId!);
              if (mounted) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Todo deleted successfully!')),
                );
                _exitScreen();
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showUnsavedChangesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text('You have unsaved changes. What would you like to do?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _hasUnsavedChanges = false;
              });
              _exitScreen();
            },
            child: const Text('Discard'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _saveTodo();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _exitScreen() {
    // Prefer GoRouter's canPop to avoid "nothing to pop" errors when the route
    // was opened with context.go (no entry on the back stack).
    if (context.canPop()) {
      context.pop();
      return;
    }
    // Fallback to Navigator in case of nested navigators/dialog contexts.
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }
    // As a last resort, navigate to home.
    context.go('/home');
  }
}