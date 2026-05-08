import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../services/access_control.dart';
import '../../../services/app_config.dart';
import 'package:url_launcher/url_launcher_string.dart';

class TwilioPanel extends StatefulWidget {
  final Future<void> Function(String to, String body)? onSendSms;
  final bool loading;

  const TwilioPanel({super.key, this.onSendSms, this.loading = false});

  @override
  State<TwilioPanel> createState() => _TwilioPanelState();
}

class _TwilioPanelState extends State<TwilioPanel> {
  final TextEditingController _numberController = TextEditingController(text: '+263771234567');
  final TextEditingController _messageController = TextEditingController(
    text: 'CyberSentinel Alert!\nHigh risk threat detected.\nPlease check the dashboard.',
  );
  final List<_SmsLog> _logs = [
    _SmsLog('To: +263771234567', 'CyberSentinel Alert! High risk threat...', 'SENT'),
    _SmsLog('To: +263771234568', 'Login attempt detected from new device.', 'SENT'),
    _SmsLog('To: +263771234569', 'Incident #INC-2024-001 resolved.', 'SENT'),
  ];
  bool _isSending = false;

  @override
  void dispose() {
    _numberController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendSms() async {
    if (!AccessControl.instance.canPerform('twilio.send')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Current role cannot send alerts')));
      return;
    }

    final to = _numberController.text.trim();
    final message = _messageController.text.trim();
    if (to.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please provide number and message')));
      return;
    }

    setState(() {
      _isSending = true;
      _logs.insert(0, _SmsLog('To: $to', message.replaceAll('\n', ' '), 'QUEUED'));
    });

    if (widget.onSendSms != null) {
      await widget.onSendSms!(to, message);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('SMS sent via mock service')));
    }

    setState(() {
      _isSending = false;
      if (_logs.isNotEmpty) {
        final updated = _SmsLog(_logs[0].to, _logs[0].message, 'SENT');
        _logs[0] = updated;
      }
    });
  }

  Future<void> _sendEmail() async {
    if (!AccessControl.instance.canPerform('twilio.send')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Current role cannot send alerts')));
      return;
    }

    final recipients = AppConfig.instance.groupEmails.isEmpty
        ? ['mlestiwege@gmail.com']
        : AppConfig.instance.groupEmails;
    final toEmail = recipients.join(',');
    final subject = Uri.encodeComponent('CyberSentinel Alert');
    final body = Uri.encodeComponent(_messageController.text.trim() + '\n\nSent from CyberSentinel');
    final mailto = 'mailto:$toEmail?subject=$subject&body=$body';

    final launched = await launchUrlString(mailto);
    if (!launched) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open email client')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([AppConfig.instance, AccessControl.instance]),
      builder: (context, _) {
        final canSend = AccessControl.instance.canPerform('twilio.send');

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.secondaryBlack,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF2A3050)),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'TWILIO SMS PANEL',
                    style: TextStyle(
                      color: AppTheme.textWhite,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.successGreen.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'CONNECTED',
                      style: TextStyle(color: AppTheme.successGreen, fontSize: 10),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF08111F),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF1E2A44)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ACCOUNT SID', style: TextStyle(color: AppTheme.textGrey, fontSize: 10)),
                    SizedBox(height: 4),
                    Text('AC6f61826004287c…', style: TextStyle(color: AppTheme.textWhite, fontSize: 11)),
                    SizedBox(height: 10),
                    Text('TWILIO NUMBER', style: TextStyle(color: AppTheme.textGrey, fontSize: 10)),
                    SizedBox(height: 4),
                    Text('+19784648388', style: TextStyle(color: AppTheme.textWhite, fontSize: 11)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _numberController,
                style: const TextStyle(color: AppTheme.textWhite),
                decoration: InputDecoration(
                  labelText: 'To',
                  labelStyle: const TextStyle(color: AppTheme.textGrey),
                  filled: true,
                  fillColor: const Color(0xFF08111F),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _messageController,
                maxLines: 3,
                style: const TextStyle(color: AppTheme.textWhite),
                decoration: InputDecoration(
                  labelText: 'Message',
                  labelStyle: const TextStyle(color: AppTheme.textGrey),
                  filled: true,
                  fillColor: const Color(0xFF08111F),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isSending || !canSend || widget.loading ? null : _sendSms,
                      icon: const Icon(Icons.send, size: 16),
                      label: const Text('Send SMS'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: canSend ? _sendEmail : null,
                      icon: const Icon(Icons.email, size: 16),
                      label: Text('Email (${AppConfig.instance.groupEmails.isEmpty ? 1 : AppConfig.instance.groupEmails.length})'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (!canSend)
                Container(
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
              if (!canSend) const SizedBox(height: 12),
              const Text(
                'Recent SMS Logs',
                style: TextStyle(
                  color: AppTheme.textWhite,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                child: ListView.separated(
                  itemCount: _logs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final log = _logs[index];
                    return Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF08111F),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF1E2A44)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(log.to, style: const TextStyle(color: AppTheme.textWhite, fontSize: 11)),
                                const SizedBox(height: 4),
                                Text(log.message, style: const TextStyle(color: AppTheme.textGrey, fontSize: 10)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: log.status == 'SENT'
                                  ? AppTheme.successGreen.withOpacity(0.12)
                                  : AppTheme.warningOrange.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              log.status,
                              style: TextStyle(
                                color: log.status == 'SENT' ? AppTheme.successGreen : AppTheme.warningOrange,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SmsLog {
  final String to;
  final String message;
  final String status;

  _SmsLog(this.to, this.message, this.status);
}