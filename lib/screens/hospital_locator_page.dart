import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;
import '../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/animated_card.dart';
import '../widgets/animated_button.dart';

class HospitalLocatorPage extends StatefulWidget {
  const HospitalLocatorPage({Key? key}) : super(key: key);

  @override
  State<HospitalLocatorPage> createState() => _HospitalLocatorPageState();
}

class _HospitalLocatorPageState extends State<HospitalLocatorPage> {
  final MapController _mapController = MapController();
  Position? _currentPosition;
  bool _isLoading = true;
  String _errorMessage = '';
  List<Map<String, dynamic>> _nearbyHospitals = [];

  final List<Map<String, dynamic>> _hospitalDatabase = [
    {
      'name': 'City General Hospital',
      'address': '123 Medical Center Dr, Downtown',
      'phone': '+1-234-567-8900',
      'rating': 4.5,
      'type': 'General Hospital',
      'emergency': true,
      'latitude': 37.7749,
      'longitude': -122.4194,
      'services': ['Emergency', 'Surgery', 'ICU', 'Cardiology'],
      'openTime': '24/7',
    },
    {
      'name': 'Emergency Care Center',
      'address': '456 Emergency Blvd, Midtown',
      'phone': '+1-234-567-8901',
      'rating': 4.2,
      'type': 'Emergency Care',
      'emergency': true,
      'latitude': 37.7849,
      'longitude': -122.4094,
      'services': ['Emergency', 'Urgent Care', 'X-Ray'],
      'openTime': '24/7',
    },
    {
      'name': 'Specialty Medical Center',
      'address': '789 Specialist Ave, Uptown',
      'phone': '+1-234-567-8902',
      'rating': 4.7,
      'type': 'Specialty Hospital',
      'emergency': false,
      'latitude': 37.7649,
      'longitude': -122.4294,
      'services': ['Orthopedics', 'Neurology', 'Oncology'],
      'openTime': '8:00 AM - 6:00 PM',
    },
    {
      'name': 'Children\'s Hospital',
      'address': '321 Kids Care St, Suburbs',
      'phone': '+1-234-567-8903',
      'rating': 4.8,
      'type': 'Pediatric Hospital',
      'emergency': true,
      'latitude': 37.7549,
      'longitude': -122.4394,
      'services': ['Pediatric Emergency', 'NICU', 'Pediatric Surgery'],
      'openTime': '24/7',
    },
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = 'Location permissions are denied';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = 'Location permissions are permanently denied';
          _isLoading = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });

      _findNearbyHospitals();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error getting location: $e';
        _isLoading = false;
      });
    }
  }

  void _findNearbyHospitals() {
    if (_currentPosition == null) return;

    List<Map<String, dynamic>> hospitalsWithDistance = [];

    for (var hospital in _hospitalDatabase) {
      double distance = _calculateDistance(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        hospital['latitude'],
        hospital['longitude'],
      );

      hospital['distance'] = distance;
      hospitalsWithDistance.add(hospital);
    }

    hospitalsWithDistance.sort(
      (a, b) => (a['distance'] as double).compareTo(b['distance'] as double),
    );

    setState(() {
      _nearbyHospitals = hospitalsWithDistance;
    });
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371;
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);

    double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    await launchUrl(launchUri);
  }

  Future<void> _openMaps(
    double latitude,
    double longitude,
    String hospitalName,
  ) async {
    final Uri launchUri = Uri(
      scheme: 'geo',
      path: '$latitude,$longitude',
      queryParameters: {'q': '$latitude,$longitude($hospitalName)'},
    );

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      final String googleMapsUrl =
          'https://maps.google.com/?q=$latitude,$longitude';
      final Uri webUri = Uri.parse(googleMapsUrl);
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  List<Marker> _buildMarkers() {
    List<Marker> markers = [];

    // User location marker
    if (_currentPosition != null) {
      markers.add(
        Marker(
          width: 60,
          height: 60,
          point: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF9AFF00),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9AFF00).withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.person_pin_circle,
              color: Color(0xFF0A0A0A),
              size: 30,
            ),
          ),
        ),
      );
    }

    // Hospital markers
    for (var hospital in _nearbyHospitals) {
      markers.add(
        Marker(
          width: 50,
          height: 50,
          point: LatLng(hospital['latitude'], hospital['longitude']),
          child: GestureDetector(
            onTap: () => _showHospitalDetails(hospital),
            child: Container(
              decoration: BoxDecoration(
                color:
                    hospital['emergency']
                        ? Colors.red
                        : const Color(0xFF9AFF00),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(
                hospital['emergency'] ? Icons.warning : Icons.local_hospital,
                color:
                    hospital['emergency']
                        ? Colors.white
                        : const Color(0xFF0A0A0A),
                size: 24,
              ),
            ),
          ),
        ),
      );
    }

    return markers;
  }

  void _showHospitalDetails(Map<String, dynamic> hospital) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: themeProvider.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.6,
            maxChildSize: 0.9,
            minChildSize: 0.4,
            builder:
                (context, scrollController) => Container(
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: themeProvider.secondaryTextColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color:
                                    hospital['emergency']
                                        ? Colors.red.withOpacity(0.2)
                                        : themeProvider.primaryColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                hospital['emergency']
                                    ? Icons.warning
                                    : Icons.local_hospital,
                                color:
                                    hospital['emergency']
                                        ? Colors.red
                                        : themeProvider.primaryColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    hospital['name'],
                                    style: TextStyle(
                                      color: themeProvider.textColor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    hospital['type'],
                                    style: TextStyle(
                                      color: themeProvider.secondaryTextColor,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: themeProvider.primaryColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                '${hospital['distance'].toStringAsFixed(1)} km away',
                                style: TextStyle(
                                  color: themeProvider.primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${hospital['rating']} / 5.0',
                                  style: TextStyle(color: themeProvider.textColor),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                        _buildInfoRow(Icons.location_on, hospital['address']),
                        _buildInfoRow(Icons.phone, hospital['phone']),
                        _buildInfoRow(Icons.access_time, hospital['openTime']),

                        const SizedBox(height: 20),
                        Text(
                          'Services Available',
                          style: TextStyle(
                            color: themeProvider.primaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          children:
                              (hospital['services'] as List<String>)
                                  .map(
                                    (service) => Container(
                                      margin: const EdgeInsets.only(
                                        right: 8,
                                        bottom: 8,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: themeProvider.cardColor,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        service,
                                        style: TextStyle(
                                          color: themeProvider.textColor,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),

                        const SizedBox(height: 30),
                        Row(
                          children: [
                            Expanded(
                              child: AnimatedButton(
                                text: 'Call',
                                icon: Icons.phone,
                                onPressed:
                                    () => _makePhoneCall(hospital['phone']),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AnimatedButton(
                                text: 'Directions',
                                icon: Icons.directions,
                                onPressed:
                                    () => _openMaps(
                                      hospital['latitude'],
                                      hospital['longitude'],
                                      hospital['name'],
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
          ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: themeProvider.primaryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: themeProvider.textColor, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n=AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: themeProvider.backgroundColor,
        title: Text(
          l10n.hosNearME,
          style: TextStyle(
            color: themeProvider.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: themeProvider.primaryColor),
        actions: [
          IconButton(
            onPressed: _getCurrentLocation,
            icon: const Icon(Icons.my_location),
            tooltip: 'Refresh Location',
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: themeProvider.primaryColor),
                    SizedBox(height: 16),
                    Text(
                      'Finding hospitals near you...',
                      style: TextStyle(color: themeProvider.textColor, fontSize: 16),
                    ),
                  ],
                ),
              )
              : _errorMessage.isNotEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        _errorMessage,
                        style: TextStyle(
                          color: themeProvider.textColor,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _getCurrentLocation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeProvider.primaryColor,
                      ),
                      child: Text(
                        'Try Again',
                        style: TextStyle(color: themeProvider.backgroundColor),
                      ),
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        child: FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            center:
                                _currentPosition != null
                                    ? LatLng(
                                      _currentPosition!.latitude,
                                      _currentPosition!.longitude,
                                    )
                                    : LatLng(37.7749, -122.4194),
                            zoom: 13.0,
                            minZoom: 3.0,
                            maxZoom: 18.0,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              subdomains: ['a', 'b', 'c'],
  userAgentPackageName: 'com.yourdomain.appname', // REQUIRED
                            ),
                            MarkerLayer(markers: _buildMarkers()),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(color: themeProvider.surfaceColor),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          Text(
                            l10n.hosNearBY,
                            style: TextStyle(
                              color: themeProvider.primaryColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child:
                                _nearbyHospitals.isEmpty
                                    ? Center(
                                      child: Text(
                                        'No hospitals found nearby',
                                        style: TextStyle(
                                          color: themeProvider.textColor,
                                          fontSize: 16,
                                        ),
                                      ),
                                    )
                                    : ListView.builder(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      itemCount: _nearbyHospitals.length,
                                      itemBuilder: (context, index) {
                                        final hospital =
                                            _nearbyHospitals[index];
                                        return AnimatedCard(
                                          onTap: () => _showHospitalDetails(hospital),
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor:
                                                  hospital['emergency']
                                                      ? Colors.red.withOpacity(
                                                        0.2,
                                                      )
                                                      : themeProvider.primaryColor.withOpacity(0.2),
                                              child: Icon(
                                                hospital['emergency']
                                                    ? Icons.warning
                                                    : Icons.local_hospital,
                                                color:
                                                    hospital['emergency']
                                                        ? Colors.red
                                                        : themeProvider.primaryColor,
                                              ),
                                            ),
                                            title: Text(
                                              hospital['name'],
                                              style: TextStyle(
                                                color: themeProvider.textColor,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            subtitle: Text(
                                              '${hospital['type']} • ${hospital['distance'].toStringAsFixed(1)} km',
                                              style: TextStyle(
                                                color: themeProvider.secondaryTextColor,
                                              ),
                                            ),
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                  size: 16,
                                                ),
                                                Text(
                                                  ' ${hospital['rating']}',
                                                  style: TextStyle(
                                                    color: themeProvider.textColor,
                                                  ),
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
                    ),
                  ),
                ],
              ),
    );
  }
}