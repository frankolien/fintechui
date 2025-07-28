import 'package:fintechui/presentation/screens/homepage/atm_locator.dart';
import 'package:fintechui/presentation/screens/homepage/home.dart';
import 'package:fintechui/presentation/screens/homepage/qr_code_scanner_screen.dart';
import 'package:fintechui/presentation/screens/sidescreens/transferscreen/recent_transaction.dart';
import 'package:fintechui/presentation/screens/sidescreens/transferscreen/transfer_successful_screen.dart';
import 'package:flutter/material.dart';

import 'insurance_screen.dart';
import 'menu_screen.dart';
import 'trend_screen.dart';
import 'wallet_screen.dart';
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getBodyWidget(), 
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.location_pin),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner_sharp),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.trending_up),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.apps),
              label: '',
            ),
          ],
        ),
      ),
    );
  }

  Widget _getBodyWidget() {
    switch (_selectedIndex) {
      case 0:
        return Home(
          
        ); // Your main content
      case 1:
        return AtmLocatorScreen();
      case 2:
        return QRScannerScreen();
      case 3:
        return TrendScreen();
      case 4:
        return InsuranceScreen();

      default:
        return Home();
    }
  }
}


