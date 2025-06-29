import 'dart:async';
import 'package:fintechui/presentation/screens/tab_view.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SplashScreen extends StatefulWidget {
  final double size;
  const SplashScreen({
    super.key,
    this.size = 1200.0, // Default size for the splash screen
    });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
    double _opacity = 0.0; // Initial opacity for the text
    @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1.0; // Update the opacity to make the text fully visible
      });
    });

    // Set a timer to navigate to the next screen after a delay
    Timer(const Duration(milliseconds: 1700), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>  TabViewW()), // Replace HomeScreen with your next screen
      );
    });
  }
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1B2E),
      body: Center(
        child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Shimmer.fromColors(
          baseColor: Color(0xFF1A1B2E),
          highlightColor: Colors.grey[400]!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
            ),
          ),
        ),
            ),
      )

    );
  }
}