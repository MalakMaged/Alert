import 'package:flutter/material.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:image/image.dart' as img;

class WeaponDetectionPage extends StatefulWidget {
  const WeaponDetectionPage({Key? key}) : super(key: key);

  @override
  State<WeaponDetectionPage> createState() => _YoloImageState();
}

class _YoloImageState extends State<WeaponDetectionPage> {
  late FlutterVision vision;
  List<Map<String, dynamic>> yoloResults = [];  // Initialize yoloResults as an empty list
  bool isLoaded = false;
  File? _image;
  final ImagePicker _picker = ImagePicker();
  int? imageWidth;
  int? imageHeight;

  @override
  void initState() {
    super.initState();
    vision = FlutterVision();
    loadYoloModel();
  }

  @override
  void dispose() {
    vision.closeYoloModel();
    super.dispose();
  }

  Future<void> loadYoloModel() async {
    await vision.loadYoloModel(
        labels: 'assets/labels.txt',
        modelPath: 'assets/best-fp16.tflite',
        modelVersion: "yolov5",
        numThreads: 8,
        useGpu: false);
    setState(() {
      isLoaded = true;
    });
  }

  Future<void> getImage() async {
    final pickedFile = await _picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final image = File(pickedFile.path);
      final decodedImage = img.decodeImage(await image.readAsBytes());

      if (decodedImage != null) {
        setState(() {
          _image = image;
          imageWidth = decodedImage.width;
          imageHeight = decodedImage.height;
        });
        yoloOnImage(image, imageWidth!, imageHeight!);
      }
    }
  }

  Future<void> yoloOnImage(File image, int width, int height) async {
    final bytes = await image.readAsBytes();
    final result = await vision.yoloOnImage(
        bytesList: bytes,
        imageHeight: height,
        imageWidth: width,
        iouThreshold: 0.4,
        confThreshold: 0.4,
        classThreshold: 0.5);
    setState(() {
      yoloResults = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("YOLO Image Detection"),
      ),
      body: Column(
        children: [
          if (_image != null)
            Stack(
              children: [
                Image.file(_image!, fit: BoxFit.contain),
                ...displayBoxesAroundRecognizedObjects(size),
              ],
            ),
          if (_image == null)
            Center(
              child: TextButton(
                onPressed: getImage,
                child: const Text("Select Image"),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> displayBoxesAroundRecognizedObjects(Size screen) {
    if (yoloResults.isEmpty || _image == null) return [];
    double factorX = screen.width / (imageWidth ?? 1);
    double factorY = screen.height / (imageHeight ?? 1);

    Color colorPick = const Color.fromARGB(255, 50, 233, 30);

    return yoloResults.map((result) {
      return Positioned(
        left: result["box"][0] * factorX,
        top: result["box"][1] * factorY,
        width: (result["box"][2] - result["box"][0]) * factorX,
        height: (result["box"][3] - result["box"][1]) * factorY,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            border: Border.all(color: Colors.pink, width: 2.0),
          ),
          child: Text(
            "${result['tag']} ${(result['box'][4] * 100).toStringAsFixed(0)}%",
            style: TextStyle(
              background: Paint()..color = colorPick,
              color: Colors.white,
              fontSize: 18.0,
            ),
          ),
        ),
      );
    }).toList();
  }
}
