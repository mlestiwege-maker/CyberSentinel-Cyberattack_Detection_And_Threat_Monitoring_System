import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'dart:math';

class MonitoringScreen extends StatefulWidget {
  const MonitoringScreen({super.key});

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> {
  final _random = Random();

  late List<_Metric> _metrics;

  @override
  void initState() {
    super.initState();
    _metrics = [
      _Metric('CPU', '42%', AppTheme.accentBlue),
      _Metric('RAM', '68%', AppTheme.warningOrange),
      _Metric('Disk', '55%', AppTheme.successGreen),
      _Metric('Network In', '1.2 MB/s', AppTheme.accentBlue),
      _Metric('Network Out', '890 KB/s', AppTheme.warningOrange),
      _Metric('Uptime', '99.98%', AppTheme.successGreen),
    ];
  }

  void _refreshMetrics() {
    setState(() {
      _metrics = [
        _Metric('CPU', '${35 + _random.nextInt(30)}%', AppTheme.accentBlue),
        _Metric('RAM', '${50 + _random.nextInt(35)}%', AppTheme.warningOrange),
        _Metric('Disk', '${45 + _random.nextInt(20)}%', AppTheme.successGreen),
        _Metric('Network In', '${(0.8 + _random.nextDouble() * 1.8).toStringAsFixed(1)} MB/s', AppTheme.accentBlue),
        _Metric('Network Out', '${(500 + _random.nextInt(900))} KB/s', AppTheme.warningOrange),
        _Metric('Uptime', '${(99 + _random.nextDouble()).toStringAsFixed(2)}%', AppTheme.successGreen),
      ];
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Monitoring metrics refreshed')));
  }

  @override
  Widget build(BuildContext context) {
    return _FeatureShell(
      title: 'Threat Monitor',
      subtitle: 'Live operational status and host telemetry',
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: _refreshMetrics,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Refresh Metrics'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentBlue,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.8,
              ),
              itemCount: _metrics.length,
              itemBuilder: (context, index) {
                final metric = _metrics[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryBlack,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF2A3050)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(color: metric.color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(metric.name, style: const TextStyle(color: AppTheme.textGrey, fontSize: 11)),
                            const SizedBox(height: 4),
                            Text(metric.value, style: TextStyle(color: metric.color, fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
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
  }
}

class _Metric {
  final String name;
  final String value;
  final Color color;

  _Metric(this.name, this.value, this.color);
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
