import 'package:camera_demo/locator.dart';
import 'package:camera_demo/pages/face_check.dart';
import 'package:camera_demo/pages/sign_in.dart';
import 'package:camera_demo/services/face_detector_service.dart';
import 'package:camera_demo/services/ml_service.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _loading = false;

  final MLService _mlService = locator<MLService>();
  final FaceDetectorService _faceDetectorService =
      locator<FaceDetectorService>();

  @override
  void initState() {
    super.initState();
    _initializing();
  }

  _initializing() async {
    setState(() {
      _loading = true;
    });
    _faceDetectorService.initialize();
    await _mlService.initialize();

    setState(() {
      _loading = false;
    });
  }

  Widget _body() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(vertical: 100.0, horizontal: 0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const FaceCheckPage()));
            },
            icon: const Icon(
              Icons.camera_alt,
              size: 60.0,
            ),
          ),
          IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const SignInPage()));
              },
              icon: const Icon(Icons.face, size: 60.0))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FaceRecognition'),
      ),
      body:
          _loading ? const Center(child: CircularProgressIndicator()) : _body(),
    );
  }
}
