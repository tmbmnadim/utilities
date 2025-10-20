import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:utilities/controllers/location_controller.dart';
import 'package:utilities/utils/custom_marker.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final locationCtrl = Get.find<LocationController>();
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
    super.dispose();
    locationCtrl.disposeContents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  child: Text(
                    "Couldn't get location!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.redAccent,
                    ),
                  ),
                )
              else
                Expanded(
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
