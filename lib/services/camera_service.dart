import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class CameraService {
  CameraController? _cameraController;
  CameraController? get cameraController => _cameraController;

  InputImage? _inputImage;
  InputImage? get inputImage => _inputImage;

  bool isBusy = false;

  late CameraDescription _camera;

  Future<void> initialize() async {
    if (cameraController != null) return;
    _camera = await _getCameraDescription();
    await _setupCameraController();
  }

  Future<CameraDescription> _getCameraDescription() async {
    List<CameraDescription> cameras = await availableCameras();
    return cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front);
  }

  Future _setupCameraController() async {
    _cameraController = CameraController(
      _camera,
      ResolutionPreset.max,
      enableAudio: false,
    );

    await _cameraController?.initialize();
  }

  Future processImage(CameraImage image) async {
    final WriteBuffer allBytes = WriteBuffer();

    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }

    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize =
        Size(image.width.toDouble(), image.height.toDouble());

    final imageRotation =
        InputImageRotationValue.fromRawValue(_camera.sensorOrientation);
    if (imageRotation == null) return;

    final inputImageFormat =
        InputImageFormatValue.fromRawValue(image.format.raw);
    if (inputImageFormat == null) return;

    final planeData = image.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();
    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );

    _inputImage =
        InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);
  }

  dispose() async {
    await _cameraController?.dispose();
    _cameraController = null;
  }
}
