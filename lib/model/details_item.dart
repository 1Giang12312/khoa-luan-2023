import 'package:cloud_firestore/cloud_firestore.dart';

class DetailEvent {
  late bool gd_huy;
  late bool tk_duyet;
  late DateTime ngay_gio_bat_dau;
  late DateTime ngay_post;
  late String ten_cong_viec;
  late String thoi_gian_cv;
  late String tieu_de;
  late bool trang_thai;
  late String tai_khoan_id;
  late String do_uu_tien;
  late String id;
  DetailEvent({
    required this.gd_huy,
    required this.tk_duyet,
    required this.ngay_gio_bat_dau,
    required this.ngay_post,
    required this.ten_cong_viec,
    required this.thoi_gian_cv,
    required this.tieu_de,
    required this.trang_thai,
    required this.tai_khoan_id,
    required this.do_uu_tien,
    required this.id,
  });
}
