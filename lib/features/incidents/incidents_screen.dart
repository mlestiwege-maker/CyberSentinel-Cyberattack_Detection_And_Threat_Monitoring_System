// DEPRECATED: This file is legacy and should not be used.
// Please use: /frontend/lib/features/incidents/incidents_screen.dart instead
//
// This file is kept only to prevent import errors from other legacy code.
// All active development should reference the frontend folder.

import 'package:flutter/material.dart';

class IncidentsScreen extends StatelessWidget {
  const IncidentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('This screen has been moved to the frontend package'),
      ),
    );
  }
}