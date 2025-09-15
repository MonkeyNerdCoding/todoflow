# TodoFlow Development Guide

Welcome to the TodoFlow development guide! This document provides comprehensive information for developers who want to contribute to or understand the TodoFlow codebase.

## 🏗️ Architecture Overview

### Application Architecture
TodoFlow follows **Clean Architecture** principles with a feature-based modular structure:

```
┌─────────────────────────────────────────────────┐
│                Presentation Layer               │
│  (Screens, Widgets, UI Components)             │
│                     ↓                           │
│               Provider Layer                    │
│     (Riverpod State Management)                 │
│                     ↓                           │
│              Business Logic Layer               │
│         (Models, Services, Utils)               │
│                     ↓                           │
│                Data Layer                       │
│        (Local Storage, Persistence)             │
└─────────────────────────────────────────────────┘
```

### State Management Architecture
TodoFlow uses **Riverpod 2.x** with modern provider patterns:

```dart
// Provider Hierarchy
AppProviders (Global State)
├── ThemeNotifier (Theme Management)
├── CategoryNotifier (Category State)
├── TodoListNotifier (Todo State)
├── FilterProvider (UI Filters)
└── StatsProvider (Computed Statistics)

// Provider Types Used
- StateProvider: Simple values (theme, filters, search)
- StateNotifierProvider: Complex logic (todos, categories)
- AsyncNotifierProvider: Async operations (storage, loading)
- Family Providers: Parameterized state (filtered data)
```

## 📁 Project Structure

### Directory Organization
```
lib/
├── main.dart                    # App entry point
├── core/                        # Core functionality
│   ├── models/                  # Data models
│   │   ├── category.dart       # Category model
│   │   ├── todo.dart           # Todo model
│   │   ├── subtask.dart        # Subtask model
│   │   └── enums/              # Enums (Priority, etc.)
│   └── providers/              # Global providers
│       ├── providers.dart      # Provider exports
│       ├── theme_provider.dart # Theme management
│       └── storage_provider.dart # Data persistence
├── features/                   # Feature modules
│   ├── home/                   # Dashboard feature
│   │   ├── home_screen.dart   # Main screen
│   │   ├── widgets/           # Feature-specific widgets
│   │   └── providers/         # Feature providers
│   ├── todos/                  # Todo management
│   │   ├── todo_list_screen.dart
│   │   ├── add_edit_todo_screen.dart
│   │   ├── widgets/
│   │   └── providers/
│   └── categories/             # Category management
├── shared/                     # Shared components
│   ├── constants/              # App constants
│   │   ├── app_constants.dart  # Sizing, spacing
│   │   ├── app_colors.dart     # Color palette
│   │   └── app_strings.dart    # Text constants
│   ├── themes/                 # Theme configuration
│   │   ├── app_theme.dart      # Material 3 themes
│   │   ├── app_decorations.dart # Widget decorations
│   │   └── color_extensions.dart # Theme extensions
│   └── widgets/                # Reusable widgets
│       ├── enhanced_stat_card.dart
│       ├── enhanced_todo_item.dart
│       └── common_widgets.dart
test/                           # Test files
├── models_test.dart            # Model tests
├── widget_test.dart            # Widget tests
└── integration_test/           # Integration tests
```
```
lib/
├── main.dart                    # App entry point
├── core/                        # Core functionality
│   ├── models/                  # Data models
│   │   ├── category.dart       # Category model
│   │   ├── todo.dart           # Todo model
│   │   ├── subtask.dart        # Subtask model
│   │   └── enums/              # Enums (Priority, etc.)
│   ├── providers/              # Global providers
│   │   ├── providers.dart      # Provider exports
│   │   ├── theme_provider.dart # Theme management
│   │   └── storage_provider.dart # Data persistence
│   └── utils/                  # Utility functions
│       ├── date_utils.dart     # Date helpers
│       ├── color_utils.dart    # Color utilities
│       └── validators.dart     # Form validation
├── features/                   # Feature modules
│   ├── home/                   # Dashboard feature
│   │   ├── home_screen.dart   # Main screen
│   │   ├── widgets/           # Feature-specific widgets
│   │   └── providers/         # Feature providers
│   ├── todos/                  # Todo management
│   │   ├── todo_list_screen.dart
│   │   ├── add_edit_todo_screen.dart
│   │   ├── widgets/
│   │   └── providers/
│   ├── categories/             # Category management
│   └── forms/                  # Form components
├── shared/                     # Shared components
│   ├── constants/              # App constants
│   │   ├── app_constants.dart  # Sizing, spacing
│   │   ├── app_colors.dart     # Color palette
│   │   └── app_strings.dart    # Text constants
│   ├── themes/                 # Theme configuration
│   │   ├── app_theme.dart      # Material 3 themes
│   │   ├── app_decorations.dart # Widget decorations
│   │   └── color_extensions.dart # Theme extensions
│   └── widgets/                # Reusable widgets
│       ├── enhanced_stat_card.dart
│       ├── enhanced_todo_item.dart
│       └── common_widgets.dart
test/                           # Test files
├── models_test.dart            # Model tests
├── widget_test.dart            # Widget tests
└── integration_test/           # Integration tests
```

