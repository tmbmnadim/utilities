import 'dart:developer';

import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionController extends GetxController {
  PermissionController() {
    _initialize();
  }
  late PermissionStatus _location;
  late PermissionStatus _camera;
  String _errorMessage = "Nothing to report!";

  PermissionStatus get location => _location;
  PermissionStatus get camera => _camera;
  String get errorMessage => _errorMessage;

  Future<void> _initialize() async {
    _location = await Permission.locationWhenInUse.status;
    _camera = await Permission.camera.status;
  }

  Future<void> getLocationPermissions() async {
    try {
      _location = await _checkAndRequest(Permission.locationWhenInUse);
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> getCameraPermissions() async {
    try {
      _camera = await _checkAndRequest(Permission.camera);
    } catch (e) {
      log(e.toString());
    }
  }

  Future<PermissionStatus> _checkAndRequest(Permission service) async {
    final status = await service.status;
    if (!status.isGranted) {
      await service.request();
    } else if (!status.isPermanentlyDenied) {
      _errorMessage = "${service.toString()} permission is permanently denied";
    }
    return await service.status;
  }
}
