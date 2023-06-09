import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khoa_luan1/data/UserID.dart';
import 'package:khoa_luan1/pages/phongban/item_details.dart';
import 'package:khoa_luan1/pages/phongban/list_thong_bao.dart';
import '../../login.dart';
import 'dart:collection';
import 'package:table_calendar/table_calendar.dart';

import '../../services/account_service.dart';
import 'add_event.dart';
import 'package:khoa_luan1/model/event.dart';
import '../../list_event.dart';
import 'list_cong_viec.dart';
import 'to_do_list_ngay.dart';
import 'to_do_list_tuan.dart';
import '../../account_info.dart';

class PhongBanHomePage extends StatefulWidget {
  const PhongBanHomePage({super.key});

  @override
  State<PhongBanHomePage> createState() => _PhongBanHomePageState();
}

class _PhongBanHomePageState extends State<PhongBanHomePage> {
  late DateTime _firstDay;
  late DateTime _lastDay;

  DateTime? _selectedDay;
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  late Map<DateTime, List<Event>> _events;
  late String tenPhongBan;
  int getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }

  var _soThongBao;
  var _phong_ban_id = '';
  @override
  void initState() {
    super.initState();
    _events = LinkedHashMap(
      equals: isSameDay,
      hashCode: getHashCode,
    );
    print(UserID.localUID);
    _firstDay = DateTime.now().subtract(const Duration(days: 1000));
    _lastDay = DateTime.now().add(const Duration(days: 1000));
    _selectedDay = DateTime.now();
    // getPhongBanID();
    // _loadFirestoreEvents();
    getPhongBanID().then((_) => _loadFirestoreEvents());
    //soLuongThongBaoChuaXem();
  }

  getPhongBanID() async {
    final usersCollection = FirebaseFirestore.instance.collection('tai_khoan');
    final userDoc = await usersCollection.doc(UserID.localUID).get();
    _phong_ban_id = userDoc['phong_ban_id'];
  }

  _loadFirestoreEvents() async {
    getPhongBanID();
    final firstDay = DateTime(
      _focusedDay.year,
      _focusedDay.month - 1,
    );
    final lastDay = DateTime(_focusedDay.year, _focusedDay.month + 2, 0);
    _events = {};

    final snap = await FirebaseFirestore.instance
        .collection('cong_viec')
        // .where('phong_ban_id', isEqualTo: _phong_ban_id)
        .where('tk_duyet', isEqualTo: true) // tk duyet moi hien
        .where('ngay_gio_bat_dau', isGreaterThanOrEqualTo: firstDay)
        .where('ngay_gio_bat_dau', isLessThanOrEqualTo: lastDay)
        .withConverter(
            fromFirestore: Event.fromFirestore,
            toFirestore: (event, options) => event.toFirestore())
        .get();

    for (var doc in snap.docs) {
      if (doc['phong_ban_id'].toString().contains(_phong_ban_id)) {
        final event = doc.data();
        final day = DateTime.utc(event.ngay_gio_bat_dau.year,
            event.ngay_gio_bat_dau.month, event.ngay_gio_bat_dau.day);
        if (_events[day] == null) {
          _events[day] = [];
        }
        _events[day]!.add(event);
      }
    }
    print(firstDay.toString() + lastDay.toString());
    setState(() {});
  }

  List<Event> _getEventsForTheDay(DateTime day) {
    return _events[day] ?? [];
  }

  // int soLuongThongBaoChuaXem() {
  //   CollectionReference usersRef =
  //       FirebaseFirestore.instance.collection('thong_bao');
  //   usersRef
  //       .where('trang_thai_xem', isEqualTo: false)
  //       .where('tai_khoan_id', isEqualTo: UserID.localUID)
  //       .get()
  //       .then((querySnapshot) {
  //     _soThongBao = querySnapshot.docs.length;
  //   });
  //   return _soThongBao;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //automaticallyImplyLeading: false,
        backgroundColor: Colors.grey[100],
        title: Text('Lịch trình', style: TextStyle(color: Colors.black)),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      drawer: Drawer(
        width: 200,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const SizedBox(
              height: 100,
              child: DrawerHeader(
                decoration:
                    BoxDecoration(color: Color.fromARGB(255, 245, 245, 245)),
                child: Text(
                  'Tuỳ chọn',
                  style: TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            ListTile(
              title: Text('Thông báo'),
              onTap: () async {
                // Do something
                final res = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ListThongBao(taiKhoanID: UserID.localUID),
                  ),
                );
              },
              // trailing: Text(
              //   _soThongBao.toString(),
              //   style: TextStyle(color: Colors.red),
              // ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Card(
                clipBehavior: Clip.antiAlias,
                margin: EdgeInsets.all(8),
                child: TableCalendar(
                  eventLoader: _getEventsForTheDay,
                  calendarFormat: _calendarFormat,
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                    _loadFirestoreEvents();
                  },
                  onPageChanged: (focusedDay) {
                    setState(() {
                      _focusedDay = focusedDay;
                    });
                    _loadFirestoreEvents();
                  },
                  headerStyle: HeaderStyle(
                      decoration: BoxDecoration(
                        color: Colors.grey,
                      ),
                      headerMargin: EdgeInsets.only(bottom: 8.0),
                      titleTextStyle: TextStyle(color: Colors.white),
                      formatButtonDecoration: BoxDecoration(
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(3)),
                      formatButtonTextStyle: TextStyle(color: Colors.white),
                      leftChevronIcon: Icon(
                        Icons.chevron_left,
                        color: Colors.white,
                      ),
                      rightChevronIcon: Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                      )),
                  firstDay: _firstDay,
                  lastDay: _lastDay,
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    if (!isSameDay(_selectedDay, selectedDay)) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    }
                  },
                  calendarBuilders: CalendarBuilders(
                    headerTitleBuilder: (context, day) {
                      return Container(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          day.toString().substring(0, 11),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              ..._getEventsForTheDay(_selectedDay!).map(
                (event) => ListEvent(
                  event: event,
                  onTap: () async {
                    final res = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ItemDetails(event.id),
                      ),
                    );
                    if (res ?? false) {
                      _loadFirestoreEvents();
                    }
                    _loadFirestoreEvents();
                  },
                ),
              ),
            ]),
      ),
    );
  }
}

// void insertEvent() {
//   var db = FirebaseFirestore.instance.collection('tai_khoan');
//   db.doc()
// }
