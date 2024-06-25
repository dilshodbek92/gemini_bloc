import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Utils {
  static Future<String> pickAndConvertImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      return ""; // Handle user canceling image selection
    }

    final imageFile = File(pickedFile.path);
    final imageBytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(imageBytes);

    return base64Image;
  }

  static Future<bool> dialogCommon(BuildContext context, String title,
      String message, bool isSingle, Function() onPressed) async {
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              !isSingle
                  ? MaterialButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      child: const Text("Cancel"),
                    )
                  : const SizedBox.shrink(),
              MaterialButton(
                onPressed: () {
                  onPressed();
                },
                child: const Text("Confirm"),
              ),
            ],
          );
        });
  }
}
