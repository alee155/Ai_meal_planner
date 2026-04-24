import 'package:ai_meal_planner/core/auth/controller/auth_session_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

typedef AuthGateBuilder = Widget Function(BuildContext context);

class AuthGate extends StatelessWidget {
  const AuthGate({
    super.key,
    required this.authenticatedBuilder,
    required this.guestBuilder,
    this.loading,
  });

  final AuthGateBuilder authenticatedBuilder;
  final AuthGateBuilder guestBuilder;
  final Widget? loading;

  @override
  Widget build(BuildContext context) {
    final auth = AuthSessionController.ensureRegistered();

    return Obx(() {
      if (!auth.isLoaded.value) {
        return loading ??
            const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      return auth.isGuest
          ? guestBuilder(context)
          : authenticatedBuilder(context);
    });
  }
}
