import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:math' as math;

class AtmLocatorScreenn extends StatefulWidget {
  const AtmLocatorScreenn({Key? key}) : super(key: key);

  @override
  State<AtmLocatorScreenn> createState() => _AtmLocatorScreennState();
}

class _AtmLocatorScreennState extends State<AtmLocatorScreenn> {
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();

  // Location variables
  Position? _currentPosition;
  bool _isLoadingLocation = true;
  StreamSubscription<Position>? _positionStream;

  // Map variables
  List<Marker> _markers = [];
  List<Polyline> _polylines = [];
  AtmLocation? _selectedAtm;
  double? _distanceToAtm;
  int? _walkingTimeMinutes;

  // Initial camera position (New York City)
  static const LatLng _initialPosition = LatLng(40.7580, -73.9855);

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _loadNearbyAtms();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _positionStream?.cancel();
    super.dispose();
  }

  // Initialize location services
  Future<void> _initializeLocation() async {
    await _requestLocationPermission();
    await _getCurrentLocation();
    _startLocationTracking();
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status != PermissionStatus.granted) {
      _showLocationPermissionDialog();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationServiceDialog();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
      });

      _updateMapPosition();
      _updateMarkersAndRoute();
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
      });
      print('Error getting location: $e');
    }
  }

  void _startLocationTracking() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );

    _positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      setState(() {
        _currentPosition = position;
      });
      _updateMarkersAndRoute();
    });
  }

  void _updateMapPosition() {
    if (_currentPosition != null) {
      _mapController.move(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        14.0,
      );
    }
  }

  // Load nearby ATMs (mock data - replace with real API)
  void _loadNearbyAtms() {
    // Mock ATM data - replace with real API call
    final mockAtms = [
      AtmLocation(
        id: '1',
        name: 'Fintech Canal Branch',
        address: '123 Canal Street, NYC',
        latitude: 40.7589,
        longitude: -73.9851,
        bankName: 'Fintech Bank',
        is24Hours: true,
        hasCashDeposit: true,
      ),
      AtmLocation(
        id: '2',
        name: 'Chase Bank ATM',
        address: '456 Broadway, NYC',
        latitude: 40.7614,
        longitude: -73.9776,
        bankName: 'Chase',
        is24Hours: false,
        hasCashDeposit: false,
      ),
      AtmLocation(
        id: '3',
        name: 'Bank of America',
        address: '789 Wall Street, NYC',
        latitude: 40.7505,
        longitude: -73.9934,
        bankName: 'Bank of America',
        is24Hours: true,
        hasCashDeposit: true,
      ),
    ];

    if (_currentPosition != null) {
      // Find nearest ATM
      AtmLocation? nearest;
      double shortestDistance = double.infinity;

      for (var atm in mockAtms) {
        double distance = Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          atm.latitude,
          atm.longitude,
        );

        if (distance < shortestDistance) {
          shortestDistance = distance;
          nearest = atm;
        }
      }

      if (nearest != null) {
        setState(() {
          _selectedAtm = nearest;
          _distanceToAtm = shortestDistance;
          _walkingTimeMinutes = (shortestDistance / 80).round(); // ~80m/min walking speed
        });
      }
    }

    _updateMarkersAndRoute();
  }

  void _updateMarkersAndRoute() {
    List<Marker> markers = [];
    List<Polyline> polylines = [];

    // Add current location marker
    if (_currentPosition != null) {
      markers.add(
        Marker(
          point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          width: 60,
          height: 60,
          child: Container(
            child: Icon(
              Icons.my_location,
              color: Colors.blue,
              size: 30,
            ),
          ),
        ),
      );
    }

    // Add ATM markers
    if (_selectedAtm != null) {
      markers.add(
        Marker(
          point: LatLng(_selectedAtm!.latitude, _selectedAtm!.longitude),
          width: 60,
          height: 60,
          child: GestureDetector(
            onTap: () => _onAtmMarkerTapped(_selectedAtm!),
            child: Container(
              child: Icon(
                Icons.local_atm,
                color: Colors.red,
                size: 30,
              ),
            ),
          ),
        ),
      );

      // Add route line
      if (_currentPosition != null) {
        polylines.add(
          Polyline(
            points: [
              LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
              LatLng(_selectedAtm!.latitude, _selectedAtm!.longitude),
            ],
            color: Colors.blue,
            strokeWidth: 3,
            //isDotted: true,
          ),
        );
      }
    }

    setState(() {
      _markers = markers;
      _polylines = polylines;
    });
  }

  void _onAtmMarkerTapped(AtmLocation atm) {
    _showAtmDetails(atm);
  }

  void _showAtmDetails(AtmLocation atm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AtmDetailsSheet(atm: atm),
    );
  }

  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text('This app needs location access to find nearby ATMs.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Services Disabled'),
        content: const Text('Please enable location services to find nearby ATMs.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _searchLocation(String query) async {
    // Implement geocoding search here
    // You can use geocoding package to convert address to coordinates
    print('Searching for: $query');
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isLandscape = screenSize.width > screenSize.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: isLandscape && !isTablet
            ? _buildLandscapeLayout(screenSize)
            : _buildPortraitLayout(screenSize, isTablet),
      ),
    );
  }

  Widget _buildPortraitLayout(Size screenSize, bool isTablet) {
    return Column(
      children: [
        _buildHeader(screenSize, isTablet),
        _buildSearchBar(screenSize, isTablet),
        Expanded(
          flex: isTablet ? 4 : 3,
          child: _buildMapArea(screenSize, isTablet),
        ),
        _buildBottomInfo(screenSize, isTablet),
      ],
    );
  }

  Widget _buildLandscapeLayout(Size screenSize) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildHeader(screenSize, false),
              _buildSearchBar(screenSize, false),
              Expanded(child: _buildMapArea(screenSize, false)),
            ],
          ),
        ),
        Container(
          width: screenSize.width * 0.4,
          padding: const EdgeInsets.all(16),
          child: _buildBottomInfo(screenSize, false, isLandscape: true),
        ),
      ],
    );
  }

  Widget _buildHeader(Size screenSize, bool isTablet) {
    final double horizontalPadding = _getResponsivePadding(screenSize, isTablet);
    final double avatarSize = isTablet ? 50 : 40;
    final double titleFontSize = isTablet ? 28 : 22;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: isTablet ? 20 : 16,
      ),
      child: Row(
        children: [
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipOval(
              child: Container(
                color: Colors.grey.shade200,
                child: Icon(
                  Icons.person,
                  color: Colors.grey.shade600,
                  size: avatarSize * 0.6,
                ),
              ),
            ),
          ),
          SizedBox(width: isTablet ? 16 : 12),
          Expanded(
            child: Text(
              'ATM Locator',
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          if (_isLoadingLocation)
            SizedBox(
              width: isTablet ? 20 : 16,
              height: isTablet ? 20 : 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.blue,
              ),
            )
          else
            Container(
              width: isTablet ? 12 : 8,
              height: isTablet ? 12 : 8,
              decoration: BoxDecoration(
                color: _currentPosition != null ? Colors.green : Colors.red,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(Size screenSize, bool isTablet) {
    final double horizontalPadding = _getResponsivePadding(screenSize, isTablet);
    final double fontSize = isTablet ? 18 : 16;
    final double iconSize = isTablet ? 28 : 24;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: isTablet ? 12 : 8,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isTablet ? 600 : double.infinity,
        ),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        ),
        child: TextField(
          controller: _searchController,
          style: TextStyle(fontSize: fontSize),
          onSubmitted: _searchLocation,
          decoration: InputDecoration(
            hintText: 'Search location',
            hintStyle: TextStyle(
              color: Colors.grey.shade500,
              fontSize: fontSize,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey.shade500,
              size: iconSize,
            ),
            suffixIcon: _currentPosition != null
                ? IconButton(
              icon: Icon(Icons.my_location, size: iconSize),
              onPressed: _updateMapPosition,
            )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: isTablet ? 20 : 16,
              vertical: isTablet ? 16 : 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapArea(Size screenSize, bool isTablet) {
    final double horizontalMargin = _getResponsivePadding(screenSize, isTablet);
    final double borderRadius = isTablet ? 20 : 16;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _currentPosition != null
                ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                : _initialPosition,
            initialZoom: 14.0,
            onTap: (tapPosition, point) {
              // Handle map tap
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.atm_locator',
            ),
            PolylineLayer(
              polylines: _polylines,
            ),
            MarkerLayer(
              markers: _markers,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomInfo(Size screenSize, bool isTablet, {bool isLandscape = false}) {
    final double horizontalPadding = _getResponsivePadding(screenSize, isTablet);
    final double fontSize = isTablet ? 18 : 16;
    final double titleFontSize = isTablet ? 20 : 16;
    final double iconSize = isTablet ? 28 : 24;
    final double iconContainerSize = isTablet ? 56 : 44;

    return Container(
      padding: EdgeInsets.all(horizontalPadding),
      constraints: BoxConstraints(
        maxWidth: isTablet ? 600 : double.infinity,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_distanceToAtm != null && _walkingTimeMinutes != null)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: isTablet ? 20 : 16,
                horizontal: isTablet ? 24 : 20,
              ),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
              ),
              child: _buildDistanceTimeRow(fontSize, iconSize),
            ),

          SizedBox(height: isTablet ? 20 : 16),

          if (_currentPosition != null)
            _buildLocationItem(
              icon: Icons.home,
              title: 'Your Location',
              subtitle: 'Lat: ${_currentPosition!.latitude.toStringAsFixed(4)}, Lng: ${_currentPosition!.longitude.toStringAsFixed(4)}',
              titleFontSize: titleFontSize,
              fontSize: fontSize,
              iconSize: iconSize,
              iconContainerSize: iconContainerSize,
            ),

          if (_selectedAtm != null) ...[
            SizedBox(height: isTablet ? 16 : 12),
            _buildLocationItem(
              icon: Icons.local_atm,
              title: _selectedAtm!.name,
              subtitle: _selectedAtm!.address,
              titleFontSize: titleFontSize,
              fontSize: fontSize,
              iconSize: iconSize,
              iconContainerSize: iconContainerSize,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDistanceTimeRow(double fontSize, double iconSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          children: [
            Icon(Icons.directions_walk, color: Colors.white, size: iconSize * 0.8),
            const SizedBox(width: 8),
            Text(
              '${(_distanceToAtm! / 1000).toStringAsFixed(1)} km',
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Container(
          width: 1,
          height: 20,
          color: Colors.white.withOpacity(0.3),
        ),
        Row(
          children: [
            Icon(Icons.access_time, color: Colors.white, size: iconSize * 0.8),
            const SizedBox(width: 8),
            Text(
              '$_walkingTimeMinutes min',
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required double titleFontSize,
    required double fontSize,
    required double iconSize,
    required double iconContainerSize,
  }) {
    return Row(
      children: [
        Container(
          width: iconContainerSize,
          height: iconContainerSize,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(iconContainerSize * 0.27),
          ),
          child: Icon(
            icon,
            color: Colors.blue,
            size: iconSize,
          ),
        ),
        SizedBox(width: iconContainerSize * 0.27),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: fontSize * 0.875,
                  color: Colors.grey.shade600,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }

  double _getResponsivePadding(Size screenSize, bool isTablet) {
    if (isTablet) {
      return screenSize.width * 0.08;
    } else if (screenSize.width > 400) {
      return 20.0;
    } else {
      return 16.0;
    }
  }
}

// ATM Location Model
class AtmLocation {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String bankName;
  final bool is24Hours;
  final bool hasCashDeposit;

  AtmLocation({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.bankName,
    required this.is24Hours,
    required this.hasCashDeposit,
  });
}

// ATM Details Bottom Sheet
class AtmDetailsSheet extends StatelessWidget {
  final AtmLocation atm;

  const AtmDetailsSheet({Key? key, required this.atm}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            atm.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            atm.address,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildFeatureChip(
                icon: Icons.access_time,
                label: atm.is24Hours ? '24/7' : 'Limited Hours',
                color: atm.is24Hours ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 12),
              _buildFeatureChip(
                icon: Icons.account_balance_wallet,
                label: atm.hasCashDeposit ? 'Cash Deposit' : 'Withdrawal Only',
                color: atm.hasCashDeposit ? Colors.blue : Colors.grey,
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Navigate to this ATM
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Get Directions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildFeatureChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}