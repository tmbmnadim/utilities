import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
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
        ResolutionPreset.medium,
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
      log("CAMERA CLOSED");
      log("SCANNING BARCODE");
      switch (_option) {
        case MlKitOptions.barcodeScanning:
          await _scanForText();
        case MlKitOptions.textRecognitionv2:
          await _scanForText();
        case MlKitOptions.faceDetection:
          throw Exception("Not Implemented");
        case MlKitOptions.faceMeshDetection:
          throw Exception("Not Implemented");
        case MlKitOptions.imageLabeling:
          throw Exception("Not Implemented");
      }
      await _scanBarcode();
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
      _results.clear();
      final scanner = BarcodeScanner();
      final inputImage = InputImage.fromFilePath(_captured!);
      final barcodes = await scanner.processImage(inputImage);
      scanner.close();
      for (var barcode in barcodes) {
        final value = barcode.value;
        _results.add(value.toString());
      }
    } catch (e) {
      _handleError(e, "MLKitController<_scanBarcode>:");
    }
  }

  Future<void> _scanForText() async {
    try {
      _results.clear();
      final scanner = TextRecognizer();
      final inputImage = InputImage.fromFilePath(_captured!);
      final result = await scanner.processImage(inputImage);
      scanner.close();

      _results.add(result.text);
    } catch (e) {
      _handleError(e, "MLKitController<_scanBarcode>:");
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
      case MlKitOptions.faceDetection:
        return "Face Detection";
      case MlKitOptions.faceMeshDetection:
        return "Face Mesh Detection (Beta)";
      case MlKitOptions.imageLabeling:
        return "Image Labeling";
      case MlKitOptions.textRecognitionv2:
        return "Text Recognition v2";
    }
  }
}
