// ignore_for_file: unused_import

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:parkinsons/pages/recreate_pattern_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      home: CaptureUserInputPage(),
    ),
  );
}

class CaptureUserInputPage extends StatefulWidget {
  const CaptureUserInputPage({Key? key}) : super(key: key);

  @override
  _CaptureUserInputPageState createState() => _CaptureUserInputPageState();
}

class _CaptureUserInputPageState extends State<CaptureUserInputPage> {
  List<Offset> cursorPositions = [];
  late User? _user;
  String jsonStorageUrl = ''; // Move this line to the class level

  @override
  void initState() {
    super.initState();
    print(
        'Current user UID: ${FirebaseAuth.instance.currentUser?.uid ?? "N/A"}');

    _user = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Capture User Input - User ${_user?.uid ?? "N/A"}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AspectRatio(
                aspectRatio: 1.0,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      cursorPositions.add(details.localPosition);
                    });
                  },
                  onPanEnd: (details) {
                    // Additional logic when finger movement ends (if needed)
                  },
                  child: CustomPaint(
                    painter: FingerDrawingPainter(
                      cursorPositions: cursorPositions,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _onFinishButtonPressed(context),
                child: const Text('Finish'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _navigateToNextPage(context),
                child: const Text('Go to Next Page'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _onFinishButtonPressed(BuildContext context) async {
    print('Pattern drawing finished.');

    if (cursorPositions.isEmpty) {
      print('No pattern drawn. Please draw a pattern.');
      return;
    }

    String csvString = _generateCsvString();

    print('User drew the pattern. Pixels traced: ${cursorPositions.length}');

    String jsonFileName =
        'json_data_${DateTime.now().millisecondsSinceEpoch}.json';

    String loggedInUserFolder = 'JSON&CSV/${_user?.uid ?? "N/A"}';
    String csvStorageUrl =
        await uploadCsvToStorage(csvString, loggedInUserFolder);

    // Obtain the JSON file link automatically
    jsonStorageUrl = await convertCsvToJsonAndUpload(
        csvString, jsonFileName, loggedInUserFolder);

    // Save user details and file links to Realtime Database
    saveUserDetailsAndLinksToDatabase(
        csvStorageUrl: csvStorageUrl, jsonStorageUrl: jsonStorageUrl);

    // Displaying debug statements
    print('CSV Storage URL: $csvStorageUrl');
    print('JSON Storage URL: $jsonStorageUrl');
  }

  void _navigateToNextPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecreatePatternPage(jsonFileLink: jsonStorageUrl),
      ),
    );
  }

  void saveUserDetailsAndLinksToDatabase({
    required String csvStorageUrl,
    required String jsonStorageUrl,
  }) async {
    DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

    try {
      // Save user details and links under 'user_details'
      await databaseReference
          .child('users')
          .child(_user?.uid ?? "N/A")
          .child('user_details')
          .update({
        'csv_link': csvStorageUrl,
        'json_link': jsonStorageUrl,
      });
    } catch (e) {
      print('Error updating user data: $e');
      // Handle the error as needed (e.g., show a message to the user)
    }
  }

  String _generateCsvString() {
    List<Map<String, dynamic>> csvList = [];

    // Include information about each point in the traced path
    for (int i = 0; i < cursorPositions.length; i++) {
      csvList.add({
        'User': _user?.uid,
        'PointIndex': i + 1,
        'XCoordinate': cursorPositions[i].dx,
        'YCoordinate': cursorPositions[i].dy,
      });
    }

    String csvString = 'User,PointIndex,XCoordinate,YCoordinate\n';
    for (var point in csvList) {
      csvString +=
          '${point['User']},${point['PointIndex']},${point['XCoordinate']},${point['YCoordinate']}\n';
    }

    return csvString;
  }

  Future<String> uploadCsvToStorage(String csvData, String folderName) async {
    final String fileName =
        '$folderName/csv_data_${DateTime.now().millisecondsSinceEpoch}.csv';
    final Reference storageReference =
        FirebaseStorage.instance.ref().child(fileName);

    await storageReference.putData(utf8.encode(csvData));

    return await storageReference.getDownloadURL();
  }

  Future<String> convertCsvToJsonAndUpload(
      String csvData, String jsonFileName, String folderName) async {
    List<Map<String, dynamic>> csvList = csvData
        .split('\n')
        .where((line) => line.isNotEmpty)
        .skip(1)
        .map((line) {
      List<String> values = line.split(',');
      return {
        'User': values[0],
        'PointIndex': int.parse(values[1]),
        'XCoordinate': double.parse(values[2]),
        'YCoordinate': double.parse(values[3]),
      };
    }).toList();

    String jsonString = jsonEncode(csvList);
    final Reference jsonStorageReference =
        FirebaseStorage.instance.ref().child('$folderName/$jsonFileName');

    await jsonStorageReference.putData(utf8.encode(jsonString));

    return await jsonStorageReference.getDownloadURL();
  }
}

class FingerDrawingPainter extends CustomPainter {
  final List<Offset> cursorPositions;

  FingerDrawingPainter({
    required this.cursorPositions,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2;

    // Draw cursor path
    for (var i = 1; i < cursorPositions.length; i++) {
      canvas.drawLine(
        cursorPositions[i - 1],
        cursorPositions[i],
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
