import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

import '../app_utils.dart';
import '../ecg/bp2_constant.dart';
import '../ecg/bp2_file.dart';

final Color darkBlue = Color.fromARGB(255, 18, 32, 47);
late Uint8List fileData;
var canvasHigh = 0.0;
late Future initFile;

void initVar() async {
  var path = "assets/20230709121347.dat";
  fileData = (await rootBundle.load(path)).buffer.asUint8List();
  print(fileData.length);
  Bp2File bp2File = Bp2File(originalData: fileData);
  bp2File.uncompress();
  var pointSize = bp2File.waveData.length;
  var totalHigh = 0.0;
  if (pointSize % Bp2Global.lineSize == 0) {
    totalHigh = (pointSize ~/
        Bp2Global.lineSize *
        Bp2Global.rangeHeightSpan *
        Bp2Global.pixelsPerMillivolt);
  } else {
    totalHigh = ((pointSize ~/ Bp2Global.lineSize + 1) *
        Bp2Global.rangeHeightSpan *
        Bp2Global.pixelsPerMillivolt);
  }
  canvasHigh = totalHigh;
}

void readFile() {
  initFile = Future(() => {initVar()});
}

class Bp2View extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    readFile();
    return MaterialApp(
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: darkBlue),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        // Outer white container with padding
        body: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 40),
          child: SingleChildScrollView(
            child: FutureBuilder(
              future: initFile,
              builder: (BuildContext context, AsyncSnapshot<dynamic> value) {
                if (value.connectionState == ConnectionState.done) {
                  return RepaintBoundary(
                    child: Center(
                      child: SizedBox(
                        height: canvasHigh,
                        width: Bp2Global.rangeWidthSpan *
                            Bp2Global.pixelsPerMillivolt,
                        child: CustomPaint(painter: FaceOutlinePainter()),
                      ),
                    ),
                  );
                } else {
                  return SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: Center(
                          child: Container(
                        width: 100,
                        height: 100,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Colors.amber),
                        child: const CircularProgressIndicator(
                          color: Colors.red,
                          strokeWidth: 20,
                        ),
                      )));
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

class FaceOutlinePainter extends CustomPainter {
  void drawEcg(Canvas canvas, Size size) {
    //fill canvas with white color
    final bgPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    canvas.drawRect(Offset.zero & size, bgPaint);

    final bgPaint1 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Color.fromRGBO(0xff, 0x00, 0x00, 0.3);

    final bgPaint2 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Color.fromRGBO(0xff, 0x00, 0x00, 0.101);

    var latticePixels = 0.1 * Bp2Global.pixelsPerMillivolt;
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

    step = 0;
    do {
      nn = step * latticePixels;
      canvas.drawLine(Offset(nn, 0), Offset(nn, size.height), bgPaint1);
      step += 5;
    } while (nn <= size.width);

    step = 0;
    do {
      nn = step * latticePixels;
      canvas.drawLine(Offset(0, nn), Offset(size.width, nn), bgPaint1);
      step += 5;
    } while (nn <= size.height);

    //drawWave

    final wavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = const Color.fromRGBO(0x24, 0x2A, 0x38, 1);

    Bp2File bp2File = Bp2File(originalData: fileData);
    bp2File.uncompress();

    var pointSize = bp2File.waveData.length;
    var totalHighNumber = 0;
    if (pointSize % Bp2Global.lineSize == 0) {
      totalHighNumber = pointSize ~/ Bp2Global.lineSize;
    } else {
      totalHighNumber = pointSize ~/ Bp2Global.lineSize + 1;
    }

    var nv = size.width / Bp2Global.lineSize;
    for (int k = 0; k < totalHighNumber; k++) {
      for (int j = 0; j < Bp2Global.lineSize; j++) {
        var index = k * Bp2Global.lineSize + j;
        if (index < bp2File.waveData.length - 1) {
          var baseH = k *
                  Bp2Global.pixelsPerMillivolt *
                  Bp2Global.rangeHeightSpan +
              Bp2Global.pixelsPerMillivolt * Bp2Global.rangeHeightSpan / 2.0;
          var y1 =
              baseH - bp2File.waveData[index] * Bp2Global.pixelsPerMillivolt;
          var y2 = baseH -
              bp2File.waveData[index + 1] * Bp2Global.pixelsPerMillivolt;
          try {
            canvas.drawLine(Offset(j.toDouble() * nv, y1),
                Offset((j + 1).toDouble() * nv, y2), wavePaint);
          } catch (e) {
            if (kDebugMode) {
              print("e: $e");
            }
          }
        }
      }
    }

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = const Color.fromRGBO(0xcc, 0xcc, 0xcc, 1);


    var path = Path();
    var baseH = Bp2Global.rangeHeightSpan* Bp2Global.pixelsPerMillivolt/2;
    var x1 = 25.0;
    var x2 = 30.0;
    path.moveTo(0, baseH);
    path.lineTo(x1, baseH);
    path.lineTo(x1, baseH - Bp2Global.pixelsPerMillivolt);
    path.lineTo(x1+x2, baseH - Bp2Global.pixelsPerMillivolt);
    path.lineTo(x1+x2, baseH);
    path.lineTo(x1*2+x2, baseH);
    canvas.drawPath(path, linePaint);
    //draw text "1mV" to canvas

    const textSpan = TextSpan(
      text: "1mV",
      style: TextStyle(
        color: Color.fromRGBO(0xbc, 0xbc, 0xbc, 1),
        fontSize: 15,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x1+x2, baseH +25));
  }

  void saveAsImage(Canvas canvas, Size size, String name) {
    final recorder = PictureRecorder();
    final recordCanvas =
        Canvas(recorder, Rect.fromLTWH(0, 0, size.width, size.height));
    drawEcg(recordCanvas, size);
    final picture = recorder.endRecording();
    final img = picture.toImage(
        (Bp2Global.rangeWidthSpan * Bp2Global.pixelsPerMillivolt).toInt(),
        canvasHigh.toInt());
    Directory? dir;
    String path;
    img.then((value) => {
          value.toByteData(format: ImageByteFormat.png).then((value) async => {
                fileData = value!.buffer.asUint8List(),
            AppUtil.saveImage(fileData)
              }),
        });
  }

  @override
  void paint(Canvas canvas, Size size) {
    drawEcg(canvas, size);
    //save to /storage/emulated/0/Android/data/com.vaca.canvas_flutter/files/xx.png
    saveAsImage(canvas, size, "bp2_img");
  }

  @override
  bool shouldRepaint(FaceOutlinePainter oldDelegate) => false;
}