### Key Design Patterns

#### 1. Provider Pattern (State Management)
```dart
// StateNotifierProvider for complex logic
@riverpod
class TodoListNotifier extends _$TodoListNotifier {
  @override
  List<Todo> build() => [];

  void addTodo(Todo todo) {
    state = [...state, todo];
    _persistTodos();
  }

  void toggleTodo(String id) {
    state = [
      for (final todo in state)
        if (todo.id == id)
          todo.copyWith(isCompleted: !todo.isCompleted)
        else
          todo,
    ];
    _persistTodos();
  }
}

// Consumer usage in widgets
class TodoList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todoListNotifierProvider);
    return ListView.builder(/* ... */);
  }
}
```

#### 2. Repository Pattern (Data Layer)
```dart
// Abstract repository interface
abstract class TodoRepository {
  Future<List<Todo>> getTodos();
  Future<void> saveTodos(List<Todo> todos);
  Future<void> deleteTodo(String id);
}

// Concrete implementation
class LocalTodoRepository implements TodoRepository {
  final SharedPreferences _prefs;
  
  @override
  Future<List<Todo>> getTodos() async {
    final jsonString = _prefs.getString('todos') ?? '[]';
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => Todo.fromJson(json)).toList();
  }
}
```

#### 3. Feature-Based Organization
Each feature is self-contained with its own:
- Screen widgets
- Provider state management
- Feature-specific widgets
- Local utilities

## 🎨 Design System

### Material Design 3 Implementation
TodoFlow uses a centralized design system based on Material Design 3:

#### Theme Architecture
```dart
// AppTheme - Centralized theme configuration
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
    textTheme: _textTheme,
    cardTheme: _cardTheme,
    appBarTheme: _appBarTheme,
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ),
  );
}
```

#### Design Constants
```dart
// AppConstants - Unified spacing and sizing
class AppConstants {
  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXl = 32.0;

  // Border Radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;

  // Component Sizes
  static const double buttonHeight = 48.0;
  static const double cardElevation = 2.0;
}
```

#### Color System
```dart
// Priority Colors
extension ColorSchemeExtension on ColorScheme {
  Color get priorityLow => const Color(0xFF4CAF50);
  Color get priorityMedium => const Color(0xFFFF9800);
  Color get priorityHigh => const Color(0xFFF44336);
  
  Color get todayTasks => primary;
  Color get completedTasks => const Color(0xFF4CAF50);
  Color get pendingTasks => const Color(0xFFFF9800);
  Color get overdueTasks => const Color(0xFFF44336);
}
```

### Component Standards

#### Widget Composition
```dart
// Enhanced components with consistent styling
class EnhancedStatCard extends StatelessWidget {
  const EnhancedStatCard({
    super.key,
    required this.icon,
    required this.number,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppConstants.cardElevation,
      margin: const EdgeInsets.all(AppConstants.spacingS),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingL),
          child: Column(/* ... */),
        ),
      ),
    );
  }
}
```

## 🔧 State Management Deep Dive

### Riverpod Provider Types

#### 1. StateProvider (Simple Values)
```dart
// UI state management
final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedFilterProvider = StateProvider<TodoFilter>((ref) => TodoFilter.all);
final isDarkModeProvider = StateProvider<bool>((ref) => false);

// Usage in widgets
Consumer(
  builder: (context, ref, child) {
    final query = ref.watch(searchQueryProvider);
    return TextField(
      onChanged: (value) => ref.read(searchQueryProvider.notifier).state = value,
    );
  },
)
```

