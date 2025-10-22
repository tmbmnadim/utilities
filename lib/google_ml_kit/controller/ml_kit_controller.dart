import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
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
    _camController!.dispose();
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
      await _camController?.initialize();
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
          throw Exception("Not Implemented");
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

  Future<void> _scanBarcode() async {
    try {
      if (_captured == null) throw Exception("Image is not available");
      if (!File(_captured!).existsSync()) throw Exception("Image not found!");
      _results.clear();
      final scanner = BarcodeScanner();
      final inputImage = InputImage.fromFilePath(_captured!);
      final barcodes = await scanner.processImage(inputImage);
      scanner.close();
      for (var barcode in barcodes) {
        final value = barcode.rawValue;
        _results.add(value ?? "No Data");
      }
    } catch (e) {
      _handleError(e, "MLKitController<_scanBarcode>:");
    }
  }

  Future<void> _scanForText() async {
    try {
      if (_captured == null) throw Exception("Image is empty!");
      if (!File(_captured!).existsSync()) throw Exception("Image not found!");
      _results.clear();
      final scanner = TextRecognizer();
      final inputImage = InputImage.fromFilePath(_captured!);
      final result = await scanner.processImage(inputImage);
      await scanner.close();
      for (var block in result.blocks) {
        log(block.text);
        log(block.recognizedLanguages.toString());
        log(block.lines.toString());
      }
      _results.addAll(result.blocks.map((e) => e.text));
    } catch (e) {
      _handleError(e, "MLKitController<_scanForText>:");
    }
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
