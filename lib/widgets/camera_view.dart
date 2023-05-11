import 'package:camera/camera.dart';
import 'package:camera_demo/locator.dart';
import 'package:camera_demo/services/camera_service.dart';
import 'package:camera_demo/services/face_detector_service.dart';
import 'package:flutter/material.dart';

class CameraView extends StatefulWidget {
  CameraView({required this.customPaint, required this.text, super.key});

  CustomPaint? customPaint;

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
    final controller = _cameraService.cameraController!;
    if (!controller.value.isInitialized) {
      return Container();
    }

    final size = MediaQuery.of(context).size;

    var scale = size.aspectRatio * controller.value.aspectRatio;

    if (scale < 1) scale = 1 / scale;

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
          if (widget.customPaint != null) widget.customPaint!,
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
