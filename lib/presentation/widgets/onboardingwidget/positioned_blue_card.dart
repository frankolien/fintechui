import 'package:flutter/cupertino.dart';

class PositionedBlueCard extends StatelessWidget {
  const PositionedBlueCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      //top: 300,
        bottom: 250,
        left: 200,
        child: Transform(
          transform: Matrix4.rotationX(-0.1),
          child: Column(
            children: [
              Image.asset(
                'lib/images/Card 16.png',
                width: MediaQuery.of(context).size.width * 0.55,
                height: MediaQuery.of(context).size.height * 0.55,
              ),
            ],
          ),
        ));
  }
}