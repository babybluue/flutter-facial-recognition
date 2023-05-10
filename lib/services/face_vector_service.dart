class FaceVectorService {
  final List<Map<dynamic, dynamic>> _predictArrays = [];

  List get predictArrays => _predictArrays;

  void addFaceVector(vector) {
    _predictArrays.add(vector);
  }
}
