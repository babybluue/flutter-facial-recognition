import 'package:camera/camera.dart';
import 'package:camera_demo/locator.dart';
import 'package:camera_demo/services/camera_service.dart';
import 'package:camera_demo/services/face_detector_service.dart';
import 'package:camera_demo/services/ml_service.dart';
import 'package:camera_demo/widgets/camera_view.dart';
import 'package:flutter/material.dart';

class FaceCheckPage extends StatefulWidget {
  const FaceCheckPage({super.key});

  @override
  State<FaceCheckPage> createState() => _FaceCheckPageState();
}

class _FaceCheckPageState extends State<FaceCheckPage> {
  bool _initializing = false;
  bool _isBusy = false;

  String? _text;

  final FaceDetectorService _faceDetectorService =
      locator<FaceDetectorService>();

  final MLService _mlService = locator<MLService>();

  final CameraService _cameraService = locator<CameraService>();

  @override
  void initState() {
    _start();
    super.initState();
  }

  @override
  void dispose() {
    _cameraService.dispose();
    _faceDetectorService.dispose();
    super.dispose();
  }

  _start() async {
    setState(() => _initializing = true);
    await _cameraService.initialize();
    _faceDetectorService.initialize();
    setState(() => _initializing = false);
    _detectFace();
  }

  _detectFace() {
    _cameraService.cameraController
        ?.startImageStream((CameraImage image) async {
      if (_cameraService.cameraController == null) return;
      if (_isBusy) return;
      _isBusy = true;
      await _cameraService.processImage(image);

      await _faceDetectorService.detectFace(_cameraService.inputImage!);

      if (_faceDetectorService.isFaceDetected) {
        final faces = _faceDetectorService.faces;

        await _mlService.predict(image, faces[0]);
        _text = _mlService.person;
        if (mounted) {
          setState(() {});
        }
        _isBusy = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _initializing
        ? const Center(child: CircularProgressIndicator())
        : CameraView(text: _text);
  }
}
