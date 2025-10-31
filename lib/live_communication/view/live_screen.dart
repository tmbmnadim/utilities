import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import 'package:utilities/live_communication/controllers/live_controller.dart';

class LiveStreamScreen extends StatefulWidget {
  final bool isNewCall;
  const LiveStreamScreen({super.key, this.isNewCall = true});

  @override
  State<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen> {
  final liveCtrl = Get.find<LiveController>();

  @override
  void initState() {
    super.initState();
    if (widget.isNewCall) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        liveCtrl.callUser(onSuccess: () {});
      });
    }
  }

  @override
  void dispose() {
    liveCtrl.disconnectMeeting();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Stream')),
      body: GetBuilder<LiveController>(
        builder: (a) {
          final remoteRenderers = liveCtrl.state.remoteRenderers;
          return Column(
            children: [
              if (liveCtrl.state.localRenderer != null)
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("You"),
                      Expanded(
                        child: Container(
                          color: Colors.black45,
                          child: RTCVideoView(
                            liveCtrl.state.localRenderer!,
                            mirror: true,
                            objectFit: RTCVideoViewObjectFit
                                .RTCVideoViewObjectFitCover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                flex: 3,
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
