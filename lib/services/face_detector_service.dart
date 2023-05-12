import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectorService {
  late FaceDetector _faceDetector;
  FaceDetector get faceDetector => _faceDetector;

  List<Face> _faces = [];

  List<Face> get faces => _faces;

  bool get isFaceDetected => _faces.isNotEmpty;

  bool _isBusy = false;
  bool _isDispose = false;

  void initialize() {
    _faceDetector = FaceDetector(
        options: FaceDetectorOptions(
      enableContours: true,
    ));
  }

  Future<void> detectFace(InputImage inputImage) async {
    if (_isDispose) return;
    if (_isBusy) return;
    _isBusy = true;
    _faces = await _faceDetector.processImage(inputImage);
    _isBusy = false;
  }

  dispose() {
    _isDispose = true;
    _faceDetector.close();
  }
}
