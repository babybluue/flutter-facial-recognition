import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectorService {
  late FaceDetector _faceDetector;
  FaceDetector get faceDetector => _faceDetector;

  List<Face> _faces = [];

  List<Face> get faces => _faces;

  bool get isFaceDetected => _faces.isNotEmpty;

  void initialize() {
    _faceDetector = FaceDetector(
        options: FaceDetectorOptions(
      enableContours: true,
    ));
  }

  Future<void> detectFace(InputImage inputImage) async {
    _faces = await _faceDetector.processImage(inputImage);
  }

  void dispose() {
    _faceDetector.close();
  }
}
