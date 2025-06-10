import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

Future<File?> pickImageFile(ImageSource source) async {
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _file = await _imagePicker.pickImage(source: source);
  if (_file != null) {
    return File(_file.path);
  }
  return null;
}

Future<Uint8List?> pickImageBytes(ImageSource source) async {
  final ImagePicker _imagePicker = ImagePicker();
  XFile? file = await _imagePicker.pickImage(source: source);
  if (file != null) {
    return await File(file.path).readAsBytes();
  }
  return null;
}