import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../services/access_control.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late List<_ReportItem> _reports;
  String? _lastExportPath;

  @override
  void initState() {
    super.initState();
    _reports = [
      _ReportItem('Daily Threat Report', 'Generated 10:00 AM', 'PDF'),
      _ReportItem('Weekly Incident Summary', 'Generated Monday', 'PDF'),
      _ReportItem('Executive Dashboard Export', 'Generated Today', 'CSV'),
      _ReportItem('SMS Activity Report', 'Generated Today', 'CSV'),
    ];
  }

  Future<void> _exportReport(int index, {bool notify = true}) async {
    if (!AccessControl.instance.canPerform('reports.export')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Current role cannot export reports')));
      return;
    }

    final now = DateTime.now();
    final report = _reports[index];
    final directory = Directory('${Platform.environment['HOME'] ?? Directory.current.path}/CyberSentinel/reports');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    final stamp = DateFormat('yyyyMMdd_HHmmss').format(now);
    final fileName = '${_slugify(report.title)}_$stamp.${report.format.toLowerCase()}';
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(_renderReport(report, now));

    if (!mounted) {
      return;
    }

    setState(() {
      _reports[index] = _ReportItem(
        report.title,
        'Generated ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
        report.format,
      );
      _lastExportPath = file.path;
    });

    if (notify) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${report.title} exported to ${file.path}')),
      );
    }
  }

  Future<void> _exportAllReports() async {
    if (!AccessControl.instance.canPerform('reports.export')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Current role cannot export reports')));
      return;
    }

    for (var i = 0; i < _reports.length; i++) {
      await _exportReport(i, notify: false);
    }

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All reports exported to the CyberSentinel folder')));
  }

  String _renderReport(_ReportItem report, DateTime timestamp) {
    return '''
CyberSentinel Report Export
Title: ${report.title}
Generated: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp)}
Format: ${report.format}

Summary:
- Security posture reviewed
- Threat feed archived
- Export created by the CyberSentinel desktop console
''';
  }

  String _slugify(String input) {
    return input.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_').replaceAll(RegExp(r'_+'), '_').replaceAll(RegExp(r'^_+|_+$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final teamSnapshot = [
      ('Tadiwa Sharara', 'Project Planning'),
      ('Bunu Anesu', 'Backend Development'),
      ('Madamu Creig', 'Network Monitoring'),
      ('Davison Karamenti', 'Machine Learning'),
      ('Dzimbanhete Bhunu', 'Threat Detection'),
      ('Lestiwege Mufutumari', 'Frontend Development'),
      ('Tinashe Matyamaenza', 'Testing'),
      ('Agatha Katiyo', 'Documentation'),
    ];

    return AnimatedBuilder(
      animation: AccessControl.instance,
      builder: (context, _) {
        final canExport = AccessControl.instance.canPerform('reports.export');

        return _FeatureShell(
          title: 'Reports',
          subtitle: 'Exportable security summaries and audit data',
          child: ListView(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 16),
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
                      'PROJECT CONTRIBUTORS',
                      style: TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'The current team structure that supports the CyberSentinel build and delivery.',
                      style: TextStyle(color: AppTheme.textGrey, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton.icon(
                        onPressed: canExport ? _exportAllReports : null,
                        icon: const Icon(Icons.file_download_outlined, size: 16),
                        label: const Text('Export All Reports'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentBlue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_lastExportPath != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.accentBlue.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.accentBlue.withOpacity(0.2)),
                        ),
                        child: Text(
                          'Last export saved to $_lastExportPath',
                          style: const TextStyle(color: AppTheme.textGrey, fontSize: 12),
                        ),
                      ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: teamSnapshot
                          .map(
                            (member) => Chip(
                              label: Text('${member.$1} • ${member.$2}'),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
              ..._reports.asMap().entries.map((entry) {
                final index = entry.key;
                final report = entry.value;
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
                      const Icon(Icons.description_outlined, color: AppTheme.accentBlue),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(report.title, style: const TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text(report.generatedAt, style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      TextButton(
                        onPressed: canExport ? () => _exportReport(index) : null,
                        child: const Text('Export'),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.accentBlue.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(report.format, style: const TextStyle(color: AppTheme.accentBlue, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _ReportItem {
  final String title;
  final String generatedAt;
  final String format;

  _ReportItem(this.title, this.generatedAt, this.format);
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
