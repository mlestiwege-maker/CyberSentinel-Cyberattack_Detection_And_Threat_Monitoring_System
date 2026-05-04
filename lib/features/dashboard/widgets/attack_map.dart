import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class AttackMap extends StatefulWidget {
  const AttackMap({super.key});

  @override
  State<AttackMap> createState() => _AttackMapState();
}

class _AttackMapState extends State<AttackMap> {
  // Mock geo-IP data
  final List<Map<String, dynamic>> attacks = [
    {'lat': 0.0, 'lng': 0.0, 'city': 'Origin', 'severity': 'HIGH'},
    {'lat': -25.2744, 'lng': 133.7751, 'city': 'Zimbabwe, Harare', 'severity': 'HIGH'},
    {'lat': 40.7128, 'lng': -74.0060, 'city': 'United States, NY', 'severity': 'HIGH'},
    {'lat': 52.5200, 'lng': 13.4050, 'city': 'Germany, Berlin', 'severity': 'MEDIUM'},
    {'lat': -29.8497, 'lng': 31.0292, 'city': 'South Africa, JHB', 'severity': 'HIGH'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.secondaryBlack,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ATTACK MAP (LIVE)',
                style: TextStyle(
                  color: AppTheme.textWhite,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  _buildLegendItem('Low', AppTheme.successGreen),
                  const SizedBox(width: 16),
                  _buildLegendItem('Medium', AppTheme.warningOrange),
                  const SizedBox(width: 16),
                  _buildLegendItem('High', AppTheme.dangerRed),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _buildWorldMap(),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textGrey,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildWorldMap() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite ? constraints.maxWidth : 400.0;
        final height = constraints.maxHeight.isFinite ? constraints.maxHeight : 300.0;

        return Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(
              painter: WorldMapPainter(attacks),
              size: Size(width, height),
            ),
            ...attacks.map((attack) {
              final left = ((attack['lng'] as double) + 180) / 360 * width;
              final top = (90 - (attack['lat'] as double)) / 180 * height;

              return Positioned(
                left: left.clamp(0.0, width - 12),
                top: top.clamp(0.0, height - 12),
                child: Tooltip(
                  message: '${attack['city']} - ${attack['severity']}',
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getSeverityColor(attack['severity']),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _getSeverityColor(attack['severity']).withOpacity(0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'HIGH':
        return AppTheme.dangerRed;
      case 'MEDIUM':
        return AppTheme.warningOrange;
      case 'LOW':
        return AppTheme.successGreen;
      default:
        return AppTheme.textGrey;
    }
  }
}

class WorldMapPainter extends CustomPainter {
  final List<Map<String, dynamic>> attacks;

  WorldMapPainter(this.attacks);

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFF1A2540)
      ..strokeWidth = 0.5;

    // Draw grid
    for (int i = 0; i < 8; i++) {
      canvas.drawLine(
        Offset(i * size.width / 8, 0),
        Offset(i * size.width / 8, size.height),
        gridPaint,
      );
    }

    for (int i = 0; i < 6; i++) {
      canvas.drawLine(
        Offset(0, i * size.height / 6),
        Offset(size.width, i * size.height / 6),
        gridPaint,
      );
    }

    // Draw connection lines between attacks
    for (int i = 0; i < attacks.length - 1; i++) {
      final from = attacks[i];
      final to = attacks[i + 1];

      final fromX = (from['lng'] + 180) / 360 * size.width;
      final fromY = (90 - from['lat']) / 180 * size.height;
      final toX = (to['lng'] + 180) / 360 * size.width;
      final toY = (90 - to['lat']) / 180 * size.height;

      final linePaint = Paint()
        ..color = AppTheme.dangerRed.withOpacity(0.3)
        ..strokeWidth = 2;

      canvas.drawLine(Offset(fromX, fromY), Offset(toX, toY), linePaint);
    }
  }

  @override
  bool shouldRepaint(WorldMapPainter oldDelegate) => true;
}
