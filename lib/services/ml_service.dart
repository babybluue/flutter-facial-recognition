import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:camera_demo/locator.dart';
import 'package:camera_demo/services/face_vector_service.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as image_lib;

import '../utils/image_converter.dart';

class MLService {
  late Interpreter interpreter;
  List? predictArray;
  double threshold = 0.5;
  dynamic person;

  final FaceVectorService _faceVectorService = locator<FaceVectorService>();

  Future initialize() async {
    await initializeInterpreter();
  }

  void dispose() {
    interpreter.close();
  }

  Future predict(CameraImage cameraImage, Face face) async {
    List input = _preProcess(cameraImage, face);

    input = input.reshape([1, 112, 112, 3]);

    List output = List.generate(1, (index) => List.filled(192, 0));

    interpreter.run(input, output);

    output = output.reshape([192]);

    predictArray = List.from(output);

    final result = await _searchResult();

    person = result;
  }

  Future initializeInterpreter() async {
    try {
      interpreter = await Interpreter.fromAsset('mobilefacenet.tflite');
    } catch (e) {
      print('Failed to load model.');
      print(e);
    }
  }

  Future _searchResult() async {
    double minDist = 999;
    double currDist = 0.0;
    var result;

    if (_faceVectorService.predictArrays.isEmpty) {
      return '';
    }
    for (var item in _faceVectorService.predictArrays) {
      currDist = _euclideanDistance(item['predictArray'], predictArray);
      if (currDist <= threshold && currDist < minDist) {
        minDist = currDist;
        result = item['name'];
      }
    }
    return result;
  }

  double _euclideanDistance(List? e1, List? e2) {
    if (e1 == null || e2 == null) throw Exception("Null argument");

    double sum = 0.0;
    for (int i = 0; i < e1.length; i++) {
      sum += pow((e1[i] - e2[i]), 2);
    }
    return sqrt(sum);
  }

  List _preProcess(CameraImage image, Face faceDetected) {
    image_lib.Image croppedImage = _cropFace(image, faceDetected);
    image_lib.Image img =
        image_lib.copyResizeCropSquare(croppedImage, size: 112);

    Float32List imageAsList = _imageToByteListFloat32(img);
    return imageAsList;
  }

  image_lib.Image _cropFace(CameraImage image, Face faceDetected) {
    image_lib.Image convertedImage = _convertCameraImage(image);
    double x = faceDetected.boundingBox.left - 10.0;
    double y = faceDetected.boundingBox.top - 10.0;
    double w = faceDetected.boundingBox.width + 10.0;
    double h = faceDetected.boundingBox.height + 10.0;
    return image_lib.copyCrop(convertedImage,
        x: x.round(), y: y.round(), width: w.round(), height: h.round());
  }

  image_lib.Image _convertCameraImage(CameraImage image) {
    var img = convertToImage(image);
    var img1 = image_lib.copyRotate(img!, angle: -90);
    return img1;
  }

  Float32List _imageToByteListFloat32(image_lib.Image image) {
    var convertedBytes = Float32List(1 * 112 * 112 * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (var i = 0; i < 112; i++) {
      for (var j = 0; j < 112; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = (pixel.r - 128) / 128;
        buffer[pixelIndex++] = (pixel.g - 128) / 128;
        buffer[pixelIndex++] = (pixel.b - 128) / 128;
      }
    }
    return convertedBytes.buffer.asFloat32List();
  }
}
