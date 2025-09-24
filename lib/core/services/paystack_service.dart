import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PaystackService {
  static const String _baseUrl = 'https://api.paystack.co';
  late final Dio _dio;
  late final String _secretKey;
  late final String _publicKey;
  late final bool _isLiveMode;

  PaystackService() {
    _dio = Dio();
    _secretKey = dotenv.env['PAYSTACK_SECRET_KEY'] ?? '';
    _publicKey = dotenv.env['PAYSTACK_PUBLIC_KEY'] ?? '';
    
    // Validate API keys
    if (_secretKey.isEmpty || _publicKey.isEmpty) {
      print('⚠️ WARNING: Paystack API keys are not configured!');
      print('Please create a .env file with your Paystack API keys:');
      print('For TEST mode:');
      print('PAYSTACK_SECRET_KEY=sk_test_your_secret_key_here');
      print('PAYSTACK_PUBLIC_KEY=pk_test_your_public_key_here');
      print('');
      print('For LIVE mode (real money):');
      print('PAYSTACK_SECRET_KEY=sk_live_your_live_secret_key_here');
      print('PAYSTACK_PUBLIC_KEY=pk_live_your_live_public_key_here');
    } else if (_secretKey.startsWith('sk_test_')) {
      _isLiveMode = false;
      print('🧪 Using Paystack TEST mode - No real money will be charged');
    } else if (_secretKey.startsWith('sk_live_')) {
      _isLiveMode = true;
      print('💰 Using Paystack LIVE mode - Real money will be charged!');
    } else {
      _isLiveMode = false;
      print('⚠️ Unknown API key format - defaulting to TEST mode');
    }
    
    _dio.options.baseUrl = _baseUrl;
    _dio.options.headers = {
      'Authorization': 'Bearer $_secretKey',
      'Content-Type': 'application/json',
    };
  }

  /// Initialize Paystack transaction with bank payment option
  Future<Map<String, dynamic>> initializeTransaction({
    required String email,
    required double amount,
    required String reference,
    String? callbackUrl,
    Map<String, dynamic>? metadata,
    bool enableBankPayment = true, // Enable "Pay with Bank" by default
  }) async {
    try {
      // Check if API keys are configured
      if (_secretKey.isEmpty || _publicKey.isEmpty) {
        throw Exception('Paystack API keys are not configured. Please check your .env file.');
      }
      final data = {
        'email': email,
        'amount': (amount * 100).toInt(), // Convert to kobo (smallest currency unit)
        'reference': reference,
        'callback_url': callbackUrl,
        'metadata': metadata ?? {},
      };

      // Add bank payment channels if enabled
      if (enableBankPayment) {
        data['channels'] = ['bank', 'card']; // Enable both bank and card payments
      }

      final response = await _dio.post('/transaction/initialize', data: data);

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to initialize transaction: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Paystack initialization error: $e');
    }
  }

  /// Verify transaction
  Future<Map<String, dynamic>> verifyTransaction(String reference) async {
    try {
      print('🔍 Paystack Service: Verifying transaction with reference: $reference');
      
      final response = await _dio.get('/transaction/verify/$reference');
      
      print('📊 Paystack Service: Verification response status: ${response.statusCode}');
      print('📊 Paystack Service: Verification response data: ${response.data}');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        print('❌ Paystack Service: Verification failed with status: ${response.statusCode}');
        throw Exception('Failed to verify transaction: ${response.statusMessage}');
      }
    } catch (e) {
      print('❌ Paystack Service: Verification error: $e');
      throw Exception('Paystack verification error: $e');
    }
  }

  /// Create transfer recipient (for bank transfers)
  Future<Map<String, dynamic>> createTransferRecipient({
    required String type, // 'nuban' for bank account
    required String name,
    required String accountNumber,
    required String bankCode,
    String? description,
  }) async {
    try {
      // Validate input parameters
      if (name.trim().isEmpty) {
        throw Exception('Account name cannot be empty');
      }
      if (accountNumber.trim().isEmpty) {
        throw Exception('Account number cannot be empty');
      }
      if (bankCode.trim().isEmpty) {
        throw Exception('Bank code cannot be empty');
      }

      final response = await _dio.post('/transferrecipient', data: {
        'type': type,
        'name': name.trim(),
        'account_number': accountNumber.trim(),
        'bank_code': bankCode.trim(),
        'description': description?.trim() ?? 'Transfer recipient',
      });

      if (response.statusCode == 200) {
        return response.data;
      } else {
        // Get more detailed error information
        final errorData = response.data;
        final errorMessage = errorData?['message'] ?? response.statusMessage;
        throw Exception('Failed to create transfer recipient: $errorMessage');
      }
    } catch (e) {
      if (e is DioException) {
        // Handle specific DioException cases
        if (e.response?.statusCode == 400) {
          final errorData = e.response?.data;
          final errorMessage = errorData?['message'] ?? 'Invalid bank account details';
          throw Exception('Bank account validation failed: $errorMessage');
        } else if (e.response?.statusCode == 401) {
          throw Exception('Paystack authentication failed. Please check your API keys.');
        } else if (e.response?.statusCode == 403) {
          throw Exception('Paystack access forbidden. Please check your account permissions.');
        }
      }
      throw Exception('Paystack recipient creation error: $e');
    }
  }

  /// Initiate transfer to bank account
  Future<Map<String, dynamic>> initiateTransfer({
    required String source, // 'balance'
    required double amount,
    required String recipient,
    required String reason,
    String? reference,
  }) async {
    try {
      final response = await _dio.post('/transfer', data: {
        'source': source,
        'amount': (amount * 100).toInt(), // Convert to kobo
        'recipient': recipient,
        'reason': reason,
        'reference': reference ?? DateTime.now().millisecondsSinceEpoch.toString(),
      });

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to initiate transfer: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Paystack transfer error: $e');
    }
  }

  /// Get list of banks
  Future<List<Map<String, dynamic>>> getBanks() async {
    try {
      final response = await _dio.get('/bank');

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      } else {
        throw Exception('Failed to get banks: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Paystack banks error: $e');
    }
  }

  /// Resolve bank account number
  Future<Map<String, dynamic>> resolveAccountNumber({
    required String accountNumber,
    required String bankCode,
  }) async {
    try {
      final response = await _dio.get('/bank/resolve', queryParameters: {
        'account_number': accountNumber,
        'bank_code': bankCode,
      });

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to resolve account: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Paystack account resolution error: $e');
    }
  }

  /// Get transaction history
  Future<Map<String, dynamic>> getTransactions({
    int? perPage,
    int? page,
    String? status,
    String? from,
    String? to,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (perPage != null) queryParams['perPage'] = perPage;
      if (page != null) queryParams['page'] = page;
      if (status != null) queryParams['status'] = status;
      if (from != null) queryParams['from'] = from;
      if (to != null) queryParams['to'] = to;

      final response = await _dio.get('/transaction', queryParameters: queryParams);

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to get transactions: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Paystack transactions error: $e');
    }
  }

  /// Get balance
  Future<Map<String, dynamic>> getBalance() async {
    try {
      final response = await _dio.get('/balance');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to get balance: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Paystack balance error: $e');
    }
  }

  /// Generate payment reference
  String generateReference() {
    return 'PAY_${DateTime.now().millisecondsSinceEpoch}_${(1000 + (9999 - 1000) * DateTime.now().microsecond / 1000000).round()}';
  }

  /// Get public key for frontend integration
  String get publicKey => _publicKey;
  
  /// Check if currently in live mode
  bool get isLiveMode => _isLiveMode;
  
  /// Check if we can simulate real money transactions
  bool get canSimulateRealMoney => !_isLiveMode;

  /// Get list of supported banks for "Pay with Bank"
  Future<List<Map<String, dynamic>>> getSupportedBanks() async {
    try {
      final response = await _dio.get('/bank');
      
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      } else {
        throw Exception('Failed to get supported banks: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Error getting supported banks: $e');
    }
  }

  /// Initialize transaction specifically for bank payment
  Future<Map<String, dynamic>> initializeBankPayment({
    required String email,
    required double amount,
    required String reference,
    String? callbackUrl,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _dio.post('/transaction/initialize', data: {
        'email': email,
        'amount': (amount * 100).toInt(),
        'reference': reference,
        'callback_url': callbackUrl,
        'metadata': metadata ?? {},
        'channels': ['bank'], // Only bank payments
      });

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to initialize bank payment: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Bank payment initialization error: $e');
    }
  }

  /// Get transaction status
  Future<Map<String, dynamic>> getTransactionStatus(String reference) async {
    try {
      final response = await _dio.get('/transaction/$reference');
      
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to get transaction status: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Error getting transaction status: $e');
    }
  }

  /// Validate bank account details before creating recipient
  Future<Map<String, dynamic>> validateBankAccount({
    required String accountNumber,
    required String bankCode,
  }) async {
    try {
      print('🔍 Validating account: $accountNumber with bank code: $bankCode');
      
      final response = await _dio.get('/bank/resolve', queryParameters: {
        'account_number': accountNumber.trim(),
        'bank_code': bankCode.trim(),
      });

      print('📊 Paystack response status: ${response.statusCode}');
      print('📊 Paystack response data: ${response.data}');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        final errorData = response.data;
        final errorMessage = errorData?['message'] ?? 'Account validation failed';
        print('❌ Account validation failed: $errorMessage');
        throw Exception('Bank account validation failed: $errorMessage');
      }
    } catch (e) {
      print('❌ Account validation error: $e');
      if (e is DioException) {
        print('❌ DioException details: ${e.response?.statusCode} - ${e.response?.data}');
        if (e.response?.statusCode == 400) {
          final errorData = e.response?.data;
          final errorMessage = errorData?['message'] ?? 'Invalid account number or bank code';
          throw Exception('Invalid bank account: $errorMessage');
        } else if (e.response?.statusCode == 422) {
          final errorData = e.response?.data;
          final errorMessage = errorData?['message'] ?? 'Invalid bank code or account number';
          final meta = errorData?['meta'];
          if (meta != null && meta['nextStep'] != null) {
            throw Exception('$errorMessage. ${meta['nextStep']}');
          }
          throw Exception('$errorMessage. Please check the bank code and try again.');
        }
      }
      throw Exception('Bank account validation error: $e');
    }
  }
}
