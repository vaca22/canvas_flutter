import 'dart:ffi' as ffi;
import 'dart:ffi';
import 'dart:io';

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

Function? filter_callback;

void callback(Pointer<ffi.Short> message, int size) {
  List<int> list = [];
  for (int i = 0; i < size; i++) {
    list.add(message[i].toInt());
  }
  if (filter_callback != null) {
    filter_callback!(list, size);
  }
}

void shortFilter(
  List<int> shortArray,
  int arraySize,
  Function myCallback,
) {
  filter_callback = myCallback;
  ffi.Pointer<ffi.Short> _arrayChem = calloc<ffi.Short>(shortArray.length);
  for (int i = 0; i < shortArray.length; i++) {
    _arrayChem[i] = shortArray[i];
  }

  return _bindings.shortfilter(
    _arrayChem,
    arraySize,
    Pointer.fromFunction(callback),
  );
}
