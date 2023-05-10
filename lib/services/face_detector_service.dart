import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectorService {
  late FaceDetector _faceDetector;
  FaceDetector get faceDetector => _faceDetector;

  List<Face> _faces = [];

  List<Face> get faces => _faces;

  bool get isFaceDetected => _faces.isNotEmpty;

  bool _isBusy = false;

  void initialize() {
    _faceDetector = FaceDetector(
        options: FaceDetectorOptions(
      enableContours: true,
    ));
  }

  Future<void> detectFace(InputImage inputImage) async {
    if (_isBusy) return;
    _isBusy = true;
    _faces = await _faceDetector.processImage(inputImage);
    _isBusy = false;
  }

  void dispose() {
    _faceDetector.close();
  }
}
