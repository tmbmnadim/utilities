import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:utilities/controllers/test_controller.dart';
import 'package:utilities/utils/controller_utils.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final testCtrl = Get.put(TestController());
    // final testState = testCtrl.state;
    return Scaffold(
      appBar: AppBar(title: Text("TESTING AND CREATING UTILS")),
      body: Obx(() {
        ControllerUtils.showGameStatus(testCtrl.status);
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: testCtrl.games.length,
                itemBuilder: (context, index) {
                  return Text(testCtrl.games[index].title ?? "N/A");
                },
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                ControllerUtils.showLoading = true;
                testCtrl.getGames();
              },
              child: Text("PRESS TO TEST"),
            ),
            SizedBox(height: 10)
          ],
        );
      }),
    );
  }
}
