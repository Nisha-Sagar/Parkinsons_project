import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:parkinsons/pages/video_record_page.dart';

class AudioPage extends StatefulWidget {
  const AudioPage({Key? key}) : super(key: key);

  @override
  _AudioPageState createState() => _AudioPageState();
}

class _AudioPageState extends State<AudioPage> {
  final record = AudioRecorder();
  bool _isRecording = false;
  String _filePath = '';
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.reference();
  final AudioPlayer _audioPlayer = AudioPlayer();
  late User _currentUser;

  final Reference _storageReference =
      FirebaseStorage.instance.ref().child('audio'); // Audio folder in Storage

  // List of random sentences
  final List<String> randomSentences = [
    'The quick brown fox jumps over the lazy dog.',
    'Flutter is an awesome framework for building mobile apps.',
    'Coding is fun and rewarding.',
    'Keep calm and code on.',
    'Hello, World! Welcome to the Flutter world.',
  ];

  // Display a random sentence
  String getRandomSentence() {
    final Random random = Random();
    String selectedSentence =
        randomSentences[random.nextInt(randomSentences.length)];
    print('Selected Sentence: $selectedSentence'); // Debug print
    return selectedSentence;
  }

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void _getCurrentUser() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        setState(() {
          _currentUser = user;
        });

        print('Current User ID: ${_currentUser.uid}');
      } else {
        print('No user signed in.');
      }
    });
  }

  Future<void> _startRecording() async {
    if (await record.hasPermission()) {
      final appDocumentsDirectory = await getApplicationDocumentsDirectory();
      _filePath =
          '${appDocumentsDirectory.path}/audio_recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await record.start(
        const RecordConfig(),
        path: _filePath,
      );

      setState(() {
        _isRecording = true;
      });

      print('Recording started');
    }
  }

  Future<void> _stopRecording() async {
    String? path = await record.stop();

    if (path!.isNotEmpty) {
      await uploadAudioToStorage(path);

      // Save audio link under the user's details in the database
      _databaseReference
          .child("users")
          .child(_currentUser.uid)
          .child("user_details")
          .update({"audio_link": path});

      print(
          'Audio link saved to database: $path'); // Print the audio link for debugging

      setState(() {
        _isRecording = false;
      });

      print('Recording stopped');
    }
  }

  Future<void> _playRecordedAudio() async {
    if (_filePath.isNotEmpty) {
      await _audioPlayer.play(UrlSource(_filePath));
    } else {
      print('File path is empty. Please record audio first.');
    }
  }

  Future<void> uploadAudioToStorage(String audioPath) async {
    final String fileName =
        'audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
    final Reference storageReference =
        _storageReference.child(fileName); // Save to the "audio" folder

    await storageReference.putFile(File(audioPath));

    final String downloadUrl = await storageReference.getDownloadURL();
    print(
        'Audio saved to storage: $downloadUrl'); // Print download URL for debugging
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Recorder'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_isRecording)
              Column(
                children: [
                  const Text(
                    'Read the sentence below:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    getRandomSentence(),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            _isRecording
                ? const Text('Recording...')
                : const Text('Tap to start recording'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isRecording ? null : () => _startRecording(),
              child: const Text('Record Audio'),
            ),
            ElevatedButton(
              onPressed: _isRecording ? () => _stopRecording() : null,
              child: const Text('Stop Recording'),
            ),
            ElevatedButton(
              onPressed: _playRecordedAudio,
              child: const Text('Play Recorded Audio'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VideoPage(),
                  ),
                );
              },
              child: const Text('Record Video'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    record.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
}
