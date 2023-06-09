import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:khoa_luan1/account_profile.dart';
import 'package:khoa_luan1/pages/giamdoc/GD_home_page.dart';
import 'package:khoa_luan1/pages/giamdoc/to_do_list_ngay.dart';
import 'package:khoa_luan1/pages/giamdoc/to_do_list_tuan.dart';
import 'package:khoa_luan1/pages/phongban/PB_home_page.dart';
import 'package:khoa_luan1/pages/phongban/add_event.dart';
import 'package:khoa_luan1/pages/thuki/TK_home_page.dart';
import 'package:khoa_luan1/pages/thuki/duyet_yeu_cau_huy_pb.dart';
import 'package:khoa_luan1/pages/phongban/to_do_list_ngay.dart' as toDoListNgay;
import 'package:khoa_luan1/pages/phongban/to_do_list_tuan.dart' as toDoListTuan;
import 'data/UserID.dart';

class DashBoard extends StatefulWidget {
  DashBoard(this.route, {Key? key}) : super(key: key);
  String route;
  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  @override
  void initState() {
    super.initState();
    phanQuyen();
    print('uid:' + UserID.localUID);
  }

  void onTabTapped(int index) {
    setState(() {
      _pageindex = index;
    });
  }

  int _pageindex = 0;
  List<Widget> _defaultList = [];
  final List<Widget> _tablist_GD = [
    ThuKiHomePage(),
    ToDoList(),
    ToDoListTuan(),
    AccountProfile(
      routeID: 'GD',
    )
  ];

  final List<Widget> _tablist_TK = [
    ThuKiHomePage(),
    DuyetYeuCauHuy(),
    AccountProfile(routeID: 'TK')
  ];

  final List<Widget> _tablist_PB = [
    PhongBanHomePage(),
    AddEvent(),
    toDoListNgay.ToDoList(),
    toDoListTuan.ToDoListTuan(),
    AccountProfile(routeID: 'PB')
  ];
  final List<Widget> _tablist_PB_thanh_vien = [
    PhongBanHomePage(),
    toDoListNgay.ToDoList(),
    toDoListTuan.ToDoListTuan(),
    AccountProfile(routeID: 'TVPB')
  ];
  void phanQuyen() {
    if (widget.route == 'PB') {
      _defaultList = _tablist_PB;
    } else if (widget.route == 'TK') {
      _defaultList = _tablist_TK;
    } else if (widget.route == 'GD') {
      _defaultList = _tablist_GD;
    } else {
      _defaultList = _tablist_PB_thanh_vien;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.route == 'PB') {
      return Scaffold(
        body: Center(
          child: _defaultList[_pageindex],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 20,
                color: Colors.black.withOpacity(.1),
              )
            ],
          ),
          child: SafeArea(
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0),
                child: Container(
                  height: 50,
                  child: GNav(
                    backgroundColor: Colors.grey[50]!,
                    rippleColor: Colors.grey[300]!,
                    hoverColor: Colors.grey[100]!,
                    gap: 8,
                    activeColor: Colors.black,
                    iconSize: 24,
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    duration: Duration(milliseconds: 400),
                    tabBackgroundColor: Colors.grey[100]!,
                    color: Colors.black,
                    tabs: [
                      GButton(
                        icon: CupertinoIcons.home,
                        text: 'Trang chủ',
                      ),
                      GButton(
                        icon: CupertinoIcons.add,
                        text: 'Thêm',
                      ),
                      GButton(
                        icon: CupertinoIcons.calendar_today,
                        text: 'Ngày',
                      ),
                      GButton(
                        icon: CupertinoIcons.calendar,
                        text: 'Tuần',
                      ),
                      GButton(
                        icon: CupertinoIcons.settings,
                        text: 'Cài đặt',
                      ),
                    ],
                    selectedIndex: _pageindex,
                    onTabChange: (index) {
                      setState(() {
                        _pageindex = index;
                      });
                    },
                  ),
                )),
          ),
        ),
      );
    } else if (widget.route == 'TK') {
      return Scaffold(
        body: Center(
          child: _defaultList[_pageindex],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 20,
                color: Colors.black.withOpacity(.1),
              )
            ],
          ),
          child: SafeArea(
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0),
                child: Container(
                  height: 50,
                  child: GNav(
                    backgroundColor: Colors.grey[50]!,
                    rippleColor: Colors.grey[300]!,
                    hoverColor: Colors.grey[100]!,
                    gap: 8,
                    activeColor: Colors.black,
                    iconSize: 24,
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    duration: Duration(milliseconds: 400),
                    tabBackgroundColor: Colors.grey[100]!,
                    color: Colors.black,
                    tabs: [
                      GButton(
                        icon: CupertinoIcons.home,
                        text: 'Trang chủ',
                      ),
                      GButton(
                        icon: CupertinoIcons.list_number,
                        text: 'Yêu cầu huỷ',
                      ),
                      GButton(
                        icon: CupertinoIcons.settings,
                        text: 'Cài đặt',
                      ),
                    ],
                    selectedIndex: _pageindex,
                    onTabChange: (index) {
                      setState(() {
                        _pageindex = index;
                      });
                    },
                  ),
                )),
          ),
        ),
      );
    } else {
      return Scaffold(
        body: Center(
          child: _defaultList[_pageindex],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 20,
                color: Colors.black.withOpacity(.1),
              )
            ],
          ),
          child: SafeArea(
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0),
                child: Container(
                  height: 50,
                  child: GNav(
                    backgroundColor: Colors.grey[50]!,
                    rippleColor: Colors.grey[300]!,
                    hoverColor: Colors.grey[100]!,
                    gap: 8,
                    activeColor: Colors.black,
                    iconSize: 24,
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    duration: Duration(milliseconds: 400),
                    tabBackgroundColor: Colors.grey[100]!,
                    color: Colors.black,
                    tabs: [
                      GButton(
                        icon: CupertinoIcons.home,
                        text: 'Trang chủ',
                      ),
                      GButton(
                        icon: CupertinoIcons.calendar_today,
                        text: 'Ngày',
                      ),
                      GButton(
                        icon: CupertinoIcons.calendar,
                        text: 'Tuần',
                      ),
                      GButton(
                        icon: CupertinoIcons.settings,
                        text: 'Cài đặt',
                      ),
                    ],
                    selectedIndex: _pageindex,
                    onTabChange: (index) {
                      setState(() {
                        _pageindex = index;
                      });
                    },
                  ),
                )),
          ),
        ),
      );
    }
  }
}
