
import 'package:flutter/material.dart';

import 'onboarding_1/onboarding_1.dart';
import 'onboarding_2/onboarding_2.dart';

class TabViewW extends StatefulWidget {
  const TabViewW({super.key});

  @override
  State<TabViewW> createState() => _TabViewWState();
}

class _TabViewWState extends State<TabViewW> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        /*appBar: AppBar(
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Onboarding 1'),
              Tab(text: 'Onboarding 2'),
            ],
          ),
        ),*/
        body:  TabBarView(
          children: [
            Onboarding1(),
            Onboarding2(),
          ],
        ),
      ),
    );
  }
}
