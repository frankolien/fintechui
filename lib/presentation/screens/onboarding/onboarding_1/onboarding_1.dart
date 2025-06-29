import 'dart:math' as math;

//import 'package:fintechui/auth/sign_in.dart';
import 'package:flutter/material.dart';

import '../../../../core/auth/sign_in.dart';
import '../../../widgets/positioned_blue_card.dart';

class Onboarding1 extends StatefulWidget {
  const Onboarding1({super.key});

  @override
  State<Onboarding1> createState() => _Onboarding1State();
}

class _Onboarding1State extends State<Onboarding1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1B2E),
       //backgroundColor: Color(0x23303B),
      body: SizedBox.expand(
        child: Stack(
          children: [

            // Blue card
            PositionedBlueCard(),
            // Purple card
            Positioned.fill(
                top: 90,
                //left: 10,
                right: 30,
                child: Transform.rotate(
                  angle: 0.002,
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
            //  White card
           Positioned(
            bottom: 600,
            child: Transform(
                alignment: Alignment.center,
  /*transform: Matrix4.identity()
    ..setEntry(3, 2, 0.002)    // Add perspective
    ..rotateX(-0.1)            // Tilt back slightly  
    ..rotateY(0.3)             // Turn to show depth
    ..translate(20.0, -30.0, 50.0),*/ // Move right, up, forward
    transform: Matrix4.rotationX(0.2),
              child: Column(
                children: [
                   Image.asset(
                     'lib/images/Card 13.png',
                     width: MediaQuery.of(context).size.width * 0.45,
                     height: MediaQuery.of(context).size.height * 0.35,
                     ),       
                ],
                         ),
            ),
           ),





              Padding(
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
                      child: RichText(text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Manage Your Payment with\n',
                            style: TextStyle(
                              letterSpacing: 4,
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w500,
                              height: 1.4,

                            ),
                          ),
                          TextSpan(
                            text: 'mobile banking',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 28,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                              // letterSpacing: 4,


                            ),
                          )
                        ],
                      )),
                    ),
                    SizedBox(height: 16),

                    // Subtitle text
                    Text(
                      'A convenient way to manage your money securely from mobile device.',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w600
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
                            width: 60,
                            height: 7,
                            decoration: BoxDecoration(
                             borderRadius: BorderRadius.circular(12),
                              shape: BoxShape.rectangle,
                              color: Colors.white, // Active indicator
                            ),
                          ),
                          SizedBox(width: 12),
                          Container(
                            width: 30,
                            height: 7,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              shape: BoxShape.rectangle,
                              color: Colors.grey, // Inactive indicator
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
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>SignIn()));
                                },
                                child: Container(
                                  height: 50,
                                  width: 60,
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
                              ),
                        ],
                                         ),
                     ),
                        ],
                      ),
                    ),
          ]
        ),
    ),
    );
  }
}


