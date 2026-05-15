import 'package:flutter/material.dart';
import 'package:cybersentinel_frontend/core/theme.dart';

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
      ('Dashboard', Icons.dashboard_rounded, null),
      ('Threat Monitor', Icons.shield_outlined, null),
      ('Incidents', Icons.report_gmailerrorred_outlined, null),
      ('Attack Map', Icons.public, null),
      ('Defensive Console', Icons.terminal_rounded, null),
      ('Users & Roles', Icons.group_outlined, null),
      ('Reports', Icons.description_outlined, null),
      ('SMS / Twilio', Icons.sms_outlined, 'LIVE'),
      ('Voice Assistant', Icons.graphic_eq, null),
      ('Settings', Icons.settings_outlined, null),
    ];

    return Container(
      width: 220,
      color: AppTheme.primaryBlack,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 22, 16, 18),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.accentBlue.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.accentBlue.withValues(alpha: 0.25)),
                  ),
                  child: const Icon(Icons.security, color: AppTheme.accentBlue),
                ),
                const SizedBox(height: 12),
                const Text(
                  'CyberSentinel',
                  style: TextStyle(
                    color: AppTheme.textWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'DEFENSIVE ATTACK TERMINAL',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textGrey,
                    fontSize: 10,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            color: Color(0xFF2A3050),
            height: 1,
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = selectedIndex == index;

                return Container(
                  color: isSelected
                      ? AppTheme.accentBlue.withValues(alpha: 0.1)
                      : Colors.transparent,
                  child: Material(
                    color: Colors.transparent,
                    child: ListTile(
                      leading: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            item.$2,
                            color: isSelected ? AppTheme.accentBlue : AppTheme.textGrey,
                            size: 20,
                          ),
                          if (item.$3 != null)
                            Positioned(
                              right: -8,
                              top: -2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppTheme.successGreen.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppTheme.successGreen.withValues(alpha: 0.25)),
                                ),
                                child: Text(
                                  item.$3!,
                                  style: const TextStyle(
                                    color: AppTheme.successGreen,
                                    fontSize: 7,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: Text(
                        item.$1,
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
                      hoverColor: AppTheme.accentBlue.withValues(alpha: 0.05),
                      selected: isSelected,
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(
            color: Color(0xFF2A3050),
            height: 1,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accentBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppTheme.accentBlue.withValues(alpha: 0.3),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'APP VERSION',
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
                  SizedBox(height: 10),
                  Text(
                    'Lestiwege Mufutumari',
                    style: TextStyle(
                      color: AppTheme.textWhite,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
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
