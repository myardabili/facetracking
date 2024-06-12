// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:facetracking/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import 'package:facetracking/core/ml/recognition_embedding.dart';

class Recognizer {
  late Interpreter interpreter;
  late InterpreterOptions _interpreterOptions;
  static const int WIDHT = 112;
  static const int HEIGHT = 112;

  String get modelName => 'assets/mobile_face_net.tflite';

  Future<void> loadModel() async {
    try {
      interpreter = await Interpreter.fromAsset(modelName);
    } catch (e) {
      print('Unable to create interpreter, Caught Exception: ${e.toString()}');
    }
  }

  Recognizer({int? numThreads}) {
    _interpreterOptions = InterpreterOptions();

    if (numThreads != null) {
      _interpreterOptions.threads = numThreads;
    }
    loadModel();
  }

  List<dynamic> imageToArray(img.Image inputImage) {
    img.Image resizedImage =
        img.copyResize(inputImage, width: WIDHT, height: HEIGHT);
    List<double> flattenedList = resizedImage.data!
        .expand((channel) => [channel.r, channel.g, channel.b])
        .map((value) => value.toDouble())
        .toList();
    Float32List float32Array = Float32List.fromList(flattenedList);
    int channels = 3;
    int height = HEIGHT;
    int widht = WIDHT;
    Float32List reshapedArray = Float32List(1 * height * widht * channels);
    for (int c = 0; c < channels; c++) {
      for (int h = 0; h < height; h++) {
        for (int w = 0; w < widht; w++) {
          int index = c * height * widht + h * widht + w;
          reshapedArray[index] =
              (float32Array[c * height * widht + h * widht + w] - 127.5) /
                  127.5;
        }
      }
    }
    return reshapedArray.reshape([1, 112, 112, 3]);
  }

  RecognitionEmbedding recognize(img.Image image, Rect location) {
    //crop face from image resize it and convert it to float array
    var input = imageToArray(image);
    print(input.shape.toString());

    //output array
    List output = List.filled(1 * 192, 0).reshape([1, 192]);

    //performs interface
    final runs = DateTime.now().millisecondsSinceEpoch;
    interpreter.run(input, output);
    final run = DateTime.now().microsecondsSinceEpoch - runs;
    print('Time to run interface: $run ms$output');

    //convert dynamic list to double list
    List<double> outputArray = output.first.cast<double>();

    return RecognitionEmbedding(location: location, embedding: outputArray);
  }

  PairEmbedding findNearest(List<double> emb, List<double> authFaceEmbedding) {
    PairEmbedding pair = PairEmbedding(distance: -5);

    double distance = 0;
    for (int i = 0; i < emb.length; i++) {
      double diff = emb[i] - authFaceEmbedding[i];
      distance += diff * diff;
    }
    distance = sqrt(distance);
    if (pair.distance == -5 || distance < pair.distance) {
      pair.distance = distance;
    }
    return pair;
  }

  Future<bool> isValidFace(List<double> emb) async {
    final authData = await AuthLocalDatasource().getAuthData();
    final faceEmbedding = authData!.user!.faceEmbedding;
    PairEmbedding pair = findNearest(
        emb,
        faceEmbedding!
            .split(',')
            .map((e) => double.parse(e))
            .toList()
            .cast<double>());
    print('distance = ${pair.distance}');
    if (pair.distance < 1.0) {
      return true;
    }
    return false;
  }
}

class PairEmbedding {
  double distance;
  PairEmbedding({
    required this.distance,
  });
}
