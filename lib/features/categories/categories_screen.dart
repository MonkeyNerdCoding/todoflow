import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/app_bottom_navigation.dart';
import '../../shared/widgets/enhanced_components.dart';
import '../../shared/constants/app_constants.dart';
import '../../core/providers/providers.dart';
import '../../core/models/models.dart';
import '../../shared/utils/color_utils.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchExpanded = false;
  String _searchQuery = '';

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
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          if (_isSearchExpanded) _buildSearchBar(context),
          _buildDragToReorderHint(context),
          Expanded(child: _buildCategoriesList(context)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          _showAddCategoryDialog(context);
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const AppBottomNavigation(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Categories'),
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
                _searchQuery = '';
              }
            });
          },
        ),
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

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingL, vertical: AppConstants.spacingS),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search categories...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              HapticFeedback.selectionClick();
              _searchController.clear();
              setState(() {
                _searchQuery = '';
              });
            },
          ),
          border: const OutlineInputBorder(),
        ),
        onChanged: (query) {
          setState(() {
            _searchQuery = query;
          });
        },
      ),
    );
  }

  Widget _buildDragToReorderHint(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingL, vertical: AppConstants.spacingS),
      child: Row(
        children: [
          Icon(
            Icons.drag_indicator,
            size: AppConstants.iconS,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppConstants.spacingS),
          Text(
            'Drag to reorder',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList(BuildContext context) {
    final categoriesAsync = ref.watch(categoryNotifierProvider);
    final todosAsync = ref.watch(todoNotifierProvider);

    return categoriesAsync.when(
      data: (categories) => todosAsync.when(
        data: (todos) {
          // Filter categories based on search
          final filteredCategories = categories.where((category) {
            if (_searchQuery.isEmpty) return category.isActive;
            return category.isActive && 
                   category.name.toLowerCase().contains(_searchQuery);
          }).toList();

          final archivedCategories = categories.where((c) => !c.isActive).toList();

          // Calculate todo counts for each category
          final categoryTodoCounts = <String, Map<String, int>>{};
          for (final category in categories) {
            final categoryTodos = todos.where((t) => t.categoryId == category.id).toList();
            final completedTodos = categoryTodos.where((t) => t.isCompleted).length;
            categoryTodoCounts[category.id] = {
              'total': categoryTodos.length,
              'completed': completedTodos,
            };
          }

          if (filteredCategories.isEmpty && _searchQuery.isNotEmpty) {
            return _buildEnhancedNoSearchResults(context);
          }

          if (filteredCategories.isEmpty && _searchQuery.isEmpty) {
            return _buildEnhancedEmptyState(context);
          }

          return _buildResponsiveCategoriesView(context, filteredCategories, archivedCategories, categoryTodoCounts);
        },
        loading: () => _buildCategoriesLoadingSkeleton(context),
        error: (error, stack) => _buildEnhancedErrorState(context, 'Error loading todos: ${error.toString()}'),
      ),
      loading: () => _buildCategoriesLoadingSkeleton(context),
      error: (error, stack) => _buildEnhancedErrorState(context, 'Error loading categories: ${error.toString()}'),
    );
  }

  Widget _buildResponsiveCategoriesView(
    BuildContext context, 
    List<Category> filteredCategories, 
    List<Category> archivedCategories, 
    Map<String, Map<String, int>> categoryTodoCounts,
  ) {
    final isMobile = AppSizing.isMobile(context);
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? AppConstants.spacingM : AppConstants.spacingL),
      child: Column(
        children: [
          // Active Categories List
          _buildActiveCategories(context, filteredCategories, categoryTodoCounts),
          
          // Archived Categories Section
          if (archivedCategories.isNotEmpty) ...[
            SizedBox(height: AppConstants.spacingXl),
            _buildEnhancedArchivedSection(context, archivedCategories),
          ],
          
          SizedBox(height: 100), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildActiveCategories(
    BuildContext context, 
    List<Category> categories, 
    Map<String, Map<String, int>> categoryTodoCounts,
  ) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      onReorder: (oldIndex, newIndex) async {
        await ref
            .read(categoryNotifierProvider.notifier)
            .reorderActiveCategories(oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        final category = categories[index];
        final counts = categoryTodoCounts[category.id] ?? {'total': 0, 'completed': 0};
        
        return Container(
          key: ValueKey(category.id),
          child: _buildEnhancedCategoryItem(
            context,
            index: index,
            category: category,
            totalTodos: counts['total']!,
            completedTodos: counts['completed']!,
          ),
        );
      },
    );
  }

  Widget _buildCategoriesLoadingSkeleton(BuildContext context) {
    final isMobile = AppSizing.isMobile(context);
    
    return ListView.builder(
      padding: EdgeInsets.all(isMobile ? AppConstants.spacingM : AppConstants.spacingL),
      itemCount: 6, // Show 6 skeleton categories
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: AppConstants.spacingM),
          child: _buildSkeletonCategoryItem(context),
        );
      },
    );
  }

  Widget _buildSkeletonCategoryItem(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = AppSizing.isMobile(context);
    
    return Semantics(
      label: 'Loading category item',
      child: AnimatedContainer(
        duration: AppConstants.animationMedium,
        decoration: AppDecorations.cardDecoration(colorScheme),
        padding: EdgeInsets.all(AppConstants.spacingL),
        child: Row(
          children: [
            // Icon skeleton
            Container(
              width: isMobile ? AppConstants.iconXl : AppConstants.iconXxl,
              height: isMobile ? AppConstants.iconXl : AppConstants.iconXxl,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppConstants.radiusS),
              ),
            ),
            SizedBox(width: AppConstants.spacingL),
            
            // Content area skeleton
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title skeleton
                  Container(
                    width: double.infinity,
                    height: isMobile ? 18 : 20,
                    decoration: BoxDecoration(
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppConstants.radiusS),
                    ),
                  ),
                  SizedBox(height: AppConstants.spacingS),
                  
                  // Description skeleton
                  Container(
                    width: double.infinity * 0.7,
                    height: isMobile ? 14 : 16,
                    decoration: BoxDecoration(
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppConstants.radiusS),
                    ),
                  ),
                ],
              ),
            ),
            
            // Trailing info skeleton
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 40,
                  height: 14,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  ),
                ),
                SizedBox(height: AppConstants.spacingS),
                Container(
                  width: 60,
                  height: 12,
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
              Icons.folder_outlined,
              size: isMobile ? AppConstants.iconXxxl : 80,
              color: colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: AppConstants.spacingXl),
            Text(
              'No categories yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: AppConstants.spacingM),
            Text(
              'Create your first category to organize your todos',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppConstants.spacingXxl),
            FilledButton.icon(
              onPressed: () => _showAddCategoryDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Category'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedNoSearchResults(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = AppSizing.isMobile(context);
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? AppConstants.spacingXl : AppConstants.spacingXxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: isMobile ? AppConstants.iconXxxl : 80,
              color: colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: AppConstants.spacingXl),
            Text(
              'No results found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: AppConstants.spacingM),
            Text(
              'Try adjusting your search or create a new category',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppConstants.spacingXxl),
            FilledButton.icon(
              onPressed: () => _showAddCategoryDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Category'),
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
                ref.invalidate(categoryNotifierProvider);
                ref.invalidate(todoNotifierProvider);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedCategoryItem(
    BuildContext context, {
    required int index,
    required Category category,
    required int totalTodos,
    required int completedTodos,
  }) {
  final color = parseHexColor(category.colorCode, fallback: Theme.of(context).colorScheme.primary);
    final iconData = _getIconData(category.iconName);
    final lastUsed = _getLastUsedText(category.createdAt);
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = AppSizing.isMobile(context);

    return Semantics(
      label: '${category.name} category with $totalTodos todos',
      button: true,
      child: Padding(
        padding: EdgeInsets.only(bottom: AppConstants.spacingM),
        child: Dismissible(
          key: Key('dismissible_${category.id}'),
          background: _buildSwipeBackground(context, true),
          secondaryBackground: _buildSwipeBackground(context, false),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              HapticFeedback.selectionClick();
              _showEditCategoryDialog(context, category);
              return false;
            } else {
              final confirmed = await _showDeleteConfirmation(context, category);
              if (confirmed) {
                HapticFeedback.heavyImpact();
              }
              return confirmed;
            }
          },
          child: EnhancedMaterial(
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
            onTap: () {
              HapticFeedback.lightImpact();
              context.go('/todos/category/${category.id}');
            },
            child: AnimatedContainer(
                duration: AppConstants.animationMedium,
                decoration: AppDecorations.cardDecoration(colorScheme),
                padding: EdgeInsets.all(AppConstants.spacingL),
                child: Row(
                  children: [
                    // Drag Handle
                    Semantics(
                      label: 'Drag to reorder category',
                      child: ReorderableDragStartListener(
                        index: index,
                        child: Padding(
                          padding: EdgeInsets.only(right: AppConstants.spacingXl),
                          child: Transform.translate(
                            offset: const Offset(0, -6), // nudge up to better align with options button
                            child: Icon(
                              Icons.drag_indicator,
                              color: colorScheme.onSurfaceVariant,
                              size: AppConstants.iconL,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Category Icon
                    _buildCategoryIcon(context, iconData, color, isMobile),
                    SizedBox(width: AppConstants.spacingL),
                    
                    // Category Details
                    Expanded(
                      child: _buildCategoryDetails(context, category, totalTodos, completedTodos, lastUsed, isMobile),
                    ),
                    
                    // Add space before menu button
                    SizedBox(width: AppConstants.spacingXl),
                    
                    // More Options
                    _buildCategoryMenu(context, category),
                  ],
                ),
              ),
            ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(BuildContext context, bool isEdit) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      decoration: BoxDecoration(
        color: isEdit ? colorScheme.primary : colorScheme.error,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      alignment: isEdit ? Alignment.centerLeft : Alignment.centerRight,
      padding: EdgeInsets.symmetric(horizontal: AppConstants.spacingL),
      child: Row(
        mainAxisAlignment: isEdit ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (isEdit) ...[
            Icon(Icons.edit, color: colorScheme.onPrimary),
            SizedBox(width: AppConstants.spacingS),
            Text(
              'Edit',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ] else ...[
            Text(
              'Delete',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onError,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: AppConstants.spacingS),
            Icon(Icons.delete, color: colorScheme.onError),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryIcon(BuildContext context, IconData iconData, Color color, bool isMobile) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconSize = isMobile ? AppConstants.iconXl : AppConstants.iconXxl;
    final containerSize = isMobile ? 48.0 : 56.0;
    
    return AnimatedContainer(
      duration: AppConstants.animationMedium,
      width: containerSize,
      height: containerSize,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(containerSize / 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: AppConstants.elevationS,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Icon(
        iconData,
        color: colorScheme.onPrimary,
        size: iconSize,
      ),
    );
  }

  Widget _buildCategoryDetails(
    BuildContext context, 
    Category category, 
    int totalTodos, 
    int completedTodos, 
    String lastUsed, 
    bool isMobile,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Name
        Text(
          category.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: isMobile ? 16 : 18,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: AppConstants.spacingS),
        
        // Todo Count and Progress
        Row(
          children: [
            // Todo count badge
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppConstants.spacingS,
                vertical: AppConstants.spacingXs,
              ),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(AppConstants.radiusS),
              ),
              child: Text(
                '$totalTodos todos',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w500,
                  fontSize: isMobile ? 11 : 12,
                ),
              ),
            ),
            SizedBox(width: AppConstants.spacingS),
            
            // Completion badge
            if (totalTodos > 0)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingS,
                  vertical: AppConstants.spacingXs,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                ),
                child: Text(
                  '$completedTodos completed',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w500,
                    fontSize: isMobile ? 11 : 12,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: AppConstants.spacingXs),
        
        // Last Used
        Text(
          lastUsed,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontSize: isMobile ? 11 : 12,
          ),
        ),
        
        // Progress bar
        if (totalTodos > 0) ...[
          SizedBox(height: AppConstants.spacingS),
          LinearProgressIndicator(
            value: completedTodos / totalTodos,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            minHeight: 4,
          ),
        ],
      ],
    );
  }

  Widget _buildCategoryMenu(BuildContext context, Category category) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Semantics(
      label: 'More options for ${category.name}',
      button: true,
      child: Padding(
        padding: EdgeInsets.all(AppConstants.spacingL),
        child: PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: colorScheme.onSurfaceVariant,
            size: AppConstants.iconL,
          ),
          tooltip: 'Category options',
          padding: EdgeInsets.zero,
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showEditCategoryDialog(context, category);
                break;
              case 'archive':
                _archiveCategory(category);
                break;
              case 'duplicate':
                _duplicateCategory(category);
                break;
              case 'delete':
                _showDeleteConfirmation(context, category);
                break;
            }
          },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit, size: AppConstants.iconS),
                SizedBox(width: AppConstants.spacingM),
                const Text('Edit category'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'archive',
            child: Row(
              children: [
                Icon(Icons.archive, size: AppConstants.iconS),
                SizedBox(width: AppConstants.spacingM),
                const Text('Archive'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'duplicate',
            child: Row(
              children: [
                Icon(Icons.copy, size: AppConstants.iconS),
                SizedBox(width: AppConstants.spacingM),
                const Text('Duplicate category'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, size: AppConstants.iconS, color: colorScheme.error),
                SizedBox(width: AppConstants.spacingM),
                Text(
                  'Delete category',
                  style: TextStyle(color: colorScheme.error),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildEnhancedArchivedSection(BuildContext context, List<Category> archivedCategories) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = AppSizing.isMobile(context);
    
    if (archivedCategories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: AppConstants.spacingL),
        
        // Archived Section Header
        ExpansionTile(
          title: Text(
            'Archived Categories',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: isMobile ? 16 : 18,
            ),
          ),
          subtitle: Text(
            '${archivedCategories.length} archived',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: isMobile ? 12 : 13,
            ),
          ),
          leading: Icon(
            Icons.archive,
            color: colorScheme.onSurfaceVariant,
            size: AppConstants.iconM,
          ),
          tilePadding: EdgeInsets.symmetric(horizontal: AppConstants.spacingL),
          childrenPadding: EdgeInsets.only(
            top: AppConstants.spacingS,
            bottom: AppConstants.spacingM,
          ),
          children: [
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: archivedCategories.length,
              separatorBuilder: (context, index) => SizedBox(height: AppConstants.spacingS),
              itemBuilder: (context, index) {
                final category = archivedCategories[index];
                final todosInCategory = ref.read(todoNotifierProvider).value
                    ?.where((todo) => todo.categoryId == category.id)
                    .toList() ?? [];
                final totalTodos = todosInCategory.length;
                final completedTodos = todosInCategory
                    .where((todo) => todo.isCompleted)
                    .length;

                return _buildArchivedCategoryItem(
                  context,
                  category: category,
                  totalTodos: totalTodos,
                  completedTodos: completedTodos,
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildArchivedCategoryItem(
    BuildContext context, {
    required Category category,
    required int totalTodos,
    required int completedTodos,
  }) {
  final color = parseHexColor(category.colorCode, fallback: Theme.of(context).colorScheme.primary);
    final iconData = _getIconData(category.iconName);
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = AppSizing.isMobile(context);

    return Semantics(
      label: 'Archived ${category.name} category with $totalTodos todos',
      button: true,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppConstants.spacingL),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          padding: EdgeInsets.all(AppConstants.spacingM),
          child: Row(
            children: [
              // Category Icon (slightly faded for archived state)
              Opacity(
                opacity: 0.6,
                child: Container(
                  width: isMobile ? 32.0 : 36.0,
                  height: isMobile ? 32.0 : 36.0,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(isMobile ? 16.0 : 18.0),
                  ),
                  child: Icon(
                    iconData,
                    color: colorScheme.onPrimary,
                    size: isMobile ? AppConstants.iconS : AppConstants.iconM,
                  ),
                ),
              ),
              SizedBox(width: AppConstants.spacingM),
              
              // Category Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                        fontSize: isMobile ? 14 : 15,
                      ),
                    ),
                    SizedBox(height: AppConstants.spacingXs),
                    Row(
                      children: [
                        Text(
                          '$totalTodos todos',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                            fontSize: isMobile ? 11 : 12,
                          ),
                        ),
                        if (totalTodos > 0) ...[
                          Text(
                            ' • ',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                              fontSize: isMobile ? 11 : 12,
                            ),
                          ),
                          Text(
                            '$completedTodos completed',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                              fontSize: isMobile ? 11 : 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              
              // Restore Button
              Semantics(
                label: 'Restore ${category.name} category',
                button: true,
                child: IconButton(
                  onPressed: () => _restoreCategory(category),
                  icon: Icon(
                    Icons.unarchive,
                    color: colorScheme.primary,
                    size: AppConstants.iconM,
                  ),
                  tooltip: 'Restore category',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Action methods
  // Removed old local reorder helper after wiring provider persistence.

  void _archiveCategory(Category category) async {
    try {
      await ref.read(categoryNotifierProvider.notifier).updateCategory(
        category.copyWith(isActive: false),
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${category.name} archived'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () => _restoreCategory(category),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error archiving category: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _restoreCategory(Category category) async {
    try {
      await ref.read(categoryNotifierProvider.notifier).updateCategory(
        category.copyWith(isActive: true),
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${category.name} restored'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error restoring category: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _duplicateCategory(Category category) async {
    try {
      final newCategory = Category.create(
        name: '${category.name} Copy',
        description: category.description,
        colorCode: category.colorCode,
        iconName: category.iconName,
      );
      
      await ref.read(categoryNotifierProvider.notifier).addCategory(newCategory);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${category.name} duplicated'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error duplicating category: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<bool> _showDeleteConfirmation(BuildContext context, Category category) async {
    final messenger = ScaffoldMessenger.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text(
          'Are you sure you want to delete "${category.name}"? This will move all todos in this category to "Uncategorized".',
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              HapticFeedback.heavyImpact();
              Navigator.of(context).pop(true);
            },
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (result == true) {
      try {
        await ref.read(categoryNotifierProvider.notifier).deleteCategory(category.id);
        if (mounted) {
          messenger.showSnackBar(
            SnackBar(
              content: Text('${category.name} deleted'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          HapticFeedback.heavyImpact();
          messenger.showSnackBar(
            SnackBar(
              content: Text('Error deleting category: $e'),
              backgroundColor: colorScheme.error,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
    
    return result ?? false;
  }

  void _showAddCategoryDialog(BuildContext context) {
    _showCategoryDialog(context, null);
  }

  void _showEditCategoryDialog(BuildContext context, Category category) {
    _showCategoryDialog(context, category);
  }

  void _showCategoryDialog(BuildContext context, Category? existingCategory) {
    showDialog(
      context: context,
      builder: (context) => _CategoryDialog(
        category: existingCategory,
        onSave: (category) async {
          if (existingCategory == null) {
            await ref.read(categoryNotifierProvider.notifier).addCategory(category);
          } else {
            await ref.read(categoryNotifierProvider.notifier).updateCategory(category);
          }
        },
      ),
    );
  }

  // Helper methods
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'work':
        return Icons.work;
      case 'person':
        return Icons.person;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'favorite':
        return Icons.favorite;
      case 'home':
        return Icons.home;
      case 'school':
        return Icons.school;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'restaurant':
        return Icons.restaurant;
      case 'car':
        return Icons.directions_car;
      case 'phone':
        return Icons.phone;
      case 'computer':
        return Icons.computer;
      default:
        return Icons.folder;
    }
  }

  

  String _getLastUsedText(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays == 0) {
      return 'Used today';
    } else if (difference.inDays == 1) {
      return 'Used yesterday';
    } else if (difference.inDays < 7) {
      return 'Used ${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? 'Used last week' : 'Used $weeks weeks ago';
    } else {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? 'Used last month' : 'Used $months months ago';
    }
  }
}

// Category Dialog Widget
class _CategoryDialog extends StatefulWidget {
  final Category? category;
  final Function(Category) onSave;

  const _CategoryDialog({
    required this.category,
    required this.onSave,
  });

  @override
  State<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedColorCode = CategoryColors.blue;
  String _selectedIconName = CategoryIcons.work;
  
  final List<String> _availableColors = CategoryColors.all;
  final List<String> _availableIcons = CategoryIcons.all;

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _descriptionController.text = widget.category!.description ?? '';
      _selectedColorCode = widget.category!.colorCode;
      _selectedIconName = widget.category!.iconName;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.category != null;
    
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
    padding: const EdgeInsets.all(AppConstants.spacingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              isEdit ? 'Edit Category' : 'Add Category',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
      const SizedBox(height: AppConstants.spacingXl),
            
            // Form
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name Field
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Category Name *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Category name is required';
                          }
                          if (value.trim().length > 30) {
                            return 'Category name must be 30 characters or less';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppConstants.spacingM),
                      
                      // Description Field
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description (optional)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                        validator: (value) {
                          if (value != null && value.length > 100) {
                            return 'Description must be 100 characters or less';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppConstants.spacingXl),
                      
                      // Icon Selection
                      Text(
                        'Icon',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: AppConstants.spacingS),
                      _buildIconGrid(),
                      const SizedBox(height: AppConstants.spacingXl),
                      
                      // Color Selection
                      Text(
                        'Color',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: AppConstants.spacingS),
                      _buildColorPalette(),
                      const SizedBox(height: AppConstants.spacingXl),
                      
                      // Preview
                      Text(
                        'Preview',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 12),
                      _buildPreview(),
                    ],
                  ),
                ),
              ),
            ),
            
            // Actions
            const SizedBox(height: AppConstants.spacingXl),
            Row(
              children: [
                if (isEdit) ...[
                  OutlinedButton.icon(
                    onPressed: () => _deleteCategory(),
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const Spacer(),
                ],
                if (!isEdit) const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: AppConstants.spacingS),
                FilledButton(
                  onPressed: _saveCategory,
                  child: Text(isEdit ? 'Save' : 'Create'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconGrid() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(AppConstants.radiusS),
      ),
      child: GridView.builder(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          crossAxisSpacing: AppConstants.spacingS,
          mainAxisSpacing: AppConstants.spacingS,
        ),
        itemCount: _availableIcons.length,
        itemBuilder: (context, index) {
          final iconName = _availableIcons[index];
          final iconData = _getIconData(iconName);
          final isSelected = iconName == _selectedIconName;
          
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _selectedIconName = iconName;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(AppConstants.radiusS),
                border: isSelected ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2) : null,
              ),
              child: Icon(
                iconData,
                color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
                size: AppConstants.iconL,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildColorPalette() {
    return Wrap(
  spacing: AppConstants.spacingM,
  runSpacing: AppConstants.spacingM,
      children: _availableColors.map((colorCode) {
  final color = parseHexColor(colorCode, fallback: Theme.of(context).colorScheme.primary);
        final isSelected = colorCode == _selectedColorCode;
        
        return GestureDetector(
          onTap: () {
    HapticFeedback.selectionClick();
            setState(() {
              _selectedColorCode = colorCode;
            });
          },
          child: Container(
    width: 40,
    height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected ? Border.all(color: Theme.of(context).colorScheme.primary, width: 3) : null,
            ),
            child: isSelected
                ? Icon(
                    Icons.check,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: AppConstants.iconM,
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }

// sửa code ở đây
  Widget _buildPreview() {
  final color = parseHexColor(_selectedColorCode, fallback: Theme.of(context).colorScheme.primary);
  final iconData = _getIconData(_selectedIconName);
  final name = _nameController.text.isEmpty ? 'Category Name' : _nameController.text;

  return Padding(
    padding: const EdgeInsets.all(AppConstants.spacingL),
    child: DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(AppConstants.radiusS),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingL),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildIconContainer(color, iconData),
            const SizedBox(width: AppConstants.spacingL),
            _buildTextColumn(name),
          ],
        ),
      ),
    ),
  );
}

Widget _buildIconContainer(Color color, IconData iconData) {
  return Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(AppConstants.radiusXl),
    ),
    child: Icon(
      iconData,
      color: Theme.of(context).colorScheme.onPrimary,
      size: AppConstants.iconM,
    ),
  );
}

Widget _buildTextColumn(String name) {
  return Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          name,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: AppConstants.spacingXs),
        Text(
          '0 todos • 0 completed',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    ),
  );
}

// sửa code ở đây
  // void _saveCategory() {
  //   if (!_formKey.currentState!.validate()) {
  //     return;
  //   }

  //   final category = widget.category?.copyWith(
  //     name: _nameController.text.trim(),
  //     description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
  //     colorCode: _selectedColorCode,
  //     iconName: _selectedIconName,
  //   ) ?? Category.create(
  //     name: _nameController.text.trim(),
  //     description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
  //     colorCode: _selectedColorCode,
  //     iconName: _selectedIconName,
  //   );

  //   widget.onSave(category);
  //   Navigator.of(context).pop();
  // }

  // void _deleteCategory() async {
  //   final confirmed = await showDialog<bool>(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Delete Category'),
  //       content: Text('Are you sure you want to delete "${widget.category!.name}"?'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.of(context).pop(false),
  //           child: const Text('Cancel'),
  //         ),
  //         FilledButton(
  //           onPressed: () => Navigator.of(context).pop(true),
  //           style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
  //           child: const Text('Delete'),
  //         ),
  //       ],
  //     ),
  //   );

  //   if (confirmed == true && mounted) {
  //     Navigator.of(context).pop(); // Close the edit dialog
  //     // The actual deletion will be handled by the parent
  //   }
  // }

  /// Builds the category object for saving.
Category _buildCategory() {
  final name = _nameController.text.trim();
  final description = _descriptionController.text.trim().isEmpty
      ? null
      : _descriptionController.text.trim();

  return widget.category?.copyWith(
        name: name,
        description: description,
        colorCode: _selectedColorCode,
        iconName: _selectedIconName,
      ) ??
      Category.create(
        name: name,
        description: description,
        colorCode: _selectedColorCode,
        iconName: _selectedIconName,
      );
}

  /// Saves the category after validation.
  void _saveCategory() {
    if (!_formKey.currentState!.validate()) return;

    final category = _buildCategory();
    widget.onSave(category);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  /// Shows delete confirmation and handles deletion if confirmed.
  Future<void> _deleteCategory() async {
    final confirmed = await _showDeleteConfirmationDialog();

    if (confirmed == true && mounted) {
      Navigator.of(context).pop(); // Close the edit dialog
      // Parent will handle actual deletion
    }
  }

  /// Shows the delete confirmation dialog.
  Future<bool?> _showDeleteConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => _DeleteConfirmationDialog(
        categoryName: widget.category!.name,
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'work':
        return Icons.work;
      case 'person':
        return Icons.person;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'favorite':
        return Icons.favorite;
      case 'home':
        return Icons.home;
      case 'school':
        return Icons.school;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'restaurant':
        return Icons.restaurant;
      case 'car':
        return Icons.directions_car;
      case 'phone':
        return Icons.phone;
      case 'computer':
        return Icons.computer;
      default:
        return Icons.folder;
    }
  }

  
}
