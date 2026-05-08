import 'package:flutter/material.dart';
import '../dashboard/widgets/twilio_panel.dart';
import '../../core/theme.dart';
import '../../services/access_control.dart';
import '../../services/app_config.dart';
import '../../services/api_service.dart';

class TwilioScreen extends StatefulWidget {
  const TwilioScreen({super.key});

  @override
  State<TwilioScreen> createState() => _TwilioScreenState();
}

class _TwilioScreenState extends State<TwilioScreen> {
  bool _loading = false;

  Future<void> _sendSms(String to, String body) async {
    if (!AccessControl.instance.canPerform('twilio.send')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Current role cannot send SMS')));
      return;
    }
    
    setState(() => _loading = true);
    try {
      final result = await ApiService.sendSms(to: to, body: body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('SMS sent successfully. Message SID: ${result['message_sid']}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send SMS: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([AppConfig.instance, AccessControl.instance]),
      builder: (context, _) {
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
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.accentBlue.withOpacity(0.2)),
                ),
                child: Text(
                  'Active role: ${AccessControl.instance.activeRole}',
                  style: const TextStyle(color: AppTheme.accentBlue, fontSize: 11, fontWeight: FontWeight.w600),
                ),
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
              const SizedBox(height: 12),
              if (!AccessControl.instance.canPerform('twilio.send'))
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.warningOrange.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.warningOrange.withOpacity(0.2)),
                  ),
                  child: const Text(
                    'Current role cannot send SMS/email alerts.',
                    style: TextStyle(color: AppTheme.warningOrange, fontSize: 12),
                  ),
                ),
              if (!AccessControl.instance.canPerform('twilio.send')) const SizedBox(height: 12),
              Expanded(
                child: TwilioPanel(
                  onSendSms: _sendSms,
                  loading: _loading,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}