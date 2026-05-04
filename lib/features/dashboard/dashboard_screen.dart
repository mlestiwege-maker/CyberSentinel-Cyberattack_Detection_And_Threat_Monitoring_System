import 'package:flutter/material.dart';
import 'widgets/stat_card.dart';
import 'widgets/threat_table.dart';
import 'widgets/attack_map.dart';
import 'widgets/system_stats.dart';
import 'widgets/defensive_terminal.dart';
import 'widgets/twilio_panel.dart';
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
              const Text(
                'CYBERSENTINEL ADMINISTRATOR CONSOLE',
                style: TextStyle(
                  color: AppTheme.textWhite,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Live security intelligence, response tools, and incident visibility in one place.',
                style: TextStyle(color: AppTheme.textGrey),
              ),
              const SizedBox(height: 16),
              // Top Stats Row
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 900;
                  return isWide
                      ? const Row(
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
                        )
                      : Column(
                          children: [
                            Row(children: const [Expanded(child: StatCard(title: 'TOTAL THREATS', value: '87', color: AppTheme.dangerRed, trend: '↑ 23%')), SizedBox(width: 12), Expanded(child: StatCard(title: 'HIGH RISK ALERTS', value: '23', color: AppTheme.warningOrange, trend: '↑ 35%'))]),
                            const SizedBox(height: 12),
                            Row(children: const [Expanded(child: StatCard(title: 'INCIDENTS', value: '16', color: AppTheme.accentBlue, trend: '')), SizedBox(width: 12), Expanded(child: StatCard(title: 'RESOLVED', value: '54', color: AppTheme.successGreen, trend: '↑ 12%'))]),
                          ],
                        );
                },
              ),
              const SizedBox(height: 20),

              // Main Content Area
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 1000;
                  final mainContent = [
                    Expanded(
                      child: SizedBox(
                        height: 460,
                        child: Card(
                          color: AppTheme.secondaryBlack,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(color: Color(0xFF2A3050), width: 1),
                          ),
                          child: const ThreatTable(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12, height: 12),
                    Expanded(
                      child: SizedBox(
                        height: 460,
                        child: Card(
                          color: AppTheme.secondaryBlack,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(color: Color(0xFF2A3050), width: 1),
                          ),
                          child: const AttackMap(),
                        ),
                      ),
                    ),
                  ];

                  return isWide
                      ? SizedBox(height: 460, child: Row(children: mainContent))
                      : Column(
                          children: [
                            SizedBox(
                              height: 420,
                              child: Card(
                                color: AppTheme.secondaryBlack,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: const BorderSide(color: Color(0xFF2A3050), width: 1),
                                ),
                                child: const ThreatTable(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 420,
                              child: Card(
                                color: AppTheme.secondaryBlack,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: const BorderSide(color: Color(0xFF2A3050), width: 1),
                                ),
                                child: const AttackMap(),
                              ),
                            ),
                          ],
                        );
                },
              ),
              const SizedBox(height: 20),

              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 900;
                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Expanded(
                          child: Card(
                            color: AppTheme.secondaryBlack,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                              side: BorderSide(color: Color(0xFF2A3050), width: 1),
                            ),
                            child: SystemStats(),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(height: 360, child: DefensiveTerminal()),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(height: 360, child: TwilioPanel()),
                        ),
                      ],
                    );
                  }

                  return Column(
                    children: const [
                      Card(
                        color: AppTheme.secondaryBlack,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          side: BorderSide(color: Color(0xFF2A3050), width: 1),
                        ),
                        child: SystemStats(),
                      ),
                      SizedBox(height: 12),
                      SizedBox(height: 360, child: DefensiveTerminal()),
                      SizedBox(height: 12),
                      SizedBox(height: 420, child: TwilioPanel()),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
