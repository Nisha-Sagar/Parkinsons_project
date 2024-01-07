import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'audio_page.dart';

class RecreatePatternPage extends StatefulWidget {
  final String jsonFileLink;

  const RecreatePatternPage({Key? key, required this.jsonFileLink})
      : super(key: key);

  @override
  _RecreatePatternPageState createState() => _RecreatePatternPageState();
}

class _RecreatePatternPageState extends State<RecreatePatternPage> {
  TextEditingController textEditingController = TextEditingController();
  List<Offset> recreatedPath = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recreate Pattern'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: TextField(
                  controller: textEditingController,
                  maxLines: 10,
                  decoration: const InputDecoration(
                    labelText: 'Enter JSON Data',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                recreatePath();
              },
              child: const Text('Finish Recreating'),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () {
                _launchURL(widget.jsonFileLink);
              },
              child: RichText(
                text: TextSpan(
                  text: 'JSON File Link: ',
                  style: DefaultTextStyle.of(context).style,
                  children: <TextSpan>[
                    TextSpan(
                      text: widget.jsonFileLink,
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: CustomPaint(
                    painter: RecreatedPathPainter(recreatedPath),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AudioPage(),
                  ),
                );
              },
              child: const Text('Next: Audio Page'),
            ),
          ],
        ),
      ),
    );
  }

  void recreatePath() {
    try {
      String jsonData = textEditingController.text;
      List<dynamic> data = jsonDecode(jsonData);

      recreatedPath = data.map<Offset>((point) {
        double x = (point['XCoordinate'] as num).toDouble();
        double y = (point['YCoordinate'] as num).toDouble();
        return Offset(x, y);
      }).toList();

      setState(() {});
    } catch (e) {
      print('Error decoding JSON: $e');
    }
  }

  // Function to launch the URL
  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }
}

class RecreatedPathPainter extends CustomPainter {
  final List<Offset> recreatedPath;

  RecreatedPathPainter(this.recreatedPath);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2;

    // Draw recreated path
    for (var i = 1; i < recreatedPath.length; i++) {
      canvas.drawLine(
        recreatedPath[i - 1],
        recreatedPath[i],
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
