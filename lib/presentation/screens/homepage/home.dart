import 'package:fintechui/presentation/screens/profile/user_profile.dart';
import 'package:fintechui/presentation/widgets/homewidget/card_carousel.dart';
import 'package:flutter/material.dart';

import '../../widgets/homewidget/quick_actions.dart';
import '../../widgets/homewidget/scheduled_payment.dart';
import '../../widgets/homewidget/service_action.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    void navigateToProfile(BuildContext context) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: ()=> navigateToProfile(context),
                child: CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    child: Icon(Icons.person,color: Colors.grey[600],size: 30,),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 8,
              top: 8, 
              child: Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white, 
                    width: 1, 
                  ),
                ),
                constraints: BoxConstraints(
                  minWidth: 12, 
                  minHeight: 12, 
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

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30,),
            SizedBox(
              height: 220,
              child: CardCarousel(),
            ),
            SizedBox(height: 15,),
            QuickActionsSection(),
            ServiceActions(),
            SizedBox(height: 15,),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Schedule Payment",style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87
                  ),),
                  GestureDetector(
                    onTap: (){},
                    child: Text("View all",style: TextStyle(
                      color: Colors.grey
                    ),),),

                ],
              ),
            ),
            ScheduledPayment(),
            SizedBox(height: 15,),

          ],
        ),

      ),

    );
  }
}