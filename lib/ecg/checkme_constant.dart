class CheckmeGlobal {
  //   1 cm = 38 logical pixels
  static const pixelsPerMillimeter = 3.8;

  //run speed 12.5mm/s
  static const speed = 12.5;

  //  1 mv = 10 mm
  static const mmPerMillivolt = 10.0;

  static const pixelsPerMillivolt = 70.0;
  static const sampleRate = 500;

//each line Time consumed  (second)
  static var eachLineTime =
      rangeWidthSpan * pixelsPerMillivolt / pixelsPerMillimeter / speed;

//  1 mv  Corresponding grid
  static const rangeHeightSpan = 2;
  static var rangeWidthSpan = 5;
  static var lineSize = (eachLineTime * sampleRate).toInt();
  static void init() {
    eachLineTime =
        rangeWidthSpan * pixelsPerMillivolt / pixelsPerMillimeter / speed;
    lineSize = (eachLineTime * sampleRate).toInt();
  }
}
