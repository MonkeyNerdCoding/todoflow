import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/models.dart';

part 'category_provider.g.dart';

@riverpod
class CategoryNotifier extends _$CategoryNotifier {
  @override
  Future<List<Category>> build() async {
    return await _loadCategories();
  }

  Future<List<Category>> _loadCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final categoriesJson = prefs.getString('categories');
      
      if (categoriesJson != null) {
        final List<dynamic> categoriesList = json.decode(categoriesJson);
        return categoriesList.map((json) => Category.fromJson(json)).toList();
      } else {
        // Create default categories if none exist
        final defaultCategories = _createDefaultCategories();
        await _saveCategories(defaultCategories);
        return defaultCategories;
      }
    } catch (e) {
      // Return default categories on error
      return _createDefaultCategories();
    }
  }

  List<Category> _createDefaultCategories() {
    return [
      Category.create(
        name: 'Work',
        description: 'Work-related tasks and projects',
        colorCode: '#2196F3',
        iconName: 'work',
      ),
      Category.create(
        name: 'Personal',
        description: 'Personal tasks and activities',
        colorCode: '#4CAF50',
        iconName: 'person',
      ),
      Category.create(
        name: 'Shopping',
        description: 'Shopping lists and errands',
        colorCode: '#FF9800',
        iconName: 'shopping_cart',
      ),
      Category.create(
        name: 'Health',
        description: 'Health and fitness goals',
        colorCode: '#E91E63',
        iconName: 'favorite',
      ),
    ];
  }

  Future<void> _saveCategories(List<Category> categories) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final categoriesJson = json.encode(categories.map((c) => c.toJson()).toList());
      await prefs.setString('categories', categoriesJson);
    } catch (e) {
      // Handle save error silently for now
    }
  }

  Future<void> addCategory(Category category) async {
    final currentState = await future;
    final updatedCategories = [...currentState, category];
    await _saveCategories(updatedCategories);
    state = AsyncValue.data(updatedCategories);
  }

  Future<void> updateCategory(Category updatedCategory) async {
    final currentState = await future;
    final updatedCategories = currentState.map((category) {
      return category.id == updatedCategory.id ? updatedCategory : category;
    }).toList();
    await _saveCategories(updatedCategories);
    state = AsyncValue.data(updatedCategories);
  }

  Future<void> deleteCategory(String categoryId) async {
    final currentState = await future;
    final updatedCategories = currentState.where((category) => category.id != categoryId).toList();
    await _saveCategories(updatedCategories);
    state = AsyncValue.data(updatedCategories);
  }

  Future<void> updateTaskCount(String categoryId, int newCount) async {
    final currentState = await future;
    final updatedCategories = currentState.map((category) {
      return category.id == categoryId ? category.updateTaskCount(newCount) : category;
    }).toList();
    await _saveCategories(updatedCategories);
    state = AsyncValue.data(updatedCategories);
  }

  // Persist reordering of active (non-archived) categories.
  Future<void> reorderActiveCategories(int oldIndex, int newIndex) async {
    final currentState = await future;
    final categories = List<Category>.from(currentState);

    // Build mapping of active-category positions to original indices
    final activeIndices = <int>[];
    for (int i = 0; i < categories.length; i++) {
      if (categories[i].isActive) activeIndices.add(i);
    }

    if (oldIndex < 0 || oldIndex >= activeIndices.length) return;
    if (newIndex < 0 || newIndex > activeIndices.length) return;

    // Translate active subset indices to original list indices
    int fromOriginal = activeIndices[oldIndex];
    int toOriginal = (newIndex == activeIndices.length)
        ? categories.length
        : activeIndices[newIndex];

    // Adjust target when removing before inserting
    final item = categories.removeAt(fromOriginal);
    if (fromOriginal < toOriginal) {
      toOriginal -= 1;
    }
    categories.insert(toOriginal, item);

    await _saveCategories(categories);
    state = AsyncValue.data(categories);
  }
}
