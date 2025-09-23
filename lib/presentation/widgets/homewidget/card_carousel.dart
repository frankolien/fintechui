import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/realtime_balance_service.dart';
import '../../../core/services/user_service.dart';
import 'atm_card.dart';

class CardCarousel extends ConsumerStatefulWidget {
  @override
  ConsumerState<CardCarousel> createState() => _CardCarouselState();
}

class _CardCarouselState extends ConsumerState<CardCarousel> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();
  final PageController _pageController = PageController();
  String _username = 'User';
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUsername();
    // Initialize real-time updates when widget is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final service = ref.read(realtimeBalanceServiceProvider);
      service.initializeRealtimeUpdates();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadUsername() async {
    try {
      final username = await _userService.getCurrentUsername();
      if (mounted) {
        setState(() {
          _username = username;
        });
      }
    } catch (e) {
      print('Error loading username: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final balanceAsync = ref.watch(balanceStreamProvider);
    final user = _auth.currentUser;
    
    if (user == null) {
      return const Center(child: Text('Please log in'));
    }

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: balanceAsync.when(
            data: (balance) => PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: 3,
              itemBuilder: (context, index) {
                List<Map<String, dynamic>> cards = [
                  {
                    'balance': balance, // Real-time balance
                    'number': '**** **** **** 8635',
                    'holder': _username,
                    'color': Color(0xFF1A1B2E), // Chipper Cash dark blue
                    'isRealTime': true,
                  },
                  {
                    'balance': 2129.33,
                    'number': '**** **** **** 5678',
                    'holder': _username,
                    'color': Color(0xFF2D2E42), // Darker blue variant
                    'isRealTime': false,
                  },
                  {
                    'balance': 2323.32,
                    'number': '**** **** **** 9012',
                    'holder': _username,
                    'color': Color(0xFF1A1B2E), // Chipper Cash dark blue
                    'isRealTime': false,
                  },
                ];
                
                return AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double value = 0.0;
                    if (_pageController.position.haveDimensions) {
                      value = index.toDouble() - (_pageController.page ?? 0);
                      value = (1 - (value.abs() * 0.15)).clamp(0.0, 1.0);
                    } else {
                      value = index == 0 ? 1.0 : 0.85;
                    }

                    return Transform.scale(
                      scale: value,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0 * (1 - value),
                        ),
                        child: AtmCard(
                          availableBalance: cards[index]['balance'],
                          cardNumber: cards[index]['number'],
                          cardHolder: cards[index]['holder'],
                          cardColor: cards[index]['color'],
                          isRealTime: cards[index]['isRealTime'] ?? false,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            loading: () => const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A1B2E)),
              ),
            ),
            error: (error, stack) => Center(
              child: Text(
                'Error loading balance: $error',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ),
        ),
        
        // Page indicators
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            return AnimatedContainer(
              duration: Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(horizontal: 3),
              width: _currentIndex == index ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _currentIndex == index 
                    ? Color(0xFF1A1B2E) 
                    : Color(0xFF1A1B2E).withOpacity(0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}