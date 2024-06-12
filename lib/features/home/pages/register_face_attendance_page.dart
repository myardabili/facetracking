import 'package:camera/camera.dart';
import 'package:facetracking/core/assets/assets.gen.dart';
import 'package:facetracking/core/components/cicle_loading.dart';
import 'package:facetracking/core/components/components.dart';
import 'package:facetracking/core/constants/colors.dart';
import 'package:facetracking/core/ml/recognizer.dart';
import 'package:facetracking/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;

import '../../../core/ml/recognition_embedding.dart';
import '../widgets/face_detector_painter.dart';

class RegisterFaceAttendancePage extends StatefulWidget {
  const RegisterFaceAttendancePage({super.key});

  @override
  State<RegisterFaceAttendancePage> createState() =>
      _RegisterFaceAttendancePageState();
}

class _RegisterFaceAttendancePageState
    extends State<RegisterFaceAttendancePage> {
  List<CameraDescription>? _availableCameras;
  late CameraDescription description = _availableCameras![1];
  CameraController? _controller;
  CameraLensDirection camDirec = CameraLensDirection.front;

  late Size size;

  bool register = false;

  late List<RecognitionEmbedding> recognitions = [];

  late FaceDetector detector;

  late Recognizer recognizer;

  bool isBusy = false;

  @override
  void initState() {
    super.initState();
    detector = FaceDetector(
        options: FaceDetectorOptions(performanceMode: FaceDetectorMode.fast));
    recognizer = Recognizer();
    _initializeCamera();
  }

  void _initializeCamera() async {
    _availableCameras = await availableCameras();
    _controller = CameraController(
      description,
      ResolutionPreset.high,
    );
    // size = _controller!.value.previewSize!;
    await _controller!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      _controller!.startImageStream((CameraImage image) {
        if (!isBusy) {
          isBusy = true;
          frame = frame;
          doFaceDetectionOnFrame();
        }
      });
      setState(() {});
    });
  }

  dynamic _scanResults;
  CameraImage? frame;

  InputImage getInputImage() {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in frame!.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();
    final Size imageSize =
        Size(frame!.width.toDouble(), frame!.height.toDouble());
    final camera = description;

    final imageRotation =
        InputImageRotationValue.fromRawValue(camera.sensorOrientation);

    final inputImageFormat =
        InputImageFormatValue.fromRawValue(frame!.format.raw);

    final int bytesPerRow =
        frame?.planes.isNotEmpty == true ? frame!.planes.first.bytesPerRow : 0;

    final inputImageMetaData = InputImageMetadata(
      size: imageSize,
      rotation: imageRotation!,
      format: inputImageFormat!,
      bytesPerRow: bytesPerRow,
    );

    final inputImage = InputImage.fromBytes(
      bytes: bytes,
      metadata: inputImageMetaData,
    );
    return inputImage;
  }

  img.Image convertYUV420ToImage(CameraImage cameraImage) {
    final width = cameraImage.width;
    final height = cameraImage.height;

    final yRowStride = cameraImage.planes[0].bytesPerRow;
    final uvRowStride = cameraImage.planes[1].bytesPerRow;
    final uvPixelStride = cameraImage.planes[1].bytesPerPixel!;

    final image = img.Image(width: width, height: height);

    for (var w = 0; w < width; w++) {
      for (var h = 0; h < height; h++) {
        final uvIndex =
            uvPixelStride * (w / 2).floor() + uvRowStride * (h / 2).floor();
        final index = h * width + w;
        final yIndex = h * yRowStride + w;

        final y = cameraImage.planes[0].bytes[yIndex];
        final u = cameraImage.planes[1].bytes[uvIndex];
        final v = cameraImage.planes[2].bytes[uvIndex];

        image.data!.setPixelR(w, h, yuv2rgb(y, u, v)); //= yuv2rgb(y, u, v);
      }
    }
    return image;
  }

  int yuv2rgb(int y, int u, int v) {
    //convert yuv pixel to rgb
    var r = (y + v * 1436 / 1024 - 179).round();
    var g = (y - u * 46549 / 131072 + 44 - v * 93604 / 131072 + 91).round();
    var b = (y + u * 1814 / 1024 - 227).round();

    //Clipping RGB values to be inside bounderies [0, 255]
    r = r.clamp(0, 255);
    g = g.clamp(0, 255);
    b = b.clamp(0, 255);

    return 0xff000000 |
        ((b << 16) & 0xff0000) |
        ((g << 8) & 0xff00) |
        (r & 0xff);
  }

  doFaceDetectionOnFrame() async {
    InputImage inputImage = getInputImage();

    List<Face> faces = await detector.processImage(inputImage);

    performFaceRecognition(faces);
  }

  img.Image? image;

  performFaceRecognition(List<Face> faces) async {
    recognitions.clear();

    //convert CameraImage to Image and rotate it so that our frame
    image = convertYUV420ToImage(frame!);
    image = img.copyRotate(image!,
        angle: camDirec == CameraLensDirection.front ? 270 : 90);

    for (Face face in faces) {
      Rect faceRect = face.boundingBox;
      //Crop face
      img.Image croppedFace = img.copyCrop(
        image!,
        x: faceRect.left.toInt(),
        y: faceRect.top.toInt(),
        width: faceRect.width.toInt(),
        height: faceRect.height.toInt(),
      );

      //Pass cropped face to face recognition model
      RecognitionEmbedding recognition =
          recognizer.recognize(croppedFace, face.boundingBox);

      recognitions.add(recognition);

      //Show face recognition dialogue
      if (register) {
        showFaceRegistrationDialogue(
          croppedFace,
          recognition,
        );
        register = false;
      }
    }

    setState(() {
      isBusy = false;
      _scanResults = recognitions;
    });
  }

  void showFaceRegistrationDialogue(
      img.Image croppedFace, RecognitionEmbedding recognition) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Face Recognition',
          textAlign: TextAlign.center,
        ),
        alignment: Alignment.center,
        content: SizedBox(
          height: MediaQuery.of(context).size.height / 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Image.memory(
                Uint8List.fromList(img.encodeBmp(croppedFace)),
                width: 200,
                height: 200,
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: BlocConsumer<LoginBloc, LoginState>(
                  builder: (context, state) {
                    if (state is LoginLoading) {
                      return const CircleLoading();
                    }
                    return Button.filled(onPressed: () {}, label: 'Register');
                  },
                  listener: (context, state) {
                    if (state is LoginFailure) {}
                    if (state is LoginLoaded) {}
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _reverseCamera() async {
    if (camDirec == CameraLensDirection.back) {
      camDirec = CameraLensDirection.front;
      description = _availableCameras![1];
    } else {
      camDirec = CameraLensDirection.back;
      description = _availableCameras![0];
    }
    // await _controller!.stopImageStream();
    // setState(() {
    //   _controller;
    // });
    _initializeCamera();
  }

  void _takePicture() async {
    await _controller!.takePicture();
    if (mounted) {
      setState(() {
        register = true;
      });
    }
  }

  Widget buildResult() {
    if (_scanResults == null || !_controller!.value.isInitialized) {
      return const Center(
        child: Text('Camera is not initialized'),
      );
    }
    final Size imageSize = Size(
      _controller!.value.previewSize!.height,
      _controller!.value.previewSize!.width,
    );
    CustomPainter painter =
        FaceDetectorPainter(imageSize, _scanResults, camDirec);
    return CustomPaint(
      painter: painter,
    );
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    if (_controller == null) {
      return const Scaffold(
        body: CircleLoading(),
      );
    }
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              width: size.width,
              height: size.height,
              child: AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: CameraPreview(_controller!),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              width: size.width,
              height: size.height,
              child: buildResult(),
            ),
            Positioned(
              bottom: 5,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: _reverseCamera,
                          icon: Assets.icons.reverse.svg(width: 48),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: _takePicture,
                          icon: const Icon(
                            Icons.circle,
                            size: 70,
                          ),
                          color: AppColors.red,
                        ),
                        const Spacer(),
                        const SpaceWidth(48),
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
