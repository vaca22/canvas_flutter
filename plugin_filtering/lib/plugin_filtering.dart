
import 'dart:async';
import 'dart:ffi' as ffi;
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'package:ffi/ffi.dart';
import 'plugin_filtering_bindings_generated.dart';


const String _libName = 'plugin_filtering';


final DynamicLibrary _dylib = () {
  if (Platform.isMacOS || Platform.isIOS) {
    return DynamicLibrary.open('$_libName.framework/$_libName');
  }
  if (Platform.isAndroid || Platform.isLinux) {
    return DynamicLibrary.open('lib$_libName.so');
  }
  if (Platform.isWindows) {
    return DynamicLibrary.open('$_libName.dll');
  }
  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();

/// The bindings to the native functions in [_dylib].
final PluginFilteringBindings _bindings = PluginFilteringBindings(_dylib);

int initializeApiDL() =>
    _bindings.ffi_Dart_InitializeApiDL(NativeApi.initializeApiDLData);


void shortFilter(
  List<int> shortArray,
  int arraySize,
    var callback,

) {
  ffi.Pointer<ffi.Short> _arrayChem =  calloc<ffi.Short>(shortArray.length);
  for (int i = 0; i < shortArray.length; i++) {
    _arrayChem[i] = shortArray[i];
  }
  final filter_result_port  = ReceivePort()
    ..listen((message) {
      callback(message);
    });
  return _bindings.shortfilter(
    _arrayChem,
    arraySize,
    filter_result_port.sendPort.nativePort,
  );
}