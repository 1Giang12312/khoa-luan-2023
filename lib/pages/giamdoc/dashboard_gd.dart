import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:khoa_luan1/pages/giamdoc/GD_home_page.dart';
import 'package:khoa_luan1/pages/giamdoc/to_do_list_ngay.dart';
import 'package:khoa_luan1/pages/giamdoc/to_do_list_tuan.dart';

class dashBoard_GD extends StatefulWidget {
  const dashBoard_GD({super.key});

  @override
  State<dashBoard_GD> createState() => _dashBoard_GDState();
}

class _dashBoard_GDState extends State<dashBoard_GD> {
  @override
  void initState() {
    super.initState();
  }

  void onTabTapped(int index) {
    setState(() {
      _pageindex = index;
    });
  }

  int _pageindex = 0;
  final List<Widget> _tablist = [GiamDocHomePage(), ToDoList(), ToDoListTuan()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // body: Stack(
      //   children: [
      //     _tablist.elementAt(_pageindex),
      //     Padding(
      //       padding: const EdgeInsets.all(5.0),
      //       child: Align(
      //         alignment: Alignment(0.0, 1.0),
      //         child: ClipRRect(
      //           borderRadius: BorderRadius.all(Radius.circular(30)),
      //           child: BottomNavigationBar(
      //             items: [
      //               BottomNavigationBarItem(
      //                   icon: Icon(Icons.home), label: 'home'),
      //               BottomNavigationBarItem(
      //                   icon: Icon(Icons.schedule), label: 'schedule'),
      //               BottomNavigationBarItem(
      //                   icon: Icon(Icons.settings), label: 'settings'),
      //             ],
      //             selectedItemColor: Colors.white,
      //             unselectedItemColor: Colors.grey,
      //             showSelectedLabels: true,
      //             showUnselectedLabels: false,
      //             backgroundColor: Colors.black,
      //             currentIndex: _pageindex,
      //             onTap: (int index) {
      //               setState(() {
      //                 _pageindex = index;
      //               });
      //             },
      //           ),
      //         ),
      //       ),
      //     )
      //   ],
      // ),
      body: SafeArea(
        child: _tablist[_pageindex],
      ),

      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        backgroundColor: Colors.black,
        currentIndex: _pageindex,
        onTap: onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
