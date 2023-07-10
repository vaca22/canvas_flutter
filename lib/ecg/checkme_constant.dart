class CheckmeGlobal {
  static const pixelsPerMillivolt = 70.0;
  static const sampleRate = 500;

//each line Time consumed  (second)
  static const eachLineTime = 4;

//  1 mv  Corresponding grid
  static const rangeHeightSpan = 1;
  static var rangeWidthSpan = 5;
  static const lineSize = eachLineTime * sampleRate;
}
