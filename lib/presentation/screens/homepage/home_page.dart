import 'package:fintechui/presentation/screens/homepage/atm_locator.dart';
import 'package:fintechui/presentation/screens/homepage/home.dart';
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
      body: _getBodyWidget(), // Your main content
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
        return Home(); // Your main content
      case 1:
        return AtmLocatorScreen();
      case 2:
        return WalletScreen();
      case 3:
        return TrendScreen();
      case 4:
        return MenuScreen();
      default:
        return Home();
    }
  }
}




/*import 'package:fintechui/presentation/screens/homepage/home.dart';
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

  // Create navigator keys for each tab
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(), // Home
    GlobalKey<NavigatorState>(), // Insurance
    GlobalKey<NavigatorState>(), // Wallet
    GlobalKey<NavigatorState>(), // Trends
    GlobalKey<NavigatorState>(), // Menu
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Handle back button - pop from current tab's navigator first
        final isFirstRouteInCurrentTab =
        !await _navigatorKeys[_selectedIndex].currentState!.maybePop();

        if (isFirstRouteInCurrentTab) {
          // If we're on the first route of current tab, go to home tab
          if (_selectedIndex != 0) {
            setState(() {
              _selectedIndex = 0;
            });
            return false;
          }
        }
        return isFirstRouteInCurrentTab;
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildNavigator(0, Home()),
            _buildNavigator(1, InsuranceScreen()),
            _buildNavigator(2, WalletScreen()),
            _buildNavigator(3, TrendScreen()),
            _buildNavigator(4, MenuScreen()),
          ],
        ),
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
            onTap: _onTabTapped,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shield_outlined),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_balance_wallet_outlined),
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
      ),
    );
  }

  Widget _buildNavigator(int index, Widget initialScreen) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(
          builder: (context) {
            switch (settings.name) {
              case '/':
                return initialScreen;

            // Add your additional screens here
              case '/payment-details':
                final payment = settings.arguments;
                return PaymentDetailsScreen(payment: payment);

              case '/transaction-history':
                return TransactionHistoryScreen();

              case '/profile':
                return ProfileScreen();

              case '/settings':
                return SettingsScreen();

            // Add more routes as needed
              default:
                return initialScreen;
            }
          },
        );
      },
    );
  }

  void _onTabTapped(int index) {
    if (_selectedIndex == index) {
      // If tapping on currently selected tab, pop to root
      _navigatorKeys[index].currentState!.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }
}*/