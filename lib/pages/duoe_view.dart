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
Future<bool> initFile = Future.value(false);

Future<void> readFile() async {
  var path = "assets/R20230707223659.dat";
  fileData = (await rootBundle.load(path)).buffer.asUint8List();
  print(fileData.length);
  DuoEkFile duoekFile = DuoEkFile(originalData: fileData);
  duoekFile.uncompress();
  var pointSize = duoekFile.waveData.length;
  var totalHigh = 0.0;
  if (pointSize % lineSize == 0) {
    totalHigh = pointSize ~/ lineSize * rangeHeightSpan * pixelPerMillivolt;
  } else {
    totalHigh =
        (pointSize ~/ lineSize + 1) * rangeHeightSpan * pixelPerMillivolt;
  }
  canvasHigh = totalHigh;
  initFile = Future.value(true);
  initFile.then((value) => print("initFile"));
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
            child: FutureBuilder<bool>(
              future: initFile,
              builder: (BuildContext context, AsyncSnapshot<bool> value) {
                final displayValue = (value.hasData) ? value.data : false;
                if (displayValue == true) {
                  return RepaintBoundary(
                    child: Center(
                      child: SizedBox(
                        height: canvasHigh,
                        width: rangeWidthSpan * pixelPerMillivolt,
                        child: CustomPaint(painter: FaceOutlinePainter()),
                      ),
                    ),
                  );
                } else {
                  return Text("file not found");
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
    if (pointSize % lineSize == 0) {
      totalHighNumber = pointSize ~/ lineSize;
    } else {
      totalHighNumber = pointSize ~/ lineSize + 1;
    }

    var nv = size.width / lineSize;
    for (int k = 0; k < totalHighNumber; k++) {
      for (int j = 0; j < lineSize; j++) {
        var index = k * lineSize + j;
        if (index < duoEkFile.waveData.length - 1) {
          var baseH = k * pixelPerMillivolt * rangeHeightSpan +
              pixelPerMillivolt * rangeHeightSpan / 2.0;
          var y1 = baseH - duoEkFile.waveData[index] * pixelPerMillivolt;
          var y2 = baseH - duoEkFile.waveData[index + 1] * pixelPerMillivolt;
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
        (rangeWidthSpan * pixelPerMillivolt).toInt(), canvasHigh.toInt());
    Directory? dir;
    String path;
    img.then((value) => {
          value.toByteData(format: ImageByteFormat.png).then((value) async => {
                fileData = value!.buffer.asUint8List(),
                dir = await getExternalStorageDirectory(),
                path = '${dir?.path}${Platform.pathSeparator}${name}.png',
                File(path).writeAsBytes(fileData),
              }),
        });
  }

  @override
  void paint(Canvas canvas, Size size) {
    drawEcg(canvas, size);
    saveAsImage(canvas, size, "duoek_eck_img");
  }

  @override
  bool shouldRepaint(FaceOutlinePainter oldDelegate) => false;
}
