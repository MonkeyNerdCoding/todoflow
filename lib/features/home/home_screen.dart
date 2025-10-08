import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/app_bottom_navigation.dart';
import '../../shared/widgets/enhanced_components.dart';
import '../../shared/widgets/optimized_todo_item.dart';
import '../../shared/constants/app_constants.dart';
import '../../core/providers/providers.dart';
import '../../core/models/models.dart';
import '../../shared/utils/color_utils.dart';

// Helper class for stat card data
class _StatCardData {
  final IconData icon;
  final String number;
  final String label;
  final Color color;
  final String route;

  const _StatCardData({
    required this.icon,
    required this.number,
    required this.label,
    required this.color,
    required this.route,
  });
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchExpanded = false;

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
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: AppConstants.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppConstants.spacingL),
                  
                  // Quick Stats Section - Optimized with selective watching
                  Consumer(builder: (context, ref, _) {
                    final statsAsync = ref.watch(todoStatsProvider);
                    return statsAsync.when(
                      data: (stats) => _buildQuickStats(context, ref, stats),
                      loading: () => _buildStatsLoadingSkeleton(context),
                      error: (error, stack) => SelectableText.rich(
                        TextSpan(
                          text: 'Error loading stats: ${error.toString()}',
                          style: TextStyle(color: Theme.of(context).colorScheme.error),
                        ),
                      ),
                    );
                  }),
                  SizedBox(height: AppConstants.spacingXxl),
                  
                  // Categories Section - Optimized with selective watching
                  Consumer(builder: (context, ref, _) {
                    final categoriesAsync = ref.watch(categoryNotifierProvider);
                    return categoriesAsync.when(
                      data: (categories) => _buildCategoriesSection(context, ref, categories),
                      loading: () => _buildCategoriesLoadingSkeleton(context),
                      error: (error, stack) => SelectableText.rich(
                        TextSpan(
                          text: 'Error loading categories: ${error.toString()}',
                          style: TextStyle(color: Theme.of(context).colorScheme.error),
                        ),
                      ),
                    );
                  }),
                  SizedBox(height: AppConstants.spacingXxl),
                  
                  // Recent Todos Section - Isolated with independent updates
                  Consumer(builder: (context, ref, _) {
                    final recentTodosAsync = ref.watch(recentTodosProvider);
                    return recentTodosAsync.when(
                      data: (todos) => _buildRecentTodosSection(context, ref, todos),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (error, stack) => SelectableText.rich(
                        TextSpan(
                          text: 'Error loading recent todos: ${error.toString()}',
                          style: TextStyle(color: Theme.of(context).colorScheme.error),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: AppConstants.spacingXxxl * 2), // Space for bottom navigation
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          context.go('/add-todo');
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const AppBottomNavigation(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
  title: Text(_getGreeting()),
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

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good Morning';
    if (hour >= 12 && hour < 17) return 'Good Afternoon';
    if (hour >= 17 && hour < 21) return 'Good Evening';
    return 'Good Night';
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.spacingL, vertical: AppConstants.spacingS),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search todos...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              setState(() {});
            },
          ),
          border: const OutlineInputBorder(),
        ),
        onChanged: (query) {
          setState(() {});
        },
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, WidgetRef ref, [TodoStatsData? preSelectedStats]) {
    final statsAsync = preSelectedStats != null 
        ? AsyncValue.data(preSelectedStats)
        : ref.watch(todoStatsProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Stats',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.spacingL),
        statsAsync.when(
          data: (stats) => _buildResponsiveStatsLayout(context, stats),
          loading: () => _buildStatsLoadingSkeleton(context),
          error: (error, stack) => SelectableText.rich(
            TextSpan(
              text: 'Error loading stats: ${error.toString()}',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResponsiveStatsLayout(BuildContext context, TodoStatsData stats) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = AppSizing.isMobile(context);
    final isTablet = AppSizing.isTablet(context);
    
    // Create stat card data
    final statCards = [
  _StatCardData(
        icon: Icons.event_available,
        number: '${stats.todaysTasks}',
        label: "Today's Tasks",
        color: colorScheme.todayTasks,
        route: '/todos?filter=today',
      ),
      _StatCardData(
        icon: Icons.check_circle,
        number: '${stats.completedToday}',
        label: 'Completed',
        color: colorScheme.completed,
        route: '/todos?filter=completed',
      ),
      _StatCardData(
        icon: Icons.schedule,
        number: '${stats.overdueTasks}',
        label: 'Overdue',
        color: colorScheme.overdue,
        route: '/todos?filter=overdue',
      ),
      _StatCardData(
        icon: Icons.folder,
        number: '${stats.activeCategories}',
        label: 'Categories',
        color: colorScheme.categories,
        route: '/categories',
      ),
    ];
    
    if (isMobile) {
      // Mobile: 2x2 grid
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildEnhancedStatCard(context, statCards[0])),
              SizedBox(width: AppConstants.spacingM),
              Expanded(child: _buildEnhancedStatCard(context, statCards[1])),
            ],
          ),
          SizedBox(height: AppConstants.spacingM),
          Row(
            children: [
              Expanded(child: _buildEnhancedStatCard(context, statCards[2])),
              SizedBox(width: AppConstants.spacingM),
              Expanded(child: _buildEnhancedStatCard(context, statCards[3])),
            ],
          ),
        ],
      );
    } else if (isTablet) {
      // Tablet: 4 cards in a single row with more spacing
      return Row(
        children: statCards.map((card) => 
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: AppConstants.spacingL),
              child: _buildEnhancedStatCard(context, card),
            ),
          ),
        ).toList(),
      );
    } else {
      // Desktop: 4 cards with maximum width and center alignment
      return Center(
        child: SizedBox(
          width: 800, // Maximum width for desktop
          child: Row(
            children: statCards.map((card) => 
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: AppConstants.spacingXl),
                  child: _buildEnhancedStatCard(context, card),
                ),
              ),
            ).toList(),
          ),
        ),
      );
    }
  }

  Widget _buildEnhancedStatCard(BuildContext context, _StatCardData data) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isMobile = AppSizing.isMobile(context);
    
    return Semantics(
      label: '${data.label}: ${data.number}',
      button: true,
      child: EnhancedMaterial(
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        onTap: () {
          HapticFeedback.lightImpact();
          context.go(data.route);
        },
        child: AnimatedContainer(
          duration: AppConstants.animationMedium,
          curve: Curves.easeInOut,
          constraints: BoxConstraints(
            minWidth: isMobile ? 140 : 180,
            minHeight: isMobile ? 100 : 140,
          ),
          padding: EdgeInsets.all(isMobile ? AppConstants.spacingL : AppConstants.spacingXl),
          // Use a tonal decoration so Quick Stats look different than
          // the solid category cards while keeping the same accent hue.
          decoration: AppDecorations.statCardTonalDecoration(colorScheme, data.color),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon with consistent sizing
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    data.icon,
                    color: data.color, // accent color for icon
                    size: isMobile ? AppConstants.iconXl : AppConstants.iconXxl,
                  ),
                ],
              ),
              
              SizedBox(height: AppConstants.spacingM),
              
              // Number with typography extension
              Text(
                data.number,
                style: theme.textTheme.statCardNumber.copyWith(
                  color: colorScheme.onSurface,
                  fontSize: isMobile ? 24 : 32,
                ),
              ),
              
              SizedBox(height: AppConstants.spacingXs),
              
              // Label with typography extension
              Text(
                data.label,
                style: theme.textTheme.statCardLabel.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: isMobile ? 12 : 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsLoadingSkeleton(BuildContext context) {
    final isMobile = AppSizing.isMobile(context);
    final isTablet = AppSizing.isTablet(context);
    
    if (isMobile) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildSkeletonStatCard(context)),
              SizedBox(width: AppConstants.spacingM),
              Expanded(child: _buildSkeletonStatCard(context)),
            ],
          ),
          SizedBox(height: AppConstants.spacingM),
          Row(
            children: [
              Expanded(child: _buildSkeletonStatCard(context)),
              SizedBox(width: AppConstants.spacingM),
              Expanded(child: _buildSkeletonStatCard(context)),
            ],
          ),
        ],
      );
    } else {
      return Row(
        children: List.generate(4, (index) => 
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: isTablet ? AppConstants.spacingL : AppConstants.spacingXl),
              child: _buildSkeletonStatCard(context),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildSkeletonStatCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = AppSizing.isMobile(context);
    
    return AnimatedContainer(
      duration: AppConstants.animationMedium,
      constraints: BoxConstraints(
        minWidth: isMobile ? 140 : 180,
        minHeight: isMobile ? 100 : 140,
      ),
      padding: EdgeInsets.all(isMobile ? AppConstants.spacingL : AppConstants.spacingXl),
      decoration: AppDecorations.cardDecoration(colorScheme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: isMobile ? AppConstants.iconXl : AppConstants.iconXxl,
            height: isMobile ? AppConstants.iconXl : AppConstants.iconXxl,
            decoration: AppDecorations.loadingContentDecoration(colorScheme),
          ),
          SizedBox(height: AppConstants.spacingM),
          Container(
            width: 60,
            height: isMobile ? 24 : 32,
            decoration: AppDecorations.loadingContentDecoration(colorScheme),
          ),
          SizedBox(height: AppConstants.spacingXs),
          Container(
            width: 80,
            height: isMobile ? 12 : 14,
            decoration: AppDecorations.loadingContentDecoration(colorScheme),
          ),
        ],
      ),
    );
  }

  //sửa code tại đây
  // Widget _buildCategoriesSection(BuildContext context, WidgetRef ref, [List<Category>? preSelectedCategories]) {
  //   final categoriesAsync = preSelectedCategories != null
  //       ? AsyncValue.data(preSelectedCategories)
  //       : ref.watch(categoryNotifierProvider);
    
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         'Categories',
  //         style: Theme.of(context).textTheme.titleMedium?.copyWith(
  //           fontWeight: FontWeight.w600,
  //         ),
  //       ),
  //       SizedBox(height: AppConstants.spacingL),
  //       categoriesAsync.when(
  //         data: (categories) => _buildResponsiveCategoriesLayout(context, categories),
  //         loading: () => _buildCategoriesLoadingSkeleton(context),
  //         error: (error, stack) => SelectableText.rich(
  //           TextSpan(
  //             text: 'Error loading categories: ${error.toString()}',
  //             style: TextStyle(color: Theme.of(context).colorScheme.error),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }
  /// Builds the categories section with a title and content based on async state.
