import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../login.dart';
import 'dart:collection';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
// import 'add_event.dart';
import 'package:khoa_luan1/model/event.dart';
import '../../list_event.dart';
import '../../services/account_service.dart';
import 'duyet_yeu_cau_huy_pb.dart';
import 'duyet_event_list.dart';
import '../../data/selectedDay.dart';
import 'item_details_tk.dart';
import '../../account_info.dart';

class ThuKiHomePage extends StatefulWidget {
  const ThuKiHomePage({super.key});

  @override
  State<ThuKiHomePage> createState() => _ThuKiHomePageState();
}

class _ThuKiHomePageState extends State<ThuKiHomePage> {
  late DateTime _firstDay;
  late DateTime _lastDay;
  DateTime? _selectedDay;
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  late Map<DateTime, List<Event>> _events;
  late String tenPhongBan;
  var userID = '';
  int getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }

  @override
  void initState() {
    super.initState();
    _events = LinkedHashMap(
      equals: isSameDay,
      hashCode: getHashCode,
    );
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final uid = user?.uid;
    userID = uid!;
    //print(uid);
    _calendarFormat = CalendarFormat.month;
    _focusedDay = DateTime.now();
    _firstDay = DateTime.now().subtract(const Duration(days: 1000));
    _lastDay = DateTime.now().add(const Duration(days: 1000));
    _selectedDay = DateTime.now();
    _loadFirestoreEvents();
  }

  _loadFirestoreEvents() async {
    // final FirebaseAuth auth = FirebaseAuth.instance;
    // final User? user = auth.currentUser;
    // final uid = user?.uid;
    final firstDay = DateTime(
      _focusedDay.year,
      _focusedDay.month - 1,
    );
    final lastDay = DateTime(_focusedDay.year, _focusedDay.month + 2, 0);
    _events = {};

    final snap = await FirebaseFirestore.instance
        .collection('cong_viec')
        // .where('tai_khoan_id', isEqualTo: uid)
        .where('tk_duyet', isEqualTo: true)
        .where('ngay_gio_bat_dau', isGreaterThanOrEqualTo: firstDay)
        .where('ngay_gio_bat_dau', isLessThanOrEqualTo: lastDay)
        .withConverter(
            fromFirestore: Event.fromFirestore,
            toFirestore: (event, options) => event.toFirestore())
        .get();
    for (var doc in snap.docs) {
      final event = doc.data();
      final day = DateTime.utc(event.ngay_gio_bat_dau.year,
          event.ngay_gio_bat_dau.month, event.ngay_gio_bat_dau.day);
      if (_events[day] == null) {
        _events[day] = [];
      }
      _events[day]!.add(event);
      //print(firstDay.toString() + lastDay.toString());
    }

    setState(() {});
  }

  List<Event> _getEventsForTheDay(DateTime day) {
    return _events[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Thư kí"),
        actions: [
          IconButton(
            onPressed: () {
              logout(context);
            },
            icon: Icon(
              Icons.logout,
            ),
          ),
          IconButton(
            onPressed: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => DuyetYeuCauHuy(),
                ),
              );
              _loadFirestoreEvents();
            },
            icon: Icon(
              Icons.event_available,
            ),
          ),
          IconButton(
            onPressed: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => AccountInfor(userIDString: userID),
                ),
              );
              _loadFirestoreEvents();
            },
            icon: Icon(
              Icons.account_box,
            ),
          ),
          // IconButton(
          //   onPressed: () async {
          //     final result = await Navigator.push<bool>(
          //       context,
          //       MaterialPageRoute(
          //         builder: (_) => ToDoList(),
          //       ),
          //     );
          //   },
          //   icon: Icon(
          //     Icons.logout,
          //   ),
          // ),
          // IconButton(
          //   onPressed: () async {
          //     final result = await Navigator.push<bool>(
          //       context,
          //       MaterialPageRoute(
          //         builder: (_) => ToDoListTuan(),
          //       ),
          //     );
          //   },
          //   icon: Icon(
          //     Icons.logout,
          //   ),
          // ),
          // IconButton(
          //   onPressed: () async {
          //     final result = await Navigator.push<bool>(
          //       context,
          //       MaterialPageRoute(
          //         builder: (_) => ListCongViec(),
          //       ),
          //     );
          //   },
          //   icon: Icon(
          //     Icons.logout,
          //   ),
          // ),
        ],
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
                        String dateString = DateFormat('yyyy-MM-dd HH:mm:ss')
                            .format(selectedDay);
                        String date = dateString.substring(0, 19);
                        // static DateTime selectedDay1=  DateTime.parse(date);
                        DateTime selectedDayFormatted = DateTime.parse(date);
                        dataSelectedDay.selectedDay = selectedDayFormatted;
                        //lưu selectedDay vào file khác
                        //print(dataSelectedDay.selectedDay.toString());
                        _focusedDay = focusedDay;
                      });
                    }
                  },
                  calendarBuilders: CalendarBuilders(
                    headerTitleBuilder: (context, day) {
                      return Container(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(day.toString()),
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
                        builder: (_) => ItemDetailsThuKi(event.id),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => DuyetEventList()
                // DuyetEvent(
                //   eventID: '',
                //   firstDate: _firstDay,
                //   lastDate: _lastDay,
                //   selectedDate: dataSelectedDay.selectedDay,
                // ),
                ),
          );
          _loadFirestoreEvents();
          //if (result ?? false) {

          //}
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> logout(BuildContext context) async {
    CircularProgressIndicator();
    await FirebaseAuth.instance.signOut();
    // await FirebaseFirestore.instance.terminate();
    // await FirebaseFirestore.instance.clearPersistence();
    // FirebaseFirestore.instance.settings=Settings(persistenceEnabled: false);
    // account.tai_khoan = '';
    // account.mat_khau = '';
    clearUserCredentials();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
  }
}

// void insertEvent() {
//   var db = FirebaseFirestore.instance.collection('tai_khoan');
//   db.doc()
// }
