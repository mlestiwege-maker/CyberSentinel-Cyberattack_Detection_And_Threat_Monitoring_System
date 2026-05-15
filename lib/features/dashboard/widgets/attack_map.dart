// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme.dart';
import '../../../models/alert_model.dart';
import '../../../services/api_service.dart';

class AttackMap extends StatefulWidget {
  const AttackMap({super.key});

  @override
  State<AttackMap> createState() => _AttackMapState();
}

class _AttackMapState extends State<AttackMap> {
  late Future<List<Alert>> _threatsFuture;
  final MapController _mapController = MapController();
  bool _showOnlyVerified = false;
  Alert? _selectedThreat;

  @override
  void initState() {
    super.initState();
    _threatsFuture = ApiService.fetchThreatFeed();
  }

  void _refresh() {
    setState(() {
      _threatsFuture = ApiService.fetchThreatFeed();
    });
  }

  bool _isVerifiedGeoIP(Alert threat) {
    return threat.latitude != null && threat.longitude != null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.secondaryBlack,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ATTACK MAP (LIVE)',
                style: TextStyle(
                  color: AppTheme.textWhite,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  _buildLegendItem('Low', AppTheme.successGreen),
                  const SizedBox(width: 16),
                  _buildLegendItem('Medium', AppTheme.warningOrange),
                  const SizedBox(width: 16),
                  _buildLegendItem('High', AppTheme.dangerRed),
                  const SizedBox(width: 20),
                  Tooltip(
                    message: 'Show only threats with verified GeoIP coordinates',
                    child: GestureDetector(
                      onTap: () => setState(() => _showOnlyVerified = !_showOnlyVerified),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _showOnlyVerified ? AppTheme.accentBlue.withValues(alpha: 0.2) : Colors.transparent,
                          border: Border.all(
                            color: _showOnlyVerified ? AppTheme.accentBlue : AppTheme.textGrey.withValues(alpha: 0.3),
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _showOnlyVerified ? Icons.check_circle : Icons.circle_outlined,
                              size: 14,
                              color: _showOnlyVerified ? AppTheme.accentBlue : AppTheme.textGrey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Verified GeoIP',
                              style: TextStyle(
                                color: _showOnlyVerified ? AppTheme.accentBlue : AppTheme.textGrey,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: FutureBuilder<List<Alert>>(
              future: _threatsFuture,
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
                        const Icon(Icons.public_off_outlined, color: AppTheme.dangerRed, size: 34),
                        const SizedBox(height: 10),
                        Text(
                          'Unable to load threat map\n${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppTheme.textGrey),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: _refresh,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                var threats = snapshot.data ?? [];
                if (_showOnlyVerified) {
                  threats = threats.where(_isVerifiedGeoIP).toList();
                }

                if (threats.isEmpty && _showOnlyVerified) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_off, color: AppTheme.warningOrange, size: 34),
                        const SizedBox(height: 10),
                        const Text(
                          'No threats with verified\nGeoIP coordinates',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppTheme.textGrey),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => setState(() => _showOnlyVerified = false),
                          child: const Text('Show all threats'),
                        ),
                      ],
                    ),
                  );
                }

                final markers = threats.map(_markerFromThreat).toList();
                
                // Keep map focused on Bindura, Zimbabwe (primary area of study)
                // Threats will be visible on the map without auto-centering away
                // WidgetsBinding.instance.addPostFrameCallback((_) {
                //   _centerOnHighestSeverity(threats);
                // });

                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF08111F),
                      border: Border.all(color: const Color(0xFF1E2A44)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      children: [
                        FlutterMap(
                          mapController: _mapController,
                          options: const MapOptions(
                            initialCenter: LatLng(-17.3044, 31.3334),
                            initialZoom: 10.0,
                            minZoom: 1.2,
                            maxZoom: 18.0,
                            interactionOptions: InteractionOptions(flags: InteractiveFlag.all),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'cybersentinel_frontend',
                            ),
                            MarkerLayer(markers: markers),
                            RichAttributionWidget(
                              attributions: [
                                TextSourceAttribution(
                                  '© OpenStreetMap contributors',
                                  onTap: () {},
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (_selectedThreat != null)
                          Positioned(
                            bottom: 16,
                            left: 16,
                            right: 16,
                            child: _buildThreatDetail(_selectedThreat!),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textGrey,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Marker _markerFromThreat(Alert threat) {
    final severity = threat.severity.toUpperCase();
    final color = _getSeverityColor(severity);
    final position = threat.latitude != null && threat.longitude != null
        ? LatLng(threat.latitude!, threat.longitude!)
        : _pseudoGeolocate(threat.sourceIp);
    final radius = _getSeverityRadius(severity);

    return Marker(
      point: position,
      width: 160,
      height: 72,
      alignment: Alignment.topCenter,
      child: GestureDetector(
        onTap: () => setState(() => _selectedThreat = threat),
        child: Tooltip(
          message: '${threat.location} • ${threat.sourceIp} • ${threat.type} • ${threat.severity}',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: radius,
                height: radius,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.45),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xCC08111F),
                  border: Border.all(color: color.withValues(alpha: 0.5)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  threat.location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThreatDetail(Alert threat) {
    final severity = threat.severity.toUpperCase();
    final color = _getSeverityColor(severity);
    
    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2845),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      threat.type,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      threat.location,
                      style: const TextStyle(
                        color: AppTheme.textGrey,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Text(
                  severity,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => setState(() => _selectedThreat = null),
                child: const Icon(Icons.close, color: AppTheme.textGrey, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Source IP',
                      style: TextStyle(color: AppTheme.textGrey, fontSize: 10),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      threat.sourceIp,
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // ignore: prefer_const_literals_to_create_immutables
                  children: [
                    const Text(
                      'Confidence',
                      style: TextStyle(color: AppTheme.textGrey, fontSize: 10.0),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '94%',
                      style: TextStyle(color: Colors.white, fontSize: 11.0, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status',
                      style: TextStyle(color: AppTheme.textGrey, fontSize: 10.0),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      threat.status,
                      style: const TextStyle(color: AppTheme.accentBlue, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 1,
            color: AppTheme.textGrey.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.info_outline, size: 14),
                  label: const Text('Details'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentBlue.withValues(alpha: 0.18),
                    foregroundColor: AppTheme.accentBlue,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.check_circle_outline, size: 14),
                  label: const Text('Resolve'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successGreen.withValues(alpha: 0.18),
                    foregroundColor: AppTheme.successGreen,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  LatLng _pseudoGeolocate(String ip) {
    if (ip.startsWith('10.') || ip.startsWith('192.168.')) {
      return const LatLng(-17.8252, 31.0335); // Harare, Zimbabwe
    }

    if (ip.startsWith('172.16.') || ip.startsWith('172.17.') || ip.startsWith('172.18.')) {
      return const LatLng(-26.2041, 28.0473); // Johannesburg
    }

    final hash = ip.codeUnits.fold<int>(0, (acc, value) => acc + value);
    final lat = ((hash % 140) - 70).toDouble();
    final lng = (((hash * 37) % 360) - 180).toDouble();
    return LatLng(lat, lng);
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'CRITICAL':
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

  double _getSeverityRadius(String severity) {
    switch (severity) {
      case 'CRITICAL':
        return 18;
      case 'HIGH':
        return 14;
      case 'MEDIUM':
        return 11;
      case 'LOW':
        return 8;
      default:
        return 8;
    }
  }
}
