// transaction_history_screen.dart
import 'package:fintechui/core/services/transfer_service.dart';
import 'package:fintechui/presentation/screens/sidescreens/transferscreen/money_transfer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionHistoryScreen extends StatelessWidget {
  final TransferService _transferService = TransferService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _transferService.getTransactionHistory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading transactions: ${snapshot.error}'),
          );
        }

        final transactions = snapshot.data ?? [];

        if (transactions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                SizedBox(height: 16),
                Text(
                  'No transactions yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Start transferring money to see your history',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.all(8),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            final isReceived = transaction['type'] == 'received';
            final timestamp = transaction['timestamp']?.toDate();

            return Container(
              width: double.infinity,
              child: Card(
                elevation: 10,
                color: Colors.grey[100],
                shadowColor: Colors.blue,
                margin: EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: isReceived
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    child: Icon(
                      isReceived ? Icons.arrow_downward : Icons.arrow_upward,
                      color: isReceived ? Colors.green : Colors.red,
                    ),
                  ),
                  title: Text(
                    isReceived
                        ? 'Received from ${transaction['senderUsername']}'
                        : 'Sent to ${transaction['recipientUsername']}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (transaction['description'] != null)
                        Text(
                          transaction['description'],
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      SizedBox(height: 4),
                      Text(
                        timestamp != null
                            ? DateFormat('MMM dd, yyyy • hh:mm a').format(timestamp)
                            : 'Unknown time',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  trailing: Text(
                    '${isReceived ? '+' : '-'}\$${transaction['amount'].toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isReceived ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

