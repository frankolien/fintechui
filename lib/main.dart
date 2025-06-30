import 'package:fintechui/presentation/screens/onboarding/splash_screen.dart';
import 'package:fintechui/presentation/screens/profile/user_profile.dart' hide ThemeProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/services/theme_provider.dart';

class SlantedCardsDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1B2E),
      body: SafeArea(
        child: PageView(
          children: [
            // Method 1: Using Transform.rotate for simple slant
            _buildSimpleSlantedCard(),

            // Method 2: Using Transform with Matrix4 for 3D perspective
            _build3DPerspectiveCard(),

            // Method 3: Using CustomPainter for precise control
            _buildCustomPaintedCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleSlantedCard() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background card (slightly rotated)
          Transform.rotate(
            angle: -0.3, // Rotate by ~6 degrees
            child: Container(
              width: 300,
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4A90E2), Color(0xFF2E5BBA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: _buildCardContent("5678 9000", isBack: true),
            ),
          ),

          // Front card
          Transform.rotate(
            angle: 0.05, // Rotate by ~3 degrees
            child: Container(
              width: 300,
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Color(0xFFF0F0F0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: _buildCardContent("5678 9000 0000", isBack: false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _build3DPerspectiveCard() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background card with 3D transform
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // perspective
              ..rotateX(-0.3)
              ..rotateY(0.2)
              ..rotateZ(-0.1),
            child: Container(
              width: 300,
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4A90E2), Color(0xFF2E5BBA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 20,
                    offset: Offset(-5, 10),
                  ),
                ],
              ),
              child: _buildCardContent("5678 9000", isBack: true),
            ),
          ),

          // Front card with different 3D transform
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // perspective
              ..rotateX(0.1)
              ..rotateY(-0.15)
              ..rotateZ(0.05),
            child: Container(
              width: 300,
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Color(0xFFF5F5F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 25,
                    offset: Offset(5, 15),
                  ),
                ],
              ),
              child: _buildCardContent("5678 9000 0000", isBack: false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomPaintedCard() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Custom painted slanted card
          CustomPaint(
            size: Size(320, 200),
            painter: SlantedCardPainter(),
          ),

          // Content overlay
          Transform.rotate(
            angle: 0.05,
            child: Container(
              width: 280,
              height: 160,
              child: _buildCardContent("1234 5678 9000", isBack: false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardContent(String cardNumber, {required bool isBack}) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'DEBIT CARD',
                style: TextStyle(
                  color: isBack ? Colors.white70 : Colors.black54,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                width: 30,
                height: 20,
                decoration: BoxDecoration(
                  color: isBack ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),

          Spacer(),

          Text(
            cardNumber,
            style: TextStyle(
              color: isBack ? Colors.white : Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),

          SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'VALID THRU',
                    style: TextStyle(
                      color: isBack ? Colors.white70 : Colors.black54,
                      fontSize: 8,
                    ),
                  ),
                  Text(
                    '12/25',
                    style: TextStyle(
                      color: isBack ? Colors.white : Colors.black87,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Text(
                'JOHN DOE',
                style: TextStyle(
                  color: isBack ? Colors.white : Colors.black87,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SlantedCardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black26
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10);

    // Create slanted path
    final path = Path();
    path.moveTo(20, 0);
    path.lineTo(size.width - 10, 20);
    path.lineTo(size.width - 20, size.height);
    path.lineTo(10, size.height - 20);
    path.close();

    // Draw shadow
    canvas.drawPath(path.shift(Offset(5, 5)), shadowPaint);

    // Draw card
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Usage in your main app:
/*class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SlantedCardsDemo(),
      debugShowCheckedModeBanner: false,
    );
  }
}*/

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              fontFamily: "SF Pro Text",
              brightness: Brightness.light,
              scaffoldBackgroundColor: Colors.grey[50],
            ),
            darkTheme: ThemeData(
              primarySwatch: Colors.blue,
              fontFamily: "SF Pro Text",
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xFF121212),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF1E1E1E),
              ),
            ),
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: SplashScreen(),
          );
        },
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
      url: "https://gnliemnkeeoxgayjfjiv.supabase.co",
      anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdubGllbW5rZWVveGdheWpmaml2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA0ODk5ODUsImV4cCI6MjA2NjA2NTk4NX0.OHq4Pf3Momf-C1GTEBlHwe4ma0tOcEKyC7sXfTRlWJI"
  );
  runApp(MyApp());
}

