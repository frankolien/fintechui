
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fintechui/presentation/screens/onboarding/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/user_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    setState(() => _isUploading = true);

    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final ref = FirebaseStorage.instance.ref().child('profile_pictures').child('$userId.jpg');

      await ref.putFile(_imageFile!);

      final downloadUrl = await ref.getDownloadURL();

      // Save the URL in Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'profilePicture': downloadUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile picture updated!')));
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed')));
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    Map<String, dynamic>? data = await UserService().getCurrentUserData();
    setState(() {
      userData = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (isLoading) return CircularProgressIndicator();
    if (userData == null) return const Center(child: Text('Failed to load user data.'));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profile',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.grey[200],
              child: Icon(Icons.notification_add, color: Colors.grey[600]),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 10),
              Stack(
                children: [
                  _imageFile != null
                      ? CircleAvatar(radius: 60, backgroundImage: FileImage(_imageFile!))
                      : CircleAvatar(radius: 60, backgroundColor: Colors.grey[300], child: Icon(Icons.person, size: 60)),

                  SizedBox(height: 10),
                  /*ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: Icon(Icons.camera_alt),
                    label: Text('Choose Image'),
                  ),
                  if (_imageFile != null)
                    ElevatedButton(
                      onPressed: _isUploading ? null : _uploadImage,
                      child: _isUploading ? CircularProgressIndicator() : Text('Upload'),
                    ),*/
                  Positioned(
                    bottom: 0,
                    left: 70,
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
                      child: GestureDetector(
                        onTap: _pickImage,
                          child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20
                          ),

                      ),
                    ),
                  ),
                  if (_imageFile != null)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:Colors.blue
                      ),
                      onPressed: _isUploading ? null : _uploadImage,
                      child: _isUploading ? CircularProgressIndicator() : Text(
                          'Upload',
                        style: TextStyle(
                          color: Colors.white
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                userData!['username'] ?? 'No data found',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 30),
              _buildBalanceSummary(isDarkMode),
              const SizedBox(height: 15),
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
              const SizedBox(height: 40),
              _buildTransactionSection(isDarkMode),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceSummary(bool isDarkMode) {
    return Container(
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
        children: const [
          Text('Total balance', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          Text(
            '\$8681.41',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 17,
              letterSpacing: 1.2,
              height: 2.5,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTransactionSection(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Recent Transactions",
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 20),
        _buildInfoCard(
          Image.asset("lib/images/dropbox.png"),
          "Dropbox",
          "1 week ago",
          "\$8.50",
          isDarkMode: isDarkMode,
        ),
        const SizedBox(height: 10),
        _buildInfoCard(
          Image.asset("lib/images/apple.png"),
          "Apple Pay",
          "3 days ago",
          "\$10.00",
          isDarkMode: isDarkMode,
        ),
        const SizedBox(height: 10),
        _buildInfoCard(
          Image.asset("lib/images/linkedin.png"),
          "Linkedin",
          "1 month ago",
          "\$3.95",
          isDarkMode: isDarkMode,
        ),
      ],
    );
  }

  Widget _buildInfoCard(
      Widget? image,
      String label,
      String value,
      String end, {
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
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      color: isDarkMode ? Colors.grey[400] : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isPlaceholder
                          ? (isDarkMode ? Colors.grey[600] : Colors.grey[400])
                          : (isDarkMode ? Colors.white : Colors.grey),
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
    final cardData = {
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
      child: Padding(
        padding: const EdgeInsets.all(11.0),
        child: Column(
          children: [
            Container(
              height: 35,
              width: 35,
              decoration: BoxDecoration(
                //color: data['color'].toString(),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Image.asset(
                data['image'].toString(),
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.attach_money, color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              data['title'].toString(),
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

enum BalanceType { active, savings, investments }
