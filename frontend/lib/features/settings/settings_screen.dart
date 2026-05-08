import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../services/app_config.dart';
import '../../services/app_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([AppState.instance, AppConfig.instance]),
      builder: (context, _) => _FeatureShell(
        title: 'Settings',
        subtitle: 'Application preferences and security options',
        child: ListView(
          children: [
            _SettingTile(
              title: 'Dark Mode',
              subtitle: 'Toggle light/dark administrator theme',
              value: AppState.instance.isDarkMode,
              onChanged: AppState.instance.setDarkMode,
            ),
            _SettingTile(
              title: 'Notifications',
              subtitle: 'Enable in-app operational notifications',
              value: AppState.instance.notificationsEnabled,
              onChanged: AppState.instance.setNotificationsEnabled,
            ),
            const _InfoTile(title: 'API Endpoint', subtitle: 'http://127.0.0.1:8000'),
            const BackendAuthSettings(),
            const TwilioSettings(),
            const GroupEmailSettings(),
            _SettingTile(
              title: 'Auto Refresh',
              subtitle: 'Threat feed refreshes every 30s when enabled',
              value: AppState.instance.autoRefreshEnabled,
              onChanged: AppState.instance.setAutoRefreshEnabled,
            ),
          ],
        ),
      ),
    );
  }
}

class BackendAuthSettings extends StatefulWidget {
  const BackendAuthSettings({super.key});

  @override
  State<BackendAuthSettings> createState() => _BackendAuthSettingsState();
}

class _BackendAuthSettingsState extends State<BackendAuthSettings> {
  final _tokenController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tokenController.text = AppConfig.instance.backendAuthToken;
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  void _save() {
    AppConfig.instance.updateBackendAuthToken(_tokenController.text);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Backend auth token saved')));
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
          const Text('Backend Authentication', style: TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          const Text(
            'Paste a JWT from the backend login endpoint so protected APIs can be called. Saved tokens are verified on launch.',
            style: TextStyle(color: AppTheme.textGrey, fontSize: 12),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _tokenController,
            style: const TextStyle(color: AppTheme.textWhite),
            decoration: const InputDecoration(
              labelText: 'Bearer token',
              labelStyle: TextStyle(color: AppTheme.textGrey),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ElevatedButton(onPressed: _save, child: const Text('Save')),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  _tokenController.clear();
                  AppConfig.instance.updateBackendAuthToken('');
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                child: const Text('Clear'),
              ),
            ],
          ),
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
                  AppConfig.instance.updateTwilio(accountSid: '', authToken: '', from: '');
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                child: const Text('Clear'),
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
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

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
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String subtitle;

  const _InfoTile({required this.title, required this.subtitle});

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
          Text(title, style: const TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
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
