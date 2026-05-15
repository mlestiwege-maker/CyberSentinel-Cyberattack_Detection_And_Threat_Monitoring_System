import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../dashboard/widgets/defensive_terminal.dart';

class DefensiveConsoleScreen extends StatelessWidget {
  const DefensiveConsoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.primaryBlack,
      padding: const EdgeInsets.all(16),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Defensive Console',
            style: TextStyle(
              color: AppTheme.textWhite,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Command center for quick containment and response actions',
            style: TextStyle(color: AppTheme.textGrey),
          ),
          SizedBox(height: 16),
          Expanded(
            child: DefensiveTerminal(),
          ),
        ],
      ),
    );
  }
}
