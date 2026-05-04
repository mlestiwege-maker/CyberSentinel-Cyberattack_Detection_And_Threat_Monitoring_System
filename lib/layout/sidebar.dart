import 'package:flutter/material.dart';
import '../core/theme.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Dashboard', Icons.dashboard),
      ('Alerts', Icons.notifications_active),
      ('Threat Monitor', Icons.shield),
      ('Incidents', Icons.error),
      ('Attack Map', Icons.map),
      ('Defensive Console', Icons.terminal),
      ('Reports', Icons.assessment),
      ('Settings', Icons.settings),
    ];

    return Container(
      width: 220,
      color: AppTheme.primaryBlack,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.accentBlue,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.security, color: Colors.white),
                ),
                const SizedBox(width: 8),
                const Text(
                  'CyberSentinel',
                  style: TextStyle(
                    color: AppTheme.textWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            color: const Color(0xFF2A3050),
            height: 1,
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final (label, icon) = items[index];
                final isSelected = selectedIndex == index;

                return Container(
                  color: isSelected
                      ? AppTheme.accentBlue.withOpacity(0.1)
                      : Colors.transparent,
                  child: Material(
                    color: Colors.transparent,
                    child: ListTile(
                      leading: Icon(
                        icon,
                        color: isSelected
                            ? AppTheme.accentBlue
                            : AppTheme.textGrey,
                        size: 20,
                      ),
                      title: Text(
                        label,
                        style: TextStyle(
                          color: isSelected
                              ? AppTheme.accentBlue
                              : AppTheme.textGrey,
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      onTap: () => onItemSelected(index),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      hoverColor: AppTheme.accentBlue.withOpacity(0.05),
                    ),
                  ),
                );
              },
            ),
          ),
          Divider(
            color: const Color(0xFF2A3050),
            height: 1,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accentBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppTheme.accentBlue.withOpacity(0.3),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'App Version',
                    style: TextStyle(
                      color: AppTheme.textGrey,
                      fontSize: 10,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'v2.0.0',
                    style: TextStyle(
                      color: AppTheme.accentBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
