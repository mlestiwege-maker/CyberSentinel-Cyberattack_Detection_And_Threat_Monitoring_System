import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'layout/main_layout.dart';
import 'services/access_control.dart';
import 'services/app_config.dart';
import 'services/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    AppState.instance.load(),
    AppConfig.instance.load(),
    AccessControl.instance.load(),
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState.instance,
      builder: (context, _) => MaterialApp(
        title: 'CyberSentinel',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: AppState.instance.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        debugShowCheckedModeBanner: false,
        home: const MainLayout(),
      ),
    );
  }
}
