import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:utilities/google_map/controllers/location_controller.dart';
import 'package:utilities/utils/custom_marker.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<LatLng> deploymentLocations = [
    LatLng(23.777299, 90.3957221),
    LatLng(23.781063, 90.3962251),
  ];
  List<List<LatLng>> pressureZones = [
    [
      LatLng(23.782658835861422, 90.40231908818114),
      LatLng(23.78182432341096, 90.40458287251417),
      LatLng(23.78091126247604, 90.40474380504968),
      LatLng(23.78119598108994, 90.40157879851775),
      LatLng(23.782658835861422, 90.40231908818114),
    ],
  ];
  final locationCtrl = Get.find<LocationController>();
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    locationCtrl.getCurrentLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      locationCtrl.setUserMarkerIcon(
        context,
        'assets/icons/png/push_pin.png',
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return BottomSheet(
                onClosing: () {},
                builder: (context) {
                  return Container(
                    color: Color(0xFFFFFFE4),
                    child: Text("THERE IS NOTHING TO SHOW HERE!"),
                  );
                },
              );
            },
          );
        },
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
    locationCtrl.disposeContents();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Generate Heatmap Circles
    final Set<Circle> heatmapCircles = deploymentLocations.map((loc) {
      return Circle(
        circleId: CircleId(loc.toString()),
        center: loc,
        radius: 300, // Radius in meters (adjust based on density needs)
        strokeWidth: 0,
        fillColor: Colors.orange.withOpacity(
          0.15,
        ), // Overlapping creates "Heat"
      );
    }).toSet();

    // 2. Generate Pressure Zone Polygons (Overcapacity Alerts)
    final Set<Polygon> alertZones = pressureZones.asMap().entries.map((entry) {
      return Polygon(
        polygonId: PolygonId("zone_${entry.key}"),
        points: entry.value,
        fillColor: Colors.redAccent.withOpacity(0.3),
        strokeColor: Colors.redAccent,
        strokeWidth: 2,
      );
    }).toSet();
    return Scaffold(
      appBar: AppBar(title: Text("Google Map")),
      backgroundColor: Color(0xFFFFFFE4),
      body: GetBuilder<LocationController>(
        builder: (ctrl) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: double.infinity),
              if (ctrl.locationFetched)
                Expanded(
                  child: GoogleMap(
                    initialCameraPosition: ctrl.cameraPosition,
                    onMapCreated: ctrl.onMapCreated,
                    mapType: ctrl.mapType,
                    markers: ctrl.markers,
                    tiltGesturesEnabled: false,
                    onCameraMove: ctrl.onCameraMove,
                    circles: heatmapCircles,
                    polygons: alertZones,
                    myLocationButtonEnabled: false,
                    mapToolbarEnabled: false,
                    onTap: (coord) {
                      ctrl.destination = coord;
                      _showBottomSheet(context, coord);
                    },
                  ),
                )
              else if (ctrl.locationLoading)
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 10,
                    children: [
                      CircularProgressIndicator.adaptive(),
                      Text(
                        "Fetching location...",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                )
              else if (ctrl.locationNotFound)
                Expanded(
                  child: Center(
                    child: Text(
                      "Location not fetched!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: Center(
                    child: Text(
                      "Location was not initialized!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    CustomMarkerWidget(icon: Icons.abc, title: "Nadim"),
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        "Live Location",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TextButton(
                          onPressed: ctrl.startListeningToLiveLocation,
                          child: Text("Start"),
                        ),
                        TextButton(
                          onPressed: ctrl.stopListeningToLiveLocation,
                          child: Text("Stop"),
                        ),
                      ],
                    ),
                    Divider(),
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        "Map Type",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TextButton(
                          onPressed: ctrl.setMapTypeNormal,
                          child: Text("Normal"),
                        ),
                        TextButton(
                          onPressed: ctrl.setMapTypeSatellite,
                          child: Text("Satellite"),
                        ),
                        TextButton(
                          onPressed: ctrl.setMapTypeTerrain,
                          child: Text("Terrain"),
                        ),
                        TextButton(
                          onPressed: ctrl.setMapTypeHybrid,
                          child: Text("Hybrid"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showBottomSheet(BuildContext context, LatLng coord) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            spacing: 10,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    final msngr = ScaffoldMessenger.of(context);
                    await locationCtrl.addWidgetMarker(
                      id: "0",
                      widget: CustomMarkerWidget(
                        icon: Icons.home,
                        title: "Mansur Nadim aaaaaaaaaaa",
                      ),
                      position: coord,
                    );
                    msngr.showSnackBar(
                      SnackBar(
                        content: Text(
                          locationCtrl.errorMessage.isNotEmpty
                              ? locationCtrl.errorMessage
                              : 'Destination set at: ${coord.latitude.toStringAsFixed(6)}, ${coord.longitude.toStringAsFixed(6)}',
                        ),
                      ),
                    );
                  },
                  child: const Text('Add Custom marker'),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          locationCtrl.errorMessage.isNotEmpty
                              ? locationCtrl.errorMessage
                              : 'Destination set at: ${coord.latitude.toStringAsFixed(6)}, ${coord.longitude.toStringAsFixed(6)}',
                        ),
                      ),
                    );
                    locationCtrl.startNavigation();
                  },
                  child: const Text('Navigate'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
