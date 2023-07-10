import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

import '../ecg/duoek_constant.dart';
import '../ecg/duoek_file.dart';

final Color darkBlue = Color.fromARGB(255, 18, 32, 47);
late Uint8List fileData;
var canvasHigh = 0.0;
late Future initFile;

void initVar() async {
  var path = "assets/R20230707223659.dat";
  fileData = (await rootBundle.load(path)).buffer.asUint8List();
  print(fileData.length);
  DuoEkFile duoekFile = DuoEkFile(originalData: fileData);
  duoekFile.uncompress();
  var pointSize = duoekFile.waveData.length;
  var totalHigh = 0.0;
  if (pointSize % DuoEkGlobal.lineSize == 0) {
    totalHigh = pointSize ~/
        DuoEkGlobal.lineSize *
        DuoEkGlobal.rangeHeightSpan *
        DuoEkGlobal.pixelsPerMillivolt;
  } else {
    totalHigh = (pointSize ~/ DuoEkGlobal.lineSize + 1) *
        DuoEkGlobal.rangeHeightSpan *
        DuoEkGlobal.pixelsPerMillivolt;
  }
  canvasHigh = totalHigh;
}

void readFile() {
  initFile = Future(() => {initVar()});
}

class DuoEkView extends StatelessWidget {
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
                        width: DuoEkGlobal.rangeWidthSpan *
                            DuoEkGlobal.pixelsPerMillivolt,
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

    var latticePixels = 0.1 * DuoEkGlobal.pixelsPerMillivolt;
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

    DuoEkFile duoEkFile = DuoEkFile(originalData: fileData);
    duoEkFile.uncompress();

    var pointSize = duoEkFile.waveData.length;
    var totalHighNumber = 0;
    if (pointSize % DuoEkGlobal.lineSize == 0) {
      totalHighNumber = pointSize ~/ DuoEkGlobal.lineSize;
    } else {
      totalHighNumber = pointSize ~/ DuoEkGlobal.lineSize + 1;
    }

    var nv = size.width / DuoEkGlobal.lineSize;
    for (int k = 0; k < totalHighNumber; k++) {
      for (int j = 0; j < DuoEkGlobal.lineSize; j++) {
        var index = k * DuoEkGlobal.lineSize + j;
        if (index < duoEkFile.waveData.length - 1) {
          var baseH =
              k * DuoEkGlobal.pixelsPerMillivolt * DuoEkGlobal.rangeHeightSpan +
                  DuoEkGlobal.pixelsPerMillivolt *
                      DuoEkGlobal.rangeHeightSpan /
                      2.0;
          var y1 = baseH -
              duoEkFile.waveData[index] * DuoEkGlobal.pixelsPerMillivolt;
          var y2 = baseH -
              duoEkFile.waveData[index + 1] * DuoEkGlobal.pixelsPerMillivolt;
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
  }

  void saveAsImage(Canvas canvas, Size size, String name) {
    final recorder = PictureRecorder();
    final recordCanvas =
        Canvas(recorder, Rect.fromLTWH(0, 0, size.width, size.height));
    drawEcg(recordCanvas, size);
    final picture = recorder.endRecording();
    final img = picture.toImage(
        (DuoEkGlobal.rangeWidthSpan * DuoEkGlobal.pixelsPerMillivolt).toInt(),
        canvasHigh.toInt());
    Directory? dir;
    String path;
    img.then((value) => {
          value.toByteData(format: ImageByteFormat.png).then((value) async => {
                fileData = value!.buffer.asUint8List(),
                dir = await getTemporaryDirectory(),
                path = '${dir?.path}${Platform.pathSeparator}${name}.png',
                File(path).writeAsBytes(fileData),
              }),
        });
  }

  @override
  void paint(Canvas canvas, Size size) {
    drawEcg(canvas, size);
    //save to /storage/emulated/0/Android/data/com.vaca.canvas_flutter/files/xx.png
    saveAsImage(canvas, size, "duoek_eck_img");
  }

  @override
  bool shouldRepaint(FaceOutlinePainter oldDelegate) => false;
}
