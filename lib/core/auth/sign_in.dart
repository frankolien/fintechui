
import 'package:fintechui/presentation/screens/homepage/home_page.dart';
import 'package:fintechui/presentation/screens/profile/profile_dashboard_widget.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'sign_up.dart';
class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
  }

  bool isLoading = false;
  bool _obscurepassword = true;


  Future<void> loginUser() async {
    setState(() {
      isLoading = true;
    });

    try {
      // FIXED: Properly await the Future and get the actual result
      String res = await AuthService().loginUser(
        email: _usernameController.text,
        password: _passwordController.text,
      );

      if (res == "success") {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (context) => HomePage()
          ),
        );
      } else {
        setState(() {
          isLoading = false;
        });
        // ADDED: Show error message to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: $res')),
        );
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
      // ADDED: Show error message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login error: $e')),
      );
    }
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
                child: Column(

                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                    Text(
                      'Login to Your Account',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30
                      ),),
                      SizedBox(height: 28,),
                       SizedBox(
                        width: 350,
                         child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                           child: Container(
                            color: Colors.white,
                             child: TextField(
                              textAlign: TextAlign.start,

                              controller: _usernameController,
                              decoration: InputDecoration(
                                hintText: 'User Id',
                                hintStyle: TextStyle(
                                  color: Colors.grey
                                ),

                                border: OutlineInputBorder(
                                  borderSide: Divider.createBorderSide(context),

                                ),
                                contentPadding: EdgeInsetsGeometry.all(20)
                              ),


                             ),
                           ),
                         ),
                       ),
                       SizedBox(height: 28,),
                       SizedBox(

                        width: 350,
                         child: Container(

                           decoration: BoxDecoration(
                             borderRadius: BorderRadius.circular(8),
                             color: Colors.white,
                           ),
                           child: TextField(
                            textAlign: TextAlign.start,


                            controller: _passwordController,
                            obscureText: _obscurepassword,
                            decoration: InputDecoration(

                            suffixIcon: IconButton(onPressed: (){
                              setState(() {
                                _obscurepassword = !_obscurepassword;
                              });
                            }, icon: Icon(
                              _obscurepassword ? Icons.visibility : Icons.visibility_off,
                            )),
                              hintText: 'Password',
                              hintStyle: TextStyle(
                                    color: Colors.grey
                                  ),
                              border: OutlineInputBorder(
                                borderSide: Divider.createBorderSide(context),

                              ),
                              contentPadding: EdgeInsetsGeometry.all(20)
                            ),


                           ),
                         ),
                       ),
                    SizedBox(
                      height:MediaQuery.of(context).size.height * 0.03,
                    ),
                    GestureDetector(
                      onTap: isLoading ? null : loginUser,
                      child: Container(
                        width: 350,
                        height: 70,
                        //color: Colors.blue,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color(0xFf456EFE),
                        ),
                        child: isLoading ? Center(child: CircularProgressIndicator(color: Colors.white,)) :
                        Center(child: Text(
                            'Login',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20
                          ),
                        ),
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03,),
                    Text(
                      'Forget User / Password ?',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03,),
                    Image.asset('lib/images/fprint.png'),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03,),
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
                                context, MaterialPageRoute(builder: (context)=> SignUp()));
                          },
                          child: Text(
                            "Sign up",
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
              )
          ],
        ),
      ),
    );
  }
}