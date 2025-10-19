import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utilities/controllers/test_controller.dart';
import 'package:utilities/utils/controller_utils.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    final testCtrl = Get.put(TestController());
    return Scaffold(
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
            SizedBox(height: 10),
          ],
        );
      }),
    );
  }
}
