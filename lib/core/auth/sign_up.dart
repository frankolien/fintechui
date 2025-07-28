import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fintechui/core/auth/sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../presentation/screens/homepage/home.dart';
import '../../presentation/screens/homepage/home_page.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _cncController = TextEditingController();
  //final _authService = AuthService();


  @override
  void dispose(){
    super.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _numberController.dispose();
    _cncController.dispose();
  }
  String? errorMessage;
  bool _isChecked = false;
  bool _isLoading = false;
  bool _obscurepassword = true;
  
  String? _validateName(String? value){
    if(value ==null || value.isEmpty){
      return "Name is required";
    }
    if(value.length <2) {
      return "Name must at least be 2 characters";
    }
    return null;
  }
  
  String? _validateEmail(String? value){
    if (value == null || value.isEmpty) {
      return "please enter a valid Email";
    }
    final emailRegex = RegExp(r'^[\w.-]+@([\w-]+\.)+[\w-]{2,}$');
    if (!emailRegex.hasMatch(value)){
    return "please enter a valid Email";
    }
    return null;
  }

  String? _validatePhone(String? value){
    if(value ==null || value.isEmpty){
      return "Phone number is required";
    }
    return null;
  }

  String? _validatePassword(String? value){
    if(value == null || value.isEmpty){
      return "Password is required";
    }
    if(value.length < 8) {
      return "Password must be at least 8 characters";
    }
    if(!value.contains(RegExp(r'[A-Z]'))){
      return 'Password must contain at least one uppercase letter';
    }
    if(!value.contains(RegExp(r'[a-z]'))){
      return 'Password must contain at least one lowercase letter';
    }
    return null;
  }




  /*Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);



      // Navigate to home screen after successful signup
      Navigator.pushReplacement(
          context, MaterialPageRoute(
          builder: (context)=> Home()));

  }*/

// Refactored sign up function
  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String authResult = await AuthService().signupUser(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (authResult != "success") {
        _showErrorMessage(authResult);
        return;
      }

      String userDataResult = await UserService().saveUserData(
        email: _emailController.text.trim(),
        username: _generateUsername(), // or use a separate username field
        fullName: _fullNameController.text.trim(),
        phoneNumber: _numberController.text.trim(),
      );

      if (userDataResult != "success") {
        _showErrorMessage("Failed to save profile: $userDataResult");
        return;
      }

      _showSuccessMessage('Account created successfully!');

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage())
      );

    } catch (e) {
      print('Sign up error: $e');
      _showErrorMessage('An unexpected error occurred. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

// Helper method to generate username from email (you can customize this)
  String _generateUsername() {
    String email = _nameController.text.trim();
    return email.split('@')[0]; // Use part before @ as username
  }

// Helper method to show error messages
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 4),
      ),
    );
  }

