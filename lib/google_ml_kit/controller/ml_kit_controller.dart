import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show WriteBuffer;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:utilities/utils/controller_utils.dart';

class MLKitController extends GetxController {
  MlKitOptions _option = MlKitOptions.barcodeScanning;
  CameraController? _camController;
  MlKitControllerStatus _status = MlKitControllerStatus.initial;
  String? _captured;
  final List<String> _results = [];
  String _error = "";

  MlKitOptions get option => _option;
  CameraController get cameraCtrl => _camController!;
  MlKitControllerStatus get status => _status;
  List<String> get scanResults => _results;
  String get errorMessage => _error;
  File get image => File(_captured!);

  @override
  void onInit() {
    super.onInit();
    initialize();
  }

  @override
  void onClose() {
    super.onClose();
    _camController?.dispose();
    _camController = null;
  }

  Future<void> initialize() async {
    try {
      if (_camController != null ||
          (_camController?.value.isInitialized ?? false)) {
        return;
      }
      _status = MlKitControllerStatus.loading;
      update();
      final available = await availableCameras();
      final imageFormatGroup = Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888;
      _camController = CameraController(
        available[0],
        ResolutionPreset.high,
        imageFormatGroup: imageFormatGroup,
      );
      if (_camController == null)
        throw Exception("Failed to initialize camera!");
      await _camController!.initialize();
      _status = MlKitControllerStatus.readyToTakePhoto;
      update();
    } catch (e) {
      _handleError(e, "MLKitController<initialize>:");
    }
  }

  Future<void> takePicture() async {
    try {
      if (_camController == null) await initialize();
      final picture = await _camController!.takePicture();
      _captured = picture.path;
      if (_captured == null) return;
      await _camController!.pausePreview();
      _status = MlKitControllerStatus.captured;
      update();
    } catch (e) {
      _handleError(e, "MLKitController<takePicture>:");
    }
  }

  Future<void> startImageScanning() async {
    try {
      if (_camController == null) await initialize();

      bool isBusy = false;

      await _camController!.startImageStream((CameraImage image) async {
        if (image.planes.isEmpty) {
          log("⚠️ CameraImage has no planes — skipping frame");
          return;
        }
        if (isBusy) return;
        isBusy = true;

        try {
          // Convert the camera image to InputImage for ML Kit
          final inputImage = _convertCameraImage(
            image,
            _camController!.description,
          );

          // Process the frame based on selected ML Kit option
          switch (_option) {
            case MlKitOptions.barcodeScanning:
              await _scanBarcode(inputImage);
              _status = MlKitControllerStatus.detected;
              update();
              break;

            case MlKitOptions.textRecognitionv2:
              await _scanForText(inputImage);
              _status = MlKitControllerStatus.detected;
              update();
              break;

            case MlKitOptions.faceDetection:
              await _scanForFace(inputImage);
              _status = MlKitControllerStatus.detected;
              update();
              break;

            default:
              log("Option not implemented for streaming.");
          }
          await Future.delayed(const Duration(milliseconds: 800));
        } catch (e) {
          _handleError(e, "MLKitController<startImageStreaming>:");
        } finally {
          isBusy = false;
        }
      });
      _status = MlKitControllerStatus.streaming;
      update();
    } catch (e) {
      _handleError(e, "MLKitController<startImageStreaming> outer:");
    }
  }

  Future<void> stopScanning() async {
    try {
      if (_camController == null) return;
      if (!_camController!.value.isStreamingImages) {
        _status = MlKitControllerStatus.readyToTakePhoto;
        update();
        return;
      }

      _camController!.stopImageStream();
      _status = MlKitControllerStatus.readyToTakePhoto;
      update();
    } catch (e) {
      _handleError(e, "MLKitController<stopScanning>:");
    }
  }

  Future<void> retakePicture() async {
    try {
      if (_camController == null) await initialize();
      await _camController!.resumePreview();
      _captured = null;
      _status = MlKitControllerStatus.readyToTakePhoto;
      update();
    } catch (e) {
      _handleError(e, "MLKitController<takePicture>:");
    }
  }

  Future<void> processImage() async {
    try {
      if (_captured == null) throw Exception("No image captured!");
      _status = MlKitControllerStatus.loading;
      update();
      await _camController!.dispose().timeout(
        Durations.medium3,
        onTimeout: () =>
            throw TimeoutException("Timeout: Camera Controller not closed!"),
      );
      _camController = null;
      switch (_option) {
        case MlKitOptions.barcodeScanning:
          await _scanBarcode();
        case MlKitOptions.textRecognitionv2:
          await _scanForText();
        case MlKitOptions.faceDetection:
          await _scanForFace();
        case MlKitOptions.faceMeshDetection:
          throw Exception("Not Implemented");
        case MlKitOptions.imageLabeling:
          throw Exception("Not Implemented");
      }
      _status = MlKitControllerStatus.processed;
      update();
    } catch (e) {
      _handleError(e, "MLKitController<takePicture>:");
    }
  }

