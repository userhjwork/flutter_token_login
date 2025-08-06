import 'package:flutter/material.dart';
import 'package:flutter_token_login/common/const/color.dart';
import 'package:flutter_token_login/common/layout/default_layout.dart';
import 'package:flutter_token_login/restaurant/view/restaurant_screen.dart';

class RootTab extends StatefulWidget {
  const RootTab({Key? key}) : super(key: key);

  @override
  State<RootTab> createState() => _RootTabState();
}

class _RootTabState extends State<RootTab> with SingleTickerProviderStateMixin {
  late TabController controller;

  int index = 0;

  @override
  void initState() {
    super.initState();

    controller = TabController(length: 4, vsync: this);

    controller.addListener(tabListener);
  }

  @override
  void dispose() {
    controller.removeListener(tabListener);

    super.dispose();
  }

  void tabListener(){
    setState(() {
      index = controller.index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      title: '코팩 딜리버리',
      child: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: controller,
        children: [
          RestaurantScreen(),
          Center(child: Container(child: Text('food'))),
          Center(child: Container(child: Text('order'))),
          Center(child: Container(child: Text('profile'))),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: PRIMARY_COLOR,
        unselectedItemColor: BODY_TEXT_COLOR,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        type: BottomNavigationBarType.fixed,
        onTap: (int index){
          controller.animateTo(index);
        },
        currentIndex: index,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fastfood_outlined),
            label: 'food',
          ),BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'order',
          ),BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'profile',
          ),
        ],
      ),
    );
  }
}
