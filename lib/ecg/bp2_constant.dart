class Bp2Global {
  static const pixelsPerMillivolt = 70.0;
  static const sampleRate = 125;

//each line Time consumed  (second)
  static const eachLineTime = 10;

//  1 mv  Corresponding grid
  static const rangeHeightSpan = 2;
  static var rangeWidthSpan = 5;
  static const lineSize = eachLineTime * sampleRate;
}
