import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/app_bottom_navigation.dart';
import '../../shared/widgets/enhanced_components.dart';
import '../../shared/utils/color_utils.dart';
import '../../shared/constants/app_constants.dart';
import '../../core/providers/providers.dart';
import '../../core/models/models.dart';

class TodoListScreen extends ConsumerStatefulWidget {
  final String? filterByCategoryId;
  final String? initialFilter;
  
  const TodoListScreen({super.key, this.filterByCategoryId, this.initialFilter});

  @override
  ConsumerState<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends ConsumerState<TodoListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchExpanded = false;
  final Set<String> _selectedTodos = <String>{};
  bool _isMultiSelectMode = false;
  final Map<String, bool> _expandedTodos = <String, bool>{};

  @override
  void initState() {
    super.initState();
    
    // Set filters if provided from navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.filterByCategoryId != null) {
        ref.read(filterStateProvider.notifier).updateCategoryFilter(widget.filterByCategoryId);
      }
      
      if (widget.initialFilter != null) {
        String filterType;
        switch (widget.initialFilter) {
          case 'today':
            filterType = 'Today';
            break;
          case 'completed':
            filterType = 'Completed';
            break;
          case 'pending':
            filterType = 'Overdue';
            break;
          case 'overdue':
            filterType = 'Overdue';
            break;
          default:
            filterType = 'All';
            break;
        }
        ref.read(filterStateProvider.notifier).updateFilter(filterType);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _isMultiSelectMode ? _buildMultiSelectAppBar(context) : _buildTopAppBar(context),
      body: Column(
        children: [
          _buildFilterChips(context),
          if (_isSearchExpanded) _buildSearchBar(context),
          _buildSortSection(context),
          Expanded(child: _buildTodoList(context)),
        ],
      ),
      floatingActionButton: _isMultiSelectMode ? null : FloatingActionButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          context.go('/add-todo');
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: _isMultiSelectMode 
          ? _buildMultiSelectBottomBar(context) 
          : const AppBottomNavigation(),
    );
  }

  PreferredSizeWidget _buildTopAppBar(BuildContext context) {
    return AppBar(
      title: const Text('All Todos'),
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 1,
      actions: [
        IconButton(
          icon: Icon(_isSearchExpanded ? Icons.search_off : Icons.search),
          onPressed: () {
            HapticFeedback.selectionClick();
            setState(() {
              _isSearchExpanded = !_isSearchExpanded;
              if (!_isSearchExpanded) {
                _searchController.clear();
                ref.read(filterStateProvider.notifier).updateSearch('');
              }
            });
          },
        ),
  // Removed extra filter dialog to avoid duplicated, confusing filter UX
        Consumer(
          builder: (context, ref, child) {
            final themeMode = ref.watch(themeNotifierProvider);
            final isDarkMode = themeMode == ThemeMode.dark;
            
            return IconButton(
              icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: () {
                HapticFeedback.selectionClick();
                ref.read(themeNotifierProvider.notifier).toggleTheme();
              },
              tooltip: isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            );
          },
        ),
      ],
    );
  }

  PreferredSizeWidget _buildMultiSelectAppBar(BuildContext context) {
    return AppBar(
      title: Text('${_selectedTodos.length} selected'),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () {
          HapticFeedback.selectionClick();
          setState(() {
            _isMultiSelectMode = false;
            _selectedTodos.clear();
          });
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.select_all),
          onPressed: () {
            HapticFeedback.selectionClick();
            _selectAllTodos();
          },
        ),
      ],
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    final todosAsync = ref.watch(todoNotifierProvider);
    final filterState = ref.watch(filterStateProvider);
    
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingL, vertical: AppConstants.spacingS),
      child: todosAsync.when(
        data: (todos) {
          
          // Use time-aware helpers on Todo to compute counts
          final todayCount = todos.where((todo) {
            if (todo.dueDate == null || todo.isCompleted) return false;
            return todo.isDueToday && !todo.isOverdue;
          }).length;

          final overdueCount = todos.where((todo) => todo.isOverdue).length;
          
          final completedCount = todos.where((todo) => todo.isCompleted).length;
          
          final filters = [
            {'name': 'All', 'count': todos.length},
            {'name': 'Today', 'count': todayCount},
            {'name': 'Overdue', 'count': overdueCount},
            {'name': 'Completed', 'count': completedCount},
          ];
          
          return ListView(
            scrollDirection: Axis.horizontal,
            children: filters.map((filter) {
              final isSelected = filterState.selectedFilter == filter['name'];
              return Padding(
                padding: const EdgeInsets.only(right: AppConstants.spacingS),
                child: FilterChip(
                  label: Text('${filter['name']} (${filter['count']})'),
                  selected: isSelected,
                  onSelected: (selected) {
                    HapticFeedback.selectionClick();
                    ref.read(filterStateProvider.notifier).updateFilter(filter['name'] as String);
                  },
                  backgroundColor: isSelected ? Theme.of(context).colorScheme.primary : null,
                  selectedColor: Theme.of(context).colorScheme.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Theme.of(context).colorScheme.onPrimary : null,
                  ),
                ),
              );
            }).toList(),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => SelectableText.rich(
          TextSpan(
            text: 'Error loading todos: ${error.toString()}',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ),
    );
  }

  Widget _buildSortSection(BuildContext context) {
    final filterState = ref.watch(filterStateProvider);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingL, vertical: AppConstants.spacingS),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: filterState.sortBy,
              decoration: const InputDecoration(
                labelText: 'Sort by',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: AppConstants.spacingM, vertical: AppConstants.spacingS),
              ),
              items: ['Due Date', 'Priority', 'Created', 'Alphabetical'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                ref.read(filterStateProvider.notifier).updateSort(newValue!, filterState.sortAscending);
              },
            ),
          ),
          const SizedBox(width: AppConstants.spacingS),
          IconButton(
            icon: Icon(filterState.sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
            onPressed: () {
              HapticFeedback.selectionClick();
              ref.read(filterStateProvider.notifier).updateSort(filterState.sortBy, !filterState.sortAscending);
            },
            tooltip: filterState.sortAscending ? 'Ascending' : 'Descending',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingL, vertical: AppConstants.spacingS),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search todos...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              HapticFeedback.selectionClick();
              _searchController.clear();
              ref.read(filterStateProvider.notifier).updateSearch('');
            },
          ),
          border: const OutlineInputBorder(),
        ),
        onChanged: (query) {
          ref.read(filterStateProvider.notifier).updateSearch(query);
        },
      ),
    );
  }

  Widget _buildTodoList(BuildContext context) {
    final filteredTodosAsync = ref.watch(filteredTodosProvider);
    final categoriesAsync = ref.watch(categoryNotifierProvider);

    return filteredTodosAsync.when(
      data: (todos) => categoriesAsync.when(
        data: (categories) {
          if (todos.isEmpty) {
            return _buildEnhancedEmptyState(context);
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(todoNotifierProvider);
              ref.invalidate(categoryNotifierProvider);
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: _buildResponsiveTodoListView(context, todos, categories),
          );
        },
        loading: () => _buildTodoListLoadingSkeleton(context),
        error: (error, stack) => _buildEnhancedErrorState(context, 'Error loading categories: ${error.toString()}'),
      ),
      loading: () => _buildTodoListLoadingSkeleton(context),
      error: (error, stack) => _buildEnhancedErrorState(context, 'Error loading todos: ${error.toString()}'),
    );
  }

  Widget _buildResponsiveTodoListView(BuildContext context, List<Todo> todos, List<Category> categories) {
    final isMobile = AppSizing.isMobile(context);
    return ListView.builder(
      padding: EdgeInsets.all(isMobile ? AppConstants.spacingM : AppConstants.spacingL),
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        final category = categories.firstWhere(
          (c) => c.id == todo.categoryId,
          orElse: () => categories.first,
        );
        return KeyedSubtree(
          key: ValueKey(todo.id),
          child: _buildEnhancedTodoItem(context, todo, category),
        );
      },
    );
  }

  Widget _buildTodoListLoadingSkeleton(BuildContext context) {
    final isMobile = AppSizing.isMobile(context);
    return ListView.builder(
      padding: EdgeInsets.all(isMobile ? AppConstants.spacingM : AppConstants.spacingL),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: AppConstants.spacingM),
          child: _buildSkeletonTodoItem(context),
        );
      },
    );
  }

  Widget _buildSkeletonTodoItem(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = AppSizing.isMobile(context);
    return Semantics(
      label: 'Loading todo item',
      child: AnimatedContainer(
        duration: AppConstants.animationMedium,
        decoration: AppDecorations.cardDecoration(colorScheme),
        padding: EdgeInsets.all(AppConstants.spacingL),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Checkbox skeleton
            Container(
              width: AppConstants.iconL,
              height: AppConstants.iconL,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppConstants.radiusS),
              ),
            ),
            SizedBox(width: AppConstants.spacingM),
            // Priority indicator skeleton
            Container(
              width: 4,
              height: isMobile ? 40 : 50,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(width: AppConstants.spacingM),
            // Content skeleton
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: isMobile ? 16 : 18,
                    decoration: BoxDecoration(
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppConstants.radiusS),
                    ),
                  ),
                  SizedBox(height: AppConstants.spacingS),
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: isMobile ? 14 : 16,
                        decoration: BoxDecoration(
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppConstants.radiusS),
                        ),
                      ),
                      SizedBox(width: AppConstants.spacingS),
                      Container(
                        width: 50,
                        height: isMobile ? 12 : 14,
                        decoration: BoxDecoration(
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppConstants.radiusS),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Trailing date skeleton
            SizedBox(width: AppConstants.spacingM),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 70,
                  height: 12,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  ),
                ),
                SizedBox(height: AppConstants.spacingS),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = AppSizing.isMobile(context);
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? AppConstants.spacingXl : AppConstants.spacingXxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt_outlined,
              size: isMobile ? AppConstants.iconXxxl : 80,
              color: colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: AppConstants.spacingXl),
            Text(
              'No todos found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: AppConstants.spacingM),
            Text(
              'Create your first todo or adjust your filters',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppConstants.spacingXxl),
            FilledButton.icon(
              onPressed: () => context.go('/add-todo'),
              icon: const Icon(Icons.add),
              label: const Text('Add Todo'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedErrorState(BuildContext context, String errorMessage) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = AppSizing.isMobile(context);
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? AppConstants.spacingXl : AppConstants.spacingXxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: isMobile ? AppConstants.iconXxxl : 80,
              color: colorScheme.error,
            ),
            SizedBox(height: AppConstants.spacingXl),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: AppConstants.spacingM),
            SelectableText.rich(
              TextSpan(
                text: errorMessage,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.error,
                ),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppConstants.spacingXxl),
            FilledButton.icon(
              onPressed: () {
                ref.invalidate(todoNotifierProvider);
                ref.invalidate(categoryNotifierProvider);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods for UI components

  // Placeholder methods - will be implemented next
  Widget _buildEnhancedTodoItem(BuildContext context, Todo todo, Category category) {
    final isSelected = _selectedTodos.contains(todo.id);
    final isExpanded = _expandedTodos[todo.id] ?? false;
  final color = parseHexColor(category.colorCode, fallback: Theme.of(context).colorScheme.primary);
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = AppSizing.isMobile(context);
    
    return Semantics(
      label: '${todo.title} todo item',
      button: true,
      selected: isSelected,
      child: Padding(
        padding: EdgeInsets.only(bottom: AppConstants.spacingM),
        child: AnimatedContainer(
          duration: AppConstants.animationMedium,
          curve: Curves.easeInOut,
          decoration: AppDecorations.selectableCardDecoration(
            colorScheme,
            isSelected: isSelected,
          ),
          child: EnhancedMaterial(
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
            onTap: _isMultiSelectMode
                ? () {
                    HapticFeedback.selectionClick();
                    _toggleSelection(todo.id);
                  }
                : () {
                    HapticFeedback.lightImpact();
                    context.go('/edit-todo/${todo.id}');
                  },
            onLongPress: () {
              HapticFeedback.heavyImpact();
              _enableMultiSelectMode(todo.id);
            },
            child: Padding(
              padding: EdgeInsets.all(AppConstants.spacingL),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Multi-select checkbox or completion checkbox
                      _buildTodoCheckbox(context, todo, isSelected),
                      SizedBox(width: AppConstants.spacingM),
                      
                      // Priority indicator
                      _buildPriorityIndicator(context, todo, isMobile),
                      SizedBox(width: AppConstants.spacingM),
                      
                      // Content area
                      Expanded(
                        child: _buildTodoContent(context, todo, category, color, isExpanded, isMobile),
                      ),
                      
                      // Trailing area
                      _buildTodoTrailing(context, todo, isExpanded, isMobile),
                    ],
                  ),
                  
                  // Expanded subtasks
                  if (isExpanded && todo.subtasks.isNotEmpty)
                    _buildExpandedSubtasks(context, todo, isMobile),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTodoCheckbox(BuildContext context, Todo todo, bool isSelected) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Semantics(
      label: _isMultiSelectMode 
          ? (isSelected ? 'Selected for bulk action' : 'Not selected')
          : (todo.isCompleted ? 'Completed todo' : 'Incomplete todo'),
      button: true,
      child: GestureDetector(
        onTap: _isMultiSelectMode 
            ? () {
                HapticFeedback.selectionClick();
                _toggleSelection(todo.id);
              }
            : () {
                HapticFeedback.lightImpact();
                _toggleTodoCompletion(todo.id);
              },
        child: AnimatedContainer(
          duration: AppConstants.animationFast,
          width: AppConstants.iconL,
          height: AppConstants.iconL,
          decoration: AppDecorations.checkboxDecoration(
            _isMultiSelectMode
                ? (isSelected ? colorScheme.primary : colorScheme.outline)
                : (todo.isCompleted ? colorScheme.primary : colorScheme.outline),
            _isMultiSelectMode ? isSelected : todo.isCompleted,
          ),
          child: (_isMultiSelectMode ? isSelected : todo.isCompleted)
              ? Icon(
                  Icons.check,
                  color: colorScheme.onPrimary,
                  size: AppConstants.iconM,
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildPriorityIndicator(BuildContext context, Todo todo, bool isMobile) {
    return Container(
      width: 4,
      height: isMobile ? 40 : 50,
      decoration: AppDecorations.priorityIndicatorDecoration(todo.priority.color),
    );
  }

  Widget _buildTodoContent(BuildContext context, Todo todo, Category category, Color color, bool isExpanded, bool isMobile) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          todo.title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
            color: todo.isCompleted ? colorScheme.onSurfaceVariant : colorScheme.onSurface,
            fontWeight: FontWeight.w500,
            fontSize: isMobile ? 16 : 18,
          ),
          maxLines: isExpanded ? null : 2,
          overflow: isExpanded ? null : TextOverflow.ellipsis,
        ),
        
        SizedBox(height: AppConstants.spacingS),
        
        // Category and subtasks badges
        Row(
          children: [
            // Category badge
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppConstants.spacingS,
                vertical: AppConstants.spacingXs,
              ),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: Text(
                category.name,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                  fontSize: isMobile ? 11 : 12,
                ),
              ),
            ),
            
            SizedBox(width: AppConstants.spacingS),
            
            // Subtasks badge
            if (todo.subtasks.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingS,
                  vertical: AppConstants.spacingXs,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                child: Text(
                  '${todo.subtasks.where((s) => s.isCompleted).length}/${todo.subtasks.length}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                    fontSize: isMobile ? 10 : 11,
                  ),
                ),
              ),
          ],
        ),
        
        // Description (if exists and expanded or mobile)
        if (todo.description != null && todo.description!.isNotEmpty) ...[
          SizedBox(height: AppConstants.spacingS),
          Text(
            todo.description!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: isMobile ? 13 : 14,
            ),
            maxLines: isExpanded ? null : (isMobile ? 2 : 1),
            overflow: isExpanded ? null : TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildTodoTrailing(BuildContext context, Todo todo, bool isExpanded, bool isMobile) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Due date
        if (todo.dueDate != null)
          Text(
            todo.dueDateDisplay,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: todo.isOverdue ? colorScheme.error : colorScheme.onSurfaceVariant,
              fontWeight: todo.isOverdue ? FontWeight.w600 : FontWeight.normal,
              fontSize: isMobile ? 11 : 12,
            ),
          ),
        
        // Expand/collapse button
        if (todo.subtasks.isNotEmpty || (todo.description?.isNotEmpty == true))
          Padding(
            padding: EdgeInsets.only(top: AppConstants.spacingS),
            child: Semantics(
              label: isExpanded ? 'Collapse details' : 'Expand details',
              button: true,
              child: GestureDetector(
                onTap: () => _toggleExpansion(todo.id),
                child: Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  size: AppConstants.iconM,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildExpandedSubtasks(BuildContext context, Todo todo, bool isMobile) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: EdgeInsets.only(top: AppConstants.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(
            color: colorScheme.outline.withValues(alpha: 0.2),
            height: 1,
          ),
          SizedBox(height: AppConstants.spacingM),
          
          Text(
            'Subtasks',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
              fontSize: isMobile ? 13 : 14,
            ),
          ),
          SizedBox(height: AppConstants.spacingM),
          
          ...todo.subtasks.map((subtask) => Padding(
            padding: EdgeInsets.only(bottom: AppConstants.spacingS),
            child: Row(
              children: [
                Semantics(
                  label: subtask.isCompleted ? 'Completed subtask' : 'Incomplete subtask',
                  button: true,
                  child: GestureDetector(
                    onTap: () async {
                      await ref.read(todoNotifierProvider.notifier)
                          .toggleSubtaskCompletion(todo.id, subtask.id);
                    },
                    child: AnimatedContainer(
                      duration: AppConstants.animationFast,
                      width: AppConstants.iconM,
                      height: AppConstants.iconM,
                      decoration: BoxDecoration(
                        color: subtask.isCompleted ? colorScheme.primary : Colors.transparent,
                        border: Border.all(
                          color: subtask.isCompleted 
                              ? colorScheme.primary 
                              : colorScheme.outline,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(AppConstants.radiusS),
                      ),
                      child: subtask.isCompleted
                          ? Icon(
                              Icons.check,
                              color: colorScheme.onPrimary,
                              size: AppConstants.iconS,
                            )
                          : null,
                    ),
                  ),
                ),
                SizedBox(width: AppConstants.spacingM),
                Expanded(
                  child: Text(
                    subtask.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      decoration: subtask.isCompleted ? TextDecoration.lineThrough : null,
                      color: subtask.isCompleted ? colorScheme.onSurfaceVariant : colorScheme.onSurface,
                      fontSize: isMobile ? 13 : 14,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // Helper methods for interactions
  void _toggleSelection(String todoId) {
    setState(() {
      if (_selectedTodos.contains(todoId)) {
        _selectedTodos.remove(todoId);
        if (_selectedTodos.isEmpty) {
          _isMultiSelectMode = false;
        }
      } else {
        _selectedTodos.add(todoId);
      }
    });
  }

  void _enableMultiSelectMode(String todoId) {
    setState(() {
      _isMultiSelectMode = true;
      _selectedTodos.add(todoId);
    });
  }

  void _toggleExpansion(String todoId) {
    setState(() {
      _expandedTodos[todoId] = !(_expandedTodos[todoId] ?? false);
    });
  }

  Widget _buildMultiSelectBottomBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
  padding: const EdgeInsets.all(AppConstants.spacingL),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            onPressed: _selectedTodos.isEmpty ? null : _bulkToggleCompletion,
            icon: const Icon(Icons.check_circle),
            label: const Text('Toggle'),
          ),
          ElevatedButton.icon(
            onPressed: _selectedTodos.isEmpty ? null : _bulkDelete,
            icon: const Icon(Icons.delete),
            label: const Text('Delete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
          ),
        ],
      ),
    );
  }

  // removed duplicate _parseColor; using parseHexColor from color_utils.dart

  Future<void> _toggleTodoCompletion(String todoId) async {
    await ref.read(todoNotifierProvider.notifier).toggleTodoCompletion(todoId);
  }

  void _selectAllTodos() {
    final filteredTodosAsync = ref.read(filteredTodosProvider);
    filteredTodosAsync.whenData((filteredTodos) {
      setState(() {
        if (_selectedTodos.length == filteredTodos.length) {
          _selectedTodos.clear();
          _isMultiSelectMode = false;
        } else {
          _selectedTodos.clear();
          _selectedTodos.addAll(filteredTodos.map((t) => t.id));
        }
      });
    });
  }

  Future<void> _bulkToggleCompletion() async {
    try {
      for (final todoId in _selectedTodos) {
        await ref.read(todoNotifierProvider.notifier).toggleTodoCompletion(todoId);
      }
      setState(() {
        _selectedTodos.clear();
        _isMultiSelectMode = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Todos updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating todos: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _bulkDelete() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Todos'),
        content: Text('Are you sure you want to delete ${_selectedTodos.length} todos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (shouldDelete == true) {
      try {
        for (final todoId in _selectedTodos) {
          await ref.read(todoNotifierProvider.notifier).deleteTodo(todoId);
        }
        setState(() {
          _selectedTodos.clear();
          _isMultiSelectMode = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Todos deleted successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          HapticFeedback.heavyImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting todos: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  // Filter dialog removed
}
