import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'layout/main_layout.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CyberSentinel',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const MainLayout(),
    );
  }
}
