import 'dart:async';

import 'package:ai_meal_planner/core/notifications/in_app_inbox_store.dart';
import 'package:get/get.dart';

class NotificationsInboxController extends GetxController {
  static NotificationsInboxController ensureRegistered() {
    if (Get.isRegistered<NotificationsInboxController>()) {
      return Get.find<NotificationsInboxController>();
    }

    return Get.put(NotificationsInboxController(), permanent: true);
  }

  final RxBool isLoading = true.obs;
  final RxList<InAppInboxItem> items = <InAppInboxItem>[].obs;
  final RxInt unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    unawaited(reload());
  }

  Future<void> reload() async {
    isLoading.value = true;
    try {
      final loaded = await InAppInboxStore.load();
      items.assignAll(loaded);
      unreadCount.value = loaded.where((e) => !e.isRead).length;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAllRead() async {
    await InAppInboxStore.markAllRead();
    await reload();
  }
}