// Helper method to show success messages
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xFF1A1B2E),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Positioned(
              right: -40,
              child: Transform.rotate(
                  angle: 0.02,
                  child: Image.asset(
                      'lib/images/Ellipse 52.png'
                  )),
            ),
              Center(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.15,),
                      Text(
                          'Create Your Account',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 30
                        ),),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.025,),
                      Container(
                         width: MediaQuery.of(context).size.width * 0.8,

                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                        child: TextFormField(
                          validator: _validateName,
                          textAlign: TextAlign.start,
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            hintText: 'Username',
                            hintStyle: TextStyle(
                                color: Colors.grey
                            ),
                            border: OutlineInputBorder(
                              borderSide: Divider.createBorderSide(context)
                            ),
                            contentPadding: EdgeInsetsGeometry.all(25)
                          ),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.025,),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,

                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                        child: TextFormField(
                          validator: _validateName,
                          textAlign: TextAlign.start,
                          controller: _fullNameController,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                              hintText: 'Full Name',
                              hintStyle: TextStyle(
                                  color: Colors.grey
                              ),
                              border: OutlineInputBorder(
                                  borderSide: Divider.createBorderSide(context)
                              ),
                              contentPadding: EdgeInsetsGeometry.all(25)
                          ),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.025,),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,

                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                        child: TextFormField(
                          validator: _validateEmail,
                          textAlign: TextAlign.start,
                          textInputAction: TextInputAction.next,
                          controller: _emailController,
                          decoration: InputDecoration(
                              hintText: 'Email',
                              hintStyle: TextStyle(
                                  color: Colors.grey
                              ),
                              border: OutlineInputBorder(
                                  borderSide: Divider.createBorderSide(context)
                              ),
                              contentPadding: EdgeInsetsGeometry.all(25)
                          ),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.025,),
                      Container(
                       width: MediaQuery.of(context).size.width * 0.8,

                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                        child: TextFormField(
                          validator: _validatePhone,
                          textAlign: TextAlign.start,
                          textInputAction: TextInputAction.next,
                          controller: _numberController,
                          decoration: InputDecoration(
                              hintText: 'Mobile Number',
                              hintStyle: TextStyle(
                                  color: Colors.grey
                              ),
                              border: OutlineInputBorder(
                                  borderSide: Divider.createBorderSide(context)
                              ),
                              contentPadding: EdgeInsetsGeometry.all(25)
                          ),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.025,),
                      /*Container(
                        width: 350,

                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                        child: TextFormField(
                          validator: (value) => value!.isEmpty ? 'Required' : null,
                          textAlign: TextAlign.start,
                          controller: _cncController,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                              hintText: 'CNC',
                              hintStyle: TextStyle(
                                  color: Colors.grey
                              ),
                              border: OutlineInputBorder(
                                  borderSide: Divider.createBorderSide(context)
                              ),
                              contentPadding: EdgeInsetsGeometry.all(25)
                          ),
                        ),
                      ),
                     SizedBox(height: MediaQuery.of(context).size.height * 0.025,),*/
                   // Replace the password field section (around line 367-410) with this:

Container(
  width: MediaQuery.of(context).size.width * 0.8,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(10),
    color: Colors.white,
  ),
  child: Row(
    children: [
      Expanded(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.7,
          child: TextFormField(
            validator: _validatePassword,
            obscureText: _obscurepassword,
            textAlign: TextAlign.start,
            textInputAction: TextInputAction.next,
            controller: _passwordController,
            decoration: InputDecoration(
              hintText: 'Password',
              suffixIcon: IconButton(
                onPressed: (){
                  setState(() {
                    _obscurepassword = !_obscurepassword;
                  });
                }, 
                icon: Icon(
                  _obscurepassword ? Icons.visibility : Icons.visibility_off,
                )
              ),
              hintStyle: TextStyle(color: Colors.grey),
              border: OutlineInputBorder(
                borderSide: Divider.createBorderSide(context),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
              ),
              contentPadding: EdgeInsets.all(25),
            ),
          ),
        ),
      ),
      Container(
        width: 60,
        height: 70, // Match the height of the text field
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
          color: Colors.white,
          border: Border(
            left: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
        ),
        child: Center(
          child: Image.asset(
            'lib/images/fprint.png',
            width: 30,
            height: 30,
          ),
        ),
      ),
    ],
  ),
),
                      SizedBox(height: 13,),
                      Container(

                        width: MediaQuery.of(context).size.width * 0.81,
                        child: Row(
                          children: [
                            Checkbox(
                              value: _isChecked,
                              onChanged: (bool? newValue) {
                                setState(() {
                                  _isChecked = newValue ?? false; // Handle null case
                                });
                              },
                              activeColor: Colors.blue,
                              checkColor: Colors.white,
                              // You can customize the color, size, and other properties.
                            ),
                        
                            RichText(
                              text: TextSpan(
                                children:[
                                  TextSpan(
                                    text: 'I agree to the ',
                                    style: TextStyle(
                                        color: Colors.white,
                                      fontSize: 15
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Terms & Conditions',
                                    style: TextStyle(
                                      color: Colors.blue,
                                        fontSize: 15
                                    ),
                                  ),
                                      ]
                              ),
                        
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.025,),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: 70,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _signUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:Color(0xFf456EFE),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Creating Account...'),
                            ],
                          )
                              : Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.025,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don\'t have an account?",
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16
                            ),
                          ),
                          SizedBox(width: 2,),
                          GestureDetector(
                            onTap: (){
                              Navigator.push(
                                  context, MaterialPageRoute(builder: (context)=> SignIn()));
                            },
                            child: Text(
                              "Sign in",
                              style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.white
                              ),
                            ),
                          ),
                        ],
                      )


                    ],
                  ),
                ),
              )
          ],
        ),
      )

    );
  }
}

