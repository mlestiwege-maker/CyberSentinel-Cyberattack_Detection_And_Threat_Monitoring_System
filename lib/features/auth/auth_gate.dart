import 'package:flutter/material.dart';

import '../../services/app_state.dart';
import '../auth/login_screen.dart';
import '../../layout/main_layout.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState.instance,
      builder: (context, _) {
        return AppState.instance.isAuthenticated ? const MainLayout() : const LoginScreen();
      },
    );
  }
}
