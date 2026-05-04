import 'package:flutter/material.dart';
import '../../core/theme.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late List<_ReportItem> _reports;

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

  void _exportReport(int index) {
    final now = DateTime.now();
    setState(() {
      _reports[index] = _ReportItem(
        _reports[index].title,
        'Generated ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
        _reports[index].format,
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_reports[index].title} exported (${_reports[index].format})')),
    );
  }

  void _exportAllReports() {
    for (var i = 0; i < _reports.length; i++) {
      _exportReport(i);
    }
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
                    onPressed: _exportAllReports,
                    icon: const Icon(Icons.file_download_outlined, size: 16),
                    label: const Text('Export All Reports'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentBlue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
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
                    onPressed: () => _exportReport(index),
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
