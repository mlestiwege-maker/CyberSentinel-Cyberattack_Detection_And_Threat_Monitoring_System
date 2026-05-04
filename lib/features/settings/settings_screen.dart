import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../services/app_config.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _FeatureShell(
      title: 'Settings',
      subtitle: 'Application preferences and security options',
      child: ListView(
        children: const [
          _SettingTile(title: 'Dark Mode', subtitle: 'CyberSentinel theme is enabled'),
          _SettingTile(title: 'Notifications', subtitle: 'Desktop alerts are active'),
          _SettingTile(title: 'API Endpoint', subtitle: 'http://127.0.0.1:8000'),
          TwilioSettings(),
          GroupEmailSettings(),
          _SettingTile(title: 'Auto Refresh', subtitle: 'Threat feed refreshes every 30s'),
        ],
      ),
    );
  }
}

class TwilioSettings extends StatefulWidget {
  const TwilioSettings({super.key});

  @override
  State<TwilioSettings> createState() => _TwilioSettingsState();
}

class GroupEmailSettings extends StatefulWidget {
  const GroupEmailSettings({super.key});

  @override
  State<GroupEmailSettings> createState() => _GroupEmailSettingsState();
}

class _GroupEmailSettingsState extends State<GroupEmailSettings> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _addEmail() {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid email address')));
      return;
    }
    setState(() {
      AppConfig.instance.addGroupEmail(email);
      _emailController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final emails = AppConfig.instance.groupEmails;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.secondaryBlack,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2A3050)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Group Email Members', style: TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          const Text(
            'Add group members so email alerts can be sent to everyone on the team.',
            style: TextStyle(color: AppTheme.textGrey, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _emailController,
                  style: const TextStyle(color: AppTheme.textWhite),
                  decoration: const InputDecoration(
                    labelText: 'Member email',
                    labelStyle: TextStyle(color: AppTheme.textGrey),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(onPressed: _addEmail, child: const Text('Add')),
            ],
          ),
          const SizedBox(height: 12),
          if (emails.isEmpty)
            const Text('No group emails yet', style: TextStyle(color: AppTheme.textGrey, fontSize: 12))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: emails
                  .map(
                    (email) => InputChip(
                      label: Text(email),
                      onDeleted: () {
                        setState(() {
                          AppConfig.instance.removeGroupEmail(email);
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _TwilioSettingsState extends State<TwilioSettings> {
  final _acctController = TextEditingController();
  final _tokenController = TextEditingController();
  final _fromController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final cfg = AppConfig.instance;
    _acctController.text = cfg.twilioAccountSid;
    _tokenController.text = cfg.twilioAuthToken;
    _fromController.text = cfg.twilioFromNumber;
  }

  @override
  void dispose() {
    _acctController.dispose();
    _tokenController.dispose();
    _fromController.dispose();
    super.dispose();
  }

  void _save() {
    AppConfig.instance.updateTwilio(
      accountSid: _acctController.text.trim(),
      authToken: _tokenController.text.trim(),
      from: _fromController.text.trim(),
    );
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Twilio settings saved (in-memory)')));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.secondaryBlack,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2A3050)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Twilio Integration', style: TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _acctController,
            style: const TextStyle(color: AppTheme.textWhite),
            decoration: const InputDecoration(labelText: 'Account SID', labelStyle: TextStyle(color: AppTheme.textGrey)),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _tokenController,
            style: const TextStyle(color: AppTheme.textWhite),
            decoration: const InputDecoration(labelText: 'Auth Token', labelStyle: TextStyle(color: AppTheme.textGrey)),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _fromController,
            style: const TextStyle(color: AppTheme.textWhite),
            decoration: const InputDecoration(labelText: 'From Number', labelStyle: TextStyle(color: AppTheme.textGrey)),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ElevatedButton(onPressed: _save, child: const Text('Save')),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  _acctController.clear();
                  _tokenController.clear();
                  _fromController.clear();
                },
                child: const Text('Clear'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SettingTile({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.secondaryBlack,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2A3050)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
              ],
            ),
          ),
          Switch(value: true, onChanged: (_) {}),
        ],
      ),
    );
  }
}

class _FeatureShell extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  const _FeatureShell({required this.title, required this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.primaryBlack,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppTheme.textWhite, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: AppTheme.textGrey)),
          const SizedBox(height: 16),
          Expanded(child: child),
        ],
      ),
    );
  }
}
