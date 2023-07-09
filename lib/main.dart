import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'checkme_pro_file.dart';
import 'checkmepro_constant.dart';
import 'duoek_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;


final Color darkBlue = Color.fromARGB(255, 18, 32, 47);
late Uint8List fileData;
var canvasHigh=0.0;

Future<void> readFile() async {
  //20230625170510  checkme pro
  // var path = "/storage/emulated/0/Android/data/com.vaca.canvas_flutter/files/R20230707223659.dat";
  var path = "/storage/emulated/0/Android/data/com.vaca.canvas_flutter/files/20230625170510";
  File file = File(path);
  fileData=await file.readAsBytes();
  CheckmeProFile checkmeProFile=CheckmeProFile(originalData: fileData);
  checkmeProFile.uncompress();

  var pointSize = checkmeProFile.waveData.length;
  var totalHigh=0.0;
  if(pointSize%lineSize==0) {
    totalHigh = pointSize ~/ lineSize * rangeHeightSpan * pixelPerMillivolt;
  }else{
    totalHigh = (pointSize ~/ lineSize+1) * rangeHeightSpan * pixelPerMillivolt;
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
              child: Center(
                child: SizedBox(
                  height: canvasHigh,
                  width: rangeWidthSpan * pixelPerMillivolt,
                  child: CustomPaint(painter: FaceOutlinePainter()),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}



class FaceOutlinePainter extends CustomPainter {


  void drawEcg(Canvas canvas, Size size){
    //fill canvas with white color
    final bgPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    canvas.drawRect(Offset.zero & size, bgPaint);


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


    //drawWave

    final wavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Color.fromRGBO(0x24, 0x2A, 0x38,1);

    print("fileData.length: ${fileData.length}");
    CheckmeProFile duoEkFile = CheckmeProFile(originalData: fileData);
    duoEkFile.uncompress();

    var pointSize = duoEkFile.waveData.length;
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
        if(index<duoEkFile.waveData.length-1){
          var baseH = k*pixelPerMillivolt*rangeHeightSpan+pixelPerMillivolt*rangeHeightSpan/2.0;
          var y1 = baseH-duoEkFile.waveData[index]*pixelPerMillivolt;
          var y2 = baseH-duoEkFile.waveData[index+1]*pixelPerMillivolt;
          try{
            canvas.drawLine(Offset(j.toDouble()*nv,y1), Offset((j+1).toDouble()*nv,y2), wavePaint);
          }catch(e){
            print("e: $e");
          }

        }
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    // final recorder = new PictureRecorder();
    // final recordCanvas = new Canvas(recorder,Rect.fromLTWH(0, 0, size.width, size.height));

    // drawEcg(recordCanvas,size);
    drawEcg(canvas, size);


    // final picture = recorder.endRecording();
    // final img = picture.toImage((rangeWidthSpan*pixelPerMillivolt).toInt(),canvasHigh.toInt());
    // img.then((value) => {
    //   value.toByteData(format: ImageByteFormat.png).then((value) => {
    //     print("value.lengthInBytes: ${value!.lengthInBytes}"),
    //     fileData=value.buffer.asUint8List(),
    //     File("/storage/emulated/0/Android/data/com.vaca.canvas_flutter/files/R20230707223659.png").writeAsBytes(fileData),
    //   }),
    // });
    // final mouth = Path();
    // mouth.moveTo(size.width * 0.8, size.height * 0.6);
    // mouth.lineTo(200, 300);
    // canvas.drawPath(mouth, paint);
  }

  @override
  bool shouldRepaint(FaceOutlinePainter oldDelegate) => false;
}
