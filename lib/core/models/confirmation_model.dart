import 'package:fintechui/core/models/bank_model.dart';

class TransferConfirmationScreenn {
  final BankModel bank;
  final String accountNumber;
  final String accountName;
  final String amount;
  final String purpose;
    final String recipientName;
  final String recipientAccount;
  final String transferAmount;
  final String recipientUid;
  final String transferFee;
  final String cardType;
  final String cardNumber;


  const TransferConfirmationScreenn({
    required this.recipientName, 
    required this.recipientAccount, 
    required this.transferAmount, 
    required this.recipientUid, 
    required this.transferFee, 
    required this.cardType, 
    required this.cardNumber,
    required this.bank,
    required this.accountNumber,
    required this.accountName,
    required this.amount,
    required this.purpose,
  });

}
