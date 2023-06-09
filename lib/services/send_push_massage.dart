import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

void SendPushMessage(
    String token, String body, String title, String channel) async {
  try {
    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization':
            'key=AAAAljFhcnQ:APA91bG5G3b-EvPM945TAhKrmN7n0ifmpNDNlhynEvo1FoSBD2KLHiUub2S2g2GscO4U0V5Sn5Ull3u4Ca0G1hN6Hzw5UlOwgUCYEgcOHEOP8q3_7kbAgorA633txp_raKsYXpoX_1h_',
      },
      body: jsonEncode(
        <String, dynamic>{
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'status': 'done',
            'body': body,
            'title': title
          },
          "notification": <String, dynamic>{
            "title": title,
            "body": body,
            "android_channel_id": channel
          },
          "to": token,
        },
      ),
    );
    //lưu vàov
  } catch (e) {
    if (kDebugMode) {
      print('error push notification');
    }
  }
}

addThongBao(
    String body, String title, String taiKhoanID, String ngayGio) async {
  try {
    await FirebaseFirestore.instance.collection('thong_bao').add({
      "noi_dung": body,
      "tieu_de": title,
      "trang_thai_xem": false,
      "tai_khoan_id": taiKhoanID,
      "ngay_gio": ngayGio
    });
  } catch (e) {
    print(e);
  }
}
