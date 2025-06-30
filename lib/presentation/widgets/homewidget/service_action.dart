import 'package:flutter/material.dart';
class ServiceAction {
  final String title;
  final IconData icon;
  final Color backgroundColor;
  final VoidCallback? onTap;

  ServiceAction({
    required this.title,
    required this.icon,
    required this.backgroundColor,
    this.onTap,
});
}

class ServiceActions extends StatelessWidget {
  final List<ServiceAction> serviceActions = [
    ServiceAction(
        title: "Recharge",
        icon: Icons.phone,
        backgroundColor: Colors.white,
        onTap: (){},
    ),
    ServiceAction(
      title: "Charity",
      icon: Icons.card_giftcard_outlined,
      backgroundColor: Colors.white,
      onTap: (){},
    ),
    ServiceAction(
      title: "Loan",
      icon: Icons.monetization_on,
      backgroundColor: Colors.white,
      onTap: (){},
    ),
    ServiceAction(
      title: "Gifts",
      icon: Icons.wallet_giftcard_outlined,
      backgroundColor: Colors.white,
      onTap: (){},
    ),
    ServiceAction(
      title: "Insurance",
      icon: Icons.shield,
      backgroundColor: Colors.white,
      onTap: (){},
    ),
  ];
  ServiceActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Service',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        Container(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: serviceActions.length,
              itemBuilder:(context,index) {
                final service = serviceActions[index];
                return Container(
                  width:80,
                  margin: EdgeInsets.only(right: 16),
                  child: GestureDetector(
                    onTap: service.onTap,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              service.icon,
                              color: Colors.blue,
                              size: 24,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            service.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
    ),
        ),
      ],
    );
  }
  Color _getIconColor(Color backgroundColor) {
    if (backgroundColor == Colors.green.shade100) return Colors.green.shade700;
    if (backgroundColor == Colors.blue.shade100) return Colors.blue.shade700;
    return Colors.grey.shade700;
  }
}
