import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart' show Colors, Material;
import 'package:flutter/widgets.dart' hide Route;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:widget_to_marker/widget_to_marker.dart';

class LocationController extends GetxController {
  bool _fetchingLocation = false;
  String _error = "";
  CameraPosition? _cameraPosition;
  Position? _userPosition;
  LatLng? _destination;
  GoogleMapController? _googleMapController;
  MapType _mapType = MapType.normal;
  BitmapDescriptor _pinMarkerIcon = BitmapDescriptor.defaultMarker;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polyLines = {};
  final MarkerId _userMarkerId = MarkerId("user");
  StreamSubscription? _locationStream;
  Timer? _debounce;
  double _zoom = 14.5;

  // ================================================== GETTERS
  // Map Controller
  GoogleMapController? get mapController => _googleMapController;
  // Current Latitude and Longitude
  LatLng get currentLatLang {
    return LatLng(_userPosition?.latitude ?? 0, _userPosition?.longitude ?? 0);
  }

  // markers
  Set<Marker> get markers {
    return _markers;
  }

  // Current Camera Position
  CameraPosition get cameraPosition {
    return _cameraPosition ??
        CameraPosition(target: currentLatLang, zoom: _zoom);
  }

  // Location Status Booleans
  bool get locationLoading => _fetchingLocation && _userPosition == null;
  bool get locationNotFound => _userPosition == null && !_fetchingLocation;
  bool get locationFetched => _userPosition != null;
  String get errorMessage => _error;

  // Map Type
  MapType get mapType => _mapType;

  // ================================================== SETTERS
  // Map Type
  set setMapType(MapType type) {
    _mapType = type;
    update();
  }

  // Destination
  set destination(LatLng pos) {
    _destination = pos;
    _setDestinationMarker();

    update();
  }

  // Zoom
  set zoom(double value) => _zoom = value;

  void setMapTypeNormal() => setMapType = MapType.normal;
  void setMapTypeSatellite() => setMapType = MapType.satellite;
  void setMapTypeHybrid() => setMapType = MapType.hybrid;
  void setMapTypeTerrain() => setMapType = MapType.terrain;
  void setMapTypeNone() => setMapType = MapType.none;

  Future<void> getCurrentLocation() async {
    try {
      if (!await _ensurePermissions()) return;

      _userPosition = await _fetchCurrentPosition();
      animateTo(currentLatLang);
      _userMarkerAtCurrentLatLang();
      _fetchingLocation = false;
      update();
    } catch (e) {
      _handleError(e, "LocationController<getCurrentLocation>:");
      _fetchingLocation = false;
    }
  }