Widget _buildCategoriesSection(
  BuildContext context,
  WidgetRef ref, [
  List<Category>? preSelectedCategories,
]) {
  final categoriesState = preSelectedCategories != null
      ? AsyncValue.data(preSelectedCategories)
      : ref.watch(categoryNotifierProvider);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildSectionTitle(context),
      const SizedBox(height: AppConstants.spacingL),
      _buildCategoriesContent(context, categoriesState),
    ],
  );
}

/// Builds the section title.
Widget _buildSectionTitle(BuildContext context) {
  return Text(
    'Categories',
    style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
  );
}

/// Builds the content based on the async state of categories.
Widget _buildCategoriesContent(BuildContext context, AsyncValue<List<Category>> categoriesState) {
  return categoriesState.when(
    data: (categories) => _buildCategories(context, categories),
    loading: () => _buildLoading(context),
    error: (error, stack) => _buildError(context, error),
  );
}

/// Builds the categories layout when data is available.
Widget _buildCategories(BuildContext context, List<Category> categories) {
  return _buildResponsiveCategoriesLayout(context, categories);
}

/// Builds the loading skeleton when categories are loading.
Widget _buildLoading(BuildContext context) {
  return _buildCategoriesLoadingSkeleton(context);
}

/// Builds the error message when categories fail to load.
Widget _buildError(BuildContext context, Object error) {
  return SelectableText.rich(
    TextSpan(
      text: 'Error loading categories: ${error.toString()}',
      style: TextStyle(color: Theme.of(context).colorScheme.error),
    ),
  );
}

  Widget _buildResponsiveCategoriesLayout(BuildContext context, List<Category> categories) {
    final isMobile = AppSizing.isMobile(context);
    final isTablet = AppSizing.isTablet(context);
    
    if (categories.isEmpty) {
      return _buildEmptyCategoriesState(context);
    }
    
    if (isMobile) {
      // Mobile: Horizontal scrolling list
      return SizedBox(
        height: AppSizing.categoryCardSize.height,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: AppConstants.spacingXs),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return Padding(
              padding: EdgeInsets.only(
                right: index < categories.length - 1 ? AppConstants.spacingM : 0,
              ),
              child: _buildEnhancedCategoryCard(context, category),
            );
          },
        ),
      );
    } else if (isTablet) {
      // Tablet: Grid with 6 items per row
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          childAspectRatio: 0.9,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return _buildEnhancedCategoryCard(context, categories[index]);
        },
      );
    } else {
      // Desktop: Grid with 4 items per row for better sizing, centered
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1.2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return _buildEnhancedCategoryCard(context, categories[index]);
            },
          ),
        ),
      );
    }
  }

  Widget _buildEnhancedCategoryCard(BuildContext context, Category category) {
    final iconData = _getIconData(category.iconName);
    final color = parseHexColor(category.colorCode, fallback: Theme.of(context).colorScheme.primary);
    final isMobile = AppSizing.isMobile(context);
    
    return Semantics(
      label: '${category.name} category',
      button: true,
      child: EnhancedMaterial(
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        onTap: () {
          HapticFeedback.lightImpact();
          context.go('/todos/category/${category.id}');
        },
        child: AnimatedContainer(
          duration: AppConstants.animationMedium,
          curve: Curves.easeInOut,
          width: isMobile ? AppSizing.categoryCardSize.width : null,
          constraints: isMobile 
            ? null 
            : const BoxConstraints(
                minHeight: 120,
                maxHeight: 180,
              ),
          decoration: AppDecorations.categoryCardDecoration(color),
          padding: EdgeInsets.all(isMobile ? AppConstants.spacingM : AppConstants.spacingL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                iconData,
                color: Theme.of(context).colorScheme.onPrimary,
                size: isMobile ? AppConstants.iconXl : AppConstants.iconXxl,
              ),
              SizedBox(height: AppConstants.spacingS),
              Text(
                category.name,
                style: Theme.of(context).textTheme.categoryName.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: isMobile ? 12 : 14,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesLoadingSkeleton(BuildContext context) {
    final isMobile = AppSizing.isMobile(context);
    final isTablet = AppSizing.isTablet(context);
    
    if (isMobile) {
      return SizedBox(
        height: AppSizing.categoryCardSize.height,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: AppConstants.spacingXs),
          itemCount: 6, // Show 6 skeleton cards
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.only(
                right: index < 5 ? AppConstants.spacingM : 0,
              ),
              child: _buildSkeletonCategoryCard(context),
            );
          },
        ),
      );
    } else {
      final crossAxisCount = isTablet ? 6 : 4;
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isTablet ? 800 : 1000),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: isTablet ? 0.9 : 1.2,
              crossAxisSpacing: isTablet ? 16 : 20,
              mainAxisSpacing: isTablet ? 16 : 20,
            ),
            itemCount: crossAxisCount * 2, // Show 2 rows of skeleton cards
            itemBuilder: (context, index) {
              return _buildSkeletonCategoryCard(context);
            },
          ),
        ),
      );
    }
  }

  Widget _buildSkeletonCategoryCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = AppSizing.isMobile(context);
    
    return AnimatedContainer(
      duration: AppConstants.animationMedium,
      width: isMobile ? AppSizing.categoryCardSize.width : null,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      padding: EdgeInsets.all(isMobile ? AppConstants.spacingM : AppConstants.spacingL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: isMobile ? AppConstants.iconXl : AppConstants.iconXxl,
            height: isMobile ? AppConstants.iconXl : AppConstants.iconXxl,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppConstants.radiusS),
            ),
          ),
          SizedBox(height: AppConstants.spacingS),
          Container(
            width: 60,
            height: isMobile ? 12 : 14,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppConstants.radiusS),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCategoriesState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: EdgeInsets.all(AppConstants.spacingXxl),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: AppConstants.elevationL,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.folder_outlined,
            size: AppConstants.iconXxxl,
            color: colorScheme.onSurfaceVariant,
          ),
          SizedBox(height: AppConstants.spacingL),
          Text(
            'No categories yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: AppConstants.spacingS),
          Text(
            'Create categories to organize your todos',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppConstants.spacingXl),
          ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              context.go('/categories');
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Category'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTodosSection(BuildContext context, WidgetRef ref, [List<Todo>? preSelectedTodos]) {
    final recentTodosAsync = preSelectedTodos != null
        ? AsyncValue.data(preSelectedTodos)
        : ref.watch(recentTodosProvider.select((value) => value));
    final categoriesAsync = ref.watch(categoryNotifierProvider.select((value) => value));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Todos',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
  const SizedBox(height: AppConstants.spacingM),
    recentTodosAsync.when(
          data: (todos) => categoriesAsync.when(
            data: (categories) {
              final filteredTodos = _getFilteredTodos(todos);
        return filteredTodos.isEmpty
          ? Container(
                      padding: const EdgeInsets.all(AppConstants.spacingXxl),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(AppConstants.radiusM),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _searchController.text.isEmpty ? Icons.task_alt : Icons.search_off,
                            size: 48,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: AppConstants.spacingM),
                          Text(
                            _searchController.text.isEmpty ? 'No todos yet' : 'No todos found',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: AppConstants.spacingXs),
                          Text(
                            _searchController.text.isEmpty 
                                ? 'Tap the + button to create your first todo'
                                : 'Try adjusting your search terms',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredTodos.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppConstants.spacingS),
                    itemBuilder: (context, index) {
                      final todo = filteredTodos[index];
                      return OptimizedTodoItem(
                        todoId: todo.id,
                        onTap: () {
                          context.go('/edit-todo/${todo.id}');
                        },
                      );
                    },
                  );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => SelectableText.rich(
              TextSpan(
                text: 'Error loading categories: ${error.toString()}',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => SelectableText.rich(
            TextSpan(
              text: 'Error loading todos: ${error.toString()}',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ),
      ],
    );
  }

  // Helper methods for parsing data
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'work':
        return Icons.work;
      case 'person':
        return Icons.person;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'favorite':
        return Icons.favorite;
      case 'home':
        return Icons.home;
      case 'school':
        return Icons.school;
      case 'fitness_center':
        return Icons.fitness_center;
      default:
        return Icons.category;
    }
  }

  List<Todo> _getFilteredTodos(List<Todo> todos) {
    if (_searchController.text.isEmpty) {
      return todos;
    }
    
    final query = _searchController.text.toLowerCase();
    return todos.where((todo) {
      return todo.title.toLowerCase().contains(query) ||
             (todo.description?.toLowerCase().contains(query) ?? false);
    }).toList();
  }
}