#### 2. StateNotifierProvider (Complex Logic)
```dart
@riverpod
class CategoryNotifier extends _$CategoryNotifier {
  @override
  List<Category> build() {
    _loadCategories();
    return [];
  }

  Future<void> _loadCategories() async {
    final repository = ref.read(categoryRepositoryProvider);
    final categories = await repository.getCategories();
    state = categories;
  }

  void addCategory(Category category) {
    state = [...state, category];
    _persistCategories();
  }

  void updateCategory(Category category) {
    state = [
      for (final cat in state)
        if (cat.id == category.id) category else cat,
    ];
    _persistCategories();
  }

  void deleteCategory(String id) {
    state = state.where((cat) => cat.id != id).toList();
    _persistCategories();
  }
}
```

#### 3. AsyncNotifierProvider (Async Operations)
```dart
@riverpod
class DataInitializer extends _$DataInitializer {
  @override
  Future<bool> build() async {
    await _initializeData();
    return true;
  }

  Future<void> _initializeData() async {
    // Load todos
    ref.read(todoListNotifierProvider.notifier).loadTodos();
    
    // Load categories
    ref.read(categoryNotifierProvider.notifier).loadCategories();
    
    // Load user preferences
    ref.read(themeNotifierProvider.notifier).loadTheme();
  }
}
```

#### 4. Computed Providers (Derived State)
```dart
// Statistics computed from todos and categories
@riverpod
TodoStats todoStats(TodoStatsRef ref) {
  final todos = ref.watch(todoListNotifierProvider);
  final now = DateTime.now();

  final todaysTasks = todos.where((todo) {
    if (todo.dueDate == null) return false;
    return isSameDay(todo.dueDate!, now);
  }).length;

  final completedTasks = todos.where((todo) => todo.isCompleted).length;
  final pendingTasks = todos.where((todo) => !todo.isCompleted).length;
  final overdueTasks = todos.where((todo) {
    if (todo.dueDate == null || todo.isCompleted) return false;
    return todo.dueDate!.isBefore(now);
  }).length;

  return TodoStats(
    todaysTasks: todaysTasks,
    completedTasks: completedTasks,
    pendingTasks: pendingTasks,
    overdueTasks: overdueTasks,
  );
}

// Filtered todos based on current filter and search
@riverpod
List<Todo> filteredTodos(FilteredTodosRef ref) {
  final todos = ref.watch(todoListNotifierProvider);
  final filter = ref.watch(selectedFilterProvider);
  final searchQuery = ref.watch(searchQueryProvider);

  var filtered = todos.where((todo) {
    // Apply filter
    switch (filter) {
      case TodoFilter.today:
        return todo.dueDate != null && isSameDay(todo.dueDate!, DateTime.now());
      case TodoFilter.completed:
        return todo.isCompleted;
      case TodoFilter.pending:
        return !todo.isCompleted;
      case TodoFilter.overdue:
        return !todo.isCompleted && 
               todo.dueDate != null && 
               todo.dueDate!.isBefore(DateTime.now());
      case TodoFilter.all:
      default:
        return true;
    }
  }).toList();

  // Apply search
  if (searchQuery.isNotEmpty) {
    filtered = filtered.where((todo) =>
      todo.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
      (todo.description?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false)
    ).toList();
  }

  return filtered;
}
```

### Provider Best Practices

#### Memory Management
```dart
// Use autoDispose for temporary state
@riverpod
class FormStateNotifier extends _$FormStateNotifier {
  @override
  FormState build() => FormState.initial();
  
  // Automatically disposed when no longer used
}

// Keep alive for persistent state
@riverpod
class UserPreferences extends _$UserPreferences {
  @override
  UserPrefs build() {
    ref.keepAlive(); // Prevent disposal
    return UserPrefs.defaults();
  }
}
```

#### Error Handling
```dart
@riverpod
class TodoListNotifier extends _$TodoListNotifier {
  @override
  List<Todo> build() => [];

  Future<void> addTodo(Todo todo) async {
    try {
      // Optimistic update
      state = [...state, todo];
      
      // Persist to storage
      await ref.read(todoRepositoryProvider).saveTodo(todo);
    } catch (error) {
      // Rollback on error
      state = state.where((t) => t.id != todo.id).toList();
      
      // Show error to user
      ref.read(errorNotifierProvider.notifier).showError(
        'Failed to add todo: $error'
      );
    }
  }
}
```

## 💾 Data Layer

### Model Definitions
TodoFlow uses **Freezed** for immutable data models:

