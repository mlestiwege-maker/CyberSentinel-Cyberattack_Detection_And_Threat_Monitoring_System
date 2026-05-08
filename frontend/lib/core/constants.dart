class AppConstants {
  static const String appName = 'CyberSentinel';
  static const String apiBaseUrl = 'http://127.0.0.1:8000';
  static const String apiVersion = '/api/v1';
  
  // API Endpoints
  static const String alertsEndpoint = '$apiBaseUrl$apiVersion/alerts';
  static const String threatsEndpoint = '$apiBaseUrl$apiVersion/threats';
  static const String incidentsEndpoint = '$apiBaseUrl$apiVersion/incidents';
  static const String dashboardSummaryEndpoint = '$apiBaseUrl$apiVersion/dashboard/summary';
  static const String twilioSendEndpoint = '$apiBaseUrl$apiVersion/twilio/send';
  static const String voiceCommandEndpoint = '$apiBaseUrl$apiVersion/voice/command';
  static const String teamMembersEndpoint = '$apiBaseUrl$apiVersion/users/team';
  static const String reportsEndpoint = '$apiBaseUrl$apiVersion/reports';
  
  // Severity Levels
  static const String severityHigh = 'HIGH';
  static const String severityMedium = 'MEDIUM';
  static const String severityLow = 'LOW';
  
  // Status
  static const String statusDetected = 'DETECTED';
  static const String statusResolved = 'RESOLVED';
  static const String statusInProgress = 'IN_PROGRESS';
}