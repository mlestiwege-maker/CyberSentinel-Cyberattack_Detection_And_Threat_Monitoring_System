import 'package:flutter/material.dart';
import 'widgets/stat_card.dart';
import 'widgets/threat_table.dart';
import 'widgets/attack_map.dart';
import 'widgets/system_stats.dart';
import '../../core/theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.primaryBlack,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Stats Row
              const Row(
                children: [
                  StatCard(
                    title: 'TOTAL THREATS',
                    value: '87',
                    color: AppTheme.dangerRed,
                    trend: '↑ 23%',
                  ),
                  SizedBox(width: 12),
                  StatCard(
                    title: 'HIGH RISK ALERTS',
                    value: '23',
                    color: AppTheme.warningOrange,
                    trend: '↑ 35%',
                  ),
                  SizedBox(width: 12),
                  StatCard(
                    title: 'INCIDENTS',
                    value: '16',
                    color: AppTheme.accentBlue,
                    trend: '',
                  ),
                  SizedBox(width: 12),
                  StatCard(
                    title: 'RESOLVED',
                    value: '54',
                    color: AppTheme.successGreen,
                    trend: '↑ 12%',
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Main Content Area
              SizedBox(
                height: 400,
                child: Row(
                  children: [
                    // Left side - Threat Table
                    Expanded(
                      child: Card(
                        color: AppTheme.secondaryBlack,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(
                            color: Color(0xFF2A3050),
                            width: 1,
                          ),
                        ),
                        child: const ThreatTable(),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Right side - Attack Map
                    Expanded(
                      child: Card(
                        color: AppTheme.secondaryBlack,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(
                            color: Color(0xFF2A3050),
                            width: 1,
                          ),
                        ),
                        child: const AttackMap(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Bottom - System Stats
              Card(
                color: AppTheme.secondaryBlack,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(
                    color: Color(0xFF2A3050),
                    width: 1,
                  ),
                ),
                child: const SystemStats(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
