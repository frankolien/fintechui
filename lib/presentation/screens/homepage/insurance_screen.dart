import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../../screens/profile/profile_dashboard_widget.dart';

class InsuranceScreen extends StatelessWidget {
  const InsuranceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Services',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // View All functionality
            },
            child: Text(
              'View All',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _showServicesModal(context),
          child: Text('Show Services'),
        ),
      ),
    );
  }

  void _showServicesModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              
              // Services options
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Manage Profile
                    _buildServiceOption(
                      context,
                      'Manage Profile',
                      Icons.person,
                      Colors.blue,
                      () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileDashboard(),
                          ),
                        );
                      },
                      isHighlighted: true,
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Submit Complaints
                    _buildServiceOption(
                      context,
                      'Submit Complaints',
                      Icons.feedback,
                      Colors.grey[600]!,
                      () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Complaints feature coming soon')),
                        );
                      },
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Contact
                    _buildServiceOption(
                      context,
                      'Contact',
                      Icons.contact_support,
                      Colors.grey[600]!,
                      () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Contact feature coming soon')),
                        );
                      },
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Settings
                    _buildServiceOption(
                      context,
                      'Settings',
                      Icons.settings,
                      Colors.grey[600]!,
                      () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Settings feature coming soon')),
                        );
                      },
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Log Out
                    _buildServiceOption(
                      context,
                      'Log Out',
                      Icons.logout,
                      Colors.grey[600]!,
                      () => _handleLogout(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildServiceOption(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    bool isHighlighted = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: isHighlighted 
              ? Colors.blue.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isHighlighted 
              ? null 
              : Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isHighlighted ? Colors.blue : color,
              size: 24,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[600],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    // Show confirmation dialog
    bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Log Out'),
          content: Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Log Out'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      try {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        );

        // Perform logout
        final authService = AuthService();
        await authService.logoutUser();

        // Close loading dialog
        Navigator.of(context).pop();

        // Navigate to onboarding screen
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/onboarding',
          (Route<dynamic> route) => false,
        );

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully logged out'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        // Close loading dialog
        Navigator.of(context).pop();

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error logging out: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}