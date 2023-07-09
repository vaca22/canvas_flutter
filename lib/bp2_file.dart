import 'dart:typed_data';

import 'package:flutter/foundation.dart';


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
    for(int i=0;i<dataLength;i+=2){
      int temp1=((originalData[dataPos+i]) + (originalData[dataPos+i+1] << 8)).toSigned(16);
      waveData.add(0.003098*temp1);
    }
  }


}
