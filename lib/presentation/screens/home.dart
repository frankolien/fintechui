import 'package:fintechui/presentation/widgets/card_carousel.dart';
import 'package:flutter/material.dart';

import '../widgets/quick_actions.dart';
import '../widgets/service_action.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppBar(
              backgroundColor: Colors.white,
              leading: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      child: Image.asset("lib/images/profile.png"),
                    ),
                  ),
                  Positioned(
                    right: 8, // Adjust position as needed
                    top: 8, // Adjust position as needed
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors
                              .white, // Optional: for a white border around the dot
                          width: 1, // Optional: border width
                        ),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 12, // Size of the dot
                        minHeight: 12, // Size of the dot
                      ),
                    ),
                  ),
                ],
              ),
              title: Text(
                  "FinTech",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 25,
                  fontWeight: FontWeight.w500
                ),
              ),
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
            //SizedBox(height: 20,),
            SizedBox(height: 20),
            // Solution 1: Directly use CardCarousel with fixed height
            SizedBox(
              height: 228, // Match your card height
              child: CardCarousel(), // This already contains a ListView
            ),
            SizedBox(height: 15,),
            QuickActionsSection(),
            ServiceActions(),
            SizedBox(height: 15,),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text("Schedule Payment",style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.black87
              ),),
            )

          ],
        ),

      ),
    );
  }
}
