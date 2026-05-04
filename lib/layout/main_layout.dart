import 'package:flutter/material.dart';
import 'sidebar.dart';
import '../core/theme.dart';
import '../features/dashboard/dashboard_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int selectedIndex = 0;

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
          const Text(
            'ADMINISTRATOR CONSOLE',
            style: TextStyle(
              color: AppTheme.accentBlue,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          // Search Bar
          SizedBox(
            width: 300,
            height: 40,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search threats, IPs, users, incidents...',
                hintStyle: const TextStyle(
                  color: AppTheme.textGrey,
                  fontSize: 12,
                ),
                filled: true,
                fillColor: AppTheme.secondaryBlack,
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppTheme.textGrey,
                  size: 18,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(
                    color: Color(0xFF2A3050),
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(
                    color: Color(0xFF2A3050),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(
                    color: AppTheme.accentBlue,
                    width: 1,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              style: const TextStyle(
                color: AppTheme.textWhite,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 20),
          // Status Chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.successGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppTheme.successGreen.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppTheme.successGreen,
                    shape: BoxShape.circle,
                  ),
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
          const SizedBox(width: 20),
          // Notification Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.secondaryBlack,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: const Color(0xFF2A3050),
                width: 1,
              ),
            ),
            child: const Stack(
              children: [
                Icon(Icons.notifications, color: AppTheme.textGrey, size: 18),
                Positioned(
                  right: 0,
                  top: 0,
                  child: CircleAvatar(
                    radius: 3,
                    backgroundColor: AppTheme.dangerRed,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // User Avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.accentBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppTheme.accentBlue.withOpacity(0.3),
              ),
            ),
            child: Center(
              child: Text(
                'LM',
                style: TextStyle(
                  color: AppTheme.accentBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final screens = [
      const DashboardScreen(),
      const Center(
        child: Text(
          'Threat Monitor',
          style: TextStyle(color: AppTheme.textWhite),
        ),
      ),
      const Center(
        child: Text(
          'Incidents',
          style: TextStyle(color: AppTheme.textWhite),
        ),
      ),
      const Center(
        child: Text(
          'Attack Map',
          style: TextStyle(color: AppTheme.textWhite),
        ),
      ),
      const Center(
        child: Text(
          'Defensive Console',
          style: TextStyle(color: AppTheme.textWhite),
        ),
      ),
      const Center(
        child: Text(
          'Reports',
          style: TextStyle(color: AppTheme.textWhite),
        ),
      ),
      const Center(
        child: Text(
          'Settings',
          style: TextStyle(color: AppTheme.textWhite),
        ),
      ),
    ];

    return screens[selectedIndex];
  }
}
