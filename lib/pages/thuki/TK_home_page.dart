import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart';
import '../../data/UserID.dart';
import '../../login.dart';
import 'dart:collection';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
// import 'add_event.dart';
import 'package:khoa_luan1/model/event.dart';
import '../../list_event.dart';
import '../../services/account_service.dart';
import '../giamdoc/GD_add_event.dart';
import '../phongban/list_thong_bao.dart';
import 'duyet_yeu_cau_huy_pb.dart';
import 'duyet_event_list.dart';
import '../../data/selectedDay.dart';
import 'item_details_tk.dart';
import '../../account_info.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:syncfusion_flutter_calendar/calendar.dart';

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
  var idThuKi = '';
  var idPhongBanTK = '';
  var tenCongViecGCalender = '';
  var diaDiemGCalender = '';
  var tieuDecGCalender = '';
  var tieuDeGoogleCalendar = '';
  var tenGoogleCalendar = '';
  late String newDocDiaDiemId;
  final today = DateTime.now();
  late bool isLoading = false;
  int getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }

  @override
  void initState() {
    //getDataFromGoogleSheet();
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
    getIdThuKy();
    //lấy dữ liệu số lượng công việc mỗi ngày theo uid
    _loadFirestoreEvents();
  }

  Future<void> kiemTraDiaDiem(
    String diaDiem,
    Timestamp starttime,
    Timestamp endtime,
    String ten,
    String thoiGianCongViec,
    String tieuDe,
  ) async {
    if (diaDiem == '') {
      newDocDiaDiemId = 'DIA_DIEM_RONG';
      themVaoCongViecGoogleCalendar(
          starttime, endtime, ten, thoiGianCongViec, tieuDe, newDocDiaDiemId);
    } else {
      final diaDiemDoc = await FirebaseFirestore.instance
          .collection('dia_diem')
          .where('ten_dia_diem', isEqualTo: diaDiem)
          // .where('is_from_google_calendar', isEqualTo: true)
          .get();
      if (diaDiemDoc.docs.isEmpty) {
        final CollectionReference usersCollection =
            FirebaseFirestore.instance.collection('dia_diem');
        DocumentReference newDocRef = await usersCollection.add({
          "ten_dia_diem": diaDiem,
          "ghi_chu": 'Địa điểm từ google Calendar',
          "trang_thai": false,
          "is_from_google_calendar": true
        });
        newDocDiaDiemId = newDocRef.id;
        themVaoCongViecGoogleCalendar(
            starttime, endtime, ten, thoiGianCongViec, tieuDe, newDocDiaDiemId);
      } else {
        themVaoCongViecGoogleCalendar(starttime, endtime, ten, thoiGianCongViec,
            tieuDe, diaDiemDoc.docs.first.id);
      }
    }
  }

  Future<void> themVaoCongViecGoogleCalendar(
      Timestamp starttime,
      Timestamp endtime,
      String ten,
      String thoiGianCongViec,
      String tieuDe,
      String diaDiemID) async {
    final collectionRef = FirebaseFirestore.instance.collection('cong_viec');
    collectionRef.get().then((querySnapshot) async {
      if (querySnapshot.docs.isEmpty) {
        print('Collection does not exist');
        await FirebaseFirestore.instance.collection('cong_viec').add({
          "is_from_google_calendar": true,
          "is_gd_them": false,
          "ngay_gio_bat_dau": starttime,
          "ngay_post": Timestamp.fromDate(DateTime.now()),
          "ten_cong_viec": ten,
          "thoi_gian_cv": thoiGianCongViec,
          "tieu_de": tieuDe,
          //thu ki duyet
          "tk_duyet": true,
          "trang_thai": true,
          "do_uu_tien": "Vừa",
          "tai_khoan_id": UserID.localUID,
          // lỗi
          "pb_huy": false,
          "ngay_toi_thieu": Timestamp.fromDate(DateTime.now()),
          "ngay_gio_ket_thuc": endtime,
          "dia_diem_id": diaDiemID,
          "file_pdf": '',
          "phong_ban_id": idPhongBanTK
        });
        if (mounted) {
          print('Đã thêm dữ liệu từ google calendar vào database');
          //newDocDiaDiemId = '';
        }
      } else {
        print('Collection exists');
        final eventCollection =
            FirebaseFirestore.instance.collection('cong_viec');
        final eventDoc = await eventCollection
            .where('ngay_gio_bat_dau', isEqualTo: starttime)
            .where('ngay_gio_ket_thuc', isEqualTo: endtime)
            .get();
        if (eventDoc.docs.isEmpty) {
          //thêm cái đó
          // Event eventData = Event
          await FirebaseFirestore.instance.collection('cong_viec').add({
            "is_from_google_calendar": true,
            "is_gd_them": false,
            "ngay_gio_bat_dau": starttime,
            "ngay_post": Timestamp.fromDate(DateTime.now()),
            "ten_cong_viec": ten,
            "thoi_gian_cv": thoiGianCongViec,
            "tieu_de": tieuDe,
            //thu ki duyet
            "tk_duyet": true,
            "trang_thai": true,
            "do_uu_tien": "Vừa",
            "tai_khoan_id": UserID.localUID,
            // lỗi
            "pb_huy": false,
            "ngay_toi_thieu": Timestamp.fromDate(DateTime.now()),
            "ngay_gio_ket_thuc": endtime,
            "dia_diem_id": diaDiemID,
            "file_pdf": '',
            "phong_ban_id": idPhongBanTK
          });
          if (mounted) {
            print('Đã thêm dữ liệu từ google calendar vào database');
            //newDocDiaDiemId = '';
          }
        }
      }
    }).catchError((error) {
      print('Error checking collection: $error');
    });
  }

  //lấy tên ,tiêu đề, vị trí trong bảng công việc google calendar
  Future<void> getDataFromGoogleSheet() async {
    setState(() {
      isLoading = true;
    });
    Response data = await http.get(
      Uri.parse(
          "https://script.google.com/macros/s/AKfycbyvSisGAFXvBNWc34Nxhdyt25byLOFixQBFb8lp9LM7WivnHcbcYPm1nlEBFO5k8USkzw/exec"),
    );
    if (data.statusCode == 200) {
      dynamic jsonAppData = convert.jsonDecode(data.body);
      //final List<Event> appointmentData = [];
      for (dynamic data in jsonAppData) {
        int differenceInMinutes =
            (_convertToTimeStamp(data['endtime']).seconds -
                    _convertToTimeStamp(data['starttime']).seconds) ~/
                60;
        // kiemTraDiaDiem(data['location']).then((_) =>
        //     themVaoCongViecGoogleCalendar(
        //         _convertToTimeStamp(data['starttime']),
        //         _convertToTimeStamp(data['endtime']),
        //         data['ten'],
        //         differenceInMinutes,
        //         data['subject']));
        kiemTraDiaDiem(
            data['location'],
            _convertToTimeStamp(data['starttime']),
            _convertToTimeStamp(data['endtime']),
            data['ten'].toString(),
            differenceInMinutes.toString(),
            data['subject'].toString());
        //_loadFirestoreEvents();
        // await kiemTraDiaDiem(data['location']);
        // await themVaoCongViecGoogleCalendar(
        //     _convertToTimeStamp(data['starttime']),
        //     _convertToTimeStamp(data['endtime']),
        //     data['ten'],
        //     differenceInMinutes,
        //     data['subject']);
        // await resetDiadiem();
      }
      // handle jsonAppData
    } else {
      // handle error
      print('Khong phai json');
    }
    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //   content: const Text('Đồng bộ thành công!'),
    //   action: SnackBarAction(
    //     label: 'Hủy',
    //     onPressed: () {},
    //   ),
    // ));
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.green,
            title: Center(
              child: Text(
                'Đồng bộ thành công!',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        },
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> getDataFromFirestoreToGoogleCalendar() async {
    setState(() {
      isLoading = true;
    });
    Response data = await http.get(
      Uri.parse(
          "https://script.google.com/macros/s/AKfycbzJJTjSkPwHgKOirc5C-aVsn8a3WEDxWdstjglfT_5YMyEQsQSRU1B-xcvG6GU6HXnDKg/exec"),
    );
    if (data.statusCode == 200) {
      print("Kết nối thành công");
    } else {
      print('Kết nối thất bại');
    }
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.green,
            title: Center(
              child: Text(
                'Đồng bộ thành công!',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        },
      );
      setState(() {
        isLoading = false;
      });
    }

    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //   content: const Text('Đồng bộ thành công!'),
    //   action: SnackBarAction(
    //     label: 'Hủy',
    //     onPressed: () {},
    //   ),
    // ));
  }

  void xoaCongViecDongBoGoogleCalendar() async {
    setState(() {
      isLoading = true;
      //_loadFirestoreEvents();
    });
    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('cong_viec');
    QuerySnapshot querySnapshot = await collectionRef
        .where('is_from_google_calendar', isEqualTo: true)
        .get();
    querySnapshot.docs.forEach((document) {
      document.reference.delete();
    });

    CollectionReference collectionRef1 =
        FirebaseFirestore.instance.collection('dia_diem');
    QuerySnapshot querySnapshot1 = await collectionRef1
        .where('is_from_google_calendar', isEqualTo: true)
        .get();
    querySnapshot1.docs.forEach((document) {
      document.reference.delete();
    });
    setState(() {
      isLoading = false;
      _loadFirestoreEvents();
    });
  }

  Timestamp _convertToTimeStamp(String date) {
    DateTime dateTime = DateTime.parse(date);

// Chuyển đổi đối tượng DateTime thành UTC
    DateTime dateTimeUtc = dateTime.toUtc();

// Chuyển đổi đối tượng DateTime thành Timestamp
    Timestamp timestamp = Timestamp.fromDate(dateTimeUtc);
    return timestamp;
  }

  void getIdThuKy() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('quyen_han')
        .where('ten_quyen_han', isEqualTo: 'Thư ký')
        .limit(1)
        .get();
    final docId = snapshot.docs.isNotEmpty ? snapshot.docs.first.id : null;
    idThuKi = docId!;

    final PBTKCollection = FirebaseFirestore.instance.collection('tai_khoan');
    final PBTKDoc = await PBTKCollection.doc(UserID.localUID).get();
    idPhongBanTK = PBTKDoc['phong_ban_id'];
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
    return !isLoading
        ? Scaffold(
            appBar: AppBar(
              // automaticallyImplyLeading: false,
              title: Text('Lịch trình ', style: TextStyle(color: Colors.black)),
              backgroundColor: Colors.grey[100],
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
                      decoration: BoxDecoration(
                          color: Color.fromARGB(255, 245, 245, 245)),
                      child: Text(
                        'Tuỳ chọn',
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Divider(
                          color: Colors.grey,
                          height: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Google Calendar & lịch nội bộ',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 7,
                        child: Divider(
                          color: Colors.grey,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                  ListTile(
                    title: Text('Tải lịch lên Google Calendar'),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(
                                "Đồng bộ lịch nội bộ lên Google Calendar!"),
                            content: Text(
                                "Hành động này có thể mất thời gian và số lượng lớn công việc sẽ được thêm vào Google Calendar!"),
                            actions: <Widget>[
                              ElevatedButton(
                                child: Text("Không"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              ElevatedButton(
                                child: Text("Có"),
                                onPressed: () async {
                                  getDataFromFirestoreToGoogleCalendar();
                                  //logout(context);
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Divider(
                          color: Colors.grey,
                          height: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Lịch nội bộ & Google Calendar',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 7,
                        child: Divider(
                          color: Colors.grey,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                  ListTile(
                    title: Text('Tải về lịch Google Calendar'),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(
                                "Tải lịch Google Calendar về lịch nội bộ!"),
                            content: Text(
                                "Hành động này có thể mất thời gian và số lượng lớn công việc sẽ được thêm vào"),
                            actions: <Widget>[
                              ElevatedButton(
                                child: Text("Không"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              ElevatedButton(
                                child: Text("Có"),
                                onPressed: () async {
                                  getDataFromGoogleSheet();
                                  //logout(context);
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  ListTile(
                    title: Text('Xoá công việc được đồng bộ'),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(
                                "Xoá tất cả công việc được đồng bộ từ Google Calendar"),
                            content: Text(
                                "Sau khi xoá bạn cũng có thể khôi phục bằng cách đồng bộ lại!"),
                            actions: <Widget>[
                              ElevatedButton(
                                child: Text("Không"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              ElevatedButton(
                                child: Text("Có"),
                                onPressed: () async {
                                  xoaCongViecDongBoGoogleCalendar();
                                  //logout(context);
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Divider(
                          color: Colors.grey,
                          height: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Thông báo',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 7,
                        child: Divider(
                          color: Colors.grey,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                  ListTile(
                    title: Text('Thông báo'),
                    onTap: () {
                      final res = Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ListThongBao(taiKhoanID: UserID.localUID),
                        ),
                      );
                    },
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
                            formatButtonTextStyle:
                                TextStyle(color: Colors.white),
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
                              String dateString =
                                  DateFormat('yyyy-MM-dd HH:mm:ss')
                                      .format(selectedDay);
                              String date = dateString.substring(0, 19);
                              // static DateTime selectedDay1=  DateTime.parse(date);
                              DateTime selectedDayFormatted =
                                  DateTime.parse(date);
                              dataSelectedDay.selectedDay =
                                  selectedDayFormatted;
                              //lưu selectedDay vào file khác
                              //print(dataSelectedDay.selectedDay.toString());
                              _focusedDay = focusedDay;
                            });
                          }
                        },
                        calendarBuilders: CalendarBuilders(
                          headerTitleBuilder: (context, day) {
                            return Container(
                              padding: const EdgeInsets.all(1.0),
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
                              builder: (_) =>
                                  ItemDetailsThuKi(event.id, false, true),
                            ),
                          );
                          if (res ?? false) {
                            _loadFirestoreEvents();
                          }
                          _loadFirestoreEvents();
                        },
                      ),
                    ),
                    SizedBox(
                      height: 70,
                    ),
                  ]),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                // print(dataSelectedDay.selectedDay);
                //nếu ngày = hôm nay thì thông báo
                if (dataSelectedDay.selectedDay.isBefore(today)) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        backgroundColor: Color.fromARGB(255, 255, 0, 0),
                        title: Center(
                          child: Text(
                            'Hãy chọn ngày trong tương lai',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    },
                  );
                } else if (dataSelectedDay.selectedDay.weekday == 6 ||
                    dataSelectedDay.selectedDay.weekday == 7) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        backgroundColor: Color.fromARGB(255, 255, 0, 0),
                        title: Center(
                          child: Text(
                            'Hãy chọn ngày trong tuần(trừ thứ 7 và chủ nhật)',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  var kk = FirebaseFirestore.instance
                      .collection('tai_khoan')
                      .doc(UserID.localUID)
                      .get()
                      .then((DocumentSnapshot documentSnapshot) async {
                    if (documentSnapshot.exists) {
                      if (documentSnapshot.get('quyen_han_id') == idThuKi) {
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
                      } else {
                        final result = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                              builder: (_) => GDAddEvent(
                                  firstDate: _firstDay,
                                  lastDate: _lastDay,
                                  selectedDate: dataSelectedDay.selectedDay)
                              // DuyetEvent(
                              //   eventID: '',
                              //   firstDate: _firstDay,
                              //   lastDate: _lastDay,
                              //   selectedDate: dataSelectedDay.selectedDay,
                              // ),
                              ),
                        );
                      }
                    } else {
                      print('loi');
                    }
                  });
                }
              },
              child: const Icon(Icons.add),
            ),
          )
        : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                Text(
                  "Đang kết nối tới Google Calendar",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
              ],
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
