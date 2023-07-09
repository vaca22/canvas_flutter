import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:plugin_filtering/plugin_filtering.dart' as cam;

class Bp2File {


  final Uint8List originalData;
   List<double> waveData=[];

  Bp2File({required this.originalData});


  var length = 0;






  double short2mv(int s) {
    return (s * 4033 / (32767*12*8));
  }

  void uncompress() {
    print(originalData.length);
    int dataPos=48 ;
    var dataLength=originalData.length-48;
    print(originalData.length);
    List<int> temp = [];
    for(int i=0;i<dataLength;i+=2){
      int temp1=((originalData[dataPos+i]) + (originalData[dataPos+i+1] << 8)).toSigned(16);
      temp.add(temp1);
      // waveData.add(0.003098*temp1);
    }

    cam.shortFilter(temp,temp.length, (List<int> list, int size) {
      for(int i=0;i<size;i++){
        waveData.add(short2mv(list[i]));
      }
    });


  }


}
