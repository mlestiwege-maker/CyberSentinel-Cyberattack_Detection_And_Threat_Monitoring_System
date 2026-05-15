import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../services/app_config.dart';
import '../../../services/notification_service.dart';
import '../../../services/app_state.dart';
import 'package:url_launcher/url_launcher_string.dart';

class TwilioPanel extends StatefulWidget {
  const TwilioPanel({super.key});

  @override
  State<TwilioPanel> createState() => _TwilioPanelState();
}

class _TwilioPanelState extends State<TwilioPanel> {
  final TextEditingController _numberController = TextEditingController(text: '+263789728505');
  final TextEditingController _messageController = TextEditingController(
    text: 'CyberSentinel Alert!\nHigh risk threat detected.\nPlease check the dashboard.',
  );
  final List<_SmsLog> _logs = [
    _SmsLog('To: +263771234567', 'CyberSentinel Alert! High risk threat...', 'SENT'),
    _SmsLog('To: +263771234568', 'Login attempt detected from new device.', 'SENT'),
    _SmsLog('To: +263771234569', 'Incident #INC-2024-001 resolved.', 'SENT'),
  ];
  bool _isSending = false;
  Future<Map<String, dynamic>?>? _statusFuture;

  @override
  void initState() {
    super.initState();
    _statusFuture = _loadNotificationStatus();
  }

  Future<Map<String, dynamic>?> _loadNotificationStatus() {
    return NotificationService.getNotificationStatus(token: AppState.instance.backendAuthToken);
  }

  void _refreshNotificationStatus() {
    if (!mounted) return;
    setState(() {
      _statusFuture = _loadNotificationStatus();
    });
  }

