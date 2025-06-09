import 'package:image_picker/image_picker.dart';

pickImage(ImageSource source) async {
  final ImagePicker _imagePicker = ImagePicker();
   XFile? _file = await _imagePicker.pickImage(source: source);
  try {
    if (_file != null) {
      return await _file.readAsBytes();
    }
  } catch (e) {
    print("Error picking image: $e");
  }
  
}