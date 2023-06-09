import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_document_picker/flutter_document_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class UploadPDF extends StatelessWidget {
  // final String idCongViec;
  // UploadPDF({required this.idCongViec});

  Future<firebase_storage.UploadTask?> uploadFile(File file) async {
    if (file == null) {
      print('no picked file');
      return null;
    }

    firebase_storage.UploadTask uploadTask;

    // Create a Reference to the file
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('pdf_files')
        .child('/some-file.pdf');

    final metadata = firebase_storage.SettableMetadata(
        contentType: 'file/pdf',
        customMetadata: {'picked-file-path': file.path});
    print("Uploading..!");

    uploadTask = ref.putData(await file.readAsBytes(), metadata);

    print("done..!");
    return Future.value(uploadTask);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MaterialButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        elevation: 5.0,
        height: 40,
        onPressed: () async {
          final path = await FlutterDocumentPicker.openDocument();

          if (path == null) {
            Navigator.pop(context);
          } else {
            print(path);
            File file = File(path);

            // firebase_storage.UploadTask? task = await uploadFile(file); //upload file
          }
        },
        child: Text(
          "Chọn file pdf",
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        color: Colors.white,
      ),
    );
  }
}
