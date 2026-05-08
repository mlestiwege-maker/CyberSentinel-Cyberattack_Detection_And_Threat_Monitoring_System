import 'package:flutter/material.dart';
import 'widgets/stat_card.dart';
import 'widgets/threat_table.dart';
import 'widgets/attack_map.dart';
import 'widgets/system_stats.dart';
import 'widgets/defensive_terminal.dart';
import 'widgets/twilio_panel.dart';
import 'widgets/incidents_overview.dart';
import 'widgets/top_attack_types.dart';
import 'widgets/voice_assistant_card.dart';
import '../../core/theme.dart';
import '../../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _summary;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    try {
      final data = await ApiService.fetchDashboardSummary();
      setState(() {
        _summary = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

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
              _buildTopStats(),
              const SizedBox(height: 20),
              _buildThreatAndMap(),
              const SizedBox(height: 20),
              _buildAnalytics(),
              const SizedBox(height: 20),
              _buildTools(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopStats() {
    final totalThreats = _summary?['total_threats']?.toString() ?? '87';
    final highRisk = _summary?['high']?.toString() ?? '23';
    final unreadAlerts = _summary?['unread_alerts']?.toString() ?? '12';
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 1100;

        if (isWide) {
          return const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: 220, child: StatCard(title: 'TOTAL THREATS', value: '87', color: AppTheme.dangerRed, trend: '↑ 23%')),
              SizedBox(width: 12),
              SizedBox(width: 220, child: StatCard(title: 'HIGH RISK ALERTS', value: '23', color: AppTheme.warningOrange, trend: '↑ 35%')),
              SizedBox(width: 12),
              SizedBox(width: 220, child: StatCard(title: 'INCIDENTS', value: '16', color: AppTheme.accentBlue, trend: '')),
              SizedBox(width: 12),
              SizedBox(width: 220, child: StatCard(title: 'RESOLVED', value: '54', color: AppTheme.successGreen, trend: '↑ 12%')),
              SizedBox(width: 12),
              SizedBox(width: 220, child: StatCard(title: 'USERS ONLINE', value: '5', color: Color(0xFF9B59FF), trend: 'Active')),
            ],
          );
        }

        return const Column(
          children: [
            Row(
              children: [
                Expanded(child: StatCard(title: 'TOTAL THREATS', value: '87', color: AppTheme.dangerRed, trend: '↑ 23%')),
                SizedBox(width: 12),
                Expanded(child: StatCard(title: 'HIGH RISK ALERTS', value: '23', color: AppTheme.warningOrange, trend: '↑ 35%')),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: StatCard(title: 'INCIDENTS', value: '16', color: AppTheme.accentBlue, trend: '')),
                SizedBox(width: 12),
                Expanded(child: StatCard(title: 'RESOLVED', value: '54', color: AppTheme.successGreen, trend: '↑ 12%')),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: StatCard(title: 'USERS ONLINE', value: '5', color: Color(0xFF9B59FF), trend: 'Active')),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildThreatAndMap() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 1000;

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Expanded(
                child: SizedBox(
                  height: 460,
                  child: Card(
                    color: AppTheme.secondaryBlack,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      side: BorderSide(color: Color(0xFF2A3050), width: 1),
                    ),
                    child: ThreatTable(),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 460,
                  child: Card(
                    color: AppTheme.secondaryBlack,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      side: BorderSide(color: Color(0xFF2A3050), width: 1),
                    ),
                    child: AttackMap(),
                  ),
                ),
              ),
            ],
          );
        }

        return const Column(
          children: [
            SizedBox(
              height: 420,
              child: Card(
                color: AppTheme.secondaryBlack,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  side: BorderSide(color: Color(0xFF2A3050), width: 1),
                ),
                child: ThreatTable(),
              ),
            ),
            SizedBox(height: 12),
            SizedBox(
              height: 420,
              child: Card(
                color: AppTheme.secondaryBlack,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  side: BorderSide(color: Color(0xFF2A3050), width: 1),
                ),
                child: AttackMap(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnalytics() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 1100;

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Expanded(child: SizedBox(height: 260, child: IncidentsOverview())),
              SizedBox(width: 12),
              Expanded(child: SizedBox(height: 260, child: TopAttackTypes())),
              SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 260,
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
              ),
            ],
          );
        }

        return const Column(
          children: [
            SizedBox(height: 240, child: IncidentsOverview()),
            SizedBox(height: 12),
            SizedBox(height: 260, child: TopAttackTypes()),
            SizedBox(height: 12),
            SizedBox(
              height: 260,
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
          ],
        );
      },
    );
  }

  Widget _buildTools() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 1100;

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Expanded(child: SizedBox(height: 260, child: VoiceAssistantCard())),
              SizedBox(width: 12),
              Expanded(child: SizedBox(height: 360, child: DefensiveTerminal())),
              SizedBox(width: 12),
              Expanded(child: SizedBox(height: 360, child: TwilioPanel())),
            ],
          );
        }

        return const Column(
          children: [
            SizedBox(height: 260, child: VoiceAssistantCard()),
            SizedBox(height: 12),
            SizedBox(height: 360, child: DefensiveTerminal()),
            SizedBox(height: 12),
            SizedBox(height: 420, child: TwilioPanel()),
          ],
        );
      },
    );
  }
}