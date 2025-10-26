import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:utilities/google_ml_kit/controller/ml_kit_controller.dart';
import 'package:utilities/utils/controller_utils.dart';

class MLKitScreen extends StatefulWidget {
  const MLKitScreen({super.key});

  @override
  State<MLKitScreen> createState() => _MLKitScreenState();
}

class _MLKitScreenState extends State<MLKitScreen> {
  MLKitController ctrl = Get.put(MLKitController());
  @override
  void dispose() {
    super.dispose();
    ctrl.onClose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ML Kit Scanner")),
      body: GetBuilder<MLKitController>(
        builder: (mlkCtrl) {
          return Column(
            children: [
              Builder(
                builder: (context) {
                  switch (ctrl.status) {
                    case MlKitControllerStatus.initial:
                      return Expanded(
                        child: Center(child: Text("Camera not initialized!")),
                      );
                    case MlKitControllerStatus.loading:
                      return Expanded(
                        child: Center(child: CircularProgressIndicator()),
                      );
                    case MlKitControllerStatus.streaming:
                    case MlKitControllerStatus.readyToTakePhoto:
                      return Expanded(child: CameraPreview(ctrl.cameraCtrl));
                    case MlKitControllerStatus.detected:
                      EasyLoading.showSuccess(ctrl.scanResults.toString());
                      return Expanded(child: CameraPreview(ctrl.cameraCtrl));
                    case MlKitControllerStatus.captured:
                      return Expanded(
                        child: Image.file(ctrl.image, fit: BoxFit.cover),
                      );
                    case MlKitControllerStatus.failure:
                      return Expanded(
                        child: Center(child: Text(ctrl.errorMessage)),
                      );
                    case MlKitControllerStatus.processed:
                      return Expanded(
                        child: Builder(
                          builder: (context) {
                            if (ctrl.scanResults.isEmpty) {
                              return Center(child: Text("Result is empty"));
                            }
                            return ListView.builder(
                              itemCount: ctrl.scanResults.length,
                              itemBuilder: (context, index) {
                                return Text(ctrl.scanResults[index]);
                              },
                            );
                          },
                        ),
                      );
                  }
                },
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  spacing: 10,
                  children: [
                    SizedBox(width: 0),
                    if (ctrl.status == MlKitControllerStatus.readyToTakePhoto)
                      ElevatedButton(
                        onPressed: () => ctrl.startImageScanning(),
                        child: Text("Start Scanning"),
                      )
                    else if (ctrl.status == MlKitControllerStatus.streaming ||
                        ctrl.status == MlKitControllerStatus.detected ||
                        ctrl.status == MlKitControllerStatus.failure)
                      ElevatedButton(
                        onPressed: () => ctrl.stopScanning(),
                        child: Text("Stop Scanning"),
                      ),
                    if (ctrl.status == MlKitControllerStatus.readyToTakePhoto)
                      ElevatedButton(
                        onPressed: () => ctrl.takePicture(),
                        child: Text("Take Picture"),
                      )
                    else if (ctrl.status == MlKitControllerStatus.captured)
                      ElevatedButton(
                        onPressed: () => ctrl.retakePicture(),
                        child: Text("Retake"),
                      ),
                    if (ctrl.status == MlKitControllerStatus.captured)
                      ElevatedButton(
                        onPressed: () => ctrl.processImage(),
                        child: Text("Process Image"),
                      ),
                    if (ctrl.status == MlKitControllerStatus.processed)
                      ElevatedButton(
                        onPressed: () => ctrl.retakePicture(),
                        child: Text("Take another"),
                      ),
                    if (ctrl.status == MlKitControllerStatus.readyToTakePhoto ||
                        ctrl.status == MlKitControllerStatus.streaming ||
                        ctrl.status == MlKitControllerStatus.detected)
                      _dropDownMenu(context, mlkCtrl),
                    SizedBox(width: 0),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _dropDownMenu(BuildContext context, MLKitController mlkCtrl) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.symmetric(horizontal: 10),
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: DropdownButton<MlKitOptions>(
        value: mlkCtrl.option,
        underline: SizedBox(),
        style: TextStyle(color: Colors.white),
        iconEnabledColor: Colors.white,
        borderRadius: BorderRadius.circular(10),
        dropdownColor: Theme.of(context).colorScheme.primaryFixedDim,
        padding: EdgeInsets.zero,
        items: MlKitOptions.values.map((value) {
          return DropdownMenuItem(
            value: value,
            enabled: value.index < 3,
            child: Text(value.toTitle()),
            onTap: () => mlkCtrl.changeOption(value),
          );
        }).toList(),
        onChanged: (value) => mlkCtrl.changeOption(value),
      ),
    );
  }
}
