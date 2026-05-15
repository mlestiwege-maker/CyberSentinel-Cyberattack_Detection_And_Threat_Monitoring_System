import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../models/alert_model.dart';
import '../../../core/theme.dart';

class ThreatTable extends StatefulWidget {
  const ThreatTable({super.key});

  @override
  State<ThreatTable> createState() => _ThreatTableState();
}

class _ThreatTableState extends State<ThreatTable> {
  late Future<List<Alert>> alertsFuture;

  @override
  void initState() {
    super.initState();
    // Trigger a fresh token-aware load so the dashboard doesn't hit 403 on protected alerts.
    alertsFuture = ApiService.fetchThreatFeed();
  }

  Color getSeverityColor(String severity) {
    switch (severity.toUpperCase()) {
      case 'HIGH':
        return AppTheme.dangerRed;
      case 'MEDIUM':
        return AppTheme.warningOrange;
      case 'LOW':
        return AppTheme.successGreen;
      default:
        return AppTheme.textGrey;
    }
  }

  Color getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'DETECTED':
        return AppTheme.dangerRed;
      case 'RESOLVED':
        return AppTheme.successGreen;
      case 'IN_PROGRESS':
        return AppTheme.warningOrange;
      default:
        return AppTheme.textGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.secondaryBlack,
      child: FutureBuilder<List<Alert>>(
        future: alertsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.accentBlue),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: AppTheme.dangerRed),
                  const SizedBox(height: 10),
                  Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: AppTheme.textGrey),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No threats detected',
                style: TextStyle(color: AppTheme.textGrey),
              ),
            );
          }

          final alerts = snapshot.data!;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'LIVE THREAT FEED',
                    style: TextStyle(
                      color: AppTheme.textWhite,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTableHeader(),
                  const SizedBox(height: 8),
                  ...alerts.take(10).map((alert) => _buildTableRow(alert)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTableHeader() {
    const headerStyle = TextStyle(
      color: AppTheme.textGrey,
      fontSize: 11,
      fontWeight: FontWeight.bold,
    );

    return const Row(
      children: [
        SizedBox(width: 60, child: Text('TIME', style: headerStyle)),
        SizedBox(width: 100, child: Text('TYPE', style: headerStyle)),
        Expanded(child: Text('SOURCE IP', style: headerStyle)),
        SizedBox(width: 120, child: Text('LOCATION', style: headerStyle)),
        SizedBox(width: 80, child: Text('SEVERITY', style: headerStyle)),
        SizedBox(width: 100, child: Text('STATUS', style: headerStyle)),
      ],
    );
  }

  Widget _buildTableRow(Alert alert) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF2A3050), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              alert.time,
              style: const TextStyle(color: AppTheme.textGrey, fontSize: 12),
            ),
          ),
          SizedBox(
            width: 100,
            child: Text(
              alert.type,
              style: const TextStyle(color: AppTheme.textWhite, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              alert.sourceIp,
              style: const TextStyle(color: AppTheme.textWhite, fontSize: 12),
            ),
          ),
          SizedBox(
            width: 120,
            child: Text(
              alert.location,
              style: const TextStyle(color: AppTheme.textGrey, fontSize: 12),
            ),
          ),
          SizedBox(
            width: 80,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: getSeverityColor(alert.severity).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                alert.severity,
                style: TextStyle(
                  color: getSeverityColor(alert.severity),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 100,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: getStatusColor(alert.status).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                alert.status,
                style: TextStyle(
                  color: getStatusColor(alert.status),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