  Future<void> startListeningToLiveLocation() async {
    try {
      if (!await _ensurePermissions()) return;
      if (_locationStream != null && _locationStream!.isPaused) {
        _locationStream!.resume();
        return;
      }
      _locationStream?.cancel();

      final stream = Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
        ),
      );
      _locationStream = stream.listen((pos) {
        log("POSITION UPDATED: ${pos.latitude}:${pos.longitude}");
        _updateUserMarkerAndCamera(pos);
        update();
      });
      update();
    } catch (e) {
      _handleError(e, "LocationController<startListeningToLiveLocation>:");
    }
  }

  Future<void> stopListeningToLiveLocation() async {
    try {
      if (_locationStream == null || _locationStream!.isPaused) return;
      _locationStream!.pause();
      update();
    } catch (e) {
      _handleError(e, "LocationController<stopListeningToLiveLocation>:");
    }
  }

  Future<void> startNavigation() async {
    try {
      _error = "";
      _polyLines.clear();
      // await _drawPolylinesbetweenPoints();
      if (_polyLines.isEmpty) return;
      await startListeningToLiveLocation();
    } catch (e) {
      _handleError(e, "LocationController<startNavigation>:");
    }
  }

  Future<void> setUserMarkerIcon(
    BuildContext context,
    String icon, {
    VoidCallback? onTap,
  }) async {
    try {
      if(!context.mounted) return;
      _pinMarkerIcon = await _processMarkerIcon(context, icon);
    } catch (e) {
      _handleError(e, "LocationController<setUserMarkerIcon>:");
    } finally {
      _userMarkerAtCurrentLatLang();
    }
    update();
  }

  Future<void> addWidgetMarker({
    required String id,
    required Widget widget,
    required LatLng position,
  }) async {
    try {
      _error = "";
      final wrapped = Material(
        color: Colors.transparent,
        child: RepaintBoundary(child: widget),
      );

      final bitmap = await wrapped.toBitmapDescriptor();
      final marker = Marker(
        markerId: MarkerId(id),
        icon: bitmap,
        position: position,
      );
      markers.removeWhere((e) => e.markerId.value == id);
      markers.add(marker);
      update();
    } catch (e) {
      _handleError(e, "LocationController<generateCustomMarker>:");
    }
  }

  Future<void> animateTo(LatLng pos) async {
    try {
      if (_googleMapController == null) return;
      _cameraPosition = CameraPosition(target: pos, zoom: _zoom);
      await _googleMapController!.animateCamera(
        CameraUpdate.newCameraPosition(_cameraPosition!),
      );
    } catch (e) {
      _handleError(e, "LocationController<animateTo>:");
    }
  }

  Future<void> onMapCreated(GoogleMapController controller) async {
    _googleMapController = controller;
  }

  void onCameraMove(CameraPosition pos) {
    // Cancel previous timer
    _debounce?.cancel();

    // Start new timer
    _debounce = Timer(const Duration(milliseconds: 500), () {
      // This runs only when user stops moving for 500ms

      _cameraPosition = pos;
      _zoom = pos.zoom;
    });
  }

  void disposeContents() {
    _googleMapController?.dispose();
    _googleMapController = null;
    _locationStream?.cancel();
    _locationStream = null;
    _debounce?.cancel();
    _debounce = null;
  }

  Future<void> _drawPolylinesbetweenPoints() async {
    try {
      final apiKey = dotenv.env['googleMapsApiKey'];
      if (apiKey == null || apiKey.isEmpty) throw Exception("Missing API key.");

      if (_userPosition == null || _destination == null) {
        throw Exception("Missing start or destination position.");
      }

      final polylinePoints = PolylinePoints(apiKey: apiKey);
      final request = RoutesApiRequest(
        origin: PointLatLng(_userPosition!.latitude, _userPosition!.longitude),
        destination: PointLatLng(
          _destination!.latitude,
          _destination!.longitude,
        ),
        travelMode: TravelMode.driving,
        routingPreference: RoutingPreference.trafficAware,
      );

      final response = await polylinePoints.getRouteBetweenCoordinatesV2(
        request: request,
      );

      if (!response.isSuccessful) {
        throw Exception(response.errorMessage ?? "Polyline request failed.");
      }

      final route = response.routes.first;
      final points = route.polylinePoints ?? [];

      _polyLines
        ..clear()
        ..add(
          Polyline(
            polylineId: const PolylineId('route'),
            points: points.map((p) => LatLng(p.latitude, p.longitude)).toList(),
            width: 5,
            color: const Color(0xFF2196F3),
          ),
        );

      update();
    } catch (e) {
      _error = e.toString();
      log("Polyline error: $e");
    }
  }

  Future<Position> _fetchCurrentPosition() async {
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  void _updateUserMarkerAndCamera(Position pos) {
    _userPosition = pos;
    _userMarkerAtCurrentLatLang();
    animateTo(currentLatLang);
  }

  void _handleError(Object e, [String context = ""]) {
    final message = "$context: ${e.toString()}";
    _error = message;
    log(message);
    update();
  }

  void _userMarkerAtCurrentLatLang() {
    _markers.removeWhere((marker) => marker.markerId.value == "user");
    _markers.add(
      Marker(
        markerId: _userMarkerId,
        position: currentLatLang,
        infoWindow: InfoWindow(title: "You are here"),
        onTap: () {},
      ),
    );
  }

  void _setDestinationMarker() {
    if (_destination == null) throw Exception("Destination is not set!");
    _markers.removeWhere((marker) => marker.markerId.value == "destination");
    _markers.add(
      Marker(
        markerId: MarkerId("destination"),
        position: _destination!,
        icon: _pinMarkerIcon,
        infoWindow: InfoWindow(title: "This is your destination"),
        onTap: () {},
      ),
    );
  }

  Future<bool> _ensurePermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _error = "Location services are disabled.";
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      _error = "Location permission denied.";
      return false;
    }

    return true;
  }

  Future<AssetMapBitmap> _processMarkerIcon(
    BuildContext context,
    String icon,
  ) async {
    final ImageConfiguration imageConfiguration = createLocalImageConfiguration(
      context,
    );

    return await AssetMapBitmap.create(
      imageConfiguration,
      icon,
      width: 32,
      height: 32,
    );
  }
}
