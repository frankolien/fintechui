import 'package:flutter/material.dart';
import "package:flutter/services.dart";
import "package:provider/provider.dart";
import "package:shared_preferences/shared_preferences.dart";


class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveThemeToPrefs();
    notifyListeners();
  }

  void _saveThemeToPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("isDarkMode", _isDarkMode);
  }

  void _loadThemeFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool("isDarkMode") ?? false;
    notifyListeners();
  }
}

class ProfilePage extends StatefulWidget {
  final ThemeProvider themeProvider;

  const ProfilePage({Key? key, required this.themeProvider}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = widget.themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey[50],
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profile',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.grey[200],
              child: Icon(Icons.notification_add,color: Colors.grey[600],),
            ),
          )
        ],
      ),
       body: SingleChildScrollView(
         child: Padding(
             padding: EdgeInsets.all(16),
           child: Center(
             child: Column(
               children: [
                 const SizedBox(height: 10),

                 // Profile Picture Section
                 Stack(
                   children: [
                     CircleAvatar(
                       //backgroundColor: Colors.transparent,
                         radius: 54,
                         backgroundImage:NetworkImage('https://media.licdn.com/dms/image/v2/D4D03AQHFzR3cYawcGg/profile-displayphoto-shrink_800_800/B4DZdOB9gLGYAg-/0/1749360829128?e=1756944000&v=beta&t=OWtyfqBkydBtiMlSTnRaar0WGVVoKpu8Kz7KS41VRWI'),
                         child: ClipOval(

                         )
                     ),
                     Positioned(
                       bottom: 0,
                       left: 70,
                       child: Container(
                         width: 35,
                         height: 35,
                         decoration: BoxDecoration(
                           color: Colors.blue,
                           shape: BoxShape.circle,
                         ),
                         child: const Icon(
                           Icons.edit,
                           color: Colors.white,
                           size: 20,
                         ),
                       ),
                     ),
                   ],
                 ),

                 const SizedBox(height: 10),

                 Text(
                   'Frank Olien',
                   style: TextStyle(
                     fontSize: 18,
                     fontWeight: FontWeight.w700,
                     color: isDarkMode ? Colors.white : Colors.black87,
                   ),
                 ),

                 const SizedBox(height: 30),
                 Container(
                   width: double.infinity,
                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                   decoration: BoxDecoration(
                     color: Colors.white,
                       borderRadius: BorderRadius.circular(12),
                   boxShadow: [
                     BoxShadow(
                       color: isDarkMode
                           ? Colors.black.withOpacity(0.3)
                           : Colors.black.withOpacity(0.05),
                       blurRadius: 10,
                       offset: const Offset(0, 2),
                     ),
                   ],
                   ),
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Text(
                           'Total balance',
                         style: TextStyle(
                           fontSize: 17,
                           fontWeight: FontWeight.w600
                         ),
                       ),
                       Text(
                           '\$4950.00',
                         style: TextStyle(
                           fontWeight: FontWeight.w700,
                               fontSize: 17,
                           letterSpacing: 1.2,
                           height: 2.5
                         ),

                       )
                     ],
                   ),
                 ),
                 SizedBox(height: 15,),
                 SizedBox(
                   height: 121,
                   child: ListView(
                     scrollDirection: Axis.horizontal,
                     children: [
                       _buildBalanceCard(BalanceType.active, "\$15.00", isDarkMode),
                       const SizedBox(width: 10),
                       _buildBalanceCard(BalanceType.savings, "\$150.00", isDarkMode),
                       const SizedBox(width: 10),
                       _buildBalanceCard(BalanceType.investments, "\$20.00", isDarkMode),
                     ],
                   ),
                 ),
                 SizedBox(height: 40,),
                 Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text("Recent Transactions",textAlign: TextAlign.start,style: TextStyle(
                         fontSize: 17,
                         fontWeight: FontWeight.bold,
                         color: Colors.black87
                     ),),
                     SizedBox(height: 20,),
                     _buildInfoCard(Image.asset("lib/images/dropbox.png"),
                     "Dropbox",
                     "1 week ago",
                     "\$8.50",
                     isDarkMode: isDarkMode,
                     ),
                     SizedBox(height: 10,),
                     _buildInfoCard(Image.asset("lib/images/apple.png"),
                       "Apple Pay",
                       "3 days ago",
                       "\$10.00",
                       isDarkMode: isDarkMode,
                     ),
                     SizedBox(height: 10,),
                     _buildInfoCard(Image.asset("lib/images/linkedin.png"),
                       "Linkedin",
                       "1 month ago",
                       "\3.95",
                       isDarkMode: isDarkMode,
                     ),
                   ],
                 )

               ],
             ),
           ),


         ),
       ),
    );
  }
  // might be used later
  Widget _buildInfoCard(
      Widget? image,
    String label,
    String value,
      String end,{
    Widget? trailing,
    bool isPlaceholder = false,
    required bool isDarkMode,
  }) {
    return Container(

      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (image != null) image,
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      letterSpacing: -0.5,
                      color: isDarkMode ? Colors.grey[400] : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 12,
                      color: isPlaceholder
                          ? (isDarkMode ? Colors.grey[600] : Colors.grey[400])
                          : (isDarkMode ? Colors.white : Colors.grey),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              if (trailing != null) trailing,
            ],
          ),
          Text(
            end,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              letterSpacing: 2,
              fontSize: 16,
              color: isDarkMode ? Colors.grey[400] : Colors.black87,
    ),
          ),
        ],
      ),
    );
  }


  Widget _buildBalanceCard(BalanceType type, String amount, bool isDarkMode) {
    // Define image and title for each type

    final Map<BalanceType, Map<String, dynamic>> cardData = {
      BalanceType.active: {
        'title': 'Active Balance',
        'image': 'lib/images/sss.png',
        'color': Colors.green.shade100,
      },
      BalanceType.savings: {
        'title': 'Total Loan',
        'image': 'lib/images/ssd.png',
        'color': Colors.pink.shade100,
      },
      BalanceType.investments: {
        'title': 'Loan',
        'image': 'lib/images/archive-book.png',
        'color': Colors.blue[100],
      },
    };

    final data = cardData[type]!;

    return Container(
      width: 114,
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(11.0),
        child: Column(
          children: [
            Container(
              height: 35,
              width: 35,
              decoration: BoxDecoration(
                color: data['color'],
                borderRadius: BorderRadius.circular(5),
              ),
              child: Image.asset(
                data['image'],
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.attach_money, color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              data['title'],
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            Text(
              amount,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                letterSpacing: 1.5,
                height: 2,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            )
          ],
        ),
      ),
    );
  }

}

enum BalanceType {
  active,
  savings,
  investments,
  // add more as needed
}