```dart
@freezed
class Todo with _$Todo {
  const factory Todo({
    required String id,
    required String title,
    String? description,
    required String categoryId,
    required Priority priority,
    DateTime? dueDate,
    DateTime? dueTime,
    @Default(false) bool isCompleted,
    required DateTime createdAt,
    DateTime? completedAt,
    @Default([]) List<Subtask> subtasks,
  }) = _Todo;

  factory Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);
}

// Generated methods available:
// - copyWith() for immutable updates
// - == and hashCode for value equality
// - toString() for debugging
// - fromJson() and toJson() for serialization
```

### Data Persistence
```dart
class LocalStorageService {
  static const String _todosKey = 'todos';
  static const String _categoriesKey = 'categories';
  static const String _preferencesKey = 'preferences';

  Future<void> saveTodos(List<Todo> todos) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = todos.map((todo) => todo.toJson()).toList();
    await prefs.setString(_todosKey, jsonEncode(jsonList));
  }

  Future<List<Todo>> loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_todosKey);
    if (jsonString == null) return [];
    
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => Todo.fromJson(json)).toList();
  }
}
```

### Data Migration
```dart
class DataMigration {
  static const int currentVersion = 2;
  
  static Future<void> migrateIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final version = prefs.getInt('data_version') ?? 1;
    
    if (version < currentVersion) {
      await _performMigration(version, currentVersion);
      await prefs.setInt('data_version', currentVersion);
    }
  }
  
  static Future<void> _performMigration(int from, int to) async {
    // Handle data structure changes between versions
    if (from == 1 && to >= 2) {
      await _migrateV1ToV2();
    }
  }
}
```

## 🧪 Testing Strategy

### Test Structure
```
test/
├── unit/                      # Unit tests
│   ├── models/               # Model tests
│   ├── providers/            # Provider logic tests
│   └── utils/                # Utility function tests
├── widget/                   # Widget tests
│   ├── screens/              # Screen widget tests
│   └── components/           # Component tests
├── integration/              # Integration tests
│   ├── user_flows/           # Complete user journey tests
│   └── api_integration/      # External API tests
└── helpers/                  # Test utilities
    ├── test_helpers.dart     # Common test utilities
    ├── mock_data.dart        # Mock data generators
    └── widget_tester_extensions.dart
```

### Unit Testing

#### Model Tests
```dart
void main() {
  group('Todo Model', () {
    test('should create todo with required fields', () {
      final todo = Todo(
        id: '1',
        title: 'Test Todo',
        categoryId: 'cat1',
        priority: Priority.medium,
        createdAt: DateTime.now(),
      );

      expect(todo.id, '1');
      expect(todo.title, 'Test Todo');
      expect(todo.isCompleted, false);
    });

    test('should update completion status with copyWith', () {
      final todo = Todo(/* ... */);
      final completed = todo.copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
      );

      expect(completed.isCompleted, true);
      expect(completed.completedAt, isNotNull);
    });
  });
}
```

#### Provider Tests
```dart
void main() {
  group('TodoListNotifier', () {
    late ProviderContainer container;
    late TodoListNotifier notifier;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          todoRepositoryProvider.overrideWithValue(MockTodoRepository()),
        ],
      );
      notifier = container.read(todoListNotifierProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('should add todo to list', () {
      final todo = Todo(/* ... */);
      
      notifier.addTodo(todo);
      
      final todos = container.read(todoListNotifierProvider);
      expect(todos, contains(todo));
    });

    test('should toggle todo completion', () {
      final todo = Todo(id: '1', isCompleted: false, /* ... */);
      notifier.state = [todo];
      
      notifier.toggleTodo('1');
      
      final updatedTodos = container.read(todoListNotifierProvider);
      expect(updatedTodos.first.isCompleted, true);
    });
  });
}
```

### Widget Testing

#### Screen Tests
```dart
void main() {
  group('HomeScreen', () {
    testWidgets('should display stats cards', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            todoStatsProvider.overrideWith((ref) => TodoStats(
              todaysTasks: 5,
              completedTasks: 10,
              pendingTasks: 3,
              overdueTasks: 2,
            )),
          ],
          child: MaterialApp(home: HomeScreen()),
        ),
      );

      expect(find.text('5'), findsOneWidget); // Today's tasks
      expect(find.text('10'), findsOneWidget); // Completed tasks
      expect(find.text('3'), findsOneWidget); // Pending tasks
      expect(find.text('2'), findsOneWidget); // Overdue tasks
    });

    testWidgets('should navigate to todos when stat card tapped', (tester) async {
      // Test navigation behavior
    });
  });
}
```

