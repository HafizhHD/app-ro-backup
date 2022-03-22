import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ruangkeluarga/global/custom_widget/global_widget.dart';
import 'package:ruangkeluarga/global/global.dart';

final picker = ImagePicker();

Future<File?> openCamOrDirDialog() async {
  final File? img = await Get.dialog<File>(AlertDialog(
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextButton(
            onPressed: () async {
              showLoadingOverlay();
              final _getImg = await getImageCamera();
              closeOverlay();
              if (_getImg != null)
                Get.back(
                    result: await ImageCropper()
                        .cropImage(sourcePath: _getImg.path));
              else
                Get.back();
            },
            child: Row(
              children: [
                Icon(Icons.add_a_photo_outlined),
                SizedBox(width: 10),
                Flexible(child: Text('Ambil Foto', textAlign: TextAlign.left)),
              ],
            )),
        TextButton(
            onPressed: () async {
              final _getImg = await getImageStorage();
              if (_getImg != null)
                Get.back(
                    result: await ImageCropper()
                        .cropImage(sourcePath: _getImg.path));
              else
                Get.back();
            },
            child: Row(
              children: [
                Icon(Icons.add_photo_alternate_outlined),
                SizedBox(width: 10),
                Text('Pilih Gambar', textAlign: TextAlign.left),
              ],
            )),
      ],
    ),
  ));

  return img;
}

Future<File?> getImageCamera() async {
  var camera = await Permission.camera.status;
  if (!camera.isGranted) {
    await Permission.camera.request();
  }
  final pickedFile =
      await picker.pickImage(source: ImageSource.camera, imageQuality: 50);
  if (pickedFile != null) {
    final rawFile = File(pickedFile.path);
    // final rawFileSize = rawFile.readAsBytesSync();
    // print('RAW FILE SIZE ${rawFileSize.length}');
    // if (rawFileSize.length > 1024 * 1024) {
    //   Directory tempDir = await getTemporaryDirectory();
    //   final targetPath = '${tempDir.path}/temp.jpg';
    //   final targetFile = File(targetPath);
    //   targetFile.deleteSync();
    //
    //   final compressed = await FlutterImageCompress.compressAndGetFile(
    //     rawFile.path,
    //     targetPath,
    //     quality: 50,
    //   );
    //
    //   print('COMPRESSED FILE SIZE ${compressed.readAsBytesSync().length}');
    //   print(compressed.path);
    //
    //   return compressed;
    // }

    return rawFile;
  }
  print('No image taken.');
  return null;
}

Future<File?> getImageStorage() async {
  var storage = await Permission.storage.status;
  if (!storage.isGranted) {
    await Permission.storage.request();
  }
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  if (pickedFile != null) return File(pickedFile.path);
  print('No image selected.');
  return null;
}
