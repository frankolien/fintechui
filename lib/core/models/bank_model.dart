import 'dart:convert';
import 'dart:ui';

import 'package:http/http.dart' as http;

class BankModel {
  final String name;
  final String code;
  final String slug;
  final String logo;
  final Color color;

  BankModel({
    required this.name,
    required this.code,
    required this.slug,
    required this.logo,
    required this.color,
  });

  // Convert to JSON for Firebase storage
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'slug': slug,
      'logo': logo,
      'color': color.value,
    };
  }

  // Create from JSON for Firebase retrieval
  factory BankModel.fromJson(Map<String, dynamic> json) {
    return BankModel(
      name: json['name'],
      code: json['code'],
      slug: json['slug'],
      logo: json['logo'],
      color: Color(json['color']),
    );
  }
}

// Alternative API service class for better organization
class BankApiService {
  static const String baseUrl = 'https://api.paystack.co';
  static const String publicKey = 'pk_test_c07b97bebf3fff9084d4debbf6272f058d006f62';
  
  static Future<List<BankModel>> fetchBanks() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/bank'),
        headers: {
          'Authorization': 'Bearer $publicKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          final List<dynamic> banksList = data['data'];
          
          return banksList.map((bank) => BankModel(
            name: bank['name'],
            code: bank['code'],
            slug: bank['slug'],
            logo: _getBankLogo(bank['name']),
            color: _getBankColor(bank['name']),
          )).toList();
        }
      }
      throw Exception('Failed to load banks');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static String _getBankLogo(String bankName) {
    // Same logic as in the main class
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
    return bankLogos[bankName] ?? 'assets/images/default_bank.png';
  }

  static Color _getBankColor(String bankName) {
    // Same logic as in the main class
    final Map<String, Color> bankColors = {
      'Access Bank': Color(0xFF1A5490),
      'First Bank of Nigeria': Color(0xFF1E3A8A),
      // ... add more mappings
    };
    return bankColors[bankName] ?? Color(0xFF424242);
  }
}

// Usage example:
// final selectedBank = await Navigator.push<BankModel>(
//   context,
//   MaterialPageRoute(builder: (context) => const BankTransferScreen()),
// );
// if (selectedBank != null) {
//   print('Selected bank: ${selectedBank.name} (${selectedBank.code})');
// }