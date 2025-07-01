
import 'package:fintechui/core/auth/sign_in.dart';
import 'package:flutter/material.dart';

import '../../presentation/screens/homepage/home.dart';
import '../../presentation/screens/homepage/home_page.dart';
import '../services/auth_service.dart';
class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
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
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,}$');
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




  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);



      // Navigate to home screen after successful signup
      Navigator.pushReplacement(
          context, MaterialPageRoute(
          builder: (context)=> Home()));

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xFF1A1B2E),
      body: SizedBox.expand(
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
                        width: 350,

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
                            hintText: 'Name',
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
                        width: 350,

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
                        width: 350,

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
                     Padding(
                       padding: const EdgeInsets.symmetric(horizontal: 22.0,),
                       child: Row(
                         children: [
                           Expanded(
                             child: Container(
                               //width: 10,

                               decoration: BoxDecoration(
                                 borderRadius: BorderRadius.circular(10),
                                 color: Colors.white,
                               ),
                               child: TextFormField(
                                 validator: _validatePassword,
                                 obscureText: true,
                                 textAlign: TextAlign.start,
                                 textInputAction: TextInputAction.next,
                                 controller: _passwordController,
                                 decoration: InputDecoration(
                                     hintText: 'Password',
                                     suffixIcon: IconButton(onPressed: (){
                                       setState(() {
                                         _obscurepassword = !_obscurepassword;
                                       });
                                     }, icon: Icon(
                                       _obscurepassword ? Icons.visibility : Icons.visibility_off,
                                     )),
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
                           ),
                           SizedBox(width: 30,),
                           Container(
                             width: 60,

                             decoration: BoxDecoration(
                               borderRadius: BorderRadius.circular(10),
                               color: Colors.white,
                             ),
                             child:  Image.asset('lib/images/fprint.png'),
                           ),
                         ],
                       ),
                     ),
                      SizedBox(height: 13,),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
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
                      _isLoading
                          ? CircularProgressIndicator()
                      :
                      GestureDetector(
                        onTap: (){
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> HomePage()));
                        },

                        child: Container(
                          width: 350,
                          height: 70,
                          //color: Colors.blue,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color(0xFf456EFE),
                          ),
                          child: Center(child: Text(
                            'Login',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20
                            ),
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

