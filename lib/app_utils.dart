/// 使用 File api
/// 使用 Uint8List 数据类型
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
      final result =
          await ImageGallerySaver.saveImage(imageBytes, quality: 100);
      if (result == null || result == '') throw '图片保存失败';
      print("保存成功");
      Fluttertoast.showToast(
          msg: "ecg image saved to gallery",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } catch (e) {
      print(e.toString());
    }
  }
}
