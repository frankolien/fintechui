import 'package:fintechui/core/models/bank_model.dart';
import 'package:fintechui/presentation/screens/sidescreens/paybillscreen/account_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BankTransferScreen extends StatefulWidget {
  const BankTransferScreen({Key? key}) : super(key: key);

  @override
  State<BankTransferScreen> createState() => _BankTransferScreenState();
}

class _BankTransferScreenState extends State<BankTransferScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedBank = '';
  List<BankModel> _filteredBanks = [];
  List<BankModel> _allBanks = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchBanks();
    _searchController.addListener(_filterBanks);
  }

  Future<void> _fetchBanks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('https://api.paystack.co/bank'),
        headers: {
          'Authorization': 'Bearer pk_test_c07b97bebf3fff9084d4debbf6272f058d006f62',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          final List<dynamic> banksList = data['data'];
          
          setState(() {
            _allBanks = banksList.map((bank) => BankModel(
              name: bank['name'],
              code: bank['code'],
              slug: bank['slug'],
              logo: _getBankLogo(bank['name']),
              color: _getBankColor(bank['name']),
            )).toList();
            
            // Sort banks alphabetically
            _allBanks.sort((a, b) => a.name.compareTo(b.name));
            _filteredBanks = List.from(_allBanks);
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = 'Failed to load banks';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to connect to bank service';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  String _getBankLogo(String bankName) {
    // Map bank names to logo assets
    final Map<String, String> bankLogos = {
      'Access Bank': 'lib/images/access.png',
      'First Bank of Nigeria': 'lib/images/firstbank.png',
      'Guaranty Trust Bank': 'lib/images/gtb.png',
      'Zenith Bank': 'lib/images/zenith.png',
      'United Bank For Africa': 'lib/images/uba.png',
      'Opay Digital Services Limited (OPay)': 'lib/images/Unknown.jpg',
      'Kuda Microfinance Bank': 'lib/images/kuda.png',
      'Sterling Bank': 'lib/images/sterling.png',
      'Fidelity Bank': 'lib/images/fidelity.png',
      'Union Bank of Nigeria': 'lib/images/union.png',
      'Wema Bank': 'lib/images/wema.png',
      'Stanbic IBTC Bank': 'lib/images/ibtc_bank.png',
      'Ecobank Nigeria': 'assets/images/ecobank.png',
      'First City Monument Bank': 'lib/images/fcmb.png',
      'Polaris Bank': 'lib/images/polaris.png',
      'PalmPay': 'lib/images/palmpay.png',
      'Moniepoint Microfinance Bank': 'lib/images/moniepoint.png',
    };
    
    return bankLogos[bankName] ?? 'lib/images/verve.png';
  }

  Color _getBankColor(String bankName) {
    // Map bank names to brand colors
    final Map<String, Color> bankColors = {
      'Access Bank': Color(0xFF1A5490),
      'First Bank of Nigeria': Color(0xFF1E3A8A),
      'Guaranty Trust Bank': Color(0xFFFF6B00),
      'Zenith Bank': Color(0xFFE31837),
      'United Bank For Africa': Color(0xFFE31837),
      'Opay Digital Services Limited (OPay)': Color(0xFF1EC71E),
      'Kuda Microfinance Bank': Color(0xFF40196D),
      'Sterling Bank': Color(0xFF58C443),
      'Fidelity Bank': Color(0xFF8B0000),
      'Union Bank of Nigeria': Color(0xFF1F4E79),
      'Wema Bank': Color(0xFF7B1FA2),
      'Stanbic IBTC Bank': Color(0xFF0066CC),
      'Ecobank Nigeria': Color(0xFF0066CC),
      'First City Monument Bank': Color(0xFF8B0000),
      'Polaris Bank': Color(0xFF1565C0),
      'PalmPay': Color(0xFF6C1AB5),
      'Moniepoint Microfinance Bank': Color(0xFF0066FF),
    };
    
    return bankColors[bankName] ?? Color(0xFF424242);
  }

  void _filterBanks() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredBanks = List.from(_allBanks);
      } else {
        _filteredBanks = _allBanks.where((bank) {
          return bank.name.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios,
                            size: 20,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Bank Transfer',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications_outlined,
                          size: 20,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Transfer to Bank',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Search or select recipients bank',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Search Field
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: 'Search',
                              prefixIcon: Icon(Icons.search, color: Colors.grey),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Banks List
                        Expanded(
                          child: _isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF6366F1),
                                  ),
                                )
                              : _errorMessage.isNotEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.error_outline,
                                            size: 48,
                                            color: Colors.red,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            _errorMessage,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.red,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          ElevatedButton(
                                            onPressed: _fetchBanks,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF6366F1),
                                              foregroundColor: Colors.white,
                                            ),
                                            child: const Text('Retry'),
                                          ),
                                        ],
                                      ),
                                    )
                                  : _filteredBanks.isEmpty
                                      ? const Center(
                                          child: Text(
                                            'No banks found',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        )
                                      : ListView.builder(
                                          itemCount: _filteredBanks.length,
                                          itemBuilder: (context, index) {
                                            final bank = _filteredBanks[index];
                                            final isSelected = _selectedBank == bank.name;
                                            
                                            return GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _selectedBank = bank.name;
                                                });
                                              },
                                              child: Container(
                                                margin: const EdgeInsets.only(bottom: 12),
                                                padding: const EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[50],
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: isSelected ? Colors.blue : Colors.transparent,
                                                    width: 2,
                                                  ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 48,
                                                      height: 48,
                                                      decoration: BoxDecoration(
                                                        color: bank.color,
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          bank.name.length >= 2
                                                              ? bank.name.substring(0, 2).toUpperCase()
                                                              : bank.name.toUpperCase(),
                                                          style: const TextStyle(
                                                            color: Colors.white,
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            bank.name,
                                                            style: const TextStyle(
                                                              fontSize: 16,
                                                              fontWeight: FontWeight.w500,
                                                              color: Colors.black,
                                                            ),
                                                          ),
                                                          const SizedBox(height: 2),
                                                          Text(
                                                            'Code: ${bank.code}',
                                                            style: const TextStyle(
                                                              fontSize: 12,
                                                              color: Colors.grey,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 20,
                                                      height: 20,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color: isSelected ? Colors.blue : Colors.grey,
                                                          width: 2,
                                                        ),
                                                        color: isSelected ? Colors.blue : Colors.transparent,
                                                      ),
                                                      child: isSelected
                                                          ? const Icon(
                                                              Icons.check,
                                                              size: 12,
                                                              color: Colors.white,
                                                            )
                                                          : null,
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
                
                // Continue Button
                Container(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedBank.isNotEmpty
                          ? () {
                              // Find the selected bank object
                              final selectedBank = _allBanks.firstWhere(
                                (bank) => bank.name == _selectedBank,
                              );
                              Navigator.push(
                                context, 
                                MaterialPageRoute(
                                  builder: (context)=> 
                                AccountDetailsScreen(selectedBank: selectedBank)
                                     ),
                                    );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: Colors.grey[300],
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

