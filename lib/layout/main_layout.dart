import 'package:flutter/material.dart';
import 'sidebar.dart';
import '../core/theme.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/monitoring/monitoring_screen.dart';
import '../features/monitoring/attack_map_screen.dart';
import '../features/monitoring/defensive_console_screen.dart';
import '../features/users/users_roles_screen.dart';
import '../features/sms/twilio_screen.dart';
import '../features/voice/voice_assistant_screen.dart';
import '../features/incidents/incidents_screen.dart';
import '../features/reports/reports_screen.dart';
import '../features/settings/settings_screen.dart';
import '../services/app_state.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int selectedIndex = 0;

  late final List<Widget> _screens = [
    const DashboardScreen(),
    const MonitoringScreen(),
    const IncidentsScreen(),
    const AttackMapScreen(),
    const DefensiveConsoleScreen(),
    const UsersRolesScreen(),
    const ReportsScreen(),
    const TwilioScreen(),
    const VoiceAssistantScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            selectedIndex: selectedIndex,
            onItemSelected: (index) {
              setState(() => selectedIndex = index);
            },
          ),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: _buildContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: AppTheme.primaryBlack,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFF2A3050),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.accentBlue.withOpacity(0.2)),
                ),
                child: const Icon(Icons.security, color: AppTheme.accentBlue, size: 18),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'CyberSentinel',
                    style: TextStyle(
                      color: AppTheme.textWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'ADMINISTRATOR CONSOLE',
                    style: TextStyle(
                      color: AppTheme.textGrey,
                      fontSize: 10,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 18),
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search threats, IPs, users, incidents...',
                  hintStyle: const TextStyle(color: AppTheme.textGrey, fontSize: 12),
                  filled: true,
                  fillColor: AppTheme.secondaryBlack,
                  prefixIcon: const Icon(Icons.search, color: AppTheme.textGrey, size: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF2A3050), width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF2A3050), width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppTheme.accentBlue, width: 1),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                style: const TextStyle(color: AppTheme.textWhite, fontSize: 12),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.successGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.successGreen.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(color: AppTheme.successGreen, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                const Text(
                  'SYSTEM SECURE',
                  style: TextStyle(
                    color: AppTheme.successGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _CircleIconButton(
            icon: Icons.notifications_none,
            badge: '12',
            onTap: _showNotifications,
            tooltip: 'Notifications',
          ),
          const SizedBox(width: 10),
          _CircleIconButton(
            icon: AppState.instance.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            onTap: () {
              AppState.instance.toggleTheme();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppState.instance.isDarkMode ? 'Dark mode enabled' : 'Light mode enabled'),
                  duration: const Duration(seconds: 1),
                ),
              );
              setState(() {});
            },
            tooltip: 'Toggle theme',
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: AppTheme.secondaryBlack,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFF2A3050)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppTheme.accentBlue.withOpacity(0.2),
                  child: const Text(
                    'LM',
                    style: TextStyle(
                      color: AppTheme.accentBlue,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Admin', style: TextStyle(color: AppTheme.textWhite, fontSize: 12, fontWeight: FontWeight.w600)),
                    Text('ADMIN', style: TextStyle(color: AppTheme.accentBlue, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return _screens[selectedIndex];
  }

  void _showNotifications() {
    if (!AppState.instance.notificationsEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notifications are disabled in Settings')),
      );
      return;
    }

    final notifications = [
      'High-risk port scan detected from 185.220.101.42',
      'Brute-force attempt blocked on admin endpoint',
      'Incident INC-2026-014 moved to In Progress',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.secondaryBlack,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Notifications',
                style: TextStyle(color: AppTheme.textWhite, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...notifications.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(item, style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final String? badge;
  final VoidCallback? onTap;
  final String? tooltip;

  const _CircleIconButton({required this.icon, this.badge, this.onTap, this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppTheme.secondaryBlack,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF2A3050)),
              ),
              child: Icon(icon, color: AppTheme.textGrey, size: 18),
            ),
            if (badge != null)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppTheme.dangerRed,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
