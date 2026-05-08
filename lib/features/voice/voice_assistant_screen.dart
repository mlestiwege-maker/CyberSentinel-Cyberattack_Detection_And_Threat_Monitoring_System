import 'package:flutter/material.dart';
import '../dashboard/widgets/voice_assistant_card.dart';
import '../../core/theme.dart';
import '../../services/access_control.dart';
import '../../services/api_service.dart';

class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen> {
  bool _listening = false;
  String _lastCommand = 'No command issued yet';

  void _toggleListening() {
    if (!AccessControl.instance.canPerform('voice.command')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Current role cannot use voice commands')));
      return;
    }

    setState(() {
      _listening = !_listening;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_listening ? 'Voice listening started' : 'Voice listening stopped')),
    );
  }

  void _runQuickCommand(String command) async {
    if (!AccessControl.instance.canPerform('voice.command')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Current role cannot use voice commands')));
      return;
    }

    setState(() {
      _lastCommand = command;
    });
    
    try {
      final response = await ApiService.processVoiceCommand(command);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Assistant: ${response['response']}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Assistant command executed: $command')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AccessControl.instance,
      builder: (context, _) => Container(
        color: AppTheme.primaryBlack,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Voice Assistant',
              style: TextStyle(color: AppTheme.textWhite, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Hands-free assistant for operational security workflows',
              style: TextStyle(color: AppTheme.textGrey),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: AccessControl.instance.canPerform('voice.command') ? _toggleListening : null,
                  icon: Icon(_listening ? Icons.mic_off : Icons.mic, size: 16),
                  label: Text(_listening ? 'Stop Listening' : 'Start Listening'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _listening ? AppTheme.warningOrange : AppTheme.accentBlue,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: AccessControl.instance.canPerform('voice.command') ? () => _runQuickCommand('Open Incidents Board') : null,
                  child: const Text('Open Incidents'),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: AccessControl.instance.canPerform('voice.command') ? () => _runQuickCommand('Refresh Threat Monitor') : null,
                  child: const Text('Refresh Threats'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text('Last command: $_lastCommand', style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
            const SizedBox(height: 8),
            if (!AccessControl.instance.canPerform('voice.command'))
              const Text(
                'Current role cannot use voice commands.',
                style: TextStyle(color: AppTheme.warningOrange, fontSize: 12),
              ),
            const SizedBox(height: 16),
            const Expanded(child: VoiceAssistantCard()),
          ],
        ),
      ),
    );
  }
}