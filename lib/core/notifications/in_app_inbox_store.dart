import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class InAppInboxItem {
  const InAppInboxItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAtMs,
    required this.isRead,
    this.mealKey,
    this.hour,
    this.minute,
  });

  final int id;
  final String type; // e.g. 'meal_alarm'
  final String title;
  final String message;
  final int createdAtMs;
  final bool isRead;
  final String? mealKey;
  final int? hour;
  final int? minute;

  InAppInboxItem copyWith({bool? isRead}) {
    return InAppInboxItem(
      id: id,
      type: type,
      title: title,
      message: message,
      createdAtMs: createdAtMs,
      isRead: isRead ?? this.isRead,
      mealKey: mealKey,
      hour: hour,
      minute: minute,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'message': message,
      'createdAtMs': createdAtMs,
      'isRead': isRead,
      'mealKey': mealKey,
      'hour': hour,
      'minute': minute,
    };
  }

  static InAppInboxItem? fromJson(Object? json) {
    if (json is! Map) return null;
    final map = Map<String, dynamic>.from(json);
    final id = map['id'];
    final type = map['type'];
    final title = map['title'];
    final message = map['message'];
    final createdAtMs = map['createdAtMs'];
    if (id is! int ||
        type is! String ||
        title is! String ||
        message is! String ||
        createdAtMs is! int) {
      return null;
    }

    return InAppInboxItem(
      id: id,
      type: type,
      title: title,
      message: message,
      createdAtMs: createdAtMs,
      isRead: map['isRead'] is bool ? map['isRead'] as bool : false,
      mealKey: map['mealKey'] as String?,
      hour: map['hour'] as int?,
      minute: map['minute'] as int?,
    );
  }
}

class InAppInboxStore {
  InAppInboxStore._();

  static const _itemsKey = 'in_app_inbox_items_v1';
  static const _nextIdKey = 'in_app_inbox_next_id_v1';
  static const int _maxItems = 100;

  static Future<List<InAppInboxItem>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_itemsKey);
    if (raw == null || raw.isEmpty) return const <InAppInboxItem>[];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const <InAppInboxItem>[];
      return decoded
          .map((e) => InAppInboxItem.fromJson(e))
          .whereType<InAppInboxItem>()
          .toList(growable: false);
    } catch (_) {
      return const <InAppInboxItem>[];
    }
  }

  static Future<void> save(List<InAppInboxItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _itemsKey,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }

  static Future<int> _allocateId() async {
    final prefs = await SharedPreferences.getInstance();
    final nextId = prefs.getInt(_nextIdKey);
    if (nextId == null || nextId < 1) {
      await prefs.setInt(_nextIdKey, 2);
      return 1;
    }

    await prefs.setInt(_nextIdKey, nextId + 1);
    return nextId;
  }

  static Future<InAppInboxItem> add(InAppInboxItem item) async {
    final id = await _allocateId();
    final nextItem = InAppInboxItem(
      id: id,
      type: item.type,
      title: item.title,
      message: item.message,
      createdAtMs: item.createdAtMs,
      isRead: item.isRead,
      mealKey: item.mealKey,
      hour: item.hour,
      minute: item.minute,
    );

    final items = (await load()).toList(growable: true);
    items.insert(0, nextItem);
    if (items.length > _maxItems) {
      items.removeRange(_maxItems, items.length);
    }

    await save(items);
    return nextItem;
  }

  static Future<void> markAllRead() async {
    final items = await load();
    await save(items.map((e) => e.copyWith(isRead: true)).toList());
  }
}
