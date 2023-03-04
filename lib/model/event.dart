import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final bool gd_huy;
  final bool tk_duyet;
  final DateTime ngay_gio_bat_dau;
  final DateTime ngay_post;
  final String ten_cong_viec;
  final String thoi_gian_cv;
  final String tieu_de;
  final bool trang_thai;
  final String tai_khoan_id;
  final DateTime ngay_gio_ket_thuc;
  final String dia_diem;
  final String id;
  Event({
    required this.gd_huy,
    required this.tk_duyet,
    required this.ngay_gio_bat_dau,
    required this.ngay_post,
    required this.ten_cong_viec,
    required this.thoi_gian_cv,
    required this.tieu_de,
    required this.trang_thai,
    required this.tai_khoan_id,
    required this.ngay_gio_ket_thuc,
    required this.dia_diem,
    required this.id,
  });

  factory Event.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot,
      [SnapshotOptions? options]) {
    final data = snapshot.data()!;
    return Event(
      gd_huy: data['gd_huy'],
      ngay_gio_bat_dau: data['ngay_gio_bat_dau'].toDate(),
      ngay_post: data['ngay_post'].toDate(),
      tai_khoan_id: data['tai_khoan_id'],
      ten_cong_viec: data['ten_cong_viec'],
      thoi_gian_cv: data['thoi_gian_cv'],
      tieu_de: data['tieu_de'],
      tk_duyet: data['tk_duyet'],
      trang_thai: data['trang_thai'],
      ngay_gio_ket_thuc: data['ngay_gio_ket_thuc'].toDate(),
      dia_diem: data['dia_diem'],
      id: snapshot.id,
    );
  }

  Map<String, Object?> toFirestore() {
    return {
      "gd_huy": gd_huy,
      "ngay_gio_bat_dau": Timestamp.fromDate(ngay_gio_bat_dau),
      "ngay_post": Timestamp.fromDate(ngay_post),
      "tai_khoan_id": tai_khoan_id,
      "ten_cong_viec": ten_cong_viec,
      "thoi_gian_cv": thoi_gian_cv,
      "tieu_de": tieu_de,
      "tk_duyet": tk_duyet,
      "trang_thai": trang_thai,
      "ngay_gio_ket_thuc": ngay_gio_ket_thuc,
      "dia_diem": dia_diem
    };
  }
}