  void changeOption(MlKitOptions? option) {
    if (option == null) return;
    _option = option;
    update();
  }

  Future<void> _scanBarcode([InputImage? input]) async {
    try {
      if (_captured == null && input == null) {
        throw Exception("Image is not available");
      }
      if (_captured != null && !File(_captured!).existsSync()) {
        throw Exception("Image not found!");
      }
      _results.clear();
      final scanner = BarcodeScanner();
      final inputImage = input ?? InputImage.fromFilePath(_captured!);
      final barcodes = await scanner.processImage(inputImage);
      scanner.close();
      for (var barcode in barcodes) {
        final value = barcode.rawValue;
        _results.add(value ?? "No Data");
      }
      _captured = null;
    } catch (e) {
      _handleError(e, "MLKitController<_scanBarcode>:");
    }
  }

  Future<void> _scanForText([InputImage? input]) async {
    try {
      if (_captured == null && input == null) {
        throw Exception("Image is not available");
      }
      if (_captured != null && !File(_captured!).existsSync()) {
        throw Exception("Image not found!");
      }
      _results.clear();
      final scanner = TextRecognizer();
      final inputImage = input ?? InputImage.fromFilePath(_captured!);
      final result = await scanner.processImage(inputImage);
      await scanner.close();
      _results.addAll(result.blocks.map((e) => e.text));
      _captured = null;
    } catch (e) {
      _handleError(e, "MLKitController<_scanForText>:");
    }
  }

  Future<void> _scanForFace([InputImage? input]) async {
    try {
      if (_captured == null && input == null) {
        throw Exception("Image is not available");
      }
      if (_captured != null && !File(_captured!).existsSync()) {
        throw Exception("Image not found!");
      }
      _results.clear();
      final scanner = FaceDetector(options: FaceDetectorOptions());
      final inputImage = input ?? InputImage.fromFilePath(_captured!);
      final result = await scanner.processImage(inputImage);
      await scanner.close();
      for (var res in result) {
        // double smiling = res.smilingProbability ?? 0;
        _results.add(
          res.contours.entries.first.value?.type.toString() ?? "NO CONTOUR",
        );
        // if (smiling > 0.7) {
        // } else if (smiling > 0.5) {
        //   _results.add("Looks like a smile");
        // } else if (smiling > 0.3) {
        //   _results.add("hmmm! you should smile");
        // } else {
        //   _results.add("A neutral face");
        // }
      }
      _captured = null;
    } catch (e) {
      _handleError(e, "MLKitController<_scanForText>:");
    }
  }

  Object _createScannerForOption(MlKitOptions option) {
    switch (option) {
      case MlKitOptions.barcodeScanning:
        return BarcodeScanner();
      case MlKitOptions.faceDetection:
        return FaceDetector(
          options: FaceDetectorOptions(
            enableContours: true,
            enableLandmarks: true,
          ),
        );
      case MlKitOptions.imageLabeling:
        return ImageLabeler(options: ImageLabelerOptions());
      default:
        throw UnimplementedError("MLKit option not implemented for stream");
    }
  }

  InputImage _convertCameraImage(
    CameraImage image,
    CameraDescription description,
  ) {
    final rotation =
        InputImageRotationValue.fromRawValue(description.sensorOrientation) ??
        InputImageRotation.rotation0deg;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);

    // Check if format is supported
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) {
      throw UnsupportedError(
        'Unsupported image format: ${image.format.raw}. '
        'ML Kit supports nv21 (Android) and bgra8888 (iOS)',
      );
    }

    final metadata = InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotation,
      format: format,
      bytesPerRow: image.planes.first.bytesPerRow,
    );
    if (image.planes.length != 1)
      throw UnsupportedError('Only one image plane is supported!');
    final plane = image.planes.first;

    return InputImage.fromBytes(bytes: plane.bytes, metadata: metadata);
  }

  void _handleError(Object e, [String context = ""]) {
    final message = "$context: ${e.toString()}";
    _error = message;
    _status = MlKitControllerStatus.failure;
    log(message);
    update();
  }
}

enum MlKitOptions {
  barcodeScanning,
  textRecognitionv2,
  faceDetection,
  faceMeshDetection,
  imageLabeling;

  String toName() => name.toLowerCase();

  String toTitle() {
    switch (this) {
      case MlKitOptions.barcodeScanning:
        return "Barcode Scanning";
      case MlKitOptions.textRecognitionv2:
        return "Text Recognition v2";
      case MlKitOptions.faceDetection:
        return "Face Detection";
      case MlKitOptions.faceMeshDetection:
        return "Face Mesh Detection (Beta)";
      case MlKitOptions.imageLabeling:
        return "Image Labeling";
    }
  }
}
