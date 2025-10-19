import 'dart:developer';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationController extends GetxController {
  bool _fetchingLocation = false;
  String _error = "";
  Position? _currentPosition;
  CameraPosition _cameraPosition = CameraPosition(target: LatLng(0, 0));
  GoogleMapController? _googleMapController;

  LatLng get currentLatLang =>
      LatLng(_currentPosition?.latitude ?? 0, _currentPosition?.longitude ?? 0);

  CameraPosition get cameraPosition => CameraPosition(target: currentLatLang, zoom: 14.5);

  bool get locationLoading => _fetchingLocation && _currentPosition == null;
  bool get locationNotFound => _currentPosition == null && !_fetchingLocation;
  bool get locationFetched => _currentPosition != null;
  String get errorMessage => _error;

  GoogleMapController? get mapController => _googleMapController;

  Future<void> getCurrentLocation() async {
    try {
      _fetchingLocation = true;
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.medium),
      );
      animateTo(currentLatLang);
      _fetchingLocation = false;
    } catch (e) {
      _error = e.toString();
      log(e.toString());
      _fetchingLocation = false;
    }
    update();
  }

  Future<void> animateTo(LatLng pos) async {
    try {
      if (_googleMapController == null || _currentPosition == null) return;
      await _googleMapController!.animateCamera(
        CameraUpdate.newCameraPosition(cameraPosition),
      );
    } catch (e) {
      _error = e.toString();
      log(e.toString());
    }
  }

  Future<void> onMapCreated(GoogleMapController controller) async {
    _googleMapController = controller;
  }
}
