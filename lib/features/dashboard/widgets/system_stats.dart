import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class SystemStats extends StatelessWidget {
  const SystemStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.secondaryBlack,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SYSTEM RESOURCES',
            style: TextStyle(
              color: AppTheme.textWhite,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatWidget('CPU', '42%', AppTheme.accentBlue),
              _buildStatWidget('RAM', '68%', AppTheme.warningOrange),
              _buildStatWidget('DISK', '55%', AppTheme.successGreen),
            ],
          ),
          const SizedBox(height: 20),
          _buildNetworkStats(),
        ],
      ),
    );
  }

  Widget _buildStatWidget(String label, String percentage, Color color) {
    return Column(
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: double.parse(percentage.replaceAll('%', '')) / 100,
                color: color,
                backgroundColor: color.withValues(alpha: 0.1),
                strokeWidth: 4,
              ),
              Text(
                percentage,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: AppTheme.textGrey, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildNetworkStats() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNetworkItem('Network In', '1.2 MB/s'),
            _buildNetworkItem('Network Out', '890 KB/s'),
          ],
        ),
      ],
    );
  }

  Widget _buildNetworkItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppTheme.textGrey, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.textWhite,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
