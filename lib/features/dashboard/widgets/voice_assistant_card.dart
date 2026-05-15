import 'package:flutter/material.dart';
import 'package:cybersentinel_frontend/core/theme.dart';

class VoiceAssistantCard extends StatelessWidget {
  const VoiceAssistantCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.secondaryBlack,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2A3050)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'VOICE ASSISTANT',
            style: TextStyle(
              color: AppTheme.textWhite,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppTheme.accentBlue.withValues(alpha: 0.9),
                          AppTheme.accentBlue.withValues(alpha: 0.15),
                          Colors.transparent,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentBlue.withValues(alpha: 0.35),
                          blurRadius: 24,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.graphic_eq, color: Colors.white, size: 42),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'CyberSentinel Assistant',
                    style: TextStyle(
                      color: AppTheme.textWhite,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Listening for commands...',
                    style: TextStyle(
                      color: AppTheme.successGreen,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
