import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:utilities/controllers/location_controller.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color(0xFFFFFFE4),
      body: GetBuilder<LocationController>(
        builder: (ctrl) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: double.infinity),
              if (ctrl.locationLoading)
                Column(
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
                )
              else if (ctrl.locationNotFound)
                Text(
                  "Couldn't get location!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.redAccent,
                  ),
                )
              else if (ctrl.locationFetched)
                Expanded(
                  child: GoogleMap(
                    initialCameraPosition: ctrl.cameraPosition,
                    onMapCreated: ctrl.onMapCreated,
                  ),
                )
              else
                Text(
                  "Location was not initialized!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.redAccent,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
