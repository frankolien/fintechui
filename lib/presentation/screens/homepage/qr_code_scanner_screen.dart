import 'package:flutter/material.dart';
import 'dart:async';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({Key? key}) : super(key: key);

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Mock camera background with gradient
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
            color: Colors.white,
            ),
            child: Stack(
              children: [
                // Subtle pattern to simulate camera view
                Positioned.fill(
                  child: CustomPaint(
                    painter: CameraMockPainter(),
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white.withOpacity(0.4),
            child: Column(
              children: [
                // Top section with header
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        // Profile avatar
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[600],
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: ClipRRect(
                             borderRadius: BorderRadius.circular(20),
                              child: CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                      child: Icon(Icons.person,color: Colors.grey[600],size: 30,)),
                ),
                        ),),
                        const Spacer(),
                        // Title
                        const Text(
                          'QR Scan',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const Spacer(),
                        // Notification icon
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: Stack(
                            children: [
                              const Center(
                                child: Icon(
                                  Icons.notifications_outlined,
                                  color: Colors.black,
                                  size: 20,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Scanning area
                Container(
                  width: 280,
                  height: 280,
                  child: Stack(
                    children: [
                      // Clear center area with subtle border
                      Center(
                        child: Container(
                          width: 240,
                          height: 240,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                        ),
                      ),

                      // Corner brackets
                      Positioned(
                        top: 0,
                        left: 0,
                        child: _buildCornerBracket(topLeft: true),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: _buildCornerBracket(topRight: true),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: _buildCornerBracket(bottomLeft: true),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: _buildCornerBracket(bottomRight: true),
                      ),

                      // QR code pattern (decorative)
                      Center(
                        child: Container(
                          width: 200,
                          height: 200,
                          child: CustomPaint(
                            painter: QRPatternPainter(),
                          ),
                        ),
                      ),

                      // Scanning line animation
                      if (_isScanning)
                        AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) {
                            return Positioned(
                              top: _animation.value * 240 + 20,
                              left: 20,
                              right: 20,
                              child: Container(
                                height: 3,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      const Color(0xFF4F7AFF),
                                      const Color(0xFF4F7AFF).withOpacity(0.8),
                                      const Color(0xFF4F7AFF),
                                      Colors.transparent,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF4F7AFF).withOpacity(0.6),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Description text
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'The QR code will be automatically detected when you will place the QR code inside the frame',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      height: 1.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Loading indicator (only show when scanning)
                AnimatedOpacity(
                  opacity: _isScanning ? 1.0 : 0.5,
                  duration: const Duration(milliseconds: 300),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _isScanning ? const Color(0xFF4F7AFF) : Colors.black.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 60),

                // Scan button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isScanning ? null : _handleScanPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isScanning
                            ? Colors.grey[600]
                            : const Color(0xFF4F7AFF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        disabledBackgroundColor: Colors.grey[600],
                        disabledForegroundColor: Colors.white70,
                      ),
                      child: Text(
                        _isScanning ? 'Scanning...' : 'Scan Item',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleScanPressed() {
    setState(() {
      _isScanning = true;
    });

    // Simulate scanning process
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
        _showScanResult('https://media.licdn.com/dms/image/v2/D4D03AQHFzR3cYawcGg/profile-displayphoto-shrink_800_800/B4DZdOB9gLGYAg-/0/1749360829128?e=1756944000&v=beta&t=OWtyfqBkydBtiMlSTnRaar0WGVVoKpu8Kz7KS41VRWI');
      }
    });
  }

  void _showScanResult(String result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.qr_code_scanner,
                  color: Colors.green,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'QR Code Scanned',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Scanned Content:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  result,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Handle the scanned result (e.g., open URL, save data, etc.)
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F7AFF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Open'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCornerBracket({
    bool topLeft = false,
    bool topRight = false,
    bool bottomLeft = false,
    bool bottomRight = false,
  }) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        border: Border(
          top: (topLeft || topRight)
              ? const BorderSide(color: Colors.black, width: 4)
              : BorderSide.none,
          bottom: (bottomLeft || bottomRight)
              ? const BorderSide(color: Colors.black, width: 4)
              : BorderSide.none,
          left: (topLeft || bottomLeft)
              ? const BorderSide(color: Colors.black, width: 4)
              : BorderSide.none,
          right: (topRight || bottomRight)
              ? const BorderSide(color: Colors.black, width: 4)
              : BorderSide.none,
        ),
      ),
    );
  }
}

class CameraMockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Create subtle grid pattern to simulate camera noise/texture
    for (double x = 0; x < size.width; x += 20) {
      for (double y = 0; y < size.height; y += 20) {
        if ((x + y) % 40 == 0) {
          canvas.drawCircle(
            Offset(x, y),
            1,
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class QRPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.12)
      ..style = PaintingStyle.fill;

    const double dotSize = 5.0;
    const double spacing = 12.0;

    for (double x = spacing; x < size.width - spacing; x += spacing) {
      for (double y = spacing; y < size.height - spacing; y += spacing) {
        double opacity = 0.12;

        if ((x ~/ spacing + y ~/ spacing) % 2 == 0) {
          opacity = 0.18;
        }
        if ((x ~/ spacing) % 4 == 0 || (y ~/ spacing) % 4 == 0) {
          opacity = 0.08;
        }
        final dotPaint = Paint()
          ..color = Colors.black
          ..style = PaintingStyle.fill;
        canvas.drawCircle(
          Offset(x, y),
          dotSize / 2,
          dotPaint,
        );
      }
    }

    // Add corner finder patterns
    final cornerPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    const double cornerSize = 20.0;

    // Corner squares
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(20, 20, cornerSize, cornerSize),
        const Radius.circular(3),
      ),
      cornerPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width - 40, 20, cornerSize, cornerSize),
        const Radius.circular(3),
      ),
      cornerPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(20, size.height - 40, cornerSize, cornerSize),
        const Radius.circular(3),
      ),
      cornerPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(160, size.height - 45, cornerSize, cornerSize),
        const Radius.circular(3),
      ),
      cornerPaint,
    );

    // Center timing pattern
    final centerPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      6,
      centerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Usage example:
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'SF Pro Display',
      ),
      home: const QRScannerScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}