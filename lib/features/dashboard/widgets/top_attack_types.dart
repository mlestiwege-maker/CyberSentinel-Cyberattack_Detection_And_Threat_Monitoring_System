import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class TopAttackTypes extends StatelessWidget {
  const TopAttackTypes({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Brute Force', 35, 0.4, AppTheme.dangerRed),
      ('Port Scan', 22, 0.25, AppTheme.warningOrange),
      ('ML Anomaly', 15, 0.17, AppTheme.accentBlue),
      ('SQL Injection', 10, 0.11, AppTheme.successGreen),
      ('XSS Attack', 5, 0.07, const Color(0xFF9B59FF)),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.secondaryBlack,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2A3050)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TOP ATTACK TYPES',
              style: TextStyle(
                color: AppTheme.textWhite,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ...items.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.$1,
                            style: const TextStyle(
                              color: AppTheme.textGrey,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Text(
                          '${item.$2}',
                          style: const TextStyle(
                            color: AppTheme.textWhite,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '(${(item.$3 * 100).round()}%)',
                          style: TextStyle(
                            color: item.$4,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        minHeight: 6,
                        value: item.$3,
                        backgroundColor: const Color(0xFF2A3050),
                        valueColor: AlwaysStoppedAnimation<Color>(item.$4),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
