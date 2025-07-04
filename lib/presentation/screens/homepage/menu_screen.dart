import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TestPicker extends StatelessWidget {
  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Image Picker Test')),
      body: Center(
        child: ElevatedButton(
          child: Text('Pick Image'),
          onPressed: () async {
            try {
              final XFile? image = await picker.pickImage(source: ImageSource.gallery);
              if (image != null) {
                print('Image path: ${image.path}');
              } else {
                print('No image selected.');
              }
            } catch (e) {
              print('Error picking image: $e');
            }
          },
        ),
      ),
    );
  }
}
