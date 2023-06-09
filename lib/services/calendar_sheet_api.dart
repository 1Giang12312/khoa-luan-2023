// import 'package:flutter/material.dart';
// import 'package:gsheets/gsheets.dart';

// import 'add_header_row_gsheet.dart';

// class UserSheetAPI {
//   static const _credential = r'''
// {
//   "type": "service_account",
//   "project_id": "gsheets-386107",
//   "private_key_id": "60bee48557f3a69d616dd778a56af7a2c8243dfa",
//   "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQC8YTTbu5WSMMEB\nYG9BEQsnvjGJkrkZlkVNLS6s45wxsezFq5XTnOGJ1eeXtKcfe5sZ2jRhp5GR8epy\nayrhwgx8Ag3TfWsYlDKLJqu70L1MX+sB7xQS7ZbOVzhI0aDLldUtk7plEjoNz7VY\nKDxyi6d/j06eHZaD970i7SBlBdZ3ztBV2q6l5XZ6u7DravLlJ3rUpqG4t+A3yIVV\nneN4mzUVSjD6e4umn5Lda1ODnT0gsXn6N7+cljYyXVTHgKuanngqfeBHA6K0tq8r\nJrLoHS2v0LDTGaA60VMElIWcc+lLRt/05e7XfCIH1IAIFQFGk3NEceFSDZSdE2MQ\nGmhSQGBBAgMBAAECggEACLzKfpmeB6SWwylVp7MybQK7mfmx96+aYcjDdjXtb/mk\ndYuunJzVcjb3cbgpm0J4sHOIQ/JJhHcvzGRPnh6JxTO0L/fMgJyZFo6x3vmA2jrF\ns/aCnBkkikgN3oTInEDEHUPRnLACfNMCQodFPHvhRj+foiJVsaPLREQy4TSq3K4o\n1czasGVNKnXmwrkH5ftJduhNJAK59A0RQlXDTVIJEdpm1V1crYVcyR/P9KmpXH7d\npuVls+qFkosOLdNlYKcLhCiMULTBf2g8sGkeIXOhccbmxOhDV50NZIYz9yo1v4Rb\nyWAyWGcM1fQehQcXuT34pXrZaTCPFq65kE+vzgSjEQKBgQDvRIJhb6Qm+FnoZCGV\nzQiNo1ofS/wkLrE6ezo3KFOKc0L1ow6mmu9/AKxdE0yvUa590uIdob1kPWQGlsAN\nJJ0YkbdKI6CeAQNA3BPvYZKoXQoOv6F4WhaVqFqX9IBBW4mntvLxZGh8gfH2+Sfa\ni2vDPZZFdXE0teLta7YQHqeFCQKBgQDJja0RP8XCJjiqpFEqJEDprmGqQR6xa/tI\n92aA/2x/9xG44yWPFy4ar12UWTqtKpmd1D/1n57bw0ZYfvvu3Q1MCoxPapDLYNUL\n7jKIBSPY8CDOGIUKhHUB0pX6mDWbCDdkxfY2uuboM6vhaT15PGmTey7+SaIDynyi\ncVstFgVHeQKBgFT6VAQfDoH4upXa2kLF6z/CwINVDVwcaT2H/okQfXsyrJlpLA7o\nAB9vMchszlOGAx8VAtHbW9R6KUhdyh/g3RqYxixCswzq9yjWAQ6H7Pp28NeEH+kK\ntfK5NFO7tsF/rUgvpeEt9B4kWLeKjikEU2WoPfK1X1uFLe98zdCz0nNhAoGAQ6TL\n380iZt2DCSoqn1UZgBPpbUV7spoF9OArQ8H1vSDDjuSVF2f1LjmK0536xmFUuxaf\n/KR8oU7xTgQYM3t22f10R7cBL3CpL97akLIA7O7yY5jxFa2Mw3bUpQzueMCSLr0N\nvCKQGoA1AGrcmdK/sCKYi/lUaadMmwwmSIRqcykCgYBs8+8XI5/Gl14UtN/Uxm1l\nUevownZI7mzErrjYxJn+3e9U+oQHrFKIB1aYap/HT/Tb6sZDe2xZwCOPjV/QYUi7\noH5VJ6X28lPUxpkxACuFqy1kasH4b6Ee3g65G6fZQCHsYR8oNUOmXXMraGOX432v\ndj8Qo21ZPQ+iqVFsZiPHyQ==\n-----END PRIVATE KEY-----\n",
//   "client_email": "gsheets@gsheets-386107.iam.gserviceaccount.com",
//   "client_id": "106873324215824951442",
//   "auth_uri": "https://accounts.google.com/o/oauth2/auth",
//   "token_uri": "https://oauth2.googleapis.com/token",
//   "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
//   "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/gsheets%40gsheets-386107.iam.gserviceaccount.com"
// }
// ''';
//   static final _spreadsheetId = '1yokoDe_CTaW6BLLvDc4f8I3IHFuvuED6fAx487L27CE';
//   static final _gsheet = GSheets(_credential);
//   static Worksheet? _canlendarSheet;
//   static Future init() async {
//     try {
//       final spreadsheet = await _gsheet.spreadsheet(_spreadsheetId);
//       _canlendarSheet = await _getWorkSheet(spreadsheet,
//           title: 'Sync data from Google Calendar to Firestore');
//       final firstRow = HeaderRow.getFields();
//       _canlendarSheet!.values.insertRow(1, firstRow);
//     } catch (e) {
//       print('gshet init error: $e');
//     }
//   }

//   static Future<Worksheet> _getWorkSheet(
//     Spreadsheet spreadsheet, {
//     required String title,
//   }) async {
//     try {
//       return await spreadsheet.addWorksheet(title);
//     } catch (e) {
//       return spreadsheet.addWorksheet(title);
//     }
//   }
// }
