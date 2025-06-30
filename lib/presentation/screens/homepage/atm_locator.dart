import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

class AtmLocatorScreen extends StatefulWidget {
  const AtmLocatorScreen({Key? key}) : super(key: key);

  @override
  State<AtmLocatorScreen> createState() => _AtmLocatorScreenState();
}

class _AtmLocatorScreenState extends State<AtmLocatorScreen> {
  final TextEditingController _searchController = TextEditingController();

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
        // Left side - Map
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

        // Right side - Info
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
          // Profile avatar
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipOval(
              child: Image.network(
                'https://media.licdn.com/dms/image/v2/D4D03AQHFzR3cYawcGg/profile-displayphoto-shrink_800_800/B4DZdOB9gLGYAg-/0/1749360829128?e=1756944000&v=beta&t=OWtyfqBkydBtiMlSTnRaar0WGVVoKpu8Kz7KS41VRWI',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: Icon(
                      Icons.person,
                      color: Colors.grey.shade600,
                      size: avatarSize * 0.6,
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(width: isTablet ? 16 : 12),

          // Title
          Expanded(
            child: Center(
              child: Text(
                'Atm Locator',
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ),

          // Notification badge
          Container(
            width: isTablet ? 12 : 8,
            height: isTablet ? 12 : 8,
            decoration: const BoxDecoration(
              color: Colors.red,
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
    final double iconSize = isTablet ? 80 : 64;
    final double markerSize = isTablet ? 40 : 32;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Map placeholder
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  color: Colors.grey.shade200,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.map,
                        size: iconSize,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(height: isTablet ? 12 : 8),
                      Text(
                        'Map View',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: isTablet ? 20 : 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Responsive location markers
              _buildResponsiveMarkers(constraints, markerSize),
            ],
          );
        },
      ),
    );
  }

  Widget _buildResponsiveMarkers(BoxConstraints constraints, double markerSize) {
    final width = constraints.maxWidth;
    final height = constraints.maxHeight;

    return Stack(
      children: [
        // Location markers positioned responsively
        Positioned(
          top: height * 0.2,
          left: width * 0.15,
          child: _buildLocationMarker(Icons.location_on, Colors.grey, markerSize),
        ),
        Positioned(
          top: height * 0.25,
          right: width * 0.2,
          child: _buildLocationMarker(Icons.location_on, Colors.grey, markerSize),
        ),
        Positioned(
          bottom: height * 0.3,
          left: width * 0.25,
          child: _buildLocationMarker(Icons.location_on, Colors.blue, markerSize),
        ),

        // Responsive path line
        Positioned(
          bottom: height * 0.25,
          left: width * 0.2,
          child: Container(
            width: width * 0.3,
            height: 3,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationMarker(IconData icon, Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: size * 0.6,
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
          // Distance and time info
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

          // Location details
          if (isLandscape) ...[
            _buildLocationItem(
              icon: Icons.home,
              title: 'Your Location',
              subtitle: 'East Canal Street 18, NYC',
              titleFontSize: titleFontSize,
              fontSize: fontSize,
              iconSize: iconSize,
              iconContainerSize: iconContainerSize,
            ),
            SizedBox(height: isTablet ? 16 : 12),
            _buildLocationItem(
              icon: Icons.local_atm,
              title: 'ATM Nearby',
              subtitle: 'Fintech Canal Branch, NYC',
              titleFontSize: titleFontSize,
              fontSize: fontSize,
              iconSize: iconSize,
              iconContainerSize: iconContainerSize,
            ),
          ] else ...[
            _buildLocationItem(
              icon: Icons.home,
              title: 'Your Location',
              subtitle: 'East Canal Street 18, NYC',
              titleFontSize: titleFontSize,
              fontSize: fontSize,
              iconSize: iconSize,
              iconContainerSize: iconContainerSize,
            ),
            SizedBox(height: isTablet ? 16 : 12),
            _buildLocationItem(
              icon: Icons.local_atm,
              title: 'ATM Nearby',
              subtitle: 'Fintech Canal Branch, NYC',
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 300;

        if (isNarrow) {
          return Column(
            children: [
              _buildDistanceTimeItem(Icons.directions_walk, '540 m', fontSize, iconSize),
              const SizedBox(height: 8),
              _buildDistanceTimeItem(Icons.access_time, '10 min', fontSize, iconSize),
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildDistanceTimeItem(Icons.directions_walk, '540 m', fontSize, iconSize),
            Container(
              width: 1,
              height: 20,
              color: Colors.white.withOpacity(0.3),
            ),
            _buildDistanceTimeItem(Icons.access_time, '10 min', fontSize, iconSize),
          ],
        );
      },
    );
  }

  Widget _buildDistanceTimeItem(IconData icon, String text, double fontSize, double iconSize) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: iconSize * 0.8),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}


