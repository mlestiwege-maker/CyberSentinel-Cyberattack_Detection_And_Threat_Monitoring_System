import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../dashboard/widgets/attack_map.dart';

class AttackMapScreen extends StatelessWidget {
  const AttackMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.primaryBlack,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Attack Map',
            style: TextStyle(
              color: AppTheme.textWhite,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Geo-IP visualization of hostile connections and hot zones',
            style: TextStyle(color: AppTheme.textGrey),
          ),
          SizedBox(height: 16),
          Expanded(
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
      ),
    );
  }
}
