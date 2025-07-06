import 'package:fintechui/presentation/screens/sidescreens/transferscreen/recent_transaction.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TrendScreen extends StatefulWidget {
  @override
  _TrendScreenState createState() => _TrendScreenState();
}

class _TrendScreenState extends State<TrendScreen> {
  int selectedIndex = 4;

  double availableBalance = 0.0; // Will be loaded from Firestore

  // Chart data points
  final List<FlSpot> chartData = [
    FlSpot(0, 3.8),
    FlSpot(1, 3.9),
    FlSpot(2, 3.85),
    FlSpot(3, 3.75),
    FlSpot(4, 3.65),
    FlSpot(5, 3.12),
    FlSpot(6, 3.2),
    FlSpot(7, 3.45),
    FlSpot(8, 3.8),
    FlSpot(9, 4.1),
    FlSpot(10, 4.35),
    FlSpot(11, 4.5),
    FlSpot(12, 4.2),
    FlSpot(13, 4.0),
    FlSpot(14, 3.95),
    FlSpot(15, 3.85),
    FlSpot(16, 3.9),
    FlSpot(17, 4.0),
    FlSpot(18, 4.1),
    FlSpot(19, 4.05),
    FlSpot(20, 4.0),
  ];

  final List<String> dateLabels = [
    'Jun 10', 'Jun 11', 'Jun 12', 'Jun 13', 'Jun 14',
    'Jun 15', 'Jun 16', 'Jun 17', 'Jun 18', 'Jun 19',
    'Jun 20', 'Jun 21', 'Jun 22', 'Jun 23', 'Jun 24',
    'Jun 25', 'Jun 26', 'Jun 27', 'Jun 28', 'Jun 29', 'Jun 30'
  ];

  // Mock values for Money In/Out
  double moneyIn = 271.00;
  double moneyOut = 180.00;

  @override
  void initState() {
    super.initState();
    _loadUserBalance();
  }

  Future<void> _loadUserBalance() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (doc.exists && doc.data()?['balance'] != null) {
      setState(() {
        availableBalance = (doc.data()!['balance'] as num).toDouble();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.grey[300],
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Icon(Icons.person, color: Colors.grey[600], size: 30),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Fintech',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.grey[200],
                        child: Icon(Icons.notifications_outlined, color: Colors.grey[600]),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 40),

              // Available Balance
              Center(
                child: Column(
                  children: [
                    Text(
                      'Available Balance',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '\$${availableBalance.floor()}',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '.${(availableBalance * 100).toInt() % 100}'.padLeft(2, '0'),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(width: 8),
                        Image.network(
                          "https://upload.wikimedia.org/wikipedia/commons/thumb/7/79/Flag_of_Nigeria.svg/960px-Flag_of_Nigeria.svg.png",
                          height: 10,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40),

              // Chart
              Container(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index == 0 || index == 5 || index == 10 ||
                                index == 15 || index == 20) {
                              return Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text(
                                  dateLabels[index],
                                  style: TextStyle(
                                    color: index == 5 ? Colors.blue : Colors.grey[600],
                                    fontSize: 12,
                                    fontWeight: index == 5 ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              );
                            }
                            return SizedBox();
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: chartData,
                        isCurved: true,
                        color: Colors.blue,
                        barWidth: 3,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            if (index == 5) {
                              return FlDotCirclePainter(
                                radius: 8,
                                color: Colors.blue,
                                strokeWidth: 3,
                                strokeColor: Colors.white,
                              );
                            }
                            return FlDotCirclePainter(
                              radius: 0,
                              color: Colors.transparent,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.blue.withOpacity(0.1),
                        ),
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (touchedSpot) => Colors.blue,
                        tooltipBorder: BorderSide.none,
                        tooltipPadding: EdgeInsets.all(8),
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            return LineTooltipItem(
                              '\$${(spot.y * 1000).toInt()}',
                              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            );
                          }).toList();
                        },
                      ),
                      touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
                        setState(() {
                          if (touchResponse != null && touchResponse.lineBarSpots != null) {
                            selectedIndex = touchResponse.lineBarSpots!.first.spotIndex;
                          }
                        });
                      },
                    ),
                  ),
                ),
              ),

              // Tooltip for selected point
              if (selectedIndex == 5)
                Padding(
                  padding: EdgeInsets.only(left: 100, top: 20),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '\$3120',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              SizedBox(height: 40),

              // Last 30 Days section
              Text(
                'Last 30 Days',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              SizedBox(height: 20),

              // Money In/Out cards
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Money In',
                                style: TextStyle(
                                  color: Colors.green[600],
                                  fontSize: 16,
                                ),
                              ),
                              Spacer(),
                              Icon(Icons.trending_down,
                                  color: Colors.green[600], size: 20),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            '\$${moneyIn.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                          Text(
                            'USD',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Money Out',
                                style: TextStyle(
                                  color: Colors.red[600],
                                  fontSize: 16,
                                ),
                              ),
                              Spacer(),
                              Icon(Icons.trending_up,
                                  color: Colors.red[600], size: 20),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            '\$${moneyOut.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[700],
                            ),
                          ),
                          Text(
                            'USD',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 30),

              // Recent Transactions
              Text(
                'Recent Transactions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              SizedBox(height: 20),

              // Transaction items
              /*Column(
                children: [
                  _buildTransactionItem(
                    'Dropbox',
                    '6 Months ago',
                    '\$10.00',
                    Colors.blue,
                    Icons.cloud,
                    'Cloud Storage Subscription',
                    'Posted',
                    '1422505649',
                    'Dec 27, 2024',
                  ),
                  SizedBox(height: 16),
                  _buildTransactionItem(
                    'Apple Pay',
                    'More than 3 years ago',
                    '\$8.50',
                    Colors.black,
                    Icons.apple,
                    'POS Signature Purchase',
                    'Posted',
                    '1422505650',
                    'Jul 04, 2021',
                  ),
                ],
              ),*/
              TransactionHistoryScreen(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(String title, String subtitle, String amount,
      Color iconColor, IconData icon, String description,
      String status, String transactionId, String postedDate) {
    return GestureDetector(
      onTap: () => _showTransactionDetail(title, description, amount, status,
          transactionId, postedDate, iconColor, icon),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            'USD',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _showTransactionDetail(String title, String description, String amount,
      String status, String transactionId, String postedDate,
      Color iconColor, IconData icon) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.4,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Transaction details card
              Container(
                margin: EdgeInsets.all(20),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // App icon and title
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: iconColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: Colors.white, size: 30),
                    ),

                    SizedBox(height: 16),

                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    SizedBox(height: 4),

                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),

                    SizedBox(height: 16),

                    // Status badge
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Transaction Status: $status',
                        style: TextStyle(
                          color: Colors.green[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Amount
                    Text(
                      amount,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'USD',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),

                    SizedBox(height: 20),

                    // Transaction details
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Transaction ID',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          transactionId,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Posted Date',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          postedDate,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
