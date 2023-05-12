import 'package:camera/camera.dart';
import 'package:camera_demo/locator.dart';
import 'package:camera_demo/services/camera_service.dart';
import 'package:camera_demo/services/face_detector_service.dart';
import 'package:camera_demo/services/face_vector_service.dart';
import 'package:camera_demo/services/ml_service.dart';
import 'package:camera_demo/utils/face_detector_painter.dart';
import 'package:camera_demo/widgets/camera_view.dart';
import 'package:flutter/material.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool _initializing = false;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  final TextEditingController _nameController = TextEditingController();

  final FaceDetectorService _faceDetectorService =
      locator<FaceDetectorService>();

  final MLService _mlService = locator<MLService>();

  final CameraService _cameraService = locator<CameraService>();

  final FaceVectorService _faceVectorService = locator<FaceVectorService>();

  @override
  void initState() {
    _start();
    super.initState();
  }

  @override
  void dispose() {
    _end();
    super.dispose();
  }

  _start() async {
    setState(() => _initializing = true);
    await _cameraService.initialize();
    setState(() => _initializing = false);
    _detectFace();
  }

  _end() {
    _cameraService.dispose();
  }

  _detectFace() {
    var startTime = DateTime.now().microsecondsSinceEpoch;
    _cameraService.cameraController
        ?.startImageStream((CameraImage image) async {
      final endTime = DateTime.now().microsecondsSinceEpoch;
      if (_cameraService.cameraController == null) return;
      if (_isBusy) return;
      _isBusy = true;
      await _cameraService.processImage(image);

      await _faceDetectorService.detectFace(_cameraService.inputImage!);

      if (_faceDetectorService.isFaceDetected) {
        final faces = _faceDetectorService.faces;
        final inputImage = _cameraService.inputImage;
        final painter = FaceDetectorPainter(
            faces,
            inputImage!.inputImageData!.size,
            inputImage.inputImageData!.imageRotation);
        _customPaint = CustomPaint(painter: painter);
        if (endTime - startTime > 10000) {
          await _mlService.predict(image, faces[0]);
          startTime = DateTime.now().microsecondsSinceEpoch;
        }
      } else {
        _customPaint = null;
      }
      if (mounted) {
        setState(() {});
      }
      _isBusy = false;
    });
  }

  Future<void> _showDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TextField(
                    decoration: const InputDecoration(labelText: '姓名'),
                    autofocus: true,
                    controller: _nameController,
                  )),
              Row(
                children: [
                  TextButton(
                    onPressed: () => _saveUser(context),
                    child: const Text('确定'),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  _saveUser(BuildContext context) {
    final name = _nameController.text;
    final predictArray = _mlService.predictArray;
    final user = {'name': name, 'predictArray': predictArray};
    _faceVectorService.addFaceVector(user);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return _initializing
        ? const Center(child: CircularProgressIndicator())
        : Stack(
            children: [
              CameraView(
                customPaint: _customPaint,
                text: null,
              ),
              Positioned(
                bottom: 0,
                width: MediaQuery.of(context).size.width,
                child: Center(
                  heightFactor: 2.0,
                  child: TextButton(
                      onPressed: () => _showDialog(context),
                      child: const Text(
                        'register',
                        style: TextStyle(fontSize: 20),
                      )),
                ),
              )
            ],
          );
  }
}
