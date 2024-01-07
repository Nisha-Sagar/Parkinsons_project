import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:parkinsons/pages/about_page.dart';
import 'package:parkinsons/pages/thank_you_page.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({Key? key}) : super(key: key);

  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  CameraController? _cameraController;
  bool _isRecording = false;
  String _videoPath = '';
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.reference();
  final Reference _storageReference =
      FirebaseStorage.instance.ref().child('videos');

  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
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

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    CameraDescription? frontCamera;

    for (var camera in cameras) {
      if (camera.lensDirection == CameraLensDirection.front) {
        frontCamera = camera;
        break;
      }
    }

    if (frontCamera != null) {
      _cameraController =
          CameraController(frontCamera, ResolutionPreset.medium);
      await _cameraController?.initialize();
      setState(() {});
    } else {
      print('Front camera not available');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Recorder'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _isRecording
                ? const Text('Recording...')
                : const Text('Tap to start recording'),
            const SizedBox(height: 20),
            _cameraController!.value.isInitialized
                ? Expanded(
                    child: AspectRatio(
                      aspectRatio: _cameraController!.value.aspectRatio,
                      child: CameraPreview(_cameraController!),
                    ),
                  )
                : Container(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isRecording ? null : _startRecording,
              child: const Text('Record Video'),
            ),
            ElevatedButton(
              onPressed: _isRecording ? _stopRecording : null,
              child: const Text('Stop Recording'),
            ),
            const SizedBox(height: 20),
            _videoPath.isNotEmpty
                ? ElevatedButton(
                    onPressed: () async {
                      await _uploadVideo();
                      await _saveVideoLinkToDatabase();
                      _showVideoSavedDialog();

                      // Navigate to the ThankYouPage after saving the video
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ThankYouPage(),
                        ),
                      );
                    },
                    child: const Text('Save Video'),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  Future<void> _startRecording() async {
    if (_cameraController!.value.isInitialized) {
      try {
        await _cameraController?.startVideoRecording();
        setState(() {
          _isRecording = true;
        });
      } catch (e) {
        print('Error starting video recording: $e');
      }
    }
  }

  Future<void> _stopRecording() async {
    if (_isRecording) {
      try {
        XFile? file = await _cameraController?.stopVideoRecording();
        _videoPath = file!.path;
        setState(() {
          _isRecording = false;
        });
      } catch (e) {
        print('Error stopping video recording: $e');
      }
    }
  }

  Future<void> _uploadVideo() async {
    final File videoFile = File(_videoPath);

    if (await videoFile.exists()) {
      final String fileName =
          'video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final Reference uploadReference = _storageReference.child(fileName);
      await uploadReference.putFile(videoFile);
    } else {
      print('Video file does not exist: $_videoPath');
    }
  }

  Future<void> _saveVideoLinkToDatabase() async {
    if (_videoPath.isNotEmpty) {
      final String videoLink = await _getVideoDownloadURL();
      if (videoLink.isNotEmpty) {
        await _databaseReference
            .child('users/${_currentUser.uid}/user_details')
            .update({'video_link': videoLink});

        print(
            'Video link saved to database: $videoLink'); // Print video link for debugging
      }
    }
  }

  Future<String> _getVideoDownloadURL() async {
    final String fileName =
        'video_${DateTime.now().millisecondsSinceEpoch}.mp4';
    final Reference videoReference = _storageReference.child(fileName);
    final String downloadURL = await videoReference.getDownloadURL();
    return downloadURL;
  }

  void _showVideoSavedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Video Saved'),
          content: const Text('Your video has been saved successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