#### Component Tests
```dart
void main() {
  group('EnhancedTodoItem', () {
    testWidgets('should display todo information correctly', (tester) async {
      final todo = Todo(
        id: '1',
        title: 'Test Todo',
        description: 'Test Description',
        priority: Priority.high,
        isCompleted: false,
        createdAt: DateTime.now(),
        categoryId: 'cat1',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedTodoItem(
              todo: todo,
              categoryName: 'Work',
              categoryColor: Colors.blue,
              onTap: () {},
              onToggleComplete: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Todo'), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);
      expect(find.byType(Checkbox), findsOneWidget);
    });
  });
}
```

### Integration Testing
```dart
void main() {
  group('Todo Management Flow', () {
    testWidgets('complete todo creation and management flow', (tester) async {
      await tester.pumpWidget(TodoFlowApp());

      // Navigate to add todo
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Fill form
      await tester.enterText(find.byType(TextFormField).first, 'New Todo');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify todo appears in list
      expect(find.text('New Todo'), findsOneWidget);

      // Complete todo
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      // Verify completion
      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, true);
    });
  });
}
```

## 🚀 Development Workflow

### Getting Started

#### 1. Environment Setup
```bash
# Clone repository
git clone https://github.com/your-username/todoflow.git
cd todoflow

# Install dependencies
flutter pub get

# Generate code
flutter pub run build_runner build

# Run app
flutter run
```

#### 2. Code Generation
TodoFlow uses code generation for several purposes:

```bash
# Generate all code (run after model changes)
flutter pub run build_runner build --delete-conflicting-outputs

# Watch for changes during development
flutter pub run build_runner watch

# Clean generated files
flutter pub run build_runner clean
```

### Development Best Practices

#### Code Style
```dart
// Use descriptive names
class TodoListNotifier extends StateNotifier<List<Todo>> {
  // Not: add(todo) 
  void addTodoToList(Todo todo) { /* ... */ }
  
  // Not: toggle(id)
  void toggleTodoCompletion(String todoId) { /* ... */ }
}

// Prefer composition over inheritance
class EnhancedCard extends StatelessWidget {
  const EnhancedCard({
    super.key,
    required this.child,
    this.elevation = 2.0,
    this.margin = const EdgeInsets.all(8.0),
  });
  
  final Widget child;
  final double elevation;
  final EdgeInsets margin;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      margin: margin,
      child: child,
    );
  }
}
```

#### Error Handling
```dart
// Comprehensive error handling
@riverpod
class TodoListNotifier extends _$TodoListNotifier {
  Future<void> saveTodo(Todo todo) async {
    try {
      // Show loading state
      ref.read(loadingStateProvider.notifier).state = true;
      
      // Optimistic update
      state = [...state, todo];
      
      // Persist data
      await ref.read(todoRepositoryProvider).saveTodo(todo);
      
    } on NetworkException catch (e) {
      // Handle network errors
      _rollbackState();
      _showError('Network error: Please check your connection');
    } on StorageException catch (e) {
      // Handle storage errors
      _rollbackState();
      _showError('Storage error: Unable to save data');
    } catch (e) {
      // Handle unexpected errors
      _rollbackState();
      _showError('Unexpected error: ${e.toString()}');
    } finally {
      ref.read(loadingStateProvider.notifier).state = false;
    }
  }
}
```

#### Performance Optimization
```dart
// Optimize ListView rendering
class TodoList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(filteredTodosProvider);
    
    return ListView.builder(
      itemCount: todos.length,
      // Use keys for efficient updates
      itemBuilder: (context, index) => TodoItem(
        key: ValueKey(todos[index].id),
        todo: todos[index],
      ),
      // Add physics for better UX
      physics: const BouncingScrollPhysics(),
    );
  }
}

// Optimize provider listening
class StatCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only listen to specific stat, not entire stats object
    final todayCount = ref.watch(
      todoStatsProvider.select((stats) => stats.todaysTasks)
    );
    
    return Card(/* ... */);
  }
}
```

### Git Workflow

#### Branch Strategy
```bash
# Feature branches
git checkout -b feature/add-category-management
git checkout -b feature/bulk-todo-operations
git checkout -b bugfix/todo-completion-not-saving

# Development workflow
git add .
git commit -m "feat: add category drag and drop functionality"
git push origin feature/add-category-management

# Create pull request
```

