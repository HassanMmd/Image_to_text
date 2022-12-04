import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

class ScreenView extends StatefulWidget {
  const ScreenView({Key? key}) : super(key: key);

  @override
  State<ScreenView> createState() => _ScreenViewState();
}

class _ScreenViewState extends State<ScreenView> {
  List<TextElement> elements = [];
  XFile? imageFile;
  bool textScanning = false;
  String scannedText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ScanImage'),
        actions: [
          TextButton.icon(
              onPressed: () {
                elements.clear();
                getImage(ImageSource.gallery);
              },
              icon: const Icon(
                Icons.image,
                color: Colors.white,
              ),
              label: const Text(
                'Gallery',
                style: TextStyle(
                  color: Colors.white,
                ),
              )),
          TextButton.icon(
              onPressed: () {
                elements.clear();
                getImage(ImageSource.camera);
              },
              icon: const Icon(
                Icons.camera,
                color: Colors.white,
              ),
              label: const Text(
                'Camera',
                style: TextStyle(
                  color: Colors.white,
                ),
              )),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (imageFile == null && textScanning == false)
              Center(
                child: Container(
                  color: Colors.grey,
                  width: 400,
                  height: 400,
                ),
              ),
            if (imageFile != null)
              Image.file(
                File(imageFile!.path),
              ),
            const SizedBox(
              height: 20.0,
            ),
            Text(scannedText,
            style: const TextStyle(
              backgroundColor: Colors.grey,
            ),),
          ],
        ),
      ),
    );
  }

  void getImage(ImageSource source) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage != null) {
        // imageFile = pickedImage;
        // var path = imageFile!.path;
        setState(() {
          imageFile = pickedImage;
          var path = imageFile!.path;
        });
        getRecognisedText(pickedImage);

        textScanning = true;
      }
    } catch (e) {
      imageFile = null;
      textScanning = false;
      setState(() {});
      scannedText = 'error loading image';
    }
  }

  void getRecognisedText(XFile image) async {
    final inputImage = InputImage.fromFilePath(image.path);
    final textDetector = GoogleMlKit.vision.textRecognizer();
    RecognizedText recognizedText = await textDetector.processImage(inputImage);
    await textDetector.close();
    scannedText = '';

    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        for (TextElement element in line.elements) {
          elements.add(element);
        }
      }
    }
    setState(() {
      scannedText = elements
          .map((e) => e.text)
          .reduce((value, element) => "$value $element");
      ;
    });
  }
}
