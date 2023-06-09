import 'dart:io';

import 'package:flutter/material.dart';
//import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';

class PDFViwer extends StatefulWidget {
  final String url;

  PDFViwer({Key? key, required this.url}) : super(key: key);

  @override
  _PDFViwerState createState() => _PDFViwerState();
}

class _PDFViwerState extends State<PDFViwer> {
  String? pdfPath;
  String path = '';
  var docUrl = '';
  Future<File> loadPDF() async {
    try {
      docUrl = await FirebaseStorage.instance
          .ref()
          .child('pdf_files')
          .child('/${widget.url}')
          .getDownloadURL();
      print('docUrl:' + docUrl);
    } catch (e) {
      print(e);
      docUrl = await FirebaseStorage.instance
          .ref()
          .child('File pdf không tồn tại.pdf')
          .getDownloadURL();
      print('docUrl:' + docUrl);
    }

    return await DefaultCacheManager().getSingleFile(docUrl);
  }

  Future<String> getFilePath() async {
    final file = await loadPDF();
    path = file.path;
    return path;
  }

  @override
  void initState() {
    super.initState();
    loadPDF();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File>(
      future: loadPDF(),
      builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return PdfView(
            path: snapshot.data!.path,
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}
