import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'duoek_constant.dart';
import 'duoek_file.dart';

final Color darkBlue = Color.fromARGB(255, 18, 32, 47);
late Uint8List fileData;
var canvasHigh=0.0;

Future<void> readFile() async {
  var path = "/storage/emulated/0/Android/data/com.vaca.canvas_flutter/files/R20230707223659.dat";
  File file = File(path);
  fileData=await file.readAsBytes();
  DuoEkFile duoEkFile = DuoEkFile(originalData: fileData);
  duoEkFile.uncompress();

  var pointSize = duoEkFile.waveDataDouble.length;
  var totalHigh=0.0;
  if(pointSize%lineSize==0) {
    totalHigh = pointSize ~/ lineSize * rangeSpan * pixelPerMillivolt;
  }else{
    totalHigh = (pointSize ~/ lineSize+1) * rangeSpan * pixelPerMillivolt;
  }
  canvasHigh=totalHigh;
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
          padding: EdgeInsets.symmetric(horizontal: 0, vertical: 40),
          child: SingleChildScrollView(
            child: RepaintBoundary(
              child: SizedBox(
                height: canvasHigh,
                width: MediaQuery.of(context).size.width,
                child: CustomPaint(painter: FaceOutlinePainter()),
              ),
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
    final bgPaint1 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Color.fromRGBO(0xff, 0x00, 0x00,0.3);

    final bgPaint2 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Color.fromRGBO(0xff, 0x00, 0x00,0.101);



    var latticePixels = 0.1 * pixelPerMillivolt;
    var nn = 0.0;

    var step = 0;
    do {
      nn = step * latticePixels;
      canvas.drawLine(Offset(nn, 0), Offset(nn, size.height), bgPaint2);
      step++;
    } while (nn <= size.width);

    step = 0;
    do {
      nn = step * latticePixels;
      canvas.drawLine(Offset(0, nn), Offset(size.width, nn), bgPaint2);
      step++;
    } while (nn <= size.height);

    step=0;
    do {
      nn = step * latticePixels;
      canvas.drawLine(Offset(nn, 0), Offset(nn, size.height), bgPaint1);
      step+=5;
    } while (nn <= size.width);

    step=0;
    do {
      nn = step * latticePixels;
      canvas.drawLine(Offset(0, nn), Offset(size.width, nn), bgPaint1);
      step+=5;
    } while (nn <= size.height);


    final wavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Color.fromRGBO(0x24, 0x2A, 0x38,1);

    print("fileData.length: ${fileData.length}");
    DuoEkFile duoEkFile = DuoEkFile(originalData: fileData);
    duoEkFile.uncompress();

    var pointSize = duoEkFile.waveDataDouble.length;
    var totalHighNumber =0;
    if(pointSize%lineSize==0) {
      totalHighNumber = pointSize ~/ lineSize;
    }else{
      totalHighNumber = pointSize ~/ lineSize+1;
    }


    var nv=size.width/lineSize;
    for(int k=0;k<totalHighNumber;k++){
      for(int j=0;j<lineSize;j++){
        var index = k*lineSize+j;
        if(index<duoEkFile.waveDataDouble.length-1){
          var baseH = k*pixelPerMillivolt*rangeSpan+pixelPerMillivolt*rangeSpan/2.0;
          var y1 = baseH-duoEkFile.waveDataDouble[index]*pixelPerMillivolt;
          var y2 = baseH-duoEkFile.waveDataDouble[index+1]*pixelPerMillivolt;
          canvas.drawLine(Offset(j.toDouble()*nv,y1), Offset((j+1).toDouble()*nv,y2), wavePaint);
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
