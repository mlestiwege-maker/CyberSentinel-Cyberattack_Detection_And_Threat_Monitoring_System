import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class DefensiveTerminal extends StatefulWidget {
  const DefensiveTerminal({super.key});

  @override
  State<DefensiveTerminal> createState() => _DefensiveTerminalState();
}

class _DefensiveTerminalState extends State<DefensiveTerminal> {
  final TextEditingController _controller = TextEditingController();
  final List<_TerminalLine> _lines = [
    _TerminalLine(r'admin@cybersentinel:~$ scan --target 192.168.1.45', false),
    _TerminalLine('[+] Starting deep scan on 192.168.1.45', true),
    _TerminalLine('[+] Port Scan: 22, 80, 443, 8080 open', true),
    _TerminalLine('[+] Service Detection: Apache/2.4.41', true),
    _TerminalLine('[!] Vulnerability Detected: Outdated Web Server', true),
    _TerminalLine('[+] Scan completed.', true),
    _TerminalLine(r'admin@cybersentinel:~$ isolate --host 192.168.1.45', false),
    _TerminalLine('[+] Host quarantined from outbound traffic', true),
  ];

  final List<Map<String, String>> _commands = [
    {'label': 'Scan IP', 'command': 'scan --target '},
    {'label': 'Block IP', 'command': 'block --ip '},
    {'label': 'Unblock IP', 'command': 'unblock --ip '},
    {'label': 'Trace Route', 'command': 'trace --target '},
    {'label': 'Kill Process', 'command': 'kill --process '},
    {'label': 'Isolate Host', 'command': 'isolate --host '},
    {'label': 'Clear Logs', 'command': 'clear-logs'},
    {'label': 'System Update', 'command': 'update-system'},
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _runCommand(String command) {
    setState(() {
      if (command == 'clear-logs') {
        _lines
          ..clear()
          ..add(_TerminalLine('Logs cleared.', true));
        return;
      }
      if (command == 'update-system') {
        _lines.addAll([
          _TerminalLine(r'admin@cybersentinel:~$ update-system', false),
          _TerminalLine('[+] Checking for security patches...', true),
          _TerminalLine('[+] Applying signatures update...', true),
          _TerminalLine('[+] System update completed successfully.', true),
        ]);
        return;
      }
      if (_controller.text.trim().isNotEmpty) {
        _lines.add(_TerminalLine(r'admin@cybersentinel:~$ ' + _controller.text.trim(), false));
        _lines.add(_TerminalLine('[+] Command queued and processed.', true));
      } else {
        _lines.add(_TerminalLine(r'admin@cybersentinel:~$ ' + command, false));
        _lines.add(_TerminalLine('[+] Command executed.', true));
      }
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.secondaryBlack,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2A3050)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'DEFENSIVE TERMINAL',
              style: TextStyle(
                color: AppTheme.textWhite,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accentBlue.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('TERMINAL', style: TextStyle(color: AppTheme.accentBlue, fontSize: 10)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('LIVE', style: TextStyle(color: AppTheme.successGreen, fontSize: 10)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 120,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF08111F),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF1E2A44)),
              ),
              child: ListView.builder(
                itemCount: _lines.length,
                itemBuilder: (context, index) {
                  final line = _lines[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      line.text,
                      style: TextStyle(
                        color: line.isSystem ? AppTheme.successGreen : AppTheme.textWhite,
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              style: const TextStyle(color: AppTheme.textWhite, fontFamily: 'monospace'),
              decoration: InputDecoration(
                hintText: 'Type a command...',
                hintStyle: const TextStyle(color: AppTheme.textGrey),
                filled: true,
                fillColor: const Color(0xFF08111F),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Color(0xFF1E2A44)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: AppTheme.accentBlue),
                ),
              ),
              onSubmitted: (_) => _runCommand(_controller.text),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _commands.map((item) {
                return OutlinedButton(
                  onPressed: () => _runCommand(item['command']!),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.accentBlue.withOpacity(0.4)),
                    foregroundColor: AppTheme.accentBlue,
                  ),
                  child: Text(item['label']!, style: const TextStyle(fontSize: 11)),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _TerminalLine {
  final String text;
  final bool isSystem;

  _TerminalLine(this.text, this.isSystem);
}
