# CyberSentinel Frontend

A modern, professional Flutter security dashboard frontend for the CyberSentinel cybersecurity monitoring platform.

## 👤 Developer
**Lestiwege Mufutumari** - Frontend Developer

## 📋 Features

- **Real-time Dashboard** - Live threat monitoring and statistics
- **Threat Feed Table** - Live threat detection with severity levels
- **Attack Map** - Geo-IP visualization of attack origins
- **System Resources** - CPU, RAM, DISK, and Network monitoring
- **Responsive Layout** - Sidebar navigation with clean admin interface
- **Dark Theme** - Professional cybersecurity UI theme
- **API Integration** - Connected to FastAPI backend

## 🏗️ Project Structure

```
lib/
├── main.dart                          # App entry point
├── core/
│   ├── theme.dart                     # Dark theme configuration
│   └── constants.dart                 # App constants
├── layout/
│   ├── main_layout.dart               # Main scaffold with sidebar
│   └── sidebar.dart                   # Navigation sidebar
├── features/
│   ├── dashboard/
│   │   ├── dashboard_screen.dart      # Dashboard main screen
│   │   └── widgets/
│   │       ├── stat_card.dart         # Stat card widget
│   │       ├── threat_table.dart      # Live threat table
│   │       ├── attack_map.dart        # Geo-IP attack map
│   │       └── system_stats.dart      # System resource stats
│   ├── alerts/                        # Alerts feature (future)
│   ├── monitoring/                    # Monitoring feature (future)
│   ├── incidents/                     # Incidents feature (future)
│   ├── reports/                       # Reports feature (future)
│   └── settings/                      # Settings feature (future)
├── services/
│   └── api_service.dart               # API client service
└── models/
    └── alert_model.dart               # Alert data model
```

## 🚀 Getting Started

### Prerequisites
- Flutter 3.0+
- Dart 3.0+
- FastAPI backend running at `http://127.0.0.1:8000`

### Installation

1. Clone the repository
```bash
git clone https://github.com/yourusername/cybersentinel_frontend.git
cd cybersentinel_frontend
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the app
```bash
flutter run -d chrome  # For web
# or
flutter run           # For desktop
```

## 📦 Dependencies

- **http**: ^1.1.0 - HTTP client for API requests
- **google_maps_flutter**: ^2.5.0 - Map widget (future enhancement)
- **intl**: ^0.19.0 - Internationalization support
- **cupertino_icons**: ^1.0.2 - iOS icons

## 🎨 Theme Colors

- **Primary Black**: #0A0E27
- **Secondary Black**: #1A1F3A
- **Accent Blue**: #0099FF
- **Danger Red**: #FF3333
- **Warning Orange**: #FF9900
- **Success Green**: #00DD88

## 🔌 API Integration

The app connects to a FastAPI backend with these endpoints:

- `GET /api/v1/alerts` - Fetch security alerts
- `GET /api/v1/threats` - Fetch threats
- `GET /api/v1/incidents` - Fetch incidents

## 📝 Key Components

### Dashboard Screen
- **Stat Cards**: Display total threats, high-risk alerts, incidents, resolved
- **Threat Table**: Real-time live threat feed with filters
- **Attack Map**: Geo-IP visualization of attack origins
- **System Stats**: CPU, RAM, DISK usage monitoring

### Main Layout
- **Top Admin Bar**: Search, status indicator, notifications
- **Sidebar Navigation**: Menu items for different sections
- **Content Area**: Main feature screens

## 🎯 Next Steps

- [ ] Implement Defensive Terminal
- [ ] Add Twilio SMS integration
- [ ] Complete Threat Monitor screen
- [ ] Implement Incidents management
- [ ] Create Reports dashboard
- [ ] Add Settings panel
- [ ] Implement WebSocket for real-time updates

## 📄 License

This project is part of a university group project.

## 👥 Team

- **Lestiwege Mufutumari** - Frontend (Flutter)
- **Other members** - Backend, Infrastructure, etc.

---

**Built with ❤️ for cybersecurity monitoring**
