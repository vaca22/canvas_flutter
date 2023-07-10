import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import '../ffi/plugin_filtering.dart';

class DuoEkFile {
  var filterWaveDataLength = 0;

  final int COM_MAX_VAL = 127;
  final int COM_MIN_VAL = -127;
  final int COM_EXTEND_MAX_VAL = 382;
  final int COM_EXTEND_MIN_VAL = -382;

  final int COM_RET_ORIGINAL = -128;
  final int COM_RET_POSITIVE = 127;
  final int COM_RET_NEGATIVE = -127;

  final int UNCOM_RET_INVALI = -32768;

  final Uint8List originalData;
  List<int> fileData = [];
  List<int> unCompressData = [];

  List<double> waveData = [];

  DuoEkFile({required this.originalData});

  int unCompressNum = 0;
  int lastCompressData = 0;
  var length = 0;

  void init() {
    filterWaveDataLength = 0;
    unCompressNum = 0;
    lastCompressData = 0;
    fileData = originalData.map((e) => e.toSigned(8)).toList();
    length = fileData.length - 30;
  }

  int unCompressAlgECG(int compressData) {
    int ecgData = 0;
    switch (unCompressNum) {
      case 0:
        if (compressData == COM_RET_ORIGINAL) {
          unCompressNum = 1;
          ecgData = UNCOM_RET_INVALI;
        } else if (compressData == COM_RET_POSITIVE) {
          unCompressNum = 3;
          ecgData = UNCOM_RET_INVALI;
        } else if (compressData == COM_RET_NEGATIVE) {
          unCompressNum = 4;
          ecgData = UNCOM_RET_INVALI;
        } else {
          ecgData = lastCompressData + compressData;
          lastCompressData = ecgData;
        }
        break;
      case 1:
        lastCompressData = compressData & 0xFF;
        unCompressNum = 2;
        ecgData = UNCOM_RET_INVALI;
        break;
      case 2:
        ecgData = lastCompressData + (compressData << 8);
        lastCompressData = ecgData;
        unCompressNum = 0;
        break;
      case 3:
        ecgData = COM_MAX_VAL + (lastCompressData + (compressData & 0xFF));
        lastCompressData = ecgData;
        unCompressNum = 0;
        break;
      case 4:
        ecgData = COM_MIN_VAL + (lastCompressData - (compressData & 0xFF));
        lastCompressData = ecgData;
        unCompressNum = 0;
        break;
      default:
        break;
    }
    return ecgData;
  }

  double short2mv(int s) {
    return (s * (1.0035 * 1800) / (4096 * 178.74));
  }

  void uncompress() {
    init();
    var endNullValueCount = 0;
    for (int i = 0; i < length - 30; i++) {
      int tmp = unCompressAlgECG(fileData[10 + i]);
      if (tmp != -32768 && filterWaveDataLength < length) {
        unCompressData.add(tmp);
        filterWaveDataLength++;
      }
    }

    for (int j = filterWaveDataLength - 1; j >= 0; j--) {
      if (unCompressData[j] == 32767) {
        endNullValueCount++;
      } else {
        break;
      }
    }
    filterWaveDataLength -= endNullValueCount;

    List<int> temp = [];
    for (int i = 0; i < filterWaveDataLength; i++) {
      temp.add(unCompressData[i]);
    }

    shortFilter(temp, temp.length, (List<int> list, int size) {
      for (int i = 0; i < size; i++) {
        waveData.add(short2mv(list[i]));
      }
    });
  }
}
