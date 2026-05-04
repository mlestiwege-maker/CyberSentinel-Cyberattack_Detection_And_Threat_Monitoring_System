import 'package:flutter/material.dart';
import '../dashboard/widgets/twilio_panel.dart';
import '../../core/theme.dart';
import '../../services/app_config.dart';

class TwilioScreen extends StatelessWidget {
  const TwilioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final recipients = AppConfig.instance.groupEmails;

    return Container(
      color: AppTheme.primaryBlack,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SMS / Twilio',
            style: TextStyle(color: AppTheme.textWhite, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Send emergency SMS alerts and monitor delivery logs',
            style: TextStyle(color: AppTheme.textGrey),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.secondaryBlack,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF2A3050)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Group email recipients', style: TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(
                  recipients.isEmpty
                      ? 'No extra members added yet. mlestiwege@gmail.com is used by default.'
                      : recipients.join(', '),
                  style: const TextStyle(color: AppTheme.textGrey, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Expanded(child: TwilioPanel()),
        ],
      ),
    );
  }
}
