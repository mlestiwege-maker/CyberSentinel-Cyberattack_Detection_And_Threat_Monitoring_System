import 'package:flutter/material.dart';
import '../dashboard/widgets/voice_assistant_card.dart';
import '../../core/theme.dart';

class VoiceAssistantScreen extends StatelessWidget {
  const VoiceAssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.primaryBlack,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Voice Assistant',
            style: TextStyle(color: AppTheme.textWhite, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            'Hands-free assistant for operational security workflows',
            style: TextStyle(color: AppTheme.textGrey),
          ),
          SizedBox(height: 16),
          Expanded(child: VoiceAssistantCard()),
        ],
      ),
    );
  }
}
