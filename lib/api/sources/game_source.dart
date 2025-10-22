import 'dart:developer';

import 'package:utilities/utils/api_manager.dart';

import '../models/game_model.dart';

class TestSource {
  TestSource();
  final _api = ApiManager(baseUrl: "https://gamerpower.com");

  Future<List<GameModel>> getGames() async {
    try {
      List<dynamic> data = await _api.get(path: "/api/giveaways");

      final output = data.map((item) {
        if (item is Map<String, dynamic>) {
          return GameModel.fromJson(item);
        } else {
          log(item.toString());
        }
      });
      return List<GameModel>.from(output);
    } catch (e, s) {
      log("TestSource<getCatFacts>: $e\n$s");
      rethrow;
    }
  }
}
