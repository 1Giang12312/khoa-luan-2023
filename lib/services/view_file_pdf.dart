import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class PDFScreen extends StatefulWidget {
  final String url;

  PDFScreen({Key? key, required this.url}) : super(key: key);

  @override
  _PDFScreenState createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> {
  String? pdfPath;
  File docFile = File('');
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
          return PDFView(
            filePath: snapshot.data!.path,
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
