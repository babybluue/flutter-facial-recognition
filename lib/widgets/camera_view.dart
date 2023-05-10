import 'package:camera/camera.dart';
import 'package:camera_demo/locator.dart';
import 'package:camera_demo/services/camera_service.dart';
import 'package:camera_demo/services/face_detector_service.dart';
import 'package:camera_demo/utils/face_detector_painter.dart';
import 'package:flutter/material.dart';

class CameraView extends StatefulWidget {
  const CameraView({required this.text, super.key});

  final String? text;

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  final CameraService _cameraService = locator<CameraService>();

  final FaceDetectorService _faceDetectorService =
      locator<FaceDetectorService>();

  @override
  Widget build(BuildContext context) {
    CustomPaint? customPaint;
    final controller = _cameraService.cameraController!;
    if (!controller.value.isInitialized) {
      return Container();
    }
    if (_faceDetectorService.isFaceDetected) {
      final inputImage = _cameraService.inputImage;
      final faces = _faceDetectorService.faces;
      final painter = FaceDetectorPainter(
          faces,
          inputImage!.inputImageData!.size,
          inputImage.inputImageData!.imageRotation);

      customPaint = CustomPaint(painter: painter);
    }

    final size = MediaQuery.of(context).size;

    var scale = size.aspectRatio * controller.value.aspectRatio;

    if (scale < 1) scale = 1 / scale;
    if (mounted) {
      setState(() {});
    }
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Transform.scale(
            scale: scale,
            child: Center(
              child: CameraPreview(controller),
            ),
          ),
          if (customPaint != null) customPaint,
          if (widget.text != null)
            Positioned(
              top: 50,
              width: size.width,
              child: Center(
                child: Text("${widget.text}"),
              ),
            ),
        ],
      ),
    );
  }
}
