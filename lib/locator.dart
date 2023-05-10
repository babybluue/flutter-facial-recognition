import 'package:camera_demo/services/camera_service.dart';
import 'package:camera_demo/services/face_detector_service.dart';
import 'package:camera_demo/services/face_vector_service.dart';
import 'package:camera_demo/services/ml_service.dart';
import 'package:get_it/get_it.dart';

final locator = GetIt.instance;

void setupService() {
  locator.registerLazySingleton<CameraService>(() => CameraService());

  locator.registerLazySingleton<MLService>(() => MLService());

  locator
      .registerLazySingleton<FaceDetectorService>(() => FaceDetectorService());

  locator.registerLazySingleton<FaceVectorService>(() => FaceVectorService());
}
