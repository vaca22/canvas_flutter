import 'dart:typed_data';

import 'package:flutter/foundation.dart';

class CheckmeFile {
  final Uint8List originalData;
  List<double> waveData = [];

  CheckmeFile({required this.originalData});

  var length = 0;

  double short2mv(int s) {
    return (s * 4033 / (32767 * 12 * 8));
  }

  void uncompress() {
    int dataLength = originalData[2] +
        (originalData[3] << 8) +
        (originalData[4] << 16) +
        (originalData[5] << 24);
    int timeLength = ((originalData[0]) + (originalData[1] << 8)) ~/ 2;

    int dataPos = 21 + timeLength * 2;
    for (int i = 0; i < dataLength - 4; i += 2) {
      int temp1 =
          ((originalData[dataPos + i]) + (originalData[dataPos + i + 1] << 8))
              .toSigned(16);
      int temp2 = ((originalData[dataPos + i + 2]) +
              (originalData[dataPos + i + 3] << 8))
          .toSigned(16);
      int temp3 = (temp1 + temp2) ~/ 2;
      if (i == 0) {
        waveData.add(short2mv(temp1));
      }
      waveData.add(short2mv(temp3));
      waveData.add(short2mv(temp2));
    }
  }
}
