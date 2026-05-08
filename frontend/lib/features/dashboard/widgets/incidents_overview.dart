import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class IncidentsOverview extends StatelessWidget {
  const IncidentsOverview({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Open', 8, AppTheme.dangerRed),
      ('In Progress', 5, AppTheme.warningOrange),
      ('Resolved', 3, AppTheme.successGreen),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.secondaryBlack,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2A3050)),
      ),
      child: LimitedBox(
        maxHeight: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'INCIDENTS OVERVIEW',
                style: TextStyle(
                  color: AppTheme.textWhite,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 82,
                      height: 82,
                      child: CircularProgressIndicator(
                        value: 0.5,
                        strokeWidth: 10,
                        backgroundColor: Color(0xFF2A3050),
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.dangerRed),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '16',
                          style: TextStyle(
                            color: AppTheme.textWhite,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Total',
                          style: TextStyle(
                            color: AppTheme.textGrey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: item.$3,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.$1,
                          style: const TextStyle(
                            color: AppTheme.textGrey,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${item.$2}',
                        style: const TextStyle(
                          color: AppTheme.textWhite,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.$2 == 8
                            ? '50%'
                            : item.$2 == 5
                                ? '31%'
                                : '19%',
                        style: TextStyle(
                          color: item.$3,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
