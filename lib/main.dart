import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

final Color darkBlue = Color.fromARGB(255, 18, 32, 47);
late Uint8List fileData;

Future<void> readFile() async {
  var path = "/storage/emulated/0/Android/data/com.vaca.canvas_flutter/files/R20230707223659.dat";
  File file = File(path);
  fileData=await file.readAsBytes();
  runApp(MyApp());
}
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  readFile();

}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: darkBlue),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        // Outer white container with padding
        body: Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 80),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white,
            child: CustomPaint(painter: FaceOutlinePainter()),
          ),
        ),
      ),
    );
  }
}



class FaceOutlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Define a paint object
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.black;

    print("fileData.length: ${fileData.length}");
    final mouth = Path();
    mouth.moveTo(size.width * 0.8, size.height * 0.6);
    mouth.lineTo(200, 300);
    canvas.drawPath(mouth, paint);
  }

  @override
  bool shouldRepaint(FaceOutlinePainter oldDelegate) => false;
}
