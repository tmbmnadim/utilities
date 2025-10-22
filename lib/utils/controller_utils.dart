import 'package:flutter_easyloading/flutter_easyloading.dart';

enum ControllerStatus { initial, loading, success, updated, created, failure }

enum MlKitControllerStatus { initial, loading, readyToTakePhoto, captured, streaming, detected, processed, failure }

class ControllerUtils {
  static bool showLoading = false;
  static void showGameStatus(ControllerStatus status) {
    if (!showLoading) return;
    switch (status) {
      case ControllerStatus.initial:
        EasyLoading.show();
      case ControllerStatus.loading:
        EasyLoading.show();
      case ControllerStatus.success:
        showLoading = false;
        EasyLoading.showSuccess("Got your games...");
      case ControllerStatus.updated:
        showLoading = false;
        EasyLoading.showSuccess("Game was updated!");
      case ControllerStatus.created:
        showLoading = false;
        EasyLoading.showSuccess("Created! Hope everyone likes it!");
      case ControllerStatus.failure:
        showLoading = false;
        EasyLoading.showSuccess("Got some amazing games...");
    }
  }
}
