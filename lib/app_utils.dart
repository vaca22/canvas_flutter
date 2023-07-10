/// 使用 File api
import 'dart:io';
/// 使用 Uint8List 数据类型
import 'dart:typed_data';


import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';


class AppUtil {
  static Future<void> saveImage(Uint8List imageBytes) async {
    try {
      PermissionStatus storageStatus = await Permission.storage.status;
      if (storageStatus != PermissionStatus.granted) {
        storageStatus = await Permission.storage.request();
        if (storageStatus != PermissionStatus.granted) {
          throw '无法存储图片，请先授权！';
        }
      }
      final result = await ImageGallerySaver.saveImage(imageBytes);
      if (result == null || result == '') throw '图片保存失败';
      print("保存成功");
    } catch (e) {
      print(e.toString());
    }
  }
}