  @override
  void dispose() {
    _numberController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendSms() async {
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

    final token = AppState.instance.backendAuthToken;
    if (token.isEmpty) {
      setState(() {
        _isSending = false;
        if (_logs.isNotEmpty) {
          _logs[0] = _SmsLog(_logs[0].to, _logs[0].message, 'FAILED');
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not authenticated. Please log in again.')));
      return;
    }

    final success = await NotificationService.sendSmsAlert(
      phoneNumber: to,
      message: message,
      token: token,
    );
    if (!mounted) return;

    setState(() {
      _isSending = false;
      // update the top log status
      if (_logs.isNotEmpty) {
        final updated = _SmsLog(_logs[0].to, _logs[0].message, success ? 'SENT' : 'FAILED');
        _logs[0] = updated;
      }
    });

    _refreshNotificationStatus();

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? 'SMS sent (backend)' : 'SMS failed')));
  }

  Future<void> _sendTestSms() async {
    const testMessage = 'CyberSentinel test SMS — alert delivery check.';
    final originalMessage = _messageController.text;
    final originalNumber = _numberController.text;
    final token = AppState.instance.backendAuthToken;

    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not authenticated. Please log in again.')));
      return;
    }

    try {
      _messageController.text = testMessage;
      if (originalNumber.trim().isEmpty) {
        _numberController.text = AppConfig.instance.twilioFromNumber;
      }

      final to = _numberController.text.trim();
      setState(() {
        _isSending = true;
        _logs.insert(0, _SmsLog('To: $to', testMessage, 'QUEUED'));
      });

      final success = await NotificationService.testSmsConfiguration(
        phoneNumber: to,
        message: testMessage,
        token: token,
      );

      if (!mounted) return;

      setState(() {
        _isSending = false;
        if (_logs.isNotEmpty) {
          _logs[0] = _SmsLog(_logs[0].to, _logs[0].message, success ? 'SENT' : 'FAILED');
        }
      });

      _refreshNotificationStatus();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? 'Test SMS sent (backend)' : 'Test SMS failed')));
    } finally {
      _messageController.text = originalMessage;
      _numberController.text = originalNumber;
    }
  }

  Future<void> _sendEmail() async {
    final recipients = AppConfig.instance.groupEmails.isNotEmpty
        ? AppConfig.instance.groupEmails
        : [
            if (AppConfig.instance.primaryEmail.isNotEmpty) AppConfig.instance.primaryEmail,
            if (AppConfig.instance.primaryEmail.isEmpty) 'mlestiwege@gmail.com',
          ];

    final message = _messageController.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please provide a message')));
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      // Get current token from AppState
      final token = AppState.instance.backendAuthToken;
      if (token.isEmpty) {
        throw Exception('Not authenticated. Please log in again.');
      }

      // Try to send via backend first
      final success = await NotificationService.sendEmailAlert(
        recipients: recipients,
        subject: 'CyberSentinel Alert',
        message: message,
        token: token,
      );

      if (!mounted) return;

      if (success) {
        _refreshNotificationStatus();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email sent to ${recipients.length} recipient(s)')),
        );
      } else {
        // Fallback to mailto: if backend fails
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backend email service unavailable. Using default mail client...')),
        );
        await _sendEmailFallback(recipients);
      }
    } catch (e) {
      if (!mounted) return;
      // Fallback to mailto: on error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Using default mail client: ${e.toString()}')),
      );
      await _sendEmailFallback(recipients);
      _refreshNotificationStatus();
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  Future<void> _sendTestEmail() async {
    final token = AppState.instance.backendAuthToken;
    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not authenticated. Please log in again.')));
      return;
    }

    final recipients = AppConfig.instance.groupEmails.isNotEmpty
        ? AppConfig.instance.groupEmails
        : [
            if (AppConfig.instance.primaryEmail.isNotEmpty) AppConfig.instance.primaryEmail,
            if (AppConfig.instance.primaryEmail.isEmpty) 'mlestiwege@gmail.com',
          ];

    final testRecipient = recipients.first;

    setState(() {
      _isSending = true;
    });

    try {
      final success = await NotificationService.testEmailConfiguration(
        testRecipient: testRecipient,
        token: token,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? 'Test email sent to $testRecipient' : 'Test email failed')),
      );
      _refreshNotificationStatus();
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  Future<void> _sendEmailFallback(List<String> recipients) async {
    final toEmail = recipients.join(',');
    final subject = Uri.encodeComponent('CyberSentinel Alert');
    final body = Uri.encodeComponent('${_messageController.text.trim()}\n\nSent from CyberSentinel');
    final mailto = 'mailto:$toEmail?subject=$subject&body=$body';

    final launched = await launchUrlString(mailto, mode: LaunchMode.externalApplication);
    if (!mounted) return;
    if (!launched) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open email client')));
    }
  }

  @override
  Widget build(BuildContext context) {
        return AnimatedBuilder(
      animation: Listenable.merge([AppConfig.instance, AppState.instance]),
      builder: (context, _) {
        final cfg = AppConfig.instance;
        final hasTwilioConfig = cfg.twilioAccountSid.isNotEmpty && cfg.twilioAuthToken.isNotEmpty && cfg.twilioFromNumber.isNotEmpty;
        final isAuthenticated = AppState.instance.isAuthenticated && AppState.instance.backendAuthToken.isNotEmpty;
        final canSend = isAuthenticated;
        final canTest = isAuthenticated;
        final sidDisplay = cfg.twilioAccountSid.isEmpty
            ? 'Not configured'
            : '${cfg.twilioAccountSid.substring(0, 4)}…${cfg.twilioAccountSid.substring(cfg.twilioAccountSid.length - 4)}';
        final fromDisplay = cfg.twilioFromNumber.isEmpty ? 'Not configured' : cfg.twilioFromNumber;
        final missingFields = <String>[
          if (cfg.twilioAccountSid.isEmpty) 'Account SID',
          if (cfg.twilioAuthToken.isEmpty) 'Auth Token',
          if (cfg.twilioFromNumber.isEmpty) 'From Number',
        ];

        return FutureBuilder<Map<String, dynamic>?>(
          future: _statusFuture,
          builder: (context, snapshot) {
            final status = snapshot.data;
            final smsStatus = status?['sms'] as Map<String, dynamic>?;
            final emailStatus = status?['email'] as Map<String, dynamic>?;
            final smsMode = (smsStatus?['mode'] as String?) ?? (AppConfig.instance.twilioAccountSid.isNotEmpty ? 'twilio' : 'mock');
            final smsConfigured = smsStatus?['configured'] == true;
            final emailConfigured = emailStatus?['configured'] == true;
            final deliveryHealth = (status?['delivery_health'] as String?) ?? 'manual';

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
                      color: AppTheme.successGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      hasTwilioConfig ? 'CONNECTED' : 'SETUP REQUIRED',
                      style: const TextStyle(color: AppTheme.successGreen, fontSize: 10),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('AUTOMATED DELIVERY STATUS', style: TextStyle(color: AppTheme.textGrey, fontSize: 10)),
                    const SizedBox(height: 6),
                    Text(
                      'Health: ${deliveryHealth.toUpperCase()}',
                      style: TextStyle(
                        color: deliveryHealth == 'automatic' ? AppTheme.successGreen : AppTheme.warningOrange,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'SMS mode: ${smsMode.toUpperCase()} • ${smsConfigured ? 'recipients configured' : 'no automatic SMS recipients'}',
                      style: const TextStyle(color: AppTheme.textWhite, fontSize: 11),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Email: ${emailConfigured ? 'configured' : 'fallback logging only'}',
                      style: const TextStyle(color: AppTheme.textWhite, fontSize: 11),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Recent activity loads from backend logs after each detection/send.',
                      style: TextStyle(color: AppTheme.textGrey, fontSize: 10),
                    ),
                  ],
                ),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ACCOUNT SID', style: TextStyle(color: AppTheme.textGrey, fontSize: 10)),
                    const SizedBox(height: 4),
                    Text(sidDisplay, style: const TextStyle(color: AppTheme.textWhite, fontSize: 11)),
                    const SizedBox(height: 10),
                    const Text('TWILIO NUMBER', style: TextStyle(color: AppTheme.textGrey, fontSize: 10)),
                    const SizedBox(height: 4),
                    Text(fromDisplay, style: const TextStyle(color: AppTheme.textWhite, fontSize: 11)),
                  ],
                ),
              ),
              if (!hasTwilioConfig) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.warningOrange.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.warningOrange.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Twilio is not configured yet.',
                        style: TextStyle(color: AppTheme.warningOrange, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        missingFields.isEmpty
                            ? 'Open Settings and save your Twilio credentials.'
                            : 'Missing: ${missingFields.join(', ')}. Save them in Settings > Twilio Integration.',
                        style: const TextStyle(color: AppTheme.textGrey, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
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
                      onPressed: _isSending || !canSend ? null : _sendSms,
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
                      label: Text('Email (${AppConfig.instance.groupEmails.isNotEmpty ? AppConfig.instance.groupEmails.length : 1})'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isSending || !canTest ? null : _sendTestSms,
                      icon: const Icon(Icons.sms_outlined, size: 16),
                      label: const Text('Test SMS'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.accentBlue,
                        side: BorderSide(color: AppTheme.accentBlue.withValues(alpha: 0.4)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isSending || !canSend ? null : _sendTestEmail,
                      icon: const Icon(Icons.mark_email_read_outlined, size: 16),
                      label: const Text('Test Email'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.tealAccent,
                        side: BorderSide(color: Colors.tealAccent.withValues(alpha: 0.4)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (!isAuthenticated)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.warningOrange.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.warningOrange.withValues(alpha: 0.2)),
                  ),
                  child: const Text(
                    'Please log in again to send SMS/email alerts.',
                    style: TextStyle(color: AppTheme.warningOrange, fontSize: 12),
                  ),
                ),
              if (!isAuthenticated) const SizedBox(height: 12),
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
                                  ? AppTheme.successGreen.withValues(alpha: 0.12)
                                  : AppTheme.warningOrange.withValues(alpha: 0.12),
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
