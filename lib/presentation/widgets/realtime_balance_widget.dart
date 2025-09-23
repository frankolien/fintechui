import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/services/realtime_balance_service.dart';

/// Real-time balance display widget
class RealtimeBalanceWidget extends ConsumerStatefulWidget {
  final String? title;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final bool showCurrency;
  final String currencySymbol;

  const RealtimeBalanceWidget({
    Key? key,
    this.title,
    this.textStyle,
    this.backgroundColor,
    this.padding,
    this.showCurrency = true,
    this.currencySymbol = '₦',
  }) : super(key: key);

  @override
  ConsumerState<RealtimeBalanceWidget> createState() => _RealtimeBalanceWidgetState();
}

class _RealtimeBalanceWidgetState extends ConsumerState<RealtimeBalanceWidget> {
  RealtimeBalanceService? _service;

  @override
  void initState() {
    super.initState();
    // Initialize real-time updates when widget is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _service = ref.read(realtimeBalanceServiceProvider);
        _service?.initializeRealtimeUpdates();
      }
    });
  }

  @override
  void dispose() {
    // Clean up real-time balance service
    _service?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final balanceAsync = ref.watch(balanceStreamProvider);
    
    return Container(
      padding: widget.padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.title != null) ...[
            Text(
              widget.title!,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
          ],
          balanceAsync.when(
            data: (balance) => Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: Colors.green.shade600,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.showCurrency 
                        ? '${widget.currencySymbol}${balance.toStringAsFixed(2)}'
                        : balance.toStringAsFixed(2),
                    style: widget.textStyle ?? Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Live indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.green.shade600,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            loading: () => Row(
              children: [
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
                Text(
                  'Loading balance...',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            error: (error, stack) => Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red.shade600,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Error loading balance',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.red.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Real-time transaction history widget
class RealtimeTransactionWidget extends ConsumerStatefulWidget {
  final int maxTransactions;
  final bool showHeader;
  final String? title;

  const RealtimeTransactionWidget({
    Key? key,
    this.maxTransactions = 10,
    this.showHeader = true,
    this.title,
  }) : super(key: key);

  @override
  ConsumerState<RealtimeTransactionWidget> createState() => _RealtimeTransactionWidgetState();
}

class _RealtimeTransactionWidgetState extends ConsumerState<RealtimeTransactionWidget> {
  RealtimeBalanceService? _service;

  @override
  void initState() {
    super.initState();
    // Initialize real-time updates when widget is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _service = ref.read(realtimeBalanceServiceProvider);
        _service?.initializeRealtimeUpdates();
      }
    });
  }

  @override
  void dispose() {
    // Clean up real-time balance service
    _service?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionStreamProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showHeader) ...[
          Row(
            children: [
              Icon(
                Icons.history,
                color: Colors.blue.shade600,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                widget.title ?? 'Recent Transactions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        transactionsAsync.when(
          data: (transactions) {
            if (transactions.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        color: Colors.grey.shade400,
                        size: 48,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No transactions yet',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            
            final displayTransactions = transactions.take(widget.maxTransactions).toList();
            
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayTransactions.length,
              itemBuilder: (context, index) {
                final transaction = displayTransactions[index];
                return _buildTransactionItem(transaction);
              },
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stack) => Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red.shade600,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Error loading transactions',
                    style: TextStyle(
                      color: Colors.red.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    final type = transaction['type'] as String? ?? 'unknown';
    final amount = (transaction['amount'] as num?)?.toDouble() ?? 0.0;
    final description = transaction['description'] as String? ?? 'Transaction';
    final timestamp = transaction['timestamp'] as Timestamp?;
    final metadata = transaction['metadata'] as Map<String, dynamic>? ?? {};
    
    // Determine transaction type and display text
    final isCredit = type == 'credit' || type == 'received' || type == 'funding';
    final isDebit = type == 'debit' || type == 'sent' || type == 'bank_transfer';
    
    // Create proper display text based on transaction type
    String displayText = description;
    if (isCredit && metadata['source'] == 'paystack') {
      displayText = 'Wallet Funding';
    } else if (isCredit && metadata['source'] == 'bank_payment') {
      displayText = 'Bank Payment';
    } else if (isDebit && metadata['source'] == 'bank_transfer') {
      displayText = 'Bank Transfer';
    } else if (isDebit && metadata['transfer_type'] == 'user_to_user') {
      displayText = 'Transfer to User';
    }
    
    Color amountColor = Colors.grey.shade600;
    IconData amountIcon = Icons.swap_horiz;
    String amountPrefix = '';
    
    if (isCredit) {
      amountColor = Colors.green.shade600;
      amountIcon = Icons.add_circle_outline;
      amountPrefix = '+';
    } else if (isDebit) {
      amountColor = Colors.red.shade600;
      amountIcon = Icons.remove_circle_outline;
      amountPrefix = '-';
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: amountColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              amountIcon,
              color: amountColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayText,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                if (timestamp != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    _formatTimestamp(timestamp),
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            '$amountPrefix₦${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: amountColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
