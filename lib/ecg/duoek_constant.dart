class DuoEkGlobal {
  //   1 cm = 38 logical pixels
  static const pixelsPerMillimeter = 5.75;

  //run speed 12.5mm/s
  static const speed = 12.5;

  //  1 mv = 10 mm
  static const mmPerMillivolt = 10.0;

  static const pixelsPerMillivolt = mmPerMillivolt * pixelsPerMillimeter;
  static const sampleRate = 125;
  static const rangeHeightSpan = 3;
  static var rangeWidthSpan = 5;

  static void init() {
     eachLineTime = rangeWidthSpan*pixelsPerMillivolt/pixelsPerMillimeter/speed;
     lineSize = (eachLineTime * sampleRate).toInt();
  }

  static var eachLineTime = rangeWidthSpan*pixelsPerMillivolt/pixelsPerMillimeter/speed;
  static var lineSize = (eachLineTime * sampleRate).toInt();
}
