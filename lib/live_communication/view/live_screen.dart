import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import 'package:utilities/live_communication/controllers/live_controller.dart';

class LiveStreamScreen extends StatefulWidget {
  const LiveStreamScreen({super.key});

  @override
  State<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen> {
  final liveCtrl = Get.find<LiveController>();
  List<RTCVideoPlatformViewController> _platformViewControllers = [];
  @override
  Widget build(BuildContext context) {
    final remoteRenderers = liveCtrl.state.remoteRenderers;
    return Scaffold(
      appBar: AppBar(title: Text('Video Call')),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              itemCount: remoteRenderers.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemBuilder: (context, index) {
                final user = remoteRenderers.keys.toList()[index];
                final stream = remoteRenderers.values.toList()[index].srcObject;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(user),
                    RTCVideoPlatFormView(
                      onViewReady: (controller) {
                        _platformViewControllers.add(controller);
                        _platformViewControllers[index].setSrcObject(
                          stream: stream,
                        );
                        _platformViewControllers[index]
                            .initialize()
                            .whenComplete(() {
                              setState(() {});
                            });
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
