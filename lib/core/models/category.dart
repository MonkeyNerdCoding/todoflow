import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'category.freezed.dart';
part 'category.g.dart';

@freezed
class Category with _$Category {
  const factory Category({
    required String id,
    required String name,
    String? description,
    required String colorCode,
    required String iconName,
    required DateTime createdAt,
    @Default(0) int taskCount,
    @Default(true) bool isActive,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);

  // Factory constructor to create a new category with generated ID
  factory Category.create({
    required String name,
    String? description,
    required String colorCode,
    required String iconName,
  }) {
    return Category(
      id: const Uuid().v4(),
      name: name,
      description: description,
      colorCode: colorCode,
      iconName: iconName,
      createdAt: DateTime.now(),
      taskCount: 0,
      isActive: true,
    );
  }
}

// Extension for Category utilities
extension CategoryExtension on Category {
  // Update task count
  Category updateTaskCount(int count) {
    return copyWith(taskCount: count);
  }

  // Archive/unarchive category
  Category toggleActive() {
    return copyWith(isActive: !isActive);
  }

  // Update category details
  Category updateDetails({
    String? name,
    String? description,
    String? colorCode,
    String? iconName,
  }) {
    return copyWith(
      name: name ?? this.name,
      description: description ?? this.description,
      colorCode: colorCode ?? this.colorCode,
      iconName: iconName ?? this.iconName,
    );
  }
}

// Predefined category colors
class CategoryColors {
  static const String blue = '#2196F3';
  static const String green = '#4CAF50';
  static const String orange = '#FF9800';
  static const String purple = '#9C27B0';
  static const String red = '#F44336';
  static const String teal = '#009688';
  static const String indigo = '#3F51B5';
  static const String pink = '#E91E63';

  static const List<String> all = [
    blue,
    green,
    orange,
    purple,
    red,
    teal,
    indigo,
    pink,
  ];
}

// Predefined category icons
class CategoryIcons {
  static const String work = 'work';
  static const String personal = 'person';
  static const String shopping = 'shopping_bag';
  static const String health = 'favorite';
  static const String home = 'home';
  static const String education = 'school';
  static const String travel = 'flight';
  static const String finance = 'account_balance_wallet';

  static const List<String> all = [
    work,
    personal,
    shopping,
    health,
    home,
    education,
    travel,
    finance,
  ];
}
