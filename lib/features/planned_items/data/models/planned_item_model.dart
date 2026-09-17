import 'package:olie/features/planned_items/domain/entities/planned_item.dart';
import 'package:olie/features/planned_items/domain/entities/planned_item_priority.dart';

class PlannedItemModel extends PlannedItem {
  const PlannedItemModel({
    required super.id,
    required super.name,
    required super.priority,
    required super.estimatedValue,
    required super.estimatedDate,
    super.categoryId,
  });

  factory PlannedItemModel.fromJson(Map<String, dynamic> json) {
    return PlannedItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      priority: PlannedItemPriority.fromApiValue(json['priority'] as String),
      estimatedValue: (json['estimatedValue'] as num).toDouble(),
      estimatedDate: DateTime.parse(json['estimatedDate'] as String),
      categoryId: json['categoryId'] as String?,
    );
  }

  static Map<String, dynamic> encodeRequest({
    required String name,
    required PlannedItemPriority priority,
    required double estimatedValue,
    required DateTime estimatedDate,
    String? categoryId,
  }) {
    return {
      'name': name,
      'priority': priority.apiValue,
      'estimatedValue': estimatedValue,
      'estimatedDate': _formatDate(estimatedDate),
      'categoryId': categoryId,
    };
  }

  static String _formatDate(DateTime date) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${date.year}-${twoDigits(date.month)}-${twoDigits(date.day)}';
  }
}
