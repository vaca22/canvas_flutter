import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import '../ffi/plugin_filtering.dart';

class Bp2File {
  final Uint8List originalData;
  List<double> waveData = [];

  Bp2File({required this.originalData});

  var length = 0;

  double short2mv(int s) {
    return (s * 4033 / (32767 * 12 * 8));
  }

  void uncompress() {
    int dataPos = 48;
    var dataLength = originalData.length - 48;
    List<int> temp = [];
    for (int i = 0; i < dataLength; i += 2) {
      int temp1 =
          ((originalData[dataPos + i]) + (originalData[dataPos + i + 1] << 8))
              .toSigned(16);
      temp.add(temp1);
    }

    shortFilter(temp, temp.length, (List<int> list, int size) {
      for (int i = 0; i < size; i++) {
        waveData.add(short2mv(list[i]));
      }
    });
  }
}