#### Commit Message Convention
```bash
# Format: type(scope): description

# Types:
feat: new feature
fix: bug fix
docs: documentation
style: formatting
refactor: code restructuring
test: adding tests
chore: maintenance

# Examples:
feat(todos): add bulk delete functionality
fix(categories): resolve category color picker issue
docs(readme): update installation instructions
test(providers): add TodoListNotifier tests
```

## 📚 Learning Resources

### Flutter & Dart
- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)

### State Management
- [Riverpod Documentation](https://riverpod.dev/)
- [Riverpod GitHub Examples](https://github.com/rrousselGit/riverpod/tree/master/examples)

### Testing
- [Flutter Testing Guide](https://docs.flutter.dev/testing)
- [Widget Testing](https://docs.flutter.dev/cookbook/testing/widget)
- [Integration Testing](https://docs.flutter.dev/cookbook/testing/integration)

### Advanced Topics
- [Flutter Performance](https://docs.flutter.dev/perf)
- [Build Runner](https://pub.dev/packages/build_runner)
- [Code Generation](https://docs.flutter.dev/development/tools/code-generation)

## 🤝 Contributing

### Before Contributing
1. Read this development guide thoroughly
2. Set up development environment
3. Run tests to ensure everything works
4. Review existing code to understand patterns

### Contribution Process
1. **Issue Discussion**: Discuss major changes in GitHub issues first
2. **Fork & Branch**: Create feature branch from main
3. **Development**: Follow coding standards and test thoroughly
4. **Documentation**: Update docs for new features
5. **Testing**: Add tests for new functionality
6. **Pull Request**: Submit with clear description

### Code Review Checklist
- [ ] Code follows project conventions
- [ ] All tests pass
- [ ] Documentation updated
- [ ] No performance regressions
- [ ] Accessibility considerations
- [ ] Error handling implemented
- [ ] State management patterns followed

## 🔍 Debugging

### Development Tools
```bash
# Flutter Inspector (VS Code/Android Studio)
# Use for widget tree inspection and performance profiling

# Debug mode logging
flutter run --debug

# Performance profiling
flutter run --profile

# Release mode testing
flutter run --release
```

### Common Issues

#### Provider Issues
```dart
// Issue: Provider not updating UI
// Solution: Ensure proper provider watching
Consumer(
  builder: (context, ref, child) {
    final todos = ref.watch(todoListNotifierProvider); // Correct
    // Not: ref.read(todoListNotifierProvider) // Wrong - doesn't listen
    return TodoList(todos: todos);
  },
)

// Issue: Memory leaks from providers
// Solution: Use autoDispose for temporary state
@riverpod
class TemporaryState extends _$TemporaryState {
  @override
  String build() => '';
  // Automatically disposed when no longer used
}
```

#### Performance Issues
```dart
// Issue: Expensive rebuilds
// Solution: Use select() for specific data
final todoCount = ref.watch(
  todoListNotifierProvider.select((todos) => todos.length)
);

// Issue: Large list rendering
// Solution: Implement lazy loading
class TodoList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) {
        // Only build visible items
        return TodoItem(todo: todos[index]);
      },
    );
  }
}
```

### Debug Utilities
```dart
// Add debug logging
void debugLog(String message) {
  if (kDebugMode) {
    print('[TodoFlow] $message');
  }
}

// Provider state logging
@riverpod
class TodoListNotifier extends _$TodoListNotifier {
  @override
  List<Todo> build() {
    debugLog('TodoListNotifier initialized');
    return [];
  }
  
  void addTodo(Todo todo) {
    debugLog('Adding todo: ${todo.title}');
    state = [...state, todo];
  }
}
```

## 🎯 Future Enhancements

### Planned Features
- [ ] Todo sharing and collaboration
- [ ] Cloud synchronization
- [ ] Advanced filtering and search
- [ ] Data export/import
- [ ] Widget customization
- [ ] Notification system
- [ ] Analytics and insights

### Technical Improvements
- [ ] Offline-first architecture
- [ ] Performance optimizations
- [ ] Accessibility enhancements
- [ ] Internationalization
- [ ] Advanced testing coverage
- [ ] CI/CD pipeline

---

**Happy Coding! 🚀**

For questions or clarifications, please:
- Check the [Setup Guide](SETUP_GUIDE.md) for installation issues
- Review [README.md](README.md) for project overview
- Create GitHub issues for bugs or feature requests
- Join our community discussions
