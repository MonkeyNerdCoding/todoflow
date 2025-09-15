import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'features/home/home_screen.dart';
import 'features/todos/todo_list_screen.dart';
import 'features/todos/add_edit_todo_screen.dart';
import 'features/categories/categories_screen.dart';
import 'core/providers/providers.dart';
import 'shared/themes/app_theme.dart';

void main() {
  runApp(
    const ProviderScope(
      child: TodoFlowApp(),
    ),
  );
}

class TodoFlowApp extends ConsumerWidget {
  const TodoFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);
    
    return MaterialApp.router(
      title: 'TodoFlow',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: _router,
    );
  }
}

// Enhanced routing configuration with edit support
final GoRouter _router = GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/todos',
      name: 'todos',
      builder: (context, state) {
        final filter = state.uri.queryParameters['filter'];
        return TodoListScreen(initialFilter: filter);
      },
    ),
    GoRoute(
      path: '/add-todo',
      name: 'add-todo',
      builder: (context, state) => const AddEditTodoScreen(),
    ),
    GoRoute(
      path: '/edit-todo/:id',
      name: 'edit-todo',
      builder: (context, state) {
        final todoId = state.pathParameters['id'];
        return AddEditTodoScreen(todoId: todoId);
      },
    ),
    GoRoute(
      path: '/categories',
      name: 'categories',
      builder: (context, state) => const CategoriesScreen(),
    ),
    GoRoute(
      path: '/todos/category/:categoryId',
      name: 'todos-by-category',
      builder: (context, state) {
        final categoryId = state.pathParameters['categoryId'];
        return TodoListScreen(filterByCategoryId: categoryId);
      },
    ),
  ],
);