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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Stream')),
      body: GetBuilder<LiveController>(
        builder: (liveCtrl) {
          final remoteRenderers = liveCtrl.state.remoteRenderers;
          return Column(
            children: [
              Text("THIS USER: ${liveCtrl.state.user!.id}"),
              Expanded(
                child: GridView.builder(
                  itemCount: remoteRenderers.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: remoteRenderers.length == 1 ? 1 : 2,
                  ),
                  itemBuilder: (context, index) {
                    final user = remoteRenderers.keys.toList()[index];
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(user),
                        Expanded(
                          child: Container(
                            color: Colors.black45,
                            child: RTCVideoView(
                              remoteRenderers.values.toList()[index],
                              objectFit: RTCVideoViewObjectFit
                                  .RTCVideoViewObjectFitCover,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
