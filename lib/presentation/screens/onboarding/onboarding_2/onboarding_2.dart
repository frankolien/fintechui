
import 'package:flutter/material.dart';

import '../../../../core/auth/sign_in.dart';

class Onboarding2 extends StatefulWidget {
  const Onboarding2({super.key});

  @override
  State<Onboarding2> createState() => _Onboarding2State();
}

class _Onboarding2State extends State<Onboarding2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1B2E),
       //backgroundColor: Color(0x23303B),
      body: SizedBox.expand(
        child: Stack(
          children: [
            
           Positioned(
            bottom: 550,
            child: Transform(
                alignment: Alignment.center,
  /*transform: Matrix4.identity()
    ..setEntry(3, 2, 0.002)    // Add perspective
    ..rotateX(-0.1)            // Tilt back slightly  
    ..rotateY(0.3)             // Turn to show depth
    ..translate(20.0, -30.0, 50.0),*/ // Move right, up, forward
    transform: Matrix4.rotationX(25),

              child: Column(
                children: [
                   Image.asset(
                     'lib/images/Card_2.png',
                     width: MediaQuery.of(context).size.width * 0.45,
                     height: MediaQuery.of(context).size.height * 0.35,
                     ),       
                ],
                         ),
            ),
           ),
           Positioned.fill(
            top: 100,
            child: Transform.rotate(
              angle: 0.01,
              child: Column(
              children: [
                Image.asset(
                  'lib/images/Card 15.png',
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: MediaQuery.of(context).size.height * 0.35,
                ),
              ],
                         ),
            )),
           Positioned(
            //top: 300,
            bottom: 250,
            left: 250, 
            child: Transform(
              transform: Matrix4.rotationX(-0.1),
              child: Column(
              children: [
                Image.asset(
                  'lib/images/Card_13.png',
                   width: MediaQuery.of(context).size.width * 0.45,
                  height: MediaQuery.of(context).size.height * 0.55,
                  ),
              ],
                         ),
            )),
              SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
              
                mainAxisAlignment:
                    MainAxisAlignment.end, // Push content to bottom
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Spacer to push content down
                  Spacer(flex: 2),
      
                  // Main heading text
                  Padding(                  
                    padding: const EdgeInsets.only(top: 100.0,right: 50),
                    child: Column(
                      children: [
                        Text(
                          //'Manage Your \nPayment with\nMobile Banking!',
                          'A loan for every\n Dream with',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            letterSpacing: 4,
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                        Text(
                          'Mobile banking',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 28,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                            letterSpacing: 4,
                        
                        
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
      
                  // Subtitle text
                  Text(
                    'A loan facility that provides you financial assistance whenever you need.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      letterSpacing: 2
                    ),
                  ),
                  //SizedBox(height: 24,),
                   Expanded(
                     child: Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                             Container(
                          width: 30, //30
                          height: 7,  //7
                          decoration: BoxDecoration(
                           borderRadius: BorderRadius.circular(12),
                            shape: BoxShape.rectangle,
                            color: Colors.grey, // Active indicator
                          ),
                        ),
                        SizedBox(width: 12),
                        Container(
                          width: 60,  //60
                          height: 7,  //7
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            shape: BoxShape.rectangle,
                            color: Colors.white, // Inactive indicator
                          ),
                        ),
                          ],
                        ),
                        /*ElevatedButton(
                          onPressed: (){}, 
                          child: Text(
                            'Next',
                            ),
                            ),*/
                            GestureDetector(
                              onTap: (){
                                Navigator.pushReplacement(
                                  context, 
                                  MaterialPageRoute(builder: (context)=> SignIn())
                                  );
                              },
                              child: Container(
                                height: 50, //30
                                width: 60,  //7
                                decoration: BoxDecoration(
                                  color: Colors.grey[600],
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(12), 
                              
                                ),
                                child: Center(
                                  child: Text(
                                    "Skip",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  ),
                              ),
                            )
                       
                       
                      ],
                                       ),
                   ),
          ],
        ),
      )
              ),
          ]
        ),
    ),
    );
  }
}
