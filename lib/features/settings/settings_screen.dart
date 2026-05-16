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
            const _TwilioSetupBanner(),
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
            const PrimaryEmailSettings(),
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

class _TwilioSetupBanner extends StatelessWidget {
  const _TwilioSetupBanner();

  @override
  Widget build(BuildContext context) {
    final cfg = AppConfig.instance;
    final missing = <String>[
      if (cfg.twilioAccountSid.isEmpty) 'Account SID',
      if (cfg.twilioAuthToken.isEmpty) 'Auth Token',
      if (cfg.twilioFromNumber.isEmpty) 'From Number',
    ];

    final isConfigured = missing.isEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isConfigured
            ? AppTheme.successGreen.withValues(alpha: 0.08)
            : AppTheme.warningOrange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isConfigured
              ? AppTheme.successGreen.withValues(alpha: 0.2)
              : AppTheme.warningOrange.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isConfigured ? Icons.check_circle_outline : Icons.info_outline,
            color: isConfigured ? AppTheme.successGreen : AppTheme.warningOrange,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isConfigured ? 'Twilio is configured' : 'Twilio setup is incomplete',
                  style: TextStyle(
                    color: isConfigured ? AppTheme.successGreen : AppTheme.warningOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isConfigured
                      ? 'SMS alerts can now be sent from the dashboard.'
                      : 'Missing: ${missing.join(', ')}. Open Twilio Integration below and save the values to enable SMS alerts.',
                  style: const TextStyle(color: AppTheme.textGrey, fontSize: 12),
                ),
              ],
            ),
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

class PrimaryEmailSettings extends StatefulWidget {
  const PrimaryEmailSettings({super.key});

  @override
  State<PrimaryEmailSettings> createState() => _PrimaryEmailSettingsState();
}

class _PrimaryEmailSettingsState extends State<PrimaryEmailSettings> {
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController.text = AppConfig.instance.primaryEmail;
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _save() {
    final email = _emailController.text.trim();
    if (email.isNotEmpty && !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid primary email address')));
      return;
    }
    setState(() {
      AppConfig.instance.updatePrimaryEmail(email);
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Primary alert email saved')));
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
          const Text('Primary Alert Email', style: TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          const Text(
            'This address receives email alerts when no group recipients are configured.',
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
                    labelText: 'Primary email',
                    labelStyle: TextStyle(color: AppTheme.textGrey),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(onPressed: _save, child: const Text('Save')),
            ],
          ),
        ],
      ),
    );
  }
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
  bool _obscureToken = true;

  @override
  void initState() {
    super.initState();
    final cfg = AppConfig.instance;
    _acctController.text = cfg.twilioAccountSid;
    _tokenController.text = cfg.twilioAuthToken;
    _fromController.text = cfg.twilioFromNumber;
    _acctController.addListener(_onFieldChanged);
    _tokenController.addListener(_onFieldChanged);
    _fromController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _acctController.removeListener(_onFieldChanged);
    _tokenController.removeListener(_onFieldChanged);
    _fromController.removeListener(_onFieldChanged);
    _acctController.dispose();
    _tokenController.dispose();
    _fromController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _save() {
    if (!_isSidValid || !_isFromValid || _tokenController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix Twilio fields before saving')),
      );
      return;
    }

    AppConfig.instance.updateTwilio(
      accountSid: _acctController.text.trim(),
      authToken: _tokenController.text.trim(),
      from: _fromController.text.trim(),
    );
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Twilio settings saved (in-memory)')));
  }

  bool get _isConfigured =>
      _acctController.text.trim().isNotEmpty &&
      _tokenController.text.trim().isNotEmpty &&
      _fromController.text.trim().isNotEmpty;

  bool get _isSidValid {
    final sid = _acctController.text.trim();
    final sidRegex = RegExp(r'^AC[a-zA-Z0-9]{32}$');
    // Twilio Account SID usually starts with AC and has 34 chars total.
    return sid.isEmpty || sidRegex.hasMatch(sid);
  }

  bool get _isFromValid {
    final from = _fromController.text.trim();
    final e164Regex = RegExp(r'^\+[1-9]\d{7,14}$');
    return from.isEmpty || e164Regex.hasMatch(from);
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required bool missing,
    String? helperText,
    String? errorText,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: AppTheme.textWhite),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: missing ? AppTheme.warningOrange : AppTheme.textGrey),
        helperText: helperText,
        helperStyle: const TextStyle(color: AppTheme.textGrey, fontSize: 11),
        errorText: errorText,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: missing ? AppTheme.warningOrange.withValues(alpha: 0.05) : Colors.transparent,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: missing ? AppTheme.warningOrange.withValues(alpha: 0.45) : const Color(0xFF2A3050),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: missing ? AppTheme.warningOrange : AppTheme.accentBlue,
            width: 1.4,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final missing = <String>[
      if (_acctController.text.trim().isEmpty) 'Account SID',
      if (_tokenController.text.trim().isEmpty) 'Auth Token',
      if (_fromController.text.trim().isEmpty) 'From Number',
    ];

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
          if (missing.isNotEmpty) ...[
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.warningOrange.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.warningOrange.withValues(alpha: 0.18)),
              ),
              child: Text(
                'Missing: ${missing.join(', ')}',
                style: const TextStyle(color: AppTheme.warningOrange, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
          _buildField(
            label: 'Account SID',
            controller: _acctController,
            missing: _acctController.text.trim().isEmpty,
            helperText: 'Format: ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
            errorText: _isSidValid ? null : 'Invalid SID format',
          ),
          const SizedBox(height: 8),
          _buildField(
            label: 'Auth Token',
            controller: _tokenController,
            missing: _tokenController.text.trim().isEmpty,
            obscureText: _obscureToken,
            helperText: 'Your token is stored locally in app state.',
            suffixIcon: IconButton(
              icon: Icon(
                _obscureToken ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: AppTheme.textGrey,
              ),
              onPressed: () {
                setState(() {
                  _obscureToken = !_obscureToken;
                });
              },
            ),
          ),
          const SizedBox(height: 8),
          _buildField(
            label: 'From Number',
            controller: _fromController,
            missing: _fromController.text.trim().isEmpty,
            helperText: 'E.164 format, e.g. +263712246543',
            errorText: _isFromValid ? null : 'Use international format (+countrycode...)',
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ElevatedButton(
                onPressed: (_isSidValid && _isFromValid && _tokenController.text.trim().isNotEmpty) ? _save : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isConfigured ? AppTheme.successGreen : AppTheme.warningOrange,
                  foregroundColor: Colors.white,
                ),
                child: Text(_isConfigured ? 'Save & Ready' : 'Save & Complete Setup'),
              ),
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
