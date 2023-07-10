#ECG drawing program, including four devices, where checkmeList and checkmePro are the same


The filter function currently only supports the android system



The drawing parameters of the electrocardiogram are in the duoek_constant.dart, checkme_constant.dart, and bp2_constant.dart files respectively



```dart
  static const pixelsPerMillivolt = 70.0;
  static const sampleRate = 125;

//each line Time consumed  (second)
  static const eachLineTime = 4;

//  1 mv  Corresponding grid
  static const rangeHeightSpan = 3;
  static const rangeWidthSpan = 5;
  static const lineSize = eachLineTime * sampleRate;

```