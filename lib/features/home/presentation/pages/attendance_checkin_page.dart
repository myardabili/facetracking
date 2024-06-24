import 'package:camera/camera.dart';
import 'package:facetracking/core/assets/assets.gen.dart';
import 'package:facetracking/core/components/cicle_loading.dart';
import 'package:facetracking/core/components/components.dart';
import 'package:facetracking/core/constants/colors.dart';
import 'package:facetracking/core/extensions/build_context_ext.dart';
import 'package:facetracking/features/home/presentation/bloc/checkin/checkin_bloc.dart';
import 'package:facetracking/features/home/presentation/pages/attendance_success_page.dart';
// import 'package:facetracking/features/home/presentation/pages/location_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:location/location.dart';

import '../../../../core/ml/recognition_embedding.dart';
import '../../../../core/ml/recognizer.dart';
import '../widgets/face_detector_painter.dart';

class AttendanceCheckinPage extends StatefulWidget {
  const AttendanceCheckinPage({super.key});

  @override
  State<AttendanceCheckinPage> createState() => _AttendanceCheckinPageState();
}

class _AttendanceCheckinPageState extends State<AttendanceCheckinPage> {
  List<CameraDescription>? _availableCameras;
  late CameraDescription description = _availableCameras![1];
  CameraController? _controller;

  CameraLensDirection camDirec = CameraLensDirection.front;

  bool isFaceRegistered = false;

  String faceStatusMessage = '';

  late Size size;

  late List<RecognitionEmbedding> recognitions = [];

  late FaceDetector detector;

  late Recognizer recognizer;

  bool isBusy = false;

  double? latitude;
  double? longitude;

  @override
  void initState() {
    super.initState();

    //initialize face detector
    detector = FaceDetector(
        options: FaceDetectorOptions(performanceMode: FaceDetectorMode.fast));

    //initialize face recognizer
    recognizer = Recognizer();

    _initializeCamera();

    getCurrentPosition();
  }

  void _initializeCamera() async {
    _availableCameras = await availableCameras();
    _controller = CameraController(
      description,
      ResolutionPreset.high,
    );

    await _controller!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      size = _controller!.value.previewSize!;

      _controller!.startImageStream((CameraImage image) {
        if (!isBusy) {
          isBusy = true;
          frame = image;
          doFaceDetectionOnFrame();
        }
      });
    });
  }

  dynamic _scanResults;
  CameraImage? frame;

  doFaceDetectionOnFrame() async {
    InputImage inputImage = getInputImage();

    List<Face> faces = await detector.processImage(inputImage);

    for (Face face in faces) {
      print('Face Location ${face.boundingBox}');
    }

    performFaceRecognition(faces);
  }

  img.Image? image;
  performFaceRecognition(List<Face> faces) async {
    recognitions.clear();

    //convert CameraImage to Image and rotate it so that our frame will be in a portrait
    image = convertYUV420ToImage(frame!);
    image = img.copyRotate(image!,
        angle: camDirec == CameraLensDirection.front ? 270 : 90);

    for (Face face in faces) {
      Rect faceRect = face.boundingBox;
      //crop face
      img.Image croppedFace = img.copyCrop(image!,
          x: faceRect.left.toInt(),
          y: faceRect.top.toInt(),
          width: faceRect.width.toInt(),
          height: faceRect.height.toInt());

      //pass cropped face to face recognition model
      RecognitionEmbedding recognition =
          recognizer.recognize(croppedFace, face.boundingBox);

      recognitions.add(recognition);

      //face validation
      bool isValid = await recognizer.isValidFace(recognition.embedding);

      if (isValid) {
        setState(() {
          isFaceRegistered = true;
          faceStatusMessage = 'Wajah sudah terdaftar';
        });
      } else {
        isFaceRegistered = false;
        faceStatusMessage = 'Wajah belum terdaftar';
      }
    }

    setState(() {
      isBusy = false;
      _scanResults = recognitions;
    });
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
    // Convert yuv pixel to rgb
    var r = (y + v * 1436 / 1024 - 179).round();
    var g = (y - u * 46549 / 131072 + 44 - v * 93604 / 131072 + 91).round();
    var b = (y + u * 1814 / 1024 - 227).round();

    // Clipping RGB values to be inside boundaries [ 0 , 255 ]
    r = r.clamp(0, 255);
    g = g.clamp(0, 255);
    b = b.clamp(0, 255);

    return 0xff000000 |
        ((b << 16) & 0xff0000) |
        ((g << 8) & 0xff00) |
        (r & 0xff);
  }

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

    final inputImage =
        InputImage.fromBytes(bytes: bytes, metadata: inputImageMetaData);

    return inputImage;
  }

  void _takeAttendance() async {
    if (mounted) {
      context.read<CheckinBloc>().add(OnCheckin(
          latitude: latitude.toString(), longitude: longitude.toString()));
    }
  }

  void _reverseCamera() async {
    if (camDirec == CameraLensDirection.back) {
      camDirec = CameraLensDirection.front;
      description = _availableCameras![1];
    } else {
      camDirec = CameraLensDirection.back;
      description = _availableCameras![0];
    }
    await _controller!.stopImageStream();
    setState(() {
      _controller;
    });
    // Inisialisasi kamera dengan deskripsi kamera baru
    _initializeCamera();
  }

  Widget buildResult() {
    if (_scanResults == null || !_controller!.value.isInitialized) {
      return const Center(child: Text('Camera is not initialized'));
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

  Future<void> getCurrentPosition() async {
    try {
      Location location = Location();

      bool serviceEnable;
      PermissionStatus permissionGranted;
      LocationData locationData;

      serviceEnable = await location.serviceEnabled();
      if (!serviceEnable) {
        serviceEnable = await location.requestService();
        if (!serviceEnable) {
          return;
        }
      }

      permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          return;
        }
      }

      locationData = await location.getLocation();
      latitude = locationData.latitude;
      longitude = locationData.longitude;

      setState(() {});
    } on PlatformException catch (e) {
      if (e.code == 'IO_ERROR') {
        debugPrint(
            'A network error occured trying to lookup the supplied coordinates: ${e.message}');
      } else {
        debugPrint('Failed to lookup coordinates: ${e.message}');
      }
    } catch (e) {
      debugPrint('An unknown error occured: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    if (_controller == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Positioned(
              top: 0.0,
              left: 0.0,
              width: size.width,
              height: size.height,
              child: AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: CameraPreview(_controller!),
              ),
            ),
            Positioned(
              top: 0.0,
              left: 0.0,
              width: size.width,
              height: size.height,
              child: buildResult(),
            ),
            Positioned(
              top: 20.0,
              left: 40.0,
              right: 40.0,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isFaceRegistered
                      ? AppColors.primary.withOpacity(0.47)
                      : AppColors.red.withOpacity(0.47),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  faceStatusMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.light,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 5.0,
              left: 0.0,
              right: 0.0,
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.47),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Absensi Daatang',
                                style: TextStyle(
                                  color: AppColors.light,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Kantor',
                                style: TextStyle(
                                  color: AppColors.light,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              // context.push(const LocationPage());
                            },
                            child: Assets.images.seeLocation.image(height: 30),
                          ),
                        ],
                      ),
                    ),
                    const SpaceHeight(30),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _reverseCamera,
                          icon: Assets.icons.reverse.svg(width: 48),
                        ),
                        const Spacer(),
                        BlocConsumer<CheckinBloc, CheckinState>(
                          builder: (context, state) {
                            if (state is CheckinLoading) {
                              return const CircleLoading();
                            }
                            return IconButton(
                              onPressed:
                                  isFaceRegistered ? _takeAttendance : null,
                              icon: const Icon(
                                Icons.circle,
                                size: 70,
                              ),
                              color: isFaceRegistered
                                  ? AppColors.red
                                  : AppColors.grey,
                            );
                          },
                          listener: (context, state) {
                            if (state is CheckinFailure) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(state.message)),
                              );
                            }
                            if (state is CheckinLoaded) {
                              context.pushReplacement(
                                const AttendanceSuccessPage(status: 'Checkin'),
                              );
                            }
                          },
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
