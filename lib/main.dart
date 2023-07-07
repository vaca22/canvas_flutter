import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'duoek_file.dart';

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
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 3,
                  width: MediaQuery.of(context).size.width,
                  child: CustomPaint(painter: FaceOutlinePainter()),
                ),
              ],
            ),
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
      ..strokeWidth = 1.0
      ..color = Colors.black;

    print("fileData.length: ${fileData.length}");
    DuoEkFile duoEkFile = DuoEkFile(originalData: fileData);
    duoEkFile.uncompress();
    var lineSize = 831;
    var hhh=3;
    var co=74.283167;
    var pointSize = duoEkFile.waveDataDouble.length;
    var totalHighNumber =0;
    var totalHigh=0.0;
    if(pointSize%lineSize==0) {
      totalHighNumber = pointSize ~/ lineSize;
      totalHigh = pointSize / lineSize * hhh * co;
    }else{
      totalHighNumber = pointSize ~/ lineSize+1;
      totalHigh = (pointSize / lineSize+1) * hhh * co;
    }


    var nv=size.width/lineSize;
    for(int k=0;k<totalHighNumber;k++){
      for(int j=0;j<lineSize;j++){
        var index = k*lineSize+j;
        if(index<duoEkFile.waveDataDouble.length-1){
          var baseH = k*co*hhh+co*hhh/2.0;
          var a = baseH-duoEkFile.waveDataDouble[index]*co;
          var a2 = baseH-duoEkFile.waveDataDouble[index+1]*co;
          canvas.drawLine(Offset(j.toDouble()*nv,a), Offset((j+1).toDouble()*nv,a2), paint);
        }
      }
    }

    // final mouth = Path();
    // mouth.moveTo(size.width * 0.8, size.height * 0.6);
    // mouth.lineTo(200, 300);
    // canvas.drawPath(mouth, paint);
  }

  @override
  bool shouldRepaint(FaceOutlinePainter oldDelegate) => false;
